local ExtractAnimation = {}
ExtractAnimation.index = 1
ExtractAnimation.list = {}
ExtractAnimation.timeSpentStalled = 0

function ExtractAnimation.new(imageName)
    local image = {}
    image.data = love.graphics.newImage(imageName)
    image.x = love.graphics.getWidth()/2
    image.y = love.graphics.getHeight()/2
    image.vel = {x=math.random(20)-10,y=-math.random(15) - 15}
    image.r = 0
    image.scale = 1
    image.theta = (math.random(628)-314) / 1000
    ExtractAnimation.list[ExtractAnimation.index] = image
    ExtractAnimation.index = ExtractAnimation.index % 50 + 1
    ExtractAnimation.timeSpentStalled = 0
end

function ExtractAnimation.draw()
    for i,image in ipairs(ExtractAnimation.list) do
        love.graphics.draw(image.data,image.x,image.y,image.r,image.scale,image.scale,image.data:getWidth()/2,image.data:getHeight()/2)
        image.x = image.x + image.vel.x
        image.y = image.y + image.vel.y
        image.vel.y = image.vel.y + 1
        image.r = image.r + image.theta
        image.scale = image.scale * 0.95
    end

    -- redraw the very last one
    local image = ExtractAnimation.list[ExtractAnimation.index-1]
    if image then
        love.graphics.draw(image.data,image.x,image.y,0,1,1,image.data:getWidth()/2,image.data:getHeight()/2)
    end

    ExtractAnimation.timeSpentStalled = ExtractAnimation.timeSpentStalled + 1

    if ExtractAnimation.timeSpentStalled > 120 then
        CURRENT_FRAMES_DIR = ''
        CURRENT_FRAMES_INDEX = 0
    end
end

return ExtractAnimation