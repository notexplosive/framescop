local ctlStateEnum = require('controller_state')
local Keyframe = require('keyframe')

FileMgr = {}

FileMgr.trackPath = nil
FileMgr.autosaveCount = -1

-- TSV FILE TOP ROW LOOKS LIKE THE FOLLOWING
-- time, notes, up, down, left, {..all other buttons..}, author
FileMgr.schema = {'time','notes'}
for i=1,#ctlStateEnum.ALL_BUTTONS do
    FileMgr.schema[#FileMgr.schema+1] = ctlStateEnum.ALL_BUTTONS[i]
end

FileMgr.schema[#FileMgr.schema+1] = 'author'

function love.filedropped(file)
    -- if we're on windows, split on '\', otherwise split on '/'
    local splitName = file:getFilename():split('\\')
    if #splitName == 0 then
        splitName = file:getFilename():split('/')
    end
    local name = splitName[#splitName]
    local dotSeparated = file:getFilename():split('.')
    local extension = dotSeparated[#dotSeparated]
    
    if not currentFilm then
        local nameSplitSpaces = name:split('.')[1]:split(' ')
        local nameNoSpaces = ''
        for i=1,#nameSplitSpaces do
            nameNoSpaces = nameNoSpaces .. nameSplitSpaces[i]
        end
        local output = love.filesystem.getSaveDirectory() .. "\\framedata\\" .. nameNoSpaces
        local OSName = love.system.getOS()
        if extension == 'mp4' and OSName == 'Windows' then
            local command = ".\\ffmpeg -i \"".. file:getFilename() .. "\" -r 15 -s 320x240 \"" .. output .. "\\%d.png\" > output.txt"
            local thread = love.thread.newThread('ffmpeg_bootstrap.lua')
            love.filesystem.createDirectory('framedata/' .. nameNoSpaces)
            for _, v in pairs(love.filesystem.getDirectoryItems('framedata/' .. nameNoSpaces)) do
                love.filesystem.remove( 'framedata/' .. nameNoSpaces .. '/' .. v )
            end
            THREAD_POOL[#THREAD_POOL + 1] = thread
            CURRENT_FRAMES_DIR = nameNoSpaces
            thread:start(command,output)
        end
    end

    if currentFilm and extension == 'tsv' then
        KEYFRAME_LIST_GLOBAL = {}
        Keyframe.list = KEYFRAME_LIST_GLOBAL
        FileMgr.deserializeList(file:read():split('\n'))
        FileMgr.trackPath = name
        printst('Opened ' .. name)
    end
end

FileMgr.init = function(film)
    FileMgr.film = film
end

FileMgr.save = function()
    FileMgr.saveAs()
end

FileMgr.saveAs = function(filename)
    FileMgr.serializeList(filename)
end

FileMgr.load = function(film,filename)
    FileMgr.deserialize(filename)
    FileMgr.autosaveCount = 0
end

FileMgr.serializeList = function(filename)
    local list = KEYFRAME_LIST_GLOBAL
    local schema = FileMgr.schema
    local text = ''
    for i=1,#schema do
        text = text .. schema[i] .. DELIM
    end

    local keyframes = Keyframe.getAll(FileMgr.film,true)
    for i=1,#keyframes do
        local keyframe = keyframes[i]
        -- note: time was an added field in Keyframe.getAll, it wasn't there before
        local row = '' --to delete: FileMgr.film:timeString(keyframe.time) .. DELIM
        for i=1,#schema do
            local colName = schema[i]
            if isButton(colName) then
                local buttonPressed = keyframe:hasState(colName)

                if buttonPressed == true then
                    row = row .. 'true' .. DELIM
                else
                    row = row .. 'false' .. DELIM
                end
            else
                if keyframe[schema[i]] == nil then
                    keyframe[schema[i]] = '-'
                end
                row = row .. keyframe[schema[i]] .. DELIM
            end
        end

        text = text .. '\n' .. row
    end

    if filename == nil then
        filename = FileMgr.film:getTrackPath() or 'Unknown' .. math.random(100000)
    end

    love.filesystem.write(filename, text)

    printst(filename .. ' saved.')
    print(FileMgr.film:getFullTrackPath())
    return text
end

FileMgr.deserialize = function(filename)
    if FileMgr.trackPath == nil then
        FileMgr.trackPath = FILE_NAME .. '.tsv'
    end

    local info = love.filesystem.getInfo(FileMgr.trackPath)
    if info and info.size > 0 then
        local data = love.filesystem.read(FileMgr.trackPath)
        local lines = data:split('\n')
        FileMgr.deserializeList(lines)
    end
end

FileMgr.deserializeList = function(lines)
    local columnNames = lines[1]:split(DELIM)

    for i=2,#lines do
        local line = lines[i]:split(DELIM)
        local state = 1
        local data = {}
        for j=1,#columnNames do
            columnName = columnNames[j]
            if line[j] and line[j]:lower() == 'true' and isButton(columnName) then
                state = bit.bor(state,ctlStateEnum[columnName])
            else
                data[columnName] = line[j]
            end
        end

        local kf = Keyframe.new(FileMgr.film,FileMgr.film:timeStringToFrames(line[1]),state,data)
        kf.notes = data.notes
    end
end

return FileMgr