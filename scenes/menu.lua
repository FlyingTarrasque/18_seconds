local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local flags = ice:loadBox("flags")

local menuPrincipal = display.newGroup()
local playBtn = display.newText("START!", halfW, halfH + 80, fontType, 40)
local howToPlayBtn = display.newText("How to play", halfW, halfH + 140, fontType, 40)
local leaderboardBtn = display.newText("Leaderboards", halfW, halfH + 200, fontType, 40)

menuPrincipal:insert(playBtn)
menuPrincipal:insert(leaderboardBtn)
menuPrincipal:insert(howToPlayBtn)

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
	--playBtn.isVisible = false
	local onDimissCallback = function() leaderboardBtn.taped = false end
	blinkText(leaderboardBtn, leaderboard:show(onDimissCallback))
	return true
end

local startGame = function(event)
	if playBtn.taped then
		return true
	end
	
	playBtn.taped = true
	local callback = function()
		local tutorialCompleto = flags:retrieve("tutorial") or false
		if(tutorialCompleto) then
			storyboard.gotoScene(scenesDir .. "levelSelect", "slideLeft", 500 ) 
		else
			storyboard.gotoScene(scenesDir .. "tutorialPassoUm", "slideLeft", 500 ) 	
		end
		
	end
	blinkText(playBtn, callback)
	return true
end

local showTutorial = function(event)
	local callback = function()
		storyboard.gotoScene(scenesDir .. "tutorialPassoUm", "slideLeft", 500 ) 
	end
	blinkText(howToPlayBtn,callback)
end


function scene:createScene( event )
	local group = self.view

	_G.title = display.newText("18 Sec.", halfW, 125, fontType, 80)

	group:insert(menuPrincipal)
	-- group:insert(leaderboardBtn)
	-- group:insert(howToPlayBtn)
end

function scene:enterScene( event )
	local group = self.view

	playBtn:addEventListener('tap', startGame)
	leaderboardBtn:addEventListener('tap', showLeaderboard)
	howToPlayBtn:addEventListener('tap',showTutorial)
end

function scene:willEnterScene( event )
	transition.to(title, {time=300,x=title.x, y=125, delay=300})
end

function scene:exitScene( event )
	local group = self.view

	-- menuPrincipal:removeSelf()

	playBtn:removeEventListener('tap', startGame)
	leaderboardBtn:removeEventListener('tap', showLeaderboard)
	howToPlayBtn:removeEventListener('tap',showTutorial)
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

scene:addEventListener("willEnterScene",scene)
-----------------------------------------------------------------------------------------

return scene