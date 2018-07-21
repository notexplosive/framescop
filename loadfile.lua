function love.filedropped(file)
    local name = file:getFilename()
    local data = file:read()

    print(name)
end


WorkingDirectoryBinaries = nil
-- Loads all binaries in working directory
-- Or loads the cached list if it exists
function loadWorkingDirectory()
    if WorkingDirectoryBinaries then
        return WorkingDirectoryBinaries
    else
        WorkingDirectoryBinaries = {}
    end

    local binaries = love.filesystem.getDirectoryItems('binaries')

    for i,folderName in ipairs(binaries) do
        local path = 'binaries/'..folderName
        if love.filesystem.getInfo(path).type == 'directory' then
            local files = love.filesystem.getDirectoryItems(path)
            for j,filename in ipairs(files) do
                if filename == 'data.txt' then
                    obj = {}
                    obj.path = path
                    obj.filename = folderName
                    WorkingDirectoryBinaries[#WorkingDirectoryBinaries + 1] = obj
                end
            end
        end
    end

    return WorkingDirectoryBinaries
end