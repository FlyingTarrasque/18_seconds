local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local oldScores = ice:loadBox("scores")

local scoreGroup = display.newGroup()
local thisGameScore = 0

local finalScore = display.newText("", halfW, 130, fontType, 30)
local lastScore  = display.newText("", halfW, 170, fontType, 30)
local playAgain  = display.newText("Tap to play again!", halfW, 200, fontType, 15)

finalScore.alpha = 0
playAgain.alpha  = 0

local blinkTimer

function playAgain:tap(event)
	local options = {effect = "fade", time = 500}

	storyboard.removeScene(scenesDir .. "level")
	storyboard.gotoScene(scenesDir .. "level", options)
end

Runtime:addEventListener('tap', playAgain)

function blinkRestartText()
	if(playAgain.alpha < 1) then
  	transition.to(playAgain, {time=490, alpha=1})
	else 
  	transition.to(playAgain, {time=490, alpha=0.1})
  end
end

function scene:createScene(event)
	local group = self.view 

	thisGameScore = tonumber(event.params["thisGameScore"])
	blinkTimer = timer.performWithDelay(500, function() pcall(blinkRestartText) end, 0)

	group:insert(finalScore)
	group:insert(lastScore)
	group:insert(playAgain)
end

local function showMedal(group, actualBestScore, thisGameScore)
	print("Show medall...")
end

function scene:enterScene( event )
	local group = self.view
	ratePopup:show()

	transition.to(finalScore, {time=200, alpha=1})

	local actualBestScore = oldScores:retrieve("best") or 0
	showMedal(group, actualBestScore, thisGameScore)
	
	if(actualBestScore < thisGameScore) then
		oldScores:store("best", thisGameScore)
		oldScores:save()

		finalScore.text = "Best score now: " .. tostring(thisGameScore)
	else
		lastScore.text  = "Score: " .. tostring(thisGameScore)
		finalScore.text = "Your best score: " .. tostring(actualBestScore)
	end	
end

function scene:exitScene( event )
	local group = self.view
end

function scene:destroyScene( event )
	local group = self.view
	
	Runtime:removeEventListener('tap', playAgain)
	pcall(timer.cancel(blinkTimer))
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