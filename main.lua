require('status')
local Film = require('film')

currentFilm = nil

function love.load(arg)
    
end

function love.update(dt)
    if currentFilm then
        currentFilm:update(dt)
    end

    updateStatusText(dt)
end

love.keyboard.setKeyRepeat(true)
function love.keypressed(key, scancode, isrepeat)
    if key == 'space' and currentFilm == nil then
        currentFilm = Film.new('binaries/petscop8')
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

function love.draw()
    if currentFilm then
        currentFilm:draw()
        love.graphics.print(currentFilm:status(),0,584,0)

        love.graphics.setColor(0, 1, 0, 0.4)
        love.graphics.rectangle('fill',0,love.graphics.getHeight()-32,love.graphics.getWidth()*currentFilm.playhead/currentFilm.totalFrames,32)
        love.graphics.setColor(0, 1, 1, 0.1)
        love.graphics.rectangle('fill',
            love.graphics.getWidth()*currentFilm.playhead/currentFilm.totalFrames,
            love.graphics.getHeight()-32,
            love.graphics.getWidth()*(currentFilm.cachedFrontier-currentFilm.playhead)/currentFilm.totalFrames,
            32)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle('line',0,love.graphics.getHeight()-32,love.graphics.getWidth(),32)
    end
    love.graphics.print(StatusText)
    love.graphics.circle('line',love.graphics.getWidth()-32,32,math.random(28,32), math.random(5,20))
end