local Actions = require('actions')

local Keybind = {}
Keybind.__index = Keybind

Keybind.table = {}
Keybind.table.default = {}
-- is this even used?
Keybind.table.fileSelect = {}

Keybind.new = function(key,name,mode)
    self = {}
    setmetatable(self, Keybind)

    self.name = name
    self.key = key

    if mode == nil then
        mode = 'default'
    end

    Keybind.table[mode][key] = self

    return self
end

Keybind.exec = function(key,mode)
    -- Mode can be used to reclassify inputs depending on state
    -- For example: main menu might have other uses for left/right than playback
    if mode == nil then
        mode = 'default'
    end

    local entry = Keybind.table[mode][key]
    if entry then
        local name = entry.name
        local action = Actions[name]

        if action then
            print(name)
            action()
        end
    end
end

Keybind.new('right','stepRight')
Keybind.new('left','stepLeft')
Keybind.new('p','toggleRealtimePlayback')
Keybind.new('delete','deleteCurrentKeyframe')

Keybind.new('^s','save')
local faceButtons = {'triangle','x','square','circle'}
local wasd = {'w','s','a','d'}
local directions = {'up','down','left','right'}
for i,dir in ipairs(directions) do
    local face = faceButtons[i]
    Keybind.new('^'..dir, 'toggle' .. dir )
    Keybind.new('@'..dir, 'toggle' .. face)
    Keybind.new(wasd[i],'toggle' .. dir)
    Keybind.new('@'..wasd[i],'toggle'..face)
end

for i,v in ipairs({'start','up','down','left','right','triangle','x','square','circle','select'}) do
    Keybind.new((i-1) .. '', 'toggle'..v)
    Keybind.new('mouseClick'..v, 'toggle'..v)
end

Keybind.new('^'..'space','toggleselect')
Keybind.new('@'..'space','togglestart')
Keybind.new('+right','jumpRight')
Keybind.new('+left','jumpLeft')

return Keybind