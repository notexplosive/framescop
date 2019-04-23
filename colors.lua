love.graphics.setColor(1 / 255, 31 / 255, 75 / 255)
love.graphics.setColor(0 / 255, 91 / 255, 150 / 255)
love.graphics.setColor(100 / 255, 151 / 255, 177 / 255)

-- Color constants
function white()
    return 1, 1, 1, 1
end
function black()
    return 0, 0, 0, 1
end
function gray()
    return 0.5, 0.5, 0.5, 1
end
function darkgray()
    return 0.25, 0.25, 0.25, 1
end
function lightgray()
    return 0.75, 0.75, 0.75, 1
end

-- Keyframe UI
function toggledButtonHighlightColor()
    return 0.75, 0.75, 1, 0.75
end
function highlightedButtonColor()
    return 0, 0, 1, 0.5
end

-- Buttons (like "Play", not those on the keyframe ui)
function buttonHighlightColor()
    return 0 / 255, 91 / 255, 150 / 255, 0.75
end
function buttonBackgroundColor()
    return 100 / 255, 151 / 255, 177 / 255, 0.75
end

-- General UI
function uiBackgroundColor()
    return 0, 0, 0, 0.5
end

-- Notes
function notesBackgroundColor()
    return 0.2, 0.2, 1, 0.5
end

-- Timeline
function timelineKeyframeMarkColor()
    return 1, 1, 1, 0.25
end
function timelineColor()
    return 0, 1, 0, 0.4
end
function timelineBackgroundColor()
    return 0, 0, .25, .1
end
function timelineLoadedBufferColor()
    return 0, 1, 1, 0.4
end

-- Keyframe ticker
function keyframeTickerBGColor()
    return 0.75, 0.25, 0
end
function keyframeTickerBGSecondaryColor()
    return 1, 0.5, 0
end
function keyframeTickerCurrentFrameColor()
    return 0, 1, 0
end
function keyframeTickerCurrentFrameKeyColor()
    return 0.75, 1, 0.25
end
