-- Actions that get assigned to keys in keybind.lua
local ctlStateEnum = require('controller_state')
local Keyframe = require('keyframe')
Actions = {}

Actions.save = FileMgr.save

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

for i,buttonName in ipairs(ctlStateEnum.ALL_BUTTONS) do
    Actions['toggle'..buttonName] = function()
        appendToKeyframe(buttonName)
    end
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
    for i=#frames,1,-1 do
        if frames[i].time < currentFilm.playhead then
            currentFilm:movePlayheadTo(frames[i].time)
            return
        end
    end

    currentFilm:movePlayheadTo(1)
end

Actions.toggleRealtimePlayback = function()
    currentFilm.playRealTime = not currentFilm.playRealTime
    if currentFilm.playRealTime then
        printst('Play')
    else
        printst('Paused')
    end
end

Actions.deleteCurrentKeyframe = function()
    if Keyframe.list[currentFilm.playhead] then
        printst('Deleted keyframe')
        Keyframe.list[currentFilm.playhead] = nil
    end
end

function Actions.openNotes()
    CURRENT_TEXT_BOX.on = true
    local kf = Keyframe.getCurrentKeyframe(currentFilm,false)
    if kf then
        CURRENT_TEXT_BOX.body = kf.notes
    end
    CURRENT_MODE = 'notes'
end

function Actions.closeNotes()
    CURRENT_TEXT_BOX.submit()
    local notes = CURRENT_TEXT_BOX.clear()
    if notes == '' then
        notes = '-'
    end
    Keyframe.getCurrentKeyframe(currentFilm,true).notes = notes
    CURRENT_MODE = 'default'
end

return Actions