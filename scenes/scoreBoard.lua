local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local oldScores = ice:loadBox("scores")
local store = "best" .. currentLvl
local lvl = require("utils.lvlsConfig")

local thisGameScore = 0

local finalScore = display.newText("", halfW, 70, fontType, 70)
local lastScore  = display.newText("", halfW, 170, fontType, 70)
local playAgainBtn  = display.newText("Play Again!", halfW, halfH + 20, fontType, 40)
local leaderboardBtn = display.newText("Highscores", halfW, halfH + 80, fontType, 40)
local menuBtn = display.newText("Menu Principal", halfW, halfH + 140, fontType, 40)
leaderboardBtn.taped = false

finalScore.alpha = 0

local blinkText = function(btn, fn)
	local callback = function()
		if(btn.alpha < 1) then
	  	transition.to(btn, {time=100, alpha=1})
		else 
	  	transition.to(btn, {time=100, alpha=0.1})
	  end
	end

  timer.performWithDelay(150, function() pcall(callback) end, 6)
  timer.performWithDelay(750, function() pcall(fn) end, 1)
end

function menuBtn:tap(event)
	if menuBtn.taped then
		return true
	end
	menuBtn.taped = true
	local callback = function()
		storyboard.removeAll()
		storyboard.gotoScene(scenesDir .. "menu", "fade", 500)
	end

	blinkText(menuBtn, callback)
	return true
end

function playAgainBtn:tap(event)
	if playAgainBtn.taped then
		return true
	end
	playAgainBtn.taped = true
	local callback = function()
		local options = {effect = "fade", time = 500}

		storyboard.removeScene(scenesDir .. "level")
		storyboard.gotoScene(scenesDir .. "level", options)
	end

	blinkText(playAgainBtn, callback)
	return true
end

function leaderboardBtn:tap(event)
	if leaderboardBtn.taped == true then
		return true
	end
	leaderboardBtn.taped = true
	local callback = function() 
		local enableButton = function() leaderboardBtn.taped = false end
		local leaderboarListener = function() gameNetwork.show("leaderboards", {listener = enableButton }) end
		if gameNetwork.request("isConnected") then
			leaderboarListener()
		else
			gameNetwork.request("login",{
		    userInitiated = true,
		    listener = leaderboarListener
			});
		end
	end
	blinkText(leaderboardBtn, callback)
	return true
end

function scene:createScene(event)
	local group = self.view 
	thisGameScore = tonumber(event.params["thisGameScore"])
	
	playAgainBtn:addEventListener('tap', playAgainBtn)
	leaderboardBtn:addEventListener('tap', leaderboardBtn)
	menuBtn:addEventListener('tap', menuBtn)

	group:insert(finalScore)
	group:insert(lastScore)
	group:insert(playAgainBtn)
	group:insert(leaderboardBtn)
	group:insert(menuBtn)
end

local function showMedal(group, actualBestScore, thisGameScore)
	print("Show medall...")
end

function scene:enterScene( event )
	local group = self.view
	ratePopup:show()
	transition.to(finalScore, {time=200, alpha=1})

	local actualBestScore = oldScores:retrieve(store) or 0
	showMedal(group, actualBestScore, thisGameScore)
	
	if(actualBestScore < thisGameScore) then
		gameNetwork.request("setHighScore", {
		  localPlayerScore = {
		    category = lvl[currentLvl].leaderBoardId, -- Id of the leaderboard to submit the score into
		    value = thisGameScore -- The score to submit
		  }
		})

		oldScores:store(store, thisGameScore)
		oldScores:save()
		finalScore.text = "New Best Score!"
		lastScore.text = tostring(thisGameScore)
	else
		lastScore.text  = "Score: "..tostring(thisGameScore)
		finalScore.text = "Best: "..tostring(actualBestScore)
	end	
end

function scene:exitScene( event )
	local group = self.view
end

function scene:destroyScene( event )
	local group = self.view

	playAgainBtn:removeEventListener('tap', playAgainBtn)
	leaderboardBtn:removeEventListener('tap', leaderboardBtn)
	menuBtn:removeEventListener('tap', menuBtn)
	
	group:removeSelf()
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