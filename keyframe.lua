local ctlStateEnum = require('controller_state')

local Keyframe = {}
Keyframe.__index = Keyframe

Keyframe.list = KEYFRAME_LIST_GLOBAL
Keyframe.editMode = 0

Keyframe.new = function(film,frameIndex,state,author)
    if author == nil then
        author = CURRENT_AUTHOR
    end

    if state == 0 then
        printst('Empty keyframe created')
    else
        printst('Keyframe created')
    end

    local self = {}
    setmetatable(self, Keyframe)

    if FileMgr.autosaveCount ~= -1 then
        FileMgr.autosaveCount = FileMgr.autosaveCount + 1
        -- Every few created keyframes, save.
        if FileMgr.autosaveCount > 10 then
            FileMgr.autosaveCount = 0
            FileMgr.saveAs('autosave')
        end
    end

    self.film = film

    -- Far right bit is the isKeyFrame flag.
    self.state = bit.bor(state,1)
    self.author = author

    -- Merge with that keyframe
    if Keyframe.list[frameIndex] then
        print('warning: overwriting frame at ' .. frameIndex)
    end

    Keyframe.list[frameIndex] = self

    return self
end

Keyframe.drawUI = function(film)
    Keyframe.x = love.graphics.getWidth() - 256 - 4
    Keyframe.y = love.graphics.getHeight() - 128 - 32

    local buttonRadius = 16
    local x = Keyframe.x+buttonRadius
    local y = Keyframe.y+buttonRadius

    local state = Keyframe.getStateAtTime(film.playhead)

    -- State's far right bit will be 1 if this is an actual keyframe and not just fetching most recent
    love.graphics.setColor(0,0,0,0.25)
    love.graphics.rectangle('fill',Keyframe.x-16,Keyframe.y-16,256,128)
    if state % 2 == 1 then
        love.graphics.setColor(1,1,1,1)
        love.graphics.print('author: ' .. Keyframe.getCurrentKeyframe(film).author,Keyframe.x-16,Keyframe.y-32)
        love.graphics.rectangle('line',Keyframe.x-16,Keyframe.y-16,256,128)
    end

    local kf = Keyframe.getCurrentKeyframe(film)

    -- Up/Down/Left/Right are all just rotated V's. I'm lazy like that.
    -- TODO: maybe make these images of a PS1 controller? Could be cute.
    Keyframe.drawButton('V',x+32,y+64,buttonRadius,0,bit.band(state,ctlStateEnum.down))
    Keyframe.drawButton('V',x+32,y,buttonRadius,math.pi,bit.band(state,ctlStateEnum.up))
    Keyframe.drawButton('V',x,y+32,buttonRadius,math.pi/2,bit.band(state,ctlStateEnum.left))
    Keyframe.drawButton('V',x+64,y+32,buttonRadius,-math.pi/2,bit.band(state,ctlStateEnum.right))

    
    Keyframe.drawButton('x',x+128+32,y+64,buttonRadius,0,bit.band(state,ctlStateEnum.x))
    Keyframe.drawButton('triangle',x+128+32,y,buttonRadius,0,bit.band(state,ctlStateEnum.triangle))
    Keyframe.drawButton('square',x+128,y+32,buttonRadius,0,bit.band(state,ctlStateEnum.square))
    Keyframe.drawButton('circle',x+128+64,y+32,buttonRadius,0,bit.band(state,ctlStateEnum.circle))

    Keyframe.drawButton('start',x+128-64+16,y,buttonRadius,0,bit.band(state,ctlStateEnum.start))
    Keyframe.drawButton('select',x+128-16,y,buttonRadius,0,bit.band(state,ctlStateEnum.select))
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
    local c = {love.graphics.getColor()}
    if a == nil then
        a = 0
    end

    if text ~= 'V' and text ~= 'start' and text ~= 'select' then
        if text == 'triangle' then
            love.graphics.setColor(0.5,1,0.5)
            love.graphics.polygon('line',
                x-r*2/3,    y+r*2/6,
                x,          y-r*2/3,
                x+r*2/3,    y+r*2/6    )
        end

        if text == 'square' then
            love.graphics.setColor(1,0.7,0.7)
            love.graphics.rectangle('line',x-r/2,y-r/2,r,r)
        end

        if text == 'circle' then
            love.graphics.setColor(1,0.5,0.5)
            love.graphics.circle('line',x,y,r*2/3)
        end

        if text == 'x' then
            love.graphics.setColor(0.5,1,1)
            love.graphics.line(x-r/2,y-r/2,x+r/2,y+r/2)
            love.graphics.line(x-r/2,y+r/2,x+r/2,y-r/2)
        end

        text = ''
    end

    love.graphics.setColor(0.5,0.5,0.5)

    if Keyframe.editMode == 1 and (text == 'V' or text == 'start') then
        love.graphics.setColor(1,0.5,0.5)
    end

    if Keyframe.editMode == 2 and text ~= 'V' and text ~= 'start' then
        love.graphics.setColor(1,0.5,1)
    end

    
    -- Draw button border and background
    if text == 'start' or text == 'select' then
        if state and state > 0 then
            love.graphics.setColor(1,1,1)
            if Keyframe.editMode > 0 then
                love.graphics.circle('line',x,y,r)
            end
        end
        love.graphics.print(text,x-love.graphics.getFont():getWidth(text)/2,y,a,1,1,4,8)
    else
        if state and state > 0 then
            love.graphics.setColor(1,0.75,0.75,1)
            love.graphics.circle('fill',x,y,r)
        end
        love.graphics.circle('line',x,y,r)
        love.graphics.setColor(1,1,1)
        love.graphics.print(text,x,y,a,1,1,4,8)
    end

    love.graphics.setColor(c)
end

Keyframe.getCurrentKeyframe = function(film,forceCreate)
    local kf = Keyframe.list[film.playhead]
    if kf == nil then
        if forceCreate then
            return Keyframe.new(film,film.playhead,Keyframe.getStateAtTime(film.playhead),CURRENT_AUTHOR)
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

return Keyframe