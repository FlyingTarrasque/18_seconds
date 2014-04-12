local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local physics = require "physics"
physics.setDrawMode("hybrid")

local gameStarted = false

local middleArea = display.newRect(halfW, halfH, 375, 375)
local largeHorizontalRect = display.newRect(middleArea.x + 120, middleArea.y + 130, 120, 25)
largeHorizontalRect:setFillColor(0, 0, 30)

local largeVerticalRect = display.newRect(middleArea.x - 130, middleArea.y + 130, 30, 75)
largeVerticalRect:setFillColor(0, 0, 30)


left = display.newLine(0, screenH, 0, 0)
right = display.newLine(screenW, screenH, screenW + 2, 0)
up = display.newLine(0, 0, screenW, 0)
bottom = display.newLine(screenW, screenH, 0, screenH)

up.isVisible = false
left.isVisible = false
right.isVisible = false
bottom.isVisible = false

function collisionListener(event)
	
end

local function addEventListeners()
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
	physics.addBody(obj, 'static', {bounce = 0.95, filter = physicBodyFilter})
end

local function configAndStartPhysics()
	physics.start()
	physics.setGravity(0, gravity)
	
	addStaticBody(left)
	addStaticBody(right)
	addStaticBody(bottom)
	addStaticBody(up)
end

function scene:createScene(event)
	local group = self.view

	storyboard.removeScene(scenesDir .."scoreBoard")

	addEventListeners()
	configAndStartPhysics()
end

function scene:enterScene(event)
	local group = self.view
end

function scene:exitScene(event)
	local group = self.view

	removeEventListeners()
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