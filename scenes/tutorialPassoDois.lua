
local storyboard = require( "storyboard" )
local flags = ice:loadBox("flags")
local scene = storyboard.newScene()
local stepTwo = display.newImage(imagesDir .. "passoDois.png", halfW, halfH + 30, 0, 0)
local tipTwo = display.newText("... slide to dodge. Hold 18 seconds!", halfW, 65, fontType, 30)
local group

local function onSceneTouch( event )
	if event.phase == "moved" then
		group.x = event.x - event.xStart
	elseif event.phase == "ended" then
		if event.xStart < event.x and (event.x - event.xStart) >= 200 then
			storyboard.gotoScene( scenesDir.."tutorialPassoUm", "slideRight", 1000 )
		elseif event.xStart > event.x and (event.xStart - event.x) >= 200 then
			stepOneDot.alpha = 0
			stepTwoDot.alpha = 0
			local tutorialCompleto = flags:retrieve("tutorial") or false
			if(tutorialCompleto) then
				storyboard.gotoScene( scenesDir.."menu", "slideLeft", 1000 )
			else
				flags:store("tutorial",true)
				flags:save()
				storyboard.gotoScene( scenesDir.."levelSelect", "slideLeft", 1000 )
			end
			return true
		else
			transition.to(group, {time=400, x=0})
		end
	end
end

function scene:createScene( event )
	group = self.view
	group:insert(stepTwo)
	group:insert(tipTwo)
end

function scene:willEnterScene(event)
	stepOneDot.alpha = 0.5
	stepTwoDot.alpha = 1
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