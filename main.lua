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
require("utils.gameNetwork")
require("utils.ratePopup")

local function systemEvents( event )
   print("systemEvent " .. event.type)
   if ( event.type == "applicationSuspend" ) then
      print( "suspending..........................." )
   elseif ( event.type == "applicationResume" ) then
      print( "resuming............................." )
   elseif ( event.type == "applicationExit" ) then
      print( "exiting.............................." )
   elseif ( event.type == "applicationStart" ) then
      ads:show()  --login to the network here
   end
   return true
end
Runtime:addEventListener( "system", systemEvents )

-- include the Corona "storyboard" module
local storyboard = require "storyboard"

-- load menu screen
storyboard.gotoScene(scenesDir .. "menu")