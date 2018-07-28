require('status')
require('loadfile') -- <---- Should get rid of this one soon

KEYFRAME_LIST_GLOBAL = {}

-- Globals
-- TODO: extract text box related code into its own file
-- This would include globals like cursorTimer and TEXT_BOX_CURSOR
CURRENT_TEXT_BOX = {}
TEXT_BOX_CURSOR = '|'

CURRENT_TEXT_BOX.clear = function()
    local ret = CURRENT_TEXT_BOX.body
    CURRENT_TEXT_BOX.on = false
    CURRENT_TEXT_BOX.body = ''
    CURRENT_TEXT_BOX.submitted = false
    return ret
end

CURRENT_TEXT_BOX.submit = function()
    -- Flags itself as submitted, someone else needs to listen for this and clear
    CURRENT_TEXT_BOX.submitted = true
end

CURRENT_TEXT_BOX.clear()

currentFilm = nil -- input.lua needs currentFilm exposed, might retool this
FileMgr = require('file_manager')
DELIM = '\t'
FILE_NAME = 'empty'
APP_NAME = 'Framescop V1.0'
CURRENT_AUTHOR = ''

-- Fonts
LOVEdefaultFont = love.graphics:getFont()
BigFont = love.graphics.newFont(24)

-- Window setup
function updateWindowTitle()
    local easterEgg = {"Framescop kid very smart","Remember being framescop?",
    "That's a dead framescop",
    "Some things, you just can't framescop",
    "Framescop: Rainbow Tool",
    "You're in the other framescop too!"}
    local title = easterEgg[love.math.random(1,#easterEgg)]
    love.window.setTitle(title .. ' - ' .. FILE_NAME)
end