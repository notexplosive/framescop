require("global")
require("input")
require("colors")
require("map")

local Button = require("button")
local ctlStateEnum = require("controller_state")
local Film = require("film")
local Keyframe = require("keyframe")
local ExtractAnimation = require("extract_animation")

require("tests.test_all")

iconData = love.image.newImageData("icon.png")
love.window.setIcon(iconData)

function love.load(arg)
    -- Setup window
    love.window.updateMode(800, 600, {resizable = true})
    updateWindowTitle()

    -- Build working dir cache
    loadWorkingDirectory()

    local author = love.filesystem.read("author")
    if author then
        CURRENT_AUTHOR = author
    end
end

function love.update(dt)
    CURRENT_MOUSEOVER_TARGET = ""
    CURRENT_TEXT_BOX:update(dt)

    if currentFilm then
        currentFilm:update(dt)
    end

    Keyframe.editMode = 0
    if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
        Keyframe.editMode = 1
    elseif love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt") then
        Keyframe.editMode = 2
    end -- This way if you're pressing both ctrl & alt you don't get unexpected behaviour

    updateStatusText(dt)
end

function love.draw()
    love.graphics.setFont(BigFont)

    if CURRENT_FRAMES_DIR ~= "" then
        local w, h = love.graphics.getDimensions()
        local text = "Tool is extracting frames!"
        local items = love.filesystem.getDirectoryItems("framedata/" .. CURRENT_FRAMES_DIR)
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("line", w / 2, h / 2, 256 + math.random(32), math.random(32) + 16)

        if #items > 10 then
            love.graphics.print(CURRENT_FRAMES_INDEX)
            local advanced = false
            if CURRENT_FRAMES_INDEX < #items then
                advanced = true
                CURRENT_FRAMES_INDEX = #items
            end

            if advanced then
                local image =
                    ExtractAnimation.new(
                    "framedata/" .. CURRENT_FRAMES_DIR .. "/" .. CURRENT_FRAMES_INDEX - 1 .. ".png"
                )
            end
        end

        ExtractAnimation.draw()
        if ExtractAnimation.timeSpentStalled > 60 * 3 then
            text = "Looks like we're done!"

            -- This means we never loaded a frame
            if #items == 0 then
                text = "Something went wrong with ffmpeg\nor your mp4 file."
                EXTERNAL_COMMANDS_ALLOWED = false
            end
        end

        love.graphics.print(
            text,
            math.floor(w / 2 - love.graphics.getFont():getWidth(text) / 2),
            math.floor(h / 2 + 128)
        )
        return
    end

    if not currentFilm then
        if CURRENT_AUTHOR == "" then
            CURRENT_TEXT_BOX.on = true
            love.graphics.setFont(BigFont)
            love.graphics.print(
                "Type your username so you can be credited.\nLeave blank for 'anonymous'\n\nName: " ..
                    CURRENT_TEXT_BOX.body .. CURRENT_TEXT_BOX.cursor
            )

            if CURRENT_TEXT_BOX.submitted then
                CURRENT_AUTHOR = CURRENT_TEXT_BOX.clear()
                if CURRENT_AUTHOR == "" then
                    CURRENT_AUTHOR = "anonymous"
                end
                love.filesystem.write("author", CURRENT_AUTHOR)
            end

            return
        end

        local binaries = loadWorkingDirectory()
        if #binaries == 0 then
            love.filesystem.createDirectory("framedata")
            if not EXTERNAL_COMMANDS_ALLOWED then
                love.graphics.print("No data found and it looks like in-app frame\nextraction isn't working.\n\n\nDrag your mp4 onto the frame-extractor.bat\nand then restart Framescop")
            else
                love.graphics.print("No data found, but we can fix that!\nPlease drag an MP4 video onto this window.")
            end
        end

        -- File select menu: I threw this together in 5 minutes.
        -- TODO: make this use the new button.normal() function
        for i, obj in ipairs(binaries) do
            if love.keyboard.isDown(i) then
                love.graphics.setColor(0.5, 0.5, 1)
                currentFilm = Film.new(obj.path)
            end
            love.graphics.setFont(BigFont)
            local x = 200
            local y = 20
            local buttonText = obj.filename
            love.graphics.rectangle(
                "line",
                x,
                y + (i - 1) * 64,
                love.graphics.getFont():getWidth(buttonText) + 8,
                love.graphics.getFont():getHeight() + 8
            )
            local mx, my = love.mouse.getPosition()
            if
                mx > x and mx < x + love.graphics.getFont():getWidth(buttonText) and my > y + (i - 1) * 64 and
                    my < y + (i - 1) * 64 + love.graphics.getFont():getHeight()
             then
                love.graphics.setColor(0, 0, 1)
                love.graphics.rectangle(
                    "fill",
                    x,
                    y + (i - 1) * 64,
                    love.graphics.getFont():getWidth(buttonText) + 8,
                    love.graphics.getFont():getHeight() + 8
                )
                if love.mouse.isDown(1) then
                    currentFilm = Film.new(obj.path)
                end
            end
            love.graphics.setColor(white())
            love.graphics.print(buttonText, x, y + (i - 1) * 64)
            love.graphics.setColor(white())
        end
    end

    if currentFilm then
        currentFilm:draw()
        Keyframe.drawUI(currentFilm)

        love.graphics.print(currentFilm:status(), 4, love.graphics.getHeight() - 48, 0)

        local rootx = 128 + 32 + 8 + 2

        -- Keyframe timeline ticker pane
        local sizeOfBuffer = 15
        for i = -sizeOfBuffer, sizeOfBuffer do
            local width = 8
            local height = 16
            local x = rootx + width * i
            local y = love.graphics.getHeight() - 64 - 32 - 6

            if UI_FLIP then
                y = 64 + 32
            end

            if i == 0 then
                y = y - 3
                height = height + 5
            end

            love.graphics.setColor(keyframeTickerBGColor())
            if (currentFilm.playhead + i) % width == 0 then
                love.graphics.setColor(keyframeTickerBGSecondaryColor())
            end

            if Keyframe.list[currentFilm.playhead + i] then
                love.graphics.setColor(keyframeTickerCurrentFrameColor())
            end

            if currentFilm.playhead + i < 1 then
                love.graphics.setColor(darkgray())
            end

            love.graphics.rectangle("fill", x, y, width, height)
            love.graphics.setColor(black())
            love.graphics.rectangle("line", x, y, width, height)
            love.graphics.setColor(white())
        end

        love.graphics.setFont(BigFont)
        love.graphics.setColor(uiBackgroundColor())
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 32)
        love.graphics.setColor(white())
        love.graphics.print(StatusText)

        if FileMgr.trackPath then
            local textWidth = love.graphics.getFont():getWidth(FileMgr.trackPath)
            local textHeight = love.graphics.getFont():getHeight()
            local textX = love.graphics.getWidth() - textWidth
            love.graphics.print(FileMgr.trackPath, textX, 0)
        end

        if CURRENT_MODE == "notes" then
            love.graphics.setColor(notesBackgroundColor())
            love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
            love.graphics.setColor(white())
            printst("") -- clear the print status header
            love.graphics.print(
                "Notes at " .. currentFilm:timeString() .. ":\n" .. CURRENT_TEXT_BOX.body .. CURRENT_TEXT_BOX.cursor
            )
        end

        if CURRENT_MODE == "default" then
            local playPause = "Play"
            local uiFlip = "^"
            if UI_FLIP then
                uiFlip = "v"
            end
            if currentFilm.playRealTime then
                playPause = "Pause"
            end
            local buttonx = 16
            local buttony = love.graphics.getHeight() - 80

            if UI_FLIP then
                buttony = 32 + 16
            end

            Button.normal(">", buttonx + 192, buttony, 64, 32, "stepRight")
            Button.normal("<", buttonx + 64, buttony, 64, 32, "stepLeft")
            Button.normal(playPause, buttonx + 128, buttony, 64, 32, "toggleRealtimePlayback")
            Button.normal(">>", buttonx + 256, buttony, 64, 32, "jumpRight")
            Button.normal("<<", buttonx, buttony, 64, 32, "jumpLeft")
            Button.normal("Map", buttonx + 256 + 64, buttony, 32, 32, "toggleMap")
            Button.normal(uiFlip, buttonx + 256 + 128 + 64 + 32 + 16, buttony, 16, 32, "toggleUIFlip")
        end
    end

    if MAP_ON then
        Map.draw()
    end
end
