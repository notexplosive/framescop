-- We're calling this "Film" because it's a series of static images played back
-- to make it look like it's a contiguous video.

require('stringutil')
local readFile = require('readfile')
local Keyframe = require('keyframe')
local Timeline = require('timeline')

-- The binary most likely isn't at original framerate (30), so we scale up the "current frame" we're on
local realFPS = 30

local Film = {}
Film.__index = Film

Film.new = function(dirPath)
    local self = {}
    setmetatable(self, Film)

    local split = dirPath:split('/')
    FILE_NAME = split[#split]
    updateWindowTitle()

    self.playhead = 1

    local lines = readFile(dirPath .. '/data.txt')
    self.title = lines[1]
    self.totalFrames = tonumber(lines[2])
    self.fps = tonumber(lines[3])
    self.path = dirPath
    self.warning = false
    self.warningTimer = 0
    self.idleTimer = 1
    self.framesInMemory = 0
    self.cachedFrontier = 0
    self.preloading = false
    self.playRealTime = false
    self.realTime = 0
    self.timeline = Timeline.new(self)

    if self.title == nil or self.totalFrames == nil then
        printst('Data file at ' ..  dirPath .. ' is either corrupted or missing something')
    end

    self.data = {}
    self:h_loadAt(1,60)

    Keyframe.deserialize(self)

    return self
end

Film.update = function(self,dt)
    -- This ticks up every frame but gets reset when a key is pressed
    self.idleTimer = self.idleTimer + dt
    self.preloading = false

    local FPS = 15

    if self.playRealTime then
        self.idleTimer = 0
        self.realTime = self.realTime + dt * FPS
        self.playhead = math.floor(self.realTime) + 1
    else
        self.realTime = self.playhead
    end

    if not self.data[self.playhead + 10] then
        printst('Loading more frames...')
        self.warning = true
        self.warningTimer = self.warningTimer + dt

        -- Warning enables the red border. If it's been red for 1 second, just load the next
        -- chunk, we warned them so they will expect the lag.
        if self.warningTimer > .25 then
            self:h_loadAt(self:h_nextUnloadedFromPlayhead(),15)
            self.warningTimer = 0
        end
    else
        self.warning = false
        self.warningTimer = 0
    end

    if self.idleTimer > 1 then
        if self:h_loadAt(self:h_nextUnloadedFromPlayhead(),15) then
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
        self:h_loadAt(self.playhead-backFrames,15)
    end

    -- TODO: This could be a lot smarter.
    if self.framesInMemory > 400 then
        self:h_clearData()
    end

    self.timeline:update(dt)
end

Film.draw = function(self)
    love.graphics.draw(self:getFrameImage(self.playhead))
    if self.warning then
        self.playRealTime = false
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle('line',0,0,love.graphics.getDimensions())
        love.graphics.setColor(1,1,1)
    end

    if self.preloading then
        love.graphics.setColor(0,1,0)
        love.graphics.rectangle('line',0,0,love.graphics.getDimensions())
        love.graphics.setColor(1,1,1)
    end

    if self.playRealTime then
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle('line',0,0,love.graphics.getDimensions())
    end

    self.timeline:draw()
end

Film.getFrameImage = function(self,index)
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
    return 'time: ' .. self:timeString() .. '\t'
    .. self.framesInMemory .. ' images in memory' .. '\t'
end

-- TODO: this conversion doesn't quite work right if the framerate isn't 15
-- This isn't a huge problem because all of the binaries will be 15 fps
Film.timeString = function(self,x)
    if x == nil then 
        x = self.playhead
    end
    local video_frame = (x-1) * (realFPS / self.fps)
    local seconds = math.floor(video_frame/realFPS)
    return string.format("%02d",math.floor(seconds/60)) .. ':'
    .. string.format("%02d",seconds%60) .. ';' 
    .. string.format("%02d",video_frame%realFPS)
end

Film.timeStringToFrames = function(self,timeString)
    if timeString == nil then 
        timeString = self:timeString()
    end

    local tsSplitOnColon = timeString:split(':')
    local minutes = tsSplitOnColon[1]
    local seconds = tsSplitOnColon[2]:split(';')[1] + minutes * 60
    local video_frame = tonumber(timeString:split(';')[2]) / 2
    
    local frames = seconds * self.fps + video_frame + 1
    print('read ' .. timeString .. ' as ' .. frames)
    return frames
end

Film.getTrackPath = function(self)
    return FILE_NAME .. '_input_track' .. '.csv'
end

Film.getFullTrackPath = function(self)
    return love.filesystem.getAppdataDirectory() .. '/' .. self:getTrackPath()
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