local Timeline = {}
Timeline.__index = Timeline

Timeline.new = function(film)
    local self = {}
    setmetatable(self, Timeline)

    self.film = film
    -- playhead width and height
    self.width = 16
    self.height = 32

    self.isPressed = false
    self.x = 0

    return self
end

Timeline.update = function(self,dt)
    self.x = love.graphics.getWidth()*self.film.playhead/self.film.totalFrames
end

Timeline.draw = function(self)
    local currentFrontierPosition = love.graphics.getWidth()*(self.film.cachedFrontier-self.film.playhead)/self.film.totalFrames
    local currentViewedFramePostion = self.x
    -- Playhead can move via mouse, currentViwedPosition cannot.
    local currentPlayheadPosition = self.x
    
    if self.isPressed then
        currentPlayheadPosition = love.mouse.getX()
    end
    love.graphics.setColor(0, 1, 0, 0.4)
    love.graphics.rectangle('fill',0,love.graphics.getHeight()-32,love.graphics.getWidth()*self.film.playhead/self.film.totalFrames,32)
    if self:isFullHover() and not self:isHover() and not love.mouse.isDown(1) then
        love.graphics.setColor(0, 0, 1, .5)
        love.graphics.rectangle('fill',0,love.graphics.getHeight()-32,love.graphics.getWidth(),32)
    end
    love.graphics.setColor(0, 1, 1, 0.1)
    love.graphics.rectangle('fill',
        currentViewedFramePostion,
        love.graphics.getHeight()-self.height,
        currentFrontierPosition,
        self.height)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle('line',0,love.graphics.getHeight()-32,love.graphics.getWidth(),32)

    -- playhead
    local playheadWidth = self.width
    if self:isHover() then
        love.graphics.setColor(0,1,0)
    else
        love.graphics.setColor(1,1,1)
    end

    love.graphics.rectangle('fill',
        currentPlayheadPosition-playheadWidth/2,
        love.graphics.getHeight()-self.height,
        playheadWidth,
        self.height)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle('line',
        currentPlayheadPosition-playheadWidth/2,
        love.graphics.getHeight()-self.height,
        playheadWidth,
        self.height)
    love.graphics.setColor(1,1,1)

    -- Display current time
    if self.isPressed then
        local oldFont = love.graphics.getFont()
        love.graphics.setFont(love.graphics.newFont(48))
        local timeString = self.film:timeString(self:getFrameIndex(currentPlayheadPosition))
        local textwidth = love.graphics.getFont():getWidth(timeString)
        local textheight = love.graphics.getFont():getHeight()
        love.graphics.print(
            timeString,
            love.graphics.getWidth()/2-textwidth/2,
            love.graphics.getHeight()/2-textheight
        )
        love.graphics.setFont(oldFont)
    end
end

-- Is hovering over playhead?
Timeline.isHover = function(self)
    local mx,my = love.mouse.getPosition()
    if mx > self.x - self.width/2 and mx < self.x + self.width/2
        and my > love.graphics.getHeight() - self.height then
            return true
    end
    return false
end

-- Is hovering over timeline?
Timeline.isFullHover = function(self)
    local mx,my = love.mouse.getPosition()
    if my > love.graphics.getHeight() - self.height then
            return true
    end
    return false
end

-- Gets the frame index for the current playhead position
Timeline.getFrameIndex = function(self,x)
    return x/love.graphics.getWidth() * self.film.totalFrames
end

-- Called when the playhead was just dragged somewhere
Timeline.onRelease = function(self,x)
    local frameIndex = self:getFrameIndex(x)
    self.isPressed = false
    --self.film:h_clearData()
    self.film:movePlayheadTo(math.floor(frameIndex))
    --self.film:movePlayheadTo(x)
end

return Timeline