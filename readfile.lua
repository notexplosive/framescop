-- One-off function to read from a file.
-- NOTE: this file is not used, will delete in a future commit once we're certain

function readFile(filename)
    local f = io.open(filename,'rb')
    if f then
        local lines = {}
        for line in io.lines(filename) do
            lines[#lines + 1] = line
        end
        return lines
    end
    
    return nil
end

return readFile