local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local oldScores = ice:loadBox("scores")
local store = "best" .. currentLvl
local lvl = require("utils.lvlsConfig")

local thisGameScore = 0

local finalScore = display.newText("", halfW, 70, fontType, 70)
local lastScore  = display.newText("", halfW, 170, fontType, 70)
local playAgainBtn  = display.newText("Play Again!", halfW, halfH + 20, fontType, 40)
local leaderboardBtn = display.newText("Leaderboards", halfW, halfH + 140, fontType, 40)
local levelSelectBtn = display.newText("Level Select", halfW, halfH + 80, fontType, 40)
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

function levelSelectBtn:tap(event)
	if levelSelectBtn.taped then
		return true
	end
	levelSelectBtn.taped = true
	local callback = function()
		storyboard.removeAll()
		storyboard.gotoScene(scenesDir .. "levelSelect", "fade", 500)
	end

	blinkText(levelSelectBtn, callback)
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
		ads.show()
	end

	blinkText(playAgainBtn, callback)
	return true
end

function leaderboardBtn:tap(event)
	if leaderboardBtn.taped == true then
		return true
	end
	leaderboardBtn.taped = true
	local onDimissCallback = function() leaderboardBtn.taped = false end
	local callback = function() leaderboard:show(lvl, onDimissCallback) end
	blinkText(leaderboardBtn, callback)
	return true
end

function scene:createScene(event)
	local group = self.view 
	thisGameScore = tonumber(event.params["thisGameScore"])
	
	playAgainBtn:addEventListener('tap', playAgainBtn)
	leaderboardBtn:addEventListener('tap', leaderboardBtn)
	levelSelectBtn:addEventListener('tap', levelSelectBtn)

	group:insert(finalScore)
	group:insert(lastScore)
	group:insert(playAgainBtn)
	group:insert(leaderboardBtn)
	group:insert(levelSelectBtn)
	ads:show()
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
		leaderboard:setHighScore(thisGameScore,lvl)

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
	levelSelectBtn:removeEventListener('tap', levelSelectBtn)
	
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