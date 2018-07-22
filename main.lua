require('global')
require('input')

local ctlStateEnum = require('controller_state')
local Film = require('film')
local Keyframe = require('keyframe')

iconData = love.image.newImageData("icon.png")
love.window.setIcon( iconData )

function love.load(arg)
    -- Setup window
    love.window.updateMode(800,600,{resizable=true})
    updateWindowTitle()

    -- Build working dir cache
    loadWorkingDirectory()

    local author = love.filesystem.read('author')
    if author then
        CURRENT_AUTHOR = author
    end
end

cursorTimer = 0
function love.update(dt)
    cursorTimer = cursorTimer + dt
    if math.sin(cursorTimer * math.pi*2) > 0 then
        TEXT_BOX_CURSOR = '|'
    else
        TEXT_BOX_CURSOR = ''
    end
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
            love.graphics.print("Type your username so you can be credited.\nLeave blank for \'anonymous\'\n\nName: " .. CURRENT_TEXT_BOX.body .. TEXT_BOX_CURSOR)

            if CURRENT_TEXT_BOX.submitted then
                CURRENT_AUTHOR = CURRENT_TEXT_BOX.clear()
                if CURRENT_AUTHOR == '' then
                    CURRENT_AUTHOR = 'anonymous'
                end
                love.filesystem.write('author',CURRENT_AUTHOR)
            end

            return
        end

        local binaries = loadWorkingDirectory()
        if #binaries == 0 then
            love.graphics.print('no binaries found')
        end

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

        love.graphics.print(currentFilm:status(),4,love.graphics.getHeight()-48,0)

        local rootx = love.graphics.getWidth() - 128 - 32
        local y = love.graphics.getHeight() - 128 - 64 - 16
        
        love.graphics.print('img:'..currentFilm.playhead,rootx,y - love.graphics.getFont():getHeight() - 2)

        -- Keyframe timeline pane
        for i=-9,10 do
            local x = rootx + 10*i
            love.graphics.rectangle('line',x,y,10,10)

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

            love.graphics.rectangle('fill',x,y,10,10)
            love.graphics.setColor(1,1,1)
        end

        love.graphics.setFont(BigFont)
        love.graphics.print(StatusText)
    end
end