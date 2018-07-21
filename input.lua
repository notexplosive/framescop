local ctlStateEnum = require('controller_state')
local Keyframe = require('keyframe')

--- KEYBOARD BEHAVIOR ---
love.keyboard.setKeyRepeat(true)
function love.keypressed(key, scancode, isrepeat)
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

        if love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl') then
            if key == 's' then
                print(Keyframe.serializeList(currentFilm))
            end

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

            if key == 'right' then
                currentFilm:movePlayheadTo(currentFilm.playhead + 1)
            end

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
    if button == 1 and timeline then
        if timeline.isPressed then
            timeline:onRelease(x)
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
    if button == 1 and timeline then
        if timeline:isHover() then
            timeline.isPressed = true
        else
            if timeline:isFullHover() then
                timeline:onRelease(x)
            end
        end
    end
end