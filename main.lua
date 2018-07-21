FILE_NAME = 'empty'
APP_NAME = 'Framescop V1.0'

require('global')
require('status')
local ctlStateEnum = require('controller_state')
local Film = require('film')
local Timeline = require('timeline')
local Keyframe = require('keyframe')

local LOVEdefaultFont = love.graphics:getFont()
local BigFont = love.graphics.newFont(24)

currentFilm = nil
timeline = nil

function updateWindowTitle()
    love.window.setTitle(APP_NAME .. ' by NotExplosive - ' .. FILE_NAME)
end
love.window.updateMode(800,600,{resizable=true})

function love.load(arg)
    currentFilm = Film.new('binaries/petscop8')
    timeline = Timeline.new(currentFilm)
end

function love.update(dt)
    if currentFilm then
        currentFilm:update(dt)
        timeline:update(dt)
    end

    if love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl') then
        Keyframe.editMode = true
    else
        Keyframe.editMode = false
    end

    updateStatusText(dt)
end

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
    end

    local newState = Keyframe.getStateAtTime(currentFilm.playhead)
    local oldState = bit.bor(Keyframe.getStateAtTime(currentFilm.playhead-1),ctlStateEnum.isKeyFrame)
    -- Checks for redundant keyframes
    if newState == oldState then
        Keyframe.list[currentFilm.playhead] = nil
        printst('Deleted Keyframe')
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

function love.mousereleased(x,y,button,isTouch)
    -- Playhead release
    if button == 1 and timeline then
        if timeline.isPressed then
            timeline:onRelease(x)
        end
    end
end

function love.draw()
    love.graphics.setFont(LOVEdefaultFont)

    if currentFilm then
        currentFilm:draw()
        love.graphics.print(currentFilm:status(),4,love.graphics.getHeight()-48,0)
        timeline:draw()
        
        Keyframe.drawUI(currentFilm)
    end


    -- Keyframe timeline pane
    love.graphics.print('img:'..currentFilm.playhead,128,love.graphics.getHeight() - 128 - love.graphics.getFont():getHeight() - 2)
    love.graphics.setFont(BigFont)
    love.graphics.print(currentFilm:timeString(),10,love.graphics.getHeight() - 128 - love.graphics.getFont():getHeight())
    for i=-9,10 do
        love.graphics.rectangle('line',10*i + 100,love.graphics.getHeight() - 128,10,10)

        -- default colors
        love.graphics.setColor(1,.25,0)
        if (currentFilm.playhead + i) % 4 == 0 then
            love.graphics.setColor(.6,.2,0)
        end

        if Keyframe.list[currentFilm.playhead+i] then
            love.graphics.setColor(0,1,0)
        end

        if i == 0 then
            love.graphics.setColor(1,1,1)
            if Keyframe.list[currentFilm.playhead+i] then
                love.graphics.setColor(0,0,1)
            end
        end

        if currentFilm.playhead + i < 1 then
            love.graphics.setColor(0,0,0)
        end

        love.graphics.rectangle('fill',10*i + 100,love.graphics.getHeight() - 128,10,10)
        love.graphics.setColor(1,1,1)
    end

    love.graphics.setFont(BigFont)
    love.graphics.print(StatusText)
end