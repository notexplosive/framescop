local ctlStateEnum = require('controller_state')
local Keyframe = require('keyframe')

FileMgr = {}

FileMgr.autosaveCount = -1

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
    local buttonNames = ctlStateEnum.ALL_BUTTONS
    local text = 'time' .. DELIM
    for i=1,#buttonNames do
        text = text .. buttonNames[i] .. DELIM
    end
    text = text .. 'author'
    local keyframes = Keyframe.getAll(FileMgr.film)
    for i=1,#keyframes do
        local keyframe = keyframes[i]
        -- note: time was an added field in getAll
        local row = FileMgr.film:timeString(keyframe.time) .. DELIM
        for i=1,#buttonNames do
            local buttonName = buttonNames[i]
            local b = keyframe:hasState(buttonName)
            if b then
                row = row .. 'true' .. DELIM
            else
                row = row .. 'false' .. DELIM
            end

            if i == #buttonNames then
                row = row .. keyframe.author
            end
        end

        text = text .. '\n' .. row
    end

    if filename == nil then
        filename = FileMgr.film:getTrackPath()
    end

    love.filesystem.write(filename, text)

    printst(filename .. ' saved.')
    return text
end

FileMgr.deserialize = function(filename)
    local info = love.filesystem.getInfo(FileMgr.film:getTrackPath())
    if info and info.size > 0 then
        local data = love.filesystem.read(FileMgr.film:getTrackPath())
        local lines = data:split('\n')
        local columnNames = lines[1]:split(DELIM)
        local author = 'unknown'

        for i=2,#lines do
            local line = lines[i]:split(DELIM)
            local state = 1
            for j=1,#columnNames do
                columnName = columnNames[j]
                if line[j] and line[j]:lower() == 'true' then
                    state = bit.bor(state,ctlStateEnum[columnName])
                end

                -- Author's column
                if j == #columnNames then
                    if line[j] then
                        author = line[j]
                    end
                end
            end

            Keyframe.new(FileMgr.film,FileMgr.film:timeStringToFrames(line[1]),state,author)
        end
    end
end

return FileMgr