require('status')
require('loadfile')

-- General state
KEYFRAME_LIST_GLOBAL = {}
CURRENT_TEXT_BOX = require "textbox"
CURRENT_MOUSEOVER_TARGET = ''
CURRENT_MODE = 'default'
MAP_ON = false
MAP_LOCK = true
UI_FLIP = false

-- Image extraction
THREAD_POOL = {}
CURRENT_FRAMES_DIR = ''
CURRENT_FRAMES_INDEX = 1

-- God Objects
currentFilm = nil

-- File Management
FileMgr = require('file_manager')
DELIM = '\t'
FILE_NAME = 'empty'
APP_NAME = 'Framescop V1.5'
CURRENT_AUTHOR = ''

-- Fonts
LOVEdefaultFont = love.graphics:getFont()
BigFont = love.graphics.newFont(24)

-- Images
BUTTON_SPRITE_SHEET = love.graphics.newImage('buttons.png')
BUTTON_SPRITES = {}
BUTTON_SPRITES['direction'] = 
    love.graphics.newQuad(0,0,32,32,BUTTON_SPRITE_SHEET:getDimensions())
BUTTON_SPRITES['x'] =
    love.graphics.newQuad(32,0,32,32,BUTTON_SPRITE_SHEET:getDimensions())
BUTTON_SPRITES['circle'] =
    love.graphics.newQuad(64,0,32,32,BUTTON_SPRITE_SHEET:getDimensions())
BUTTON_SPRITES['triangle'] =
    love.graphics.newQuad(96,0,32,32,BUTTON_SPRITE_SHEET:getDimensions())
BUTTON_SPRITES['square'] =
    love.graphics.newQuad(128,0,32,32,BUTTON_SPRITE_SHEET:getDimensions())

function drawButtonGraphic(buttonName,x,y,angle)
    love.graphics.draw(BUTTON_SPRITE_SHEET,BUTTON_SPRITES[buttonName],x,y,angle,1,1,16,16)
end

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

local oldErrorHandler = love.errorhandler

function love.errorhandler(msg)
    oldErrorHandler(msg)
    Actions.save()
end