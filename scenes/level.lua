local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local physics = require "physics"
--physics.setDrawMode("hybrid")
local score = 0

local gameStarted = false

local middleArea = display.newRect(halfW, halfH, 375, 375)
local largeHorizontalRect = display.newRect(middleArea.x + 120, middleArea.y + 130, 120, 25)
largeHorizontalRect:setFillColor(0, 0, 30)

local largeVerticalRect = display.newRect(middleArea.x - 130, middleArea.y + 130, 30, 75)
largeVerticalRect:setFillColor(0, 0, 30)

local fatRect = display.newRect(middleArea.x + 120, 110, 68, 50)
fatRect:setFillColor(0, 0, 30)

local square = display.newRect(120, 110, 57, 57)
square:setFillColor(0, 0, 30)

local finger = display.newCircle( halfW, halfH, 20 )
finger:setFillColor( 255,0,0 )
finger.name = "finger"

left = display.newLine(0, screenH, 0, 0)
right = display.newLine(screenW, screenH, screenW + 2, 0)
up = display.newLine(0, 0, screenW, 0)
bottom = display.newLine(screenW, screenH, 0, screenH)

up.isVisible = false
left.isVisible = false
right.isVisible = false
bottom.isVisible = false

local function onTouchListener( event )
	local t = event.target

	local phase = event.phase
	if "began" == phase then
		local parent = t.parent
		parent:insert( t )
		display.getCurrentStage():setFocus( t, event.id )

		t.isFocus = true

		t.x0 = event.x - t.x
		t.y0 = event.y - t.y
	elseif t.isFocus then
		if "moved" == phase then
			t.x = event.x - t.x0
			t.y = event.y - t.y0
		elseif "ended" == phase or "cancelled" == phase then
			display.getCurrentStage():setFocus( t, nil )
			t.isFocus = false
		end
	end
	return true
end

function collisionListener(event)
	
end

local function addEventListeners()
	finger:addEventListener( "touch", onTouchListener )
	--Runtime:addEventListener('enterFrame', resizeCallback)
	--Runtime:addEventListener('touch', onBarMove)
	--Runtime:addEventListener('collision', collisionListener)
end

local function removeEventListeners()
	--Runtime:removeEventListener('enterFrame', resizeCallback)
	--Runtime:removeEventListener('touch', onBarMove)
	--Runtime:removeEventListener('collision', collisionListener)
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

	storyboard.removeScene(scenesDir .."scoreBoard")

	group:insert(middleArea)
	group:insert(largeVerticalRect)
	group:insert(largeHorizontalRect)
	group:insert(square)
	group:insert(fatRect)
	group:insert(finger)

	addEventListeners()
	configAndStartPhysics()
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
	obj:setLinearVelocity(200 * direcaoX, 500 * direcaoY)
end

local function onCollision( event )
	if(event.object1.name ~= nil or event.object2.name ~= nil) then
		local options = {
		  effect = "fade",
		  time = 500,
		  params = {thisGameScore = score}
		}

		storyboard.gotoScene(scenesDir .. "scoreBoard", options)
	end
end
 
Runtime:addEventListener( "collision", onCollision )

function scene:enterScene(event)
	local group = self.view

	addDynamicBody(largeVerticalRect, { categoryBits = 2, maskBits = 3, groupIndex = -1 } )
	addDynamicBody(largeHorizontalRect, { categoryBits = 2, maskBits = 3, groupIndex = -1 } )
	addDynamicBody(square, { categoryBits = 2, maskBits = 3, groupIndex = -1 } )
	addDynamicBody(fatRect, { categoryBits = 2, maskBits = 3, groupIndex = -1 } )
	addStaticBody(finger, {categoryBits = 3, groupIndex = 1})

	finger:addEventListener('touch', startGame)
	
end

function startGame()
	move(square)
	move(fatRect)
	move(largeVerticalRect)
	move(largeHorizontalRect)
	finger:removeEventListener( "touch", startGame )
	return true
end	

function scene:exitScene(event)
	local group = self.view

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