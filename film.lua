-- We're calling this "Film" because it's a series of static images played back
-- to make it look like it's a contiguous video.

local readFile = require('readfile')

local Film = {}
Film.__index = Film

Film.new = function(dirPath)
    printst('Loading new video...')
    local self = {}
    setmetatable(self, Film)

    self.playhead = 1

    local lines = readFile(dirPath .. '/data.txt')
    self.title = lines[1]
    self.totalFrames = tonumber(lines[2])
    self.fps = tonumber(lines[3])
    self.path = dirPath
    self.warning = false
    self.warningTimer = 0
    self.idleTimer = 0
    self.framesInMemory = 0
    self.cachedFrontier = 0
    self.preloading = false

    if self.title == nil or self.totalFrames == nil then
        printst('Data file at ' ..  dirPath .. ' is either corrupted or missing something')
    end

    self.data = {}
    self:h_loadAt(1,24)

    return self
end

Film.update = function(self,dt)
    -- This ticks up every frame but gets reset when a key is pressed
    self.idleTimer = self.idleTimer + dt
    self.preloading = false

    if not self.data[self.playhead + 10] then
        printst('Loading more frames...')
        self.warning = true
        self.warningTimer = self.warningTimer + dt

        -- Warning enables the red border. If it's been red for 1 second, just load the next
        -- chunk, we warned them so they will expect the lag.
        if self.warningTimer > .25 then
            self:h_loadAt(self:h_nextUnloadedFromPlayhead(),24)
            self.warningTimer = 0
        end
    else
        self.warning = false
        self.warningTimer = 0
    end

    if self.idleTimer > 1 then
        if self:h_loadAt(self:h_nextUnloadedFromPlayhead(),14) then
            printst('Loading ahead...')
            self.preloading = true
        end
    end

    if not self.data[self.playhead] then
        -- How many frames back to we render if available?
        -- TODO: extract this into a constant?
        local backFrames = 8
        if self.playhead < backFrames then
            backFrames = self.playhead
        end
        self:h_loadAt(self.playhead-backFrames,24)
    end

    -- TODO: This could be a lot smarter.
    if self.framesInMemory > 400 then
        self:h_clearData()
    end
end

Film.draw = function(self)
    love.graphics.draw(self:getFrameImage(self.playhead))
    if self.warning then
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle('line',0,0,love.graphics.getDimensions())
        love.graphics.setColor(1,1,1)
    end

    if self.preloading then
        love.graphics.setColor(0,1,0)
        love.graphics.rectangle('line',0,0,love.graphics.getDimensions())
        love.graphics.setColor(1,1,1)
    end
end

Film.getFrameImage = function(self,index)
    -- If we have the data, easy, load it!
    if self.data[index] then
        return self.data[index]
    end
    
    self:h_loadAt(index,14)
    return self.data[index]
end

Film.movePlayheadTo = function(self,index)
    if index > 0 and index < self.totalFrames then
        self.playhead = index
    end
end

Film.status = function(self)
    return 'time: ' .. self:timeString()
    .. self.framesInMemory .. ' images in memory' .. '\t'
end

Film.timeString = function(self,x)
    if x == nil then 
        x = self.playhead
    end
    -- The binary most likely isn't at original framerate (24), so we scale up the "current frame" we're on
    local realFPS = 24
    local scale = realFPS / self.fps
    local seconds = (x)*(scale / realFPS / 2)
    local video_frame = (x-1) * scale
    return string.format("%02d",seconds/60) .. ':'
    .. string.format("%02d",seconds%60) .. ';' 
    .. string.format("%02d",video_frame%realFPS) .. '\t'
end

--- HELPER FUNCTIONS BELOW THIS POINT ---


-- Helper function to keep the constructor looking clean
Film.h_loadAt = function(self,location,size)
    if location < 1 then
        location = 1
    end

    if location + size > self.totalFrames then
        size = self.totalFrames - location
    end

    local loadedSomething = false

    for i=location,location + size do
        if not self.data[i] then
            self.framesInMemory = self.framesInMemory + 1
            self.data[i] = love.graphics.newImage(self.path .. '/' .. i .. '.png')
            loadedSomething = true
        end 
    end

    return loadedSomething
end

Film.h_eraseAt = function(self,location,size)
    if location < 1 then
        location = 1
    end

    if location + size > self.totalFrames then
        size = self.totalFrames - location
    end

    for i=location,location+size do
        if self.data[i] then
            -- Delete from table, hand to garbage collector
            self.framesInMemory = self.framesInMemory - 1
            self.data[i]:release()
            self.data[i] = nil
        end
    end
end

Film.h_nextUnloadedFromPlayhead = function(self)
    -- If we've already loaded 240 frames out, we're good.
    for i=self.playhead,self:h_boundedFromPlayhead(240) do
        if self.data[i] == null then
            self.cachedFrontier = i
            return i
        end
    end

    return 0
end

Film.h_earliestLoadedFrame = function(self)
    for i=0,self.playhead do
        if self.data[i] == nil then
            return i
        end
    end
end

-- Hard reset on memory usage. Throws everything to the garbage collector except for
-- the most nearby stuff
Film.h_clearData = function(self)
    for i = 0, self.totalFrames do
        if i < self.playhead-10 or i > self.playhead+240 then
            if self.data[i] then
                self.framesInMemory = self.framesInMemory - 1
                self.data[i]:release()
                self.data[i] = nil
            end
        end
    end
end

-- If this offset from playhead is in bounds, return that.
-- Otherwise return bound we're up against
Film.h_boundedFromPlayhead = function(self,offset)
    local val = self.playhead + offset
    if val < 1 then 
        val = 1
    end
    if val > self.totalFrames then
        val = self.totalFrames
    end
    return val
end

return Film