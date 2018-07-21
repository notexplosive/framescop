FILE_NAME = 'empty'
APP_NAME = 'Framescop V1.0'

require('global')
require('status')
require('loadfile')
require('input')
local ctlStateEnum = require('controller_state')
local Film = require('film')
local Timeline = require('timeline')
local Keyframe = require('keyframe')

local LOVEdefaultFont = love.graphics:getFont()
local BigFont = love.graphics.newFont(24)

currentFilm = nil
timeline = nil

function updateWindowTitle()
    local title = APP_NAME .. ' by NotExplosive'
    love.window.setTitle(title .. ' - ' .. FILE_NAME)
end
updateWindowTitle()
love.window.updateMode(800,600,{resizable=true})

function love.load(arg)
    --currentFilm = Film.new('binaries/petscop8')
    --timeline = Timeline.new(currentFilm)
end

function love.update(dt)
    if currentFilm then
        currentFilm:update(dt)
        timeline:update(dt)
    end
    
    Keyframe.editMode = love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')

    updateStatusText(dt)
end

function love.draw()
    love.graphics.setFont(LOVEdefaultFont)

    if currentFilm then
        currentFilm:draw()
        love.graphics.print(currentFilm:status(),4,love.graphics.getHeight()-48,0)
        timeline:draw()
        
        Keyframe.drawUI(currentFilm)


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
end