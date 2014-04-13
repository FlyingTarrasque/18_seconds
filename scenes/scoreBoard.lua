local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local oldScores = ice:loadBox("scores")

local thisGameScore = 0

local finalScore = display.newText("", halfW, 110, fontType, 70)
local lastScore  = display.newText("", halfW, 170, fontType, 70)
local playAgainBtn  = display.newText("Play Again!", halfW, halfH + 20, fontType, 40)
local submitScoreBtn  = display.newText("Submit this score!", halfW, halfH + 80, fontType, 40)
local leaderboardBtn = display.newText("Highscores", halfW, halfH + 140, fontType, 40)

finalScore.alpha = 0

local blinkText = function(btn, fn)
	local callback = function()
		if(btn.alpha < 1) then
	  	transition.to(btn, {time=100, alpha=1})
		else 
	  	transition.to(btn, {time=100, alpha=0.1})
	  end
	end

  timer.performWithDelay(150, function() pcall(callback) end, 5)
  timer.performWithDelay(750, function() pcall(fn) end, 1)
end

function submitScoreBtn:tap(event)
	local callback = function()
		local submitScore = function()
			gameNetwork.request("setHighScore", {
			  localPlayerScore = {
			    category = leaderboardId, -- Id of the leaderboard to submit the score into
			    value = thisGameScore -- The score to submit
			  }
			})
		end

		if gameNetwork.request("isConnected") then
			submitScore()
		else
			gameNetwork.request("login",{
		    userInitiated = true,
		    listener = submitScore
			});
		end
	end

	blinkText(submitScoreBtn, callback)
	return true
end

function playAgainBtn:tap(event)
	print("play again")
	local callback = function()
		local options = {effect = "fade", time = 500}

		storyboard.removeScene(scenesDir .. "level")
		storyboard.gotoScene(scenesDir .. "level", options)
	end

	blinkText(playAgainBtn, callback)
	return true
end

function leaderboardBtn:tap(event)
	local callback = function() 
		local leaderboarListener = function() gameNetwork.show("leaderboards") end
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
	print("leaderboard")
	blinkText(leaderboardBtn, callback)
	return true
end

playAgainBtn:addEventListener('tap', playAgainBtn)
submitScoreBtn:addEventListener('tap', submitScoreBtn)
leaderboardBtn:addEventListener('tap', leaderboardBtn)

function scene:createScene(event)
	local group = self.view 
	thisGameScore = tonumber(event.params["thisGameScore"])
	--playAgain()

	group:insert(finalScore)
	group:insert(lastScore)
	group:insert(playAgainBtn)
	group:insert(leaderboardBtn)
	group:insert(submitScoreBtn)
end

local function showMedal(group, actualBestScore, thisGameScore)
	print("Show medall...")
end

function scene:enterScene( event )
	local group = self.view
	ratePopup:show()
	gameNetwork.show( "leaderboards" )

	transition.to(finalScore, {time=200, alpha=1})

	local actualBestScore = oldScores:retrieve("best") or 0
	showMedal(group, actualBestScore, thisGameScore)
	
	if(actualBestScore < thisGameScore) then
		oldScores:store("best", thisGameScore)
		oldScores:save()

		local function postScoreSubmit( event )
   		--whatever code you need following a score submission...
   		return true
		end

		finalScore.text = "Best score now: " .. tostring(thisGameScore)
	else
		lastScore.text  = "Score: " .. tostring(thisGameScore)
		finalScore.text = "Best score: " .. tostring(actualBestScore)
	end	
end

function scene:exitScene( event )
	local group = self.view
end

function scene:destroyScene( event )
	local group = self.view
	--print("destroy")
	playAgainBtn:removeEventListener('tap', playAgain)
	submitScoreBtn:removeEventListener('tap', submitScore)
	leaderboardBtn:removeEventListener('tap', showLeaderboard)
	
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