local ctlStateEnum = require('controller_state')
local Keyframe = require('keyframe')
Actions = {}

Actions.stepRight = function()
    currentFilm:movePlayheadTo(currentFilm.playhead + 1)
end

Actions.stepLeft = function()
    currentFilm:movePlayheadTo(currentFilm.playhead - 1)
end

function appendToKeyframe(ctlStateKey)
    local mask = ctlStateEnum[ctlStateKey]
    Keyframe.getCurrentKeyframe(currentFilm,true):flipState(mask)
end

Actions.upToKeyframe = function()
    appendToKeyframe('up')
end

Actions.downToKeyframe = function()
    appendToKeyframe('down')
end

Actions.leftToKeyframe = function()
    appendToKeyframe('left')
end

Actions.rightToKeyframe = function()
    appendToKeyframe('right')
end

Actions.jumpRight = function()
    local frames = Keyframe.getAll(currentFilm)
    for i=1,#frames do
        if frames[i].time > currentFilm.playhead then
            currentFilm:movePlayheadTo(frames[i].time)
            return
        end
    end

    currentFilm:movePlayheadTo(currentFilm.totalFrames)
end

Actions.jumpLeft = function()
    local frames = Keyframe.getAll(currentFilm)
    for i=#frames,i,-1 do
        print(frames[i].time)
        if frames[i].time < currentFilm.playhead then
            currentFilm:movePlayheadTo(frames[i].time)
            return
        end
    end

    currentFilm:movePlayheadTo(1)
end

return Actions