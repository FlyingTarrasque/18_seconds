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
local migrations = require("utils.migrations")

local storyboard = require "storyboard"
_G.onSuspending = nil
local function systemEvents( event )
   print("systemEvent " .. event.type)
   if ( event.type == "applicationSuspend" ) then
      print( "suspending..........................." )
   elseif ( event.type == "applicationResume" ) then
      if(onSuspending)then
         onSuspending()
         onSuspending = nil
      end
      storyboard.removeAll()
   elseif ( event.type == "applicationExit" ) then
      print( "exiting.............................." )
   elseif ( event.type == "applicationStart" ) then
      local migrations = require("utils.migrations")
      migrations()
      ads:show()  --login to the network here
   end
   return true
end
Runtime:addEventListener( "system", systemEvents )

-- load menu screen
storyboard.gotoScene(scenesDir .. "menu")