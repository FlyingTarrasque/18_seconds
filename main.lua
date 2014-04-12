-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
require("constants")

display.setStatusBar(display.HiddenStatusBar)

local background = display.newImageRect(imagesDir .. "background.png", display.contentWidth, display.actualContentHeight)
background.anchorX, background.anchorY = 0, 0
background.x, background.y = display.screenOriginX, display.screenOriginY
require("utils.ads")
require("utils.ice")
require("utils.ratePopup")

-- include the Corona "storyboard" module
local storyboard = require "storyboard"

-- load menu screen
storyboard.gotoScene(scenesDir .. "menu")