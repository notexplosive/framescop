local Button = {}

function Button.normal(label, x, y, width, height, action)
    if action == nil then
        action = ""
    end
    local oldFont = love.graphics.getFont()
    local mx, my = love.mouse.getPosition()
    love.graphics.setColor(buttonBackgroundColor())
    if mx > x and mx < x + width and my > y and my < y + height then
        love.graphics.setColor(buttonHighlightColor())
        -- You wanna see something crazy? Go find what this string is used for
        CURRENT_MOUSEOVER_TARGET = "Button_" .. action
        if love.mouse.isDown(0) then
        end
    end
    love.graphics.setFont(LOVEdefaultFont)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(black())
    love.graphics.print(label, x + 3, y + 1)
    love.graphics.rectangle("line", x, y, width, height)

    love.graphics.setFont(oldFont)
    love.graphics.setColor(white())
end

return Button
