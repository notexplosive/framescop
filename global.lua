require('status')
require('loadfile') -- <---- Should get rid of this one soon

KEYFRAME_LIST_GLOBAL = {}

-- Globals
CURRENT_TEXT_BOX = require "textbox"

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