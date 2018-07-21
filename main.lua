require('status')
local Film = require('film')
local Timeline = require('timeline')

currentFilm = nil
timeline = nil

function love.load(arg)
    
end

function love.update(dt)
    if currentFilm then
        print(currentFilm.playhead)
        currentFilm:update(dt)
        timeline:update(dt)
    end

    updateStatusText(dt)
end

love.keyboard.setKeyRepeat(true)
function love.keypressed(key, scancode, isrepeat)
    if key == 'space' and currentFilm == nil then
        currentFilm = Film.new('binaries/petscop8')
        timeline = Timeline.new(currentFilm)
    end

    if currentFilm then
        currentFilm.idleTimer = 0
        if key == 'right' then
            currentFilm:movePlayheadTo(currentFilm.playhead + 1)
        end

        if key == 'left' then
            currentFilm:movePlayheadTo(currentFilm.playhead - 1)
        end

        if key == 'd' then
            currentFilm:movePlayheadTo(currentFilm.playhead + 24)
        end
    end
end

function love.mousemoved(x,y,dx,dy,isTouch)
    if currentFilm then
        currentFilm.idleTimer = 0
    end
end

function love.mousepressed(x,y,button,isTouch)
    -- Playhead capture
    if button == 1 and timeline then
        if timeline.isHover then
            timeline.isPressed = true
        end
    end
end

function love.mousereleased(x,y,button,isTouch)
    -- Playhead release
    if button == 1 and timeline and timeline.isPressed then
        timeline:onRelease(x)
    end
end

function love.draw()
    if currentFilm then
        currentFilm:draw()
        love.graphics.print(currentFilm:status(),4,love.graphics.getHeight()-48,0)
        timeline:draw()
    end
    love.graphics.print(StatusText)
    love.graphics.circle('line',love.graphics.getWidth()-32,32,math.random(28,32), math.random(5,20))
end