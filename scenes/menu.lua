-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local title = display.newGroup()
title:insert(display.newText("18 sec", halfW, 140, fontType, 40))

local playBtn = display.newText("Tap to START!", halfW, 100, fontType, 20)
local blickTimer = 0

local blinkStartText = function()
	if(playBtn.alpha < 1) then
  	transition.to(playBtn, {time=490, alpha=1})
	else 
  	transition.to(playBtn, {time=490, alpha=0.1})
  end
end

local startGame = function(event)
	--storyboard.gotoScene(scenesDir .. "level1", "fade", 500 )
	return true
end

Runtime:addEventListener('tap', startGame)

function scene:createScene( event )
	ads:show()
	local group = self.view

	playBtn.x = display.contentWidth*0.5
	playBtn.y = display.contentHeight - 125
	blinkTimer = timer.performWithDelay(500, blinkStartText, 0)

	group:insert(title)
	group:insert(playBtn)
end

function scene:enterScene( event )
	local group = self.view
end

function scene:exitScene( event )
	local group = self.view

	title:removeSelf()
	ads:hide()

	Runtime:removeEventListener('tap', startGame)
	timer.cancel(blinkTimer)
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene