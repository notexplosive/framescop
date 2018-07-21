local ctlStateEnum = require('controller_state')

local Keyframe = {}
Keyframe.__index = Keyframe

Keyframe.list = {}
Keyframe.x = 600
Keyframe.y = 200
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
    self.state = bit.bor(1,state)

    -- Merge with that keyframe
    if Keyframe.list[frameIndex] then
        print('warning: overwriting frame at ' .. frameIndex)
    end

    Keyframe.list[frameIndex] = self

    return self
end

Keyframe.drawUI = function(film)
    local buttonRadius = 16
    local x = Keyframe.x+buttonRadius/2
    local y = Keyframe.y+buttonRadius/2

    local state = Keyframe.getStateAtTime(film.playhead)
    if Keyframe.editMode then
        love.graphics.setColor(1,0.25,0.75)
    end

    local kf = Keyframe.getCurrentKeyframe(film)

    Keyframe.drawButton('V',x+32,y+64,buttonRadius,bit.band(state,ctlStateEnum.down))
    Keyframe.drawButton('V',x+32,y,buttonRadius,math.pi,bit.band(state,ctlStateEnum.up))
    Keyframe.drawButton('V',x,y+32,buttonRadius,math.pi/2,bit.band(state,ctlStateEnum.left))
    Keyframe.drawButton('V',x+64,y+32,buttonRadius,-math.pi/2,bit.band(state,ctlStateEnum.right))
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
    love.graphics.print(text,tx,ty,a,1,1,4,8)
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
Keyframe.getAll = function()
    list = {}
    for i=1,self.film.totalFrames do
        if Keyframe.list[i] then
            list[#list+1] = Keyframe.list[i]
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