local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local physics = require "physics"
local score = display.newText("0", halfW, display.screenOriginY + 30, fontType, 50)
local scoreTimer

local gameEnded = false
local gameStarted = false

local lvl = require("utils.lvlsConfig")

local middleArea = display.newImage(imagesDir .. "middle_area.png", halfW, halfH, 375, 375)
middleArea:scale(lvl[currentLvl].midleAreaScale, lvl[currentLvl].midleAreaScale)

local largeHorizontalRect = display.newImage(imagesDir .. "largeHorizontalRect.png", 370, 380, 120, 25)
local largeVerticalRect = display.newImage(imagesDir .. "largeVerticalRect.png", 120, 380, 30, 75)
local fatRect = display.newImage(imagesDir .. "fatRect.png", 370, 110, 68, 50)
local square = display.newImage(imagesDir .. "square.png", 120, 110, 57, 57)

local finger = display.newCircle( halfW, halfH, 15 )
finger.alpha = 0
finger:setFillColor( 255,0,0 )
finger.name = "finger"

local function blinkFingerPosition()
	if(finger.alpha < 1) then
  	transition.to(finger, {time=490, alpha=1})
	else 
  	transition.to(finger, {time=490, alpha=0.1})
  end
end

local fingerPointTimer = timer.performWithDelay(500, function() pcall(blinkFingerPosition) end, 0)
local timeCountSeconds
local timeCountMilliseconds

left = display.newLine(0, screenH, 0, 0)
right = display.newLine(screenW, screenH, screenW + 2, 0)
up = display.newLine(0, 0, screenW, 0)
bottom = display.newLine(screenW, screenH, 0, screenH)

up.isVisible = false
left.isVisible = false
right.isVisible = false
bottom.isVisible = false

local seconds = 0
local function count1Seconds(event)
	seconds = seconds + 1
	milliseconds = 0
end

local milliseconds = 0
local function count71Milliseconnds(event)
	milliseconds = milliseconds + 0.071
	milliseconds = milliseconds % 1 --garantir que nao vai somar 1 segundo.
	score.text = seconds + milliseconds
end

local function finishGame()
	if(gameEnded == true)then
		return true
	end

	if(timeCountMilliseconds ~= nil) then
		timer.cancel(timeCountMilliseconds)
	end
	if(timeCountSeconds ~= nil) then
		timer.cancel(timeCountSeconds)
	end

	gameEnded = true

	local options = {
	  effect = "fade",
	  time = 500,
	  params = {thisGameScore = tonumber(score.text)}
	}

	storyboard.gotoScene(scenesDir .. "scoreBoard", options)
end

local function onTouchListener( event )
	local t = event.target

	local phase = event.phase
	if "began" == phase then
		if(gameStarted == false)then
			startGame()
		end
		local parent = t.parent
		parent:insert( t )
		display.getCurrentStage():setFocus( t, event.id )

		t.isFocus = true

		t.x0 = event.x - t.x
		t.y0 = event.y - t.y
	elseif "moved" == phase then
			t.x = event.x - t.x0
			t.y = event.y - t.y0
			limitMax = lvl[currentLvl].limitMax
			limitMin = lvl[currentLvl].limitMin
			if (t.y > limitMax or t.x > limitMax) or (t.y < limitMin or t.x < limitMin) then
				system.vibrate()
				finishGame()
			end
		elseif "ended" == phase or "cancelled" == phase then
			display.getCurrentStage():setFocus( t, nil )
			t.isFocus = false
			finishGame()
	end
	return true
end

local function addEventListeners()
	finger:addEventListener( "touch", onTouchListener )
end

local function removeEventListeners()
	finger:removeEventListener( "touch", onTouchListener )
end

local function addStaticBody(obj)
	physics.addBody(obj, 'static', {bounce = 1, filter = physicBodyFilter})
end

local function configAndStartPhysics()
	physics.start()
	physics.setGravity(0, gravity)
	
	addStaticBody(left)
	addStaticBody(right)
	addStaticBody(bottom)
	addStaticBody(up)
end

local function addDynamicBody(obj, bodyFilter)
	physics.addBody(obj, 'dynamic', {bounce = 1, filter = bodyFilter})
	obj.isFixedRotation = true
end

function scene:createScene(event)
	local group = self.view

	gameEnded = false
	gameStarted = false

	storyboard.removeScene(scenesDir .."scoreBoard")

	group:insert(middleArea)
	group:insert(score)
	group:insert(largeVerticalRect)
	group:insert(largeHorizontalRect)
	group:insert(square)
	group:insert(fatRect)
	group:insert(finger)

	addEventListeners()
	configAndStartPhysics()
	
	ads:show()
end

function move(obj)
	local direcaoX = math.random(-1,1)
	local direcaoY = math.random(-1,1)
	while (direcaoX == 0) do
		direcaoX = math.random(-1,1)
	end
	while (direcaoY == 0) do
		direcaoY = math.random(-1,1)
	end
	obj:setLinearVelocity(lvl[currentLvl].velocityx * direcaoX, lvl[currentLvl].velocityy * direcaoY)
end

local function onCollision( event )
	if(event.object1.name ~= nil or event.object2.name ~= nil) then
		system.vibrate()
		finishGame()
		return true
	end
end
 
Runtime:addEventListener("collision", onCollision)

function scene:enterScene(event)
	local group = self.view

	addDynamicBody(largeVerticalRect, { categoryBits = 2, maskBits = 3, groupIndex = -1 } )
	addDynamicBody(largeHorizontalRect, { categoryBits = 2, maskBits = 3, groupIndex = -1 } )
	addDynamicBody(square, { categoryBits = 2, maskBits = 3, groupIndex = -1 } )
	addDynamicBody(fatRect, { categoryBits = 2, maskBits = 3, groupIndex = -1 } )
	addStaticBody(finger, {categoryBits = 3, groupIndex = 1})
end

function startGame()
	move(square)
	move(fatRect)
	move(largeVerticalRect)
	move(largeHorizontalRect)
	
	timeCountSeconds = timer.performWithDelay( 1000, count1Seconds , 0 )
	timeCountMilliseconds = timer.performWithDelay( 71, count71Milliseconnds , 0 )
	timer.cancel(fingerPointTimer)
	finger.isVisible = false

	gameStarted = true
end	

function scene:exitScene(event)
	local group = self.view
	finger:removeSelf()
	removeEventListeners()
	timer.performWithDelay(50, function() physics.stop() end, 1)
end

function scene:destroyScene(event)
	local group = self.view

	package.loaded[physics] = nil
	physics = nil
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

scene:addEventListener( "createScene", scene )

scene:addEventListener( "enterScene", scene )

scene:addEventListener( "exitScene", scene )

scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene