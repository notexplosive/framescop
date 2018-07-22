local ctlStateEnum = require('controller_state')
local Keyframe = require('keyframe')

--- KEYBOARD BEHAVIOR ---
love.keyboard.setKeyRepeat(true)
function love.textinput( text )
    -- omit newline
    if text == '\n' then
        return
    end

    if CURRENT_TEXT_BOX.on then
        CURRENT_TEXT_BOX.body = CURRENT_TEXT_BOX.body .. text
    end
end

function love.keypressed(key, scancode, isrepeat)
    cursorTimer = 0
    if CURRENT_TEXT_BOX.on then
        if key == 'return' then
            CURRENT_TEXT_BOX.submit()
        end

        if key == 'backspace' then
            CURRENT_TEXT_BOX.body = CURRENT_TEXT_BOX.body:sub(1,#CURRENT_TEXT_BOX.body-1)
        end


        -- Hotkeys shouldn't work if we have a text box selected, so we terminate early
        return
    end

    if currentFilm then
        currentFilm.idleTimer = 0

        if key == 'return' then
            currentFilm.playRealTime = not currentFilm.playRealTime
            if currentFilm.playRealTime then
                printst('Play')
            else
                printst('Paused')
            end
        end

        if key == 'space' then
            Keyframe.new(currentFilm,currentFilm.playhead,0)
        end

        if key == 'delete' then
            if Keyframe.list[currentFilm.playhead] then
                printst('keyframe deleted')
                Keyframe.list[currentFilm.playhead] = nil
            end
        end

        if love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') then
            -- Jump right
            if key == 'right' then
                local frames = Keyframe.getAll(currentFilm)
                for i=1,#frames do
                    if frames[i].time > currentFilm.playhead then
                        currentFilm:movePlayheadTo(frames[i].time)
                        break
                    end
                end
            end

            -- Jump left
            if key == 'left' then
                local frames = Keyframe.getAll(currentFilm)
                for i=#frames,i,-1 do
                    if frames[i].time < currentFilm.playhead then
                        currentFilm:movePlayheadTo(frames[i].time)
                        break
                    end
                end
            end
        elseif love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl') then
            if key == 's' then
                FileMgr.save()
            end

            -- Toggle inputs on keyframe
            if key == 'up' then
                Keyframe.getCurrentKeyframe(currentFilm,true):flipState(ctlStateEnum.up)
            end

            if key == 'down' then
                Keyframe.getCurrentKeyframe(currentFilm,true):flipState(ctlStateEnum.down)
            end

            if key == 'left' then
                Keyframe.getCurrentKeyframe(currentFilm,true):flipState(ctlStateEnum.left)
            end

            if key == 'right' then
                Keyframe.getCurrentKeyframe(currentFilm,true):flipState(ctlStateEnum.right)
            end
        else -- Not pressing control
            -- Step Right
            if key == 'right' then
                currentFilm:movePlayheadTo(currentFilm.playhead + 1)
            end

            -- Step Left
            if key == 'left' then
                currentFilm:movePlayheadTo(currentFilm.playhead - 1)
            end
        end

        local newState = Keyframe.getStateAtTime(currentFilm.playhead)
        local oldState = bit.bor(Keyframe.getStateAtTime(currentFilm.playhead-1),ctlStateEnum.isKeyFrame)
        -- Checks for redundant keyframes
        if newState == oldState then
            Keyframe.list[currentFilm.playhead] = nil
            printst('Deleted Keyframe')
        end
    end
end

--- MOUSE BEHAVIOR ---
function love.mousereleased(x,y,button,isTouch)
    -- Playhead release
    if button == 1 and currentFilm then
        if currentFilm.timeline.isPressed then
            currentFilm.timeline:onRelease(x)
        end
    end
end

function love.mousemoved(x,y,dx,dy,isTouch)
    if currentFilm then
        currentFilm.idleTimer = 0
    end
end

function love.mousepressed(x,y,button,isTouch)
    -- Playhead capture
    if button == 1 and currentFilm then
        if currentFilm.timeline:isHover() then
            currentFilm.timeline.isPressed = true
        else
            if currentFilm.timeline:isFullHover() then
                currentFilm.timeline:onRelease(x)
            end
        end
    end
end