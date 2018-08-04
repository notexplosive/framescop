local ctlStateEnum = require('controller_state')
local Keyframe = require('keyframe')
local Keybind = require('keybind')
local Actions = require('actions')

--- KEYBOARD BEHAVIOR ---
function altDown()
    return love.keyboard.isDown('lalt') or love.keyboard.isDown('ralt')
end

function ctrlDown()
    return love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')
end

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

        if love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') then
            Keybind.exec('+'..key)
        elseif love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl') then
            Keybind.exec('^'..key)
        elseif love.keyboard.isDown('lalt') or love.keyboard.isDown('ralt') then
            Keybind.exec('@'..key)
        else -- no modifier keys
            Keybind.exec(key)
        end

        local newState = Keyframe.getStateAtTime(currentFilm.playhead)
        local oldState = bit.bor(Keyframe.getStateAtTime(currentFilm.playhead-1),ctlStateEnum.isKeyFrame)
        -- Checks for redundant keyframes
        if newState == oldState then
            Keyframe.list[currentFilm.playhead] = nil
            printst('Redundant Keyframe.')
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
        
    end
end

function love.mousepressed(x,y,button,isTouch)
    if button == 1 and CURRENT_MOUSEOVER_TARGET ~= '' then
        print(CURRENT_MOUSEOVER_TARGET)
        Keybind.exec('mouseClick'..CURRENT_MOUSEOVER_TARGET)
    end

    -- Playhead capture
    -- this should be replaced with the new mouse input framework
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


--[[ If we did a mouse-only mode, it would look something like this:1234567890
function love.wheelmoved(x,y)
    if y > 0 then
        Actions.stepLeft()
    end

    if y < 0 then
        Actions.stepRight()
    end
end
]]