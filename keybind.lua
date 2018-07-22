local Actions = require('actions')

local Keybind = {}
Keybind.__index = Keybind

Keybind.table = {}
Keybind.table.default = {}
Keybind.table.fileSelect = {}

-- Overload option    (name,key,callback) mode = 'default'
Keybind.new = function(name,key,mode,callback)
    self = {}
    setmetatable(self, Keybind)

    self.name = name
    self.key = key

    -- Overload handling
    if not self.callback then
        callback = mode
        mode = 'default'
    end
    self.callback = callback

    print(mode,key,self.callback)
    Keybind.table[mode][key] = self

    return self
end

Keybind.exec = function(key,mode)
    -- Mode can be used to reclassify inputs depending on state
    -- For example: main menu might have other uses for left/right than playback
    if mode == nil then
        mode = 'default'
    end

    local action = Keybind.table[mode][key]

    if action then
        print('ACT: ' .. action.name)
        action.callback()
    end
end

Keybind.new('stepRight','right',Actions.stepRight)
Keybind.new('stepLeft','left',Actions.stepLeft)
Keybind.new('save','^s',FileMgr.save)

for i,dir in ipairs({'up','down','left','right'}) do
    Keybind.new(dir .. 'ToKeyframe','^'..dir,Actions[dir .. 'ToKeyframe'])
end

Keybind.new('jumpRight','+right',Actions.jumpRight)
Keybind.new('jumpLeft','+left',Actions.jumpLeft)

return Keybind