require("constants")
local physics = require("physics")

local CircleFactory = {}
local CircleFactory_mt = { __index = CircleFactory }
local circlesDisplayGroup

local function defineMethods(newCircle, circleFactoryInstance)
	newCircle.setColor = function(colorNumber)
		newCircle.c1 = colors[colorNumber][1]
		newCircle.c2 = colors[colorNumber][2]
		newCircle.c3 = colors[colorNumber][3]
		newCircle:setFillColor(newCircle.c1, newCircle.c2, newCircle.c3)

		newCircle.alpha = 0.9
	end

	newCircle.shuffleColor = function()
		timer.performWithDelay(1000, function() newCircle.undivided = false end, 1)

		local color = math.floor(math.random() * 4) + 1
		newCircle.setColor(color)
	end

	newCircle.destroy = function()
		timer.cancel(newCircle.velocityLimitTimer)
		newCircle:removeSelf()
	end

	newCircle.divide = function()
		if(newCircle.radius <= minimumRadius) then
			return true
		end
		local group = newCircle.displayGroup

		local x, y = newCircle.x, newCircle.y

		local newRadius = newCircle.radius-3
		local collisionPoint = newCircle.radius/2
		newCircle.destroy()
		
		local divideCircleCallback = function()
			local newCircle1 = circleFactoryInstance:getInstance(x+newRadius, y, newRadius)
			local newCircle2 = circleFactoryInstance:getInstance(x-newRadius, y, newRadius)

			local impulse = newRadius
			if(impulse <= minimumRadius + 3)then
				impulse = 4
			else
				impulse = impulse + 3
			end
			impulse = impulse * newCircle.impulseDirection

			newCircle1:applyLinearImpulse(5, impulse, newCircle1.x, y)
			newCircle2:applyLinearImpulse(-5, impulse, newCircle2.x, y)
		end

		timer.performWithDelay(50, divideCircleCallback, 1)
	end

	newCircle.concatCircles = function(circle)
		local x, y = newCircle.x, newCircle.y
		local radiusTotal = newCircle.radius + circle.radius

		newCircle.destroy()
		circle.destroy()

		local concatCirclesCallback = function()
			local newCircle = circleFactoryInstance:getInstance(x, y, radiusTotal)
			newCircle:applyLinearImpulse(0, 30, 0, radiusTotal)
		end

		timer.performWithDelay(50, concatCirclesCallback, 1)
	end

	newCircle.onCollisionWith = function(circle)
		if (newCircle.undivided) then
			return true
		end

		if(newCircle.radius <= minimumRadius + 3 and circle.radius <= minimumRadius + 3) then
			newCircle:concatCircles()
		else
			local maiorCirculo
			local menorCirculo
			if(newCircle.radius < circle.radius)then
				maiorCirculo = circle
				menorCirculo = newCircle
			else
				maiorCirculo = newCircle
				menorCirculo = circle
			end
			
			local vx, vy = menorCirculo:getLinearVelocity()
			newCircle.impulseDirection = 1
			maiorCirculo:divide()
		end
	end
end

function CircleFactory:new()
	local newCircleFactory = {
		name = "CircleFactory",
		--displayGroup = displayGroup
	}
	circlesDisplayGroup = display.newGroup()
	
	return setmetatable( newCircleFactory, CircleFactory_mt )
end

function CircleFactory:getInstance(positionX, positionY, radius)
	local animalNumber = math.random(1, 9)

	local newCircle = display.newImage(animalsDir .. animals[animalNumber] .. ".png", positionX or 0, positionY or 0)
	circlesDisplayGroup:insert(newCircle)

	local size = radius / 48
	newCircle:scale(size, size)
	--local newCircle = display.newCircle(positionX or 0, positionY or 0, radius or 15)
	newCircle.impulseDirection = 1

	physics.addBody(newCircle, 'dynamic', {radius = radius, density = 1, bounce = 0.95, filter = physicBodyFilter})
	newCircle.isFixedRotation = true

	local dir = 0
	if(radius < 18) then dir = -1 else dir = 1 end
	newCircle:setLinearVelocity((radius*2) * dir, maxVelocity * 0.10)

	local callbackVelocityLimit = function()
		local vx, vy = newCircle:getLinearVelocity()
		local max = maxVelocity + newCircle.radius * 0.3
		
		if(vx > max)then
			newCircle:setLinearVelocity(max, vy)
		end
		if(vy > max)then
			newCircle:setLinearVelocity(vx, max)
		end
	end

	newCircle.velocityLimitTimer = timer.performWithDelay(10, function() pcall(callbackVelocityLimit) end, 0)

	newCircle.name = "circle"
	newCircle.undivided = true
	newCircle.radius = radius

	defineMethods(newCircle, self)

	--newCircle.shuffleColor()
	timer.performWithDelay(1000, function() newCircle.undivided = false end, 1)

	return newCircle
end

function CircleFactory:destroyDisplayGroup()
	circlesDisplayGroup:removeSelf()
end

function CircleFactory:getNumberOfBalls()
	return circlesDisplayGroup.numChildren
end

function CircleFactory:getDisplayGroup()
	return circlesDisplayGroup
end

_G.CircleFactory = CircleFactory
