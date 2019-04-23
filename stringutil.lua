-- Generic utility function
function isInList(element, table)
    for i, v in ipairs(table) do
        if v == element then
            return true
        end
    end
    return false
end

-- Generic utility to get a random element of an array
function getRandom(table)
    return table[math.random(#table)]
end

-- Taken from SuperFastNinja on StackOverflow
function string.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    i = 1
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end
