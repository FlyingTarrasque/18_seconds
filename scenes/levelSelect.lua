local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local menuLvl = display.newGroup()
local easy = display.newText("Easy", halfW, halfH + 80, fontType, 40)
easy.name = 'easy'
local normal = display.newText("Normal", halfW, halfH + 140, fontType, 40)
normal.name = 'normal'
local hard = display.newText("Hard", halfW, halfH + 200, fontType, 40)
hard.name = 'hard'
menuLvl:insert(easy)
menuLvl:insert(normal)
menuLvl:insert(hard)

normal.alpha = 0.5
hard.alpha = 0.5

local oldScores = ice:loadBox("scores")

local function getScore(lvl)
	return oldScores:retrieve("best" .. lvl) or 0
end

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

local startGame = function(event)
	local me = event.target

	if me.selected then
		return true
	end
	me.selected = true
	
	currentLvl = me.name
	local callback = function()
		storyboard.gotoScene(scenesDir .. "level", "fade", 500 ) 
	end
	blinkText(me, callback)
	return true
end

easy:addEventListener('tap', startGame)

function scene:createScene( event )
	local group = self.view
	print(title)
	if title == nil then
		title = display.newText("18 Sec.", halfW, 125, fontType, 80)
	end

	if(getScore("easy") >= 18) then
		normal:addEventListener('tap', startGame)
		normal.alpha = 1
	end
	if (getScore("normal") >= 18) then
		hard:addEventListener('tap', startGame)
		hard.alpha = 1
	end
	
	group:insert(menuLvl)
end

function scene:enterScene( event )
	local group = self.view

end

function scene:willEnterScene( event )
	transition.to(title, {time=300,x=title.x, y=125, delay=300})
end

function scene:exitScene( event )
	local group = self.view

	menuLvl:removeSelf()
	title:removeSelf()
	title = nil

	easy:removeEventListener('tap', startGame)
	normal:removeEventListener('tap', startGame)
	hard:removeEventListener('tap', startGame)
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