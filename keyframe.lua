local ctlStateEnum = require('controller_state')

local Keyframe = {}
Keyframe.__index = Keyframe

Keyframe.list = KEYFRAME_LIST_GLOBAL
Keyframe.x = 364
Keyframe.y = love.graphics.getHeight() - 128 - 32
Keyframe.editMode = false

Keyframe.new = function(film,frameIndex,state)
    if state == 0 then
        printst('Empty keyframe created')
    else
        printst('Keyframe created')
    end

    local self = {}
    setmetatable(self, Keyframe)

    self.film = film
    -- 1 = isKeyFrame
    self.state = bit.bor(state,1)

    -- Merge with that keyframe
    if Keyframe.list[frameIndex] then
        print('warning: overwriting frame at ' .. frameIndex)
    end

    Keyframe.list[frameIndex] = self

    return self
end

Keyframe.drawUI = function(film)
    local buttonRadius = 16
    local x = Keyframe.x+buttonRadius
    local y = Keyframe.y+buttonRadius

    local state = Keyframe.getStateAtTime(film.playhead)

    if state % 2 == 1 then
        love.graphics.rectangle('line',Keyframe.x-16,Keyframe.y-16,256,128)
    end

    local kf = Keyframe.getCurrentKeyframe(film)

    if Keyframe.editMode then
        love.graphics.setColor(1,0.25,0.75)
    end
    Keyframe.drawButton('V',x+32,y+64,buttonRadius,0,bit.band(state,ctlStateEnum.down))
    Keyframe.drawButton('V',x+32,y,buttonRadius,math.pi,bit.band(state,ctlStateEnum.up))
    Keyframe.drawButton('V',x,y+32,buttonRadius,math.pi/2,bit.band(state,ctlStateEnum.left))
    Keyframe.drawButton('V',x+64,y+32,buttonRadius,-math.pi/2,bit.band(state,ctlStateEnum.right))

    Keyframe.drawButton('V',x+128+32,y+64,buttonRadius,bit.band(state,ctlStateEnum.x))
    Keyframe.drawButton('V',x+128+32,y,buttonRadius,math.pi,bit.band(state,ctlStateEnum.triangle))
    Keyframe.drawButton('V',x+128,y+32,buttonRadius,math.pi/2,bit.band(state,ctlStateEnum.square))
    Keyframe.drawButton('V',x+128+64,y+32,buttonRadius,-math.pi/2,bit.band(state,ctlStateEnum.circle))
    love.graphics.setColor(1,1,1)
end

-- flip one bit at on state enum
-- behavior is weird for more than one bit so one at a time please
Keyframe.flipState = function(self,stateRegister)
    local isOnAlready = bit.band(self.state,stateRegister) > 0
    if isOnAlready then
        self.state = bit.band(self.state,bit.bnot(stateRegister))
    else
        self.state = bit.bor(self.state,stateRegister)
    end
end

-- Returns true if keyframe has that state
-- TODO: we can get much cleaner code if we use this more.
-- currently lots of places that have ugly nested bits functions
Keyframe.hasState = function(self,stateName)
    if not ctlStateEnum[stateName] then
        return false
    end
    return bit.band(ctlStateEnum[stateName],self.state) > 0
end

Keyframe.addState = function(self,stateName)
    if ctlStateEnum[stateName] then
        self.state = bit.bor(ctlStateEnum[stateName],self.state)
    end
end

Keyframe.drawButton = function(text,x,y,r,a,state)
    local fill = 'line'
    if state and state > 0 then
        fill = 'fill'
    end
    if a == nil then
        a = 0
    end
    love.graphics.circle(fill,x,y,r)
    local tx = x
    local ty = y
    local c = {love.graphics.getColor()}
    love.graphics.setColor(0.5,0.5,0.5)
    love.graphics.print(text,tx,ty,a,1,1,4,8)
    love.graphics.setColor(c)
end

Keyframe.getCurrentKeyframe = function(film,forceCreate)
    local kf = Keyframe.list[film.playhead]
    if kf == nil then
        if forceCreate then
            return Keyframe.new(film,film.playhead,Keyframe.getStateAtTime(film.playhead))
        end
        local i = film.playhead
        while i > 0 do
            kf = Keyframe.list[i]
            if kf then
                return kf
            end
            i = i-1
        end
    else
        return kf
    end
end

-- Returns a sorted array of all keyframes
-- Traverses through the entire timeline to get it.
-- O(n) sort for medium-large n, thoughts?
Keyframe.getAll = function(film)
    list = {}
    for i=1,film.totalFrames do
        if Keyframe.list[i] ~= nil then
            list[#list+1] = Keyframe.list[i]
            Keyframe.list[i].time = i
        end
    end
    return list
end

-- Gets either the current keyframe state or the most recent key frame state
Keyframe.getStateAtTime = function(frameIndex)
    if Keyframe.list[frameIndex] then
        return Keyframe.list[frameIndex].state
    end

    local i = frameIndex
    while i > 0 do
        if Keyframe.list[i] then
            -- Chop off the isKeyFrame bit so we know if this state comes from a keyframe or not
            return bit.band(Keyframe.list[i].state,bit.bnot(ctlStateEnum.isKeyFrame))
        end
        i = i - 1
    end

    return 0
end

Keyframe.serializeList = function(film)
    local buttonNames = ctlStateEnum.ALL_BUTTONS
    local text = 'time,'
    for i=1,#buttonNames do
        text = text .. buttonNames[i] .. ','
    end
    local keyframes = Keyframe.getAll(film)
    for i=1,#keyframes do
        local keyframe = keyframes[i]
        -- note: time was an added field in getAll
        local row = film:timeString(keyframe.time) .. ','
        for i=1,#buttonNames do
            local buttonName = buttonNames[i]
            local b = keyframe:hasState(buttonName)
            if b then
                row = row .. 'true,'
            else
                row = row .. 'false,'
            end
        end
        text = text .. '\n' .. row
    end

    local filename = film:getTrackPath()
    local file,err = love.filesystem.write(filename, text)

    printst(film:getFullTrackPath() .. ' saved.')
    return text
end

Keyframe.deserialize = function(film)
    if love.filesystem.getInfo(film:getTrackPath()) then
        local data = love.filesystem.read(film:getTrackPath())
        local lines = data:split('\n')
        local columnNames = lines[1]:split(',')

        for i=2,#lines do
            local line = lines[i]:split(',')
            local state = 1
            print(unpack(line))
            for j=1,#columnNames do
                columnName = columnNames[j]
                if line[j] == 'true' then
                    state = bit.bor(state,ctlStateEnum[columnName])
                end
            end

            Keyframe.new(film,film:timeStringToFrames(line[1]),state)
        end
    end
end

return Keyframe