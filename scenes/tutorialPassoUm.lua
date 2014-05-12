
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local stepOne = display.newImage(imagesDir .. "passoUm.png", halfW, halfH + 30, 0, 0)
local tipOne = display.newText("Touch and hold the red circle ...", halfW, 65, fontType, 30)
stepOneDot = display.newCircle(halfW - 20, screenH, 8)
stepTwoDot = display.newCircle(halfW + 20, screenH, 8)
local group

local function onSceneTouch( event )
	if event.phase == "moved" then
		group.x = event.x - event.xStart
	elseif event.phase == "ended" then
		print("ended"..event.xStart.." "..event.x)
		if event.xStart > event.x and (event.xStart - event.x) >= 200 then
			storyboard.gotoScene( scenesDir.."tutorialPassoDois", "slideLeft", 1000 )
			return true
		else
			group.x = 0
		end
	end
end

function scene:createScene( event )
	group = self.view
	group:insert(stepOne)
	group:insert(tipOne)

	g = group
	transition.to(title, {time=100,x=title.x, y=title.y-125})
end

function scene:willEnterScene( event )
	stepTwoDot.alpha = 0.5
	stepOneDot.alpha = 1
end

function scene:enterScene( event )
	local group = self.view


	Runtime:addEventListener("touch", onSceneTouch)
end

function scene:exitScene( event )
	local group = self.view

	Runtime:removeEventListener("touch", onSceneTouch)
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

scene:addEventListener("willEnterScene", scene)


-----------------------------------------------------------------------------------------

return scene