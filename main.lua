FILE_NAME = 'empty'
APP_NAME = 'Framescop V1.0'
CURRENT_AUTHOR = ''

require('global')
require('status')
require('loadfile')
require('input')
local ctlStateEnum = require('controller_state')
local Film = require('film')
local Keyframe = require('keyframe')

local LOVEdefaultFont = love.graphics:getFont()
local BigFont = love.graphics.newFont(24)

-- todo: make this local, fix where that breaks.
currentFilm = nil

-- Window setup
function updateWindowTitle()
    local title = APP_NAME .. ' by NotExplosive'
    love.window.setTitle(title .. ' - ' .. FILE_NAME)
end

updateWindowTitle()

love.window.updateMode(800,600,{resizable=true})


function love.load(arg)
    -- Build working dir cache
    loadWorkingDirectory()

    local author = love.filesystem.read('author')
    if author then
        CURRENT_AUTHOR = author
    end
end

function love.update(dt)
    if currentFilm then
        currentFilm:update(dt)
    end
    
    Keyframe.editMode = love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')

    updateStatusText(dt)
end

function love.draw()
    love.graphics.setFont(LOVEdefaultFont)

    if not currentFilm then
        if CURRENT_AUTHOR == '' then
            CURRENT_TEXT_BOX.on = true
            love.graphics.setFont(BigFont)
            love.graphics.print("Please enter the name you want to be credited as:\n" .. CURRENT_TEXT_BOX.body)

            if CURRENT_TEXT_BOX.submitted then
                CURRENT_AUTHOR = CURRENT_TEXT_BOX.clear()
                love.filesystem.write('author',CURRENT_AUTHOR)
            end

            return
        end

        local binaries = loadWorkingDirectory()
        for i,obj in ipairs(binaries) do
            if love.keyboard.isDown(i) then
                love.graphics.setColor(0.5,0.5,1)
                currentFilm = Film.new(obj.path)
            end
            love.graphics.print(i .. ':\t'..obj.niceTitle .. '\t'..obj.fps..'\t'..'('..obj.filename..')',0,(i-1)*love.graphics.getFont():getHeight())
            love.graphics.setColor(1,1,1)
        end
    end

    if currentFilm then
        currentFilm:draw()
        Keyframe.drawUI(currentFilm)

        -- Keyframe timeline pane
        love.graphics.print(currentFilm:status(),4,love.graphics.getHeight()-48,0)
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