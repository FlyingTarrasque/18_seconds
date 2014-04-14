local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local title = display.newGroup()
title:insert(display.newText("19 Sec.", halfW, 125, fontType, 80))
--title:insert(display.newText("Finger", halfW, 180, fontType, 80))

local playBtn = display.newText("START!", halfW, halfH + 80, fontType, 40)
local leaderboardBtn = display.newText("Highscores", halfW, halfH + 140, fontType, 40)
leaderboardBtn.taped = false

local blinkText = function(btn, fn)
	local callback  = function()
		if(btn.alpha < 1) then
	  	transition.to(btn, {time=100, alpha=1})
		else 
	  	transition.to(btn, {time=100, alpha=0.1})
	  end
	end

  timer.performWithDelay(150, function() pcall(callback) end, 6)
  timer.performWithDelay(750, function() pcall(fn) end, 1)
end

local showLeaderboard = function(event)
	if leaderboardBtn.taped == true then
		return true
	end
	leaderboardBtn.taped = true
	local callback = function() 
		local enableButton = function() 
			print("enabling...")
			leaderboardBtn.taped = false 
		end
		local leaderboarListener = function() gameNetwork.show("leaderboards", {listener = enableButton }) end
		if gameNetwork.request("isConnected") then
			leaderboarListener()
		else
			gameNetwork.request("login",{
		    userInitiated = true,
		    listener = leaderboarListener
			});
		end
		playBtn.isVisible = true
	end
	playBtn.isVisible = false
	blinkText(leaderboardBtn, callback)
	return true
end

local startGame = function(event)
	if playBtn.taped then
		return true
	end
	--storyboard.showOverlay( "pauseoverlay" ,{effect = "fade"  ,  params ={levelNum = "level01"}, isModal = true} )
	playBtn.taped = true
	local callback = function()
		storyboard.gotoScene(scenesDir .. "level", "slideUp", 500 ) 
	end
	leaderboardBtn.isVisible = false
	blinkText(playBtn, callback)
	return true
end

playBtn:addEventListener('tap', startGame)
leaderboardBtn:addEventListener('tap', showLeaderboard)

function scene:createScene( event )
	local group = self.view

	group:insert(title)
	group:insert(playBtn)
	group:insert(leaderboardBtn)
end

function scene:enterScene( event )
	local group = self.view
end

function scene:exitScene( event )
	local group = self.view

	title:removeSelf()

	playBtn:removeEventListener('tap', startGame)
	leaderboardBtn:removeEventListener('tap', showLeaderboard)
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