local ctlStateEnum = require('controller_state')
local Keyframe = require('keyframe')
local Keybind = require('keybind')

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
            Keybind.exec('+'..key)
        elseif love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl') then
            Keybind.exec('^'..key)
        else -- Not pressing control
            Keybind.exec(key)
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