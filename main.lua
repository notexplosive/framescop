require('global')
require('input')

local ctlStateEnum = require('controller_state')
local Film = require('film')
local Keyframe = require('keyframe')

require('tests.test_all')

iconData = love.image.newImageData("icon.png")
love.window.setIcon(iconData)

function love.load(arg)
    -- Setup window
    love.window.updateMode(800, 600, {resizable=true})
    updateWindowTitle()

    -- Build working dir cache
    loadWorkingDirectory()

    local author = love.filesystem.read('author')
    if author then
        CURRENT_AUTHOR = author
    end
end

function love.update(dt)
    CURRENT_MOUSEOVER_TARGET = ''
    CURRENT_TEXT_BOX:update(dt)

    if currentFilm then
        currentFilm:update(dt)
    end
    
    Keyframe.editMode = 0
    if love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl') then
        Keyframe.editMode = 1
    elseif love.keyboard.isDown('lalt') or love.keyboard.isDown('ralt') then
        Keyframe.editMode = 2
    end -- This way if you're pressing both ctrl & alt you don't get unexpected behaviour

    updateStatusText(dt)
end

function love.draw()
    love.graphics.setFont(LOVEdefaultFont)

    if not currentFilm then
        if CURRENT_AUTHOR == '' then
            CURRENT_TEXT_BOX.on = true
            love.graphics.setFont(BigFont)
            love.graphics.print("Type your username so you can be credited.\nLeave blank for \'anonymous\'\n\nName: " .. CURRENT_TEXT_BOX.body .. CURRENT_TEXT_BOX.cursor)

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
            love.filesystem.createDirectory('framedata')
            love.graphics.print('No data found. Framedata folder does not have any valid directories.')
        end

        -- File select menu: I threw this together in 5 minutes.
        for i,obj in ipairs(binaries) do
            if love.keyboard.isDown(i) then
                love.graphics.setColor(0.5,0.5,1)
                currentFilm = Film.new(obj.path)
            end
            love.graphics.setFont(BigFont)
            local x = 200
            local y = 20
            local buttonText = obj.filename
            love.graphics.rectangle('line',x,y+(i-1)*64,love.graphics.getFont():getWidth(buttonText) + 8,love.graphics.getFont():getHeight() + 8)
            local mx,my = love.mouse.getPosition()
            if mx > x and mx < x + love.graphics.getFont():getWidth(buttonText) and my > y+(i-1)*64 and my < y+(i-1)*64 + love.graphics.getFont():getHeight() then
                love.graphics.setColor(0,0,1)
                love.graphics.rectangle('fill',x,y+(i-1)*64,love.graphics.getFont():getWidth(buttonText) + 8,love.graphics.getFont():getHeight() + 8)
                if love.mouse.isDown(1) then
                    currentFilm = Film.new(obj.path)
                end
            end
            love.graphics.setColor(1,1,1)
            love.graphics.print(buttonText,x,y+(i-1)*64)
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
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle('fill',0,0,love.graphics.getWidth(),32)
        love.graphics.setColor(1,1,1)
        love.graphics.print(StatusText)

        if FileMgr.trackPath then
            local textWidth = love.graphics.getFont():getWidth(FileMgr.trackPath)
            local textHeight = love.graphics.getFont():getHeight()
            local textX = love.graphics.getWidth()-textWidth
            love.graphics.print(FileMgr.trackPath,textX,0)
        end

        if CURRENT_MODE == 'notes' then
            love.graphics.setColor(.25,.25,.5,.5)
            love.graphics.rectangle('fill',0,0,love.graphics.getDimensions())
            love.graphics.setColor(1,1,1)
            printst('') -- clear the print status header
            love.graphics.print('Notes at '..currentFilm:timeString()..':\n'..CURRENT_TEXT_BOX.body .. CURRENT_TEXT_BOX.cursor)
        end
    end
end