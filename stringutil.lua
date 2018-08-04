-- Generic utility function
function isInList(element,table)
    for i,v in ipairs(table) do
        if v == element then
            return true
        end
    end
    return false
end
    
-- Taken from SuperFastNinja on StackOverflow
function string.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end