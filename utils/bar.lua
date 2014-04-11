require("constants")
local physics = require("physics")

local Bar = {}
local Bar_mt = { __index = Bar }

local plataformGroup

local score
local instruction
local plataform
local instructionRemoved

local scoreSnd = audio.loadSound(soundsDir .. 'coin.mp3')

local function initializeObjects()
	score = display.newText('0', halfW - 10, 30, fontType, 30)
	score:setFillColor(10, 10, 10)

	instruction = display.newImage(imagesDir .. "ins.png", halfW + 70, screenH - 33)
	instructionRemoved = false

	plataform = display.newImage(imagesDir .. "bar.png", halfW - 10, screenH - 60, maxBarSize, 20)
	plataform.width = maxBarSize
	plataform.lastDiff = initialAmount
	--plataform = display.newRoundedRect(halfW - 10, screenH - 60, 80, 10, 3)
	plataform.name = 'bar'
	physics.addBody(plataform, 'kinematic', {friction=0.3, filter = physicBodyFilter})

	plataformGroup = display.newGroup()
end

local function defineMethods()
	plataform.onCollisionWith = function(circle, circleFactoryInstance)
		audio.play(scoreSnd)
		local impulse = circle.radius
		if(impulse <= minimumRadius + 5)then
			impulse = 4
		else
			impulse = impulse + 5
		end

		circle:applyLinearImpulse(3, impulse, 0, circle.y)
		local vx, vy = circle:getLinearVelocity()

		--plataform:setFillColor(circle.c1, circle.c2, circle.c3)
		score.text = tostring(tonumber(score.text) + 1)

		if(circleFactoryInstance:getNumberOfBalls() == 1) then
			circle.impulseDirection = -1
			circle:divide()
		end
	end
end

function Bar:new()
	local newBar = {
		name = "Bar",
	}
	
	initializeObjects()
	defineMethods()

	plataformGroup:insert(score)
	plataformGroup:insert(plataform)
	plataformGroup:insert(instruction)

	return setmetatable( newBar, Bar_mt )
end

function Bar:removeInstructions()
	if(instructionRemoved) then
		return true
	end

	instructionRemoved = true

	local onCompleteCallback = function() 
		instruction:removeSelf()
		instruction = nil
	end

	instruction.alpha = 0
	transition.from(instruction, {time = 500, alpha = 1, onComplete = onCompleteCallback})
end

function Bar:onMove(event)
	if(event.phase == 'moved') then
		plataform.y = event.y - 40
		plataform.x = event.x
	end

	return true
end

function Bar:destroyDisplayGroup()
	plataformGroup:removeSelf()
end

function Bar:getDisplayGroup()
	return plataformGroup
end

function Bar:getScore()
	return score.text
end

function Bar:getNewPlataformSize(numberOfBalls)
	local change = 1
	if(plataform.lastDiff > numberOfBalls)then
		change = -1
	elseif(plataform.lastDiff == numberOfBalls)then
		return plataform.width
	end
	local x = math.abs(numberOfBalls - plataform.lastDiff)
	plataform.lastDiff = numberOfBalls

	local diff = (x*20) * change
	local newSize = plataform.width + diff

	if(newSize > maxBarSize)then
		newSize = maxBarSize
	elseif(newSize < 10)then
		newSize = 10
	end
	return newSize
end

local resizePlataformCallback = function()
	if(physics.removeBody(plataform))then
		physics.addBody(plataform, 'kinematic', {friction=0.3, filter = physicBodyFilter})
	end
end

function Bar:resize(numberOfBalls)	
	plataform.width = self:getNewPlataformSize(numberOfBalls)
	timer.performWithDelay(10, resizePlataformCallback, 1)
end

function Bar:getPlataformSize()
	return plataform.width
end

_G.Bar = Bar
