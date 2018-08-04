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
    if currentFilm then
        -- if we're on windows, split on '\', otherwise split on '/'
        local splitName = file:getFilename():split('\\')
        if #splitName == 0 then
            splitName = file:getFilename():split('/')
        end
        local name = splitName[#splitName]
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
                row = row .. keyframe[schema[i]] .. DELIM
            end
        end

        text = text .. '\n' .. row
    end

    if filename == nil then
        filename = FileMgr.film:getTrackPath()
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
                print(columnName,line[j])
                data[columnName] = line[j]
            end
        end

        Keyframe.new(FileMgr.film,FileMgr.film:timeStringToFrames(line[1]),state,data)
    end
end

return FileMgr