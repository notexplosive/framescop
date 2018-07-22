local Actions = require('actions')

local Keybind = {}
Keybind.__index = Keybind

Keybind.table = {}
Keybind.table.default = {}
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
            action()
        end
    end
end

Keybind.new('right','stepRight')
Keybind.new('left','stepLeft')
Keybind.new('p','toggleRealtimePlayback')
Keybind.new('delete','deleteCurrentKeyframe')

Keybind.new('^s','save')
for i,dir in ipairs({'up','down','left','right'}) do
    Keybind.new('^'..dir, dir .. 'ToKeyframe')
end

Keybind.new('+right','jumpRight')
Keybind.new('+left','jumpLeft')

return Keybind