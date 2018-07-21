function love.filedropped(file)
    local name = file:getFilename()
    local data = file:read()

    print(name)
end