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
    self.hover = false
    self.x = 0

    return self
end

Timeline.update = function(self,dt)
    self.isHover = false
    self.x = love.graphics.getWidth()*self.film.playhead/self.film.totalFrames

    local mx,my = love.mouse.getPosition()
    if mx > self.x - self.width/2 and mx < self.x + self.width/2
        and my > love.graphics.getHeight() - self.height then
        self.isHover = not love.mouse.isDown(1)
    end
end

Timeline.draw = function(self)
    local currentFrontierPosition = love.graphics.getWidth()*(self.film.cachedFrontier-self.film.playhead)/self.film.totalFrames
    local currentViewedFramePostion = self.x
    local currentPlayheadPosition = self.x
    
    if self.isPressed then
        currentPlayheadPosition = love.mouse.getX()
    end
    love.graphics.setColor(0, 1, 0, 0.4)
    love.graphics.rectangle('fill',0,love.graphics.getHeight()-32,love.graphics.getWidth()*self.film.playhead/self.film.totalFrames,32)
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
    if self.isHover then
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
end

-- Called when the playhead was just dragged somewhere
Timeline.onRelease = function(self,x)
    -- TODO: this is duplicate code from Film.status, make this better
    local realFPS = 24
    local scale = realFPS / self.film.fps
    local frameIndex = x/love.graphics.getWidth() * self.film.totalFrames
    self.isPressed = false
    --self.film:h_clearData()
    self.film:movePlayheadTo(math.floor(frameIndex))
    --self.film:movePlayheadTo(x)
end

return Timeline