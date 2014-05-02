local gameNetwork = require "gameNetwork"

local loggedIntoGC = false

local isAndroid = system.getInfo("platformName") == "Android"

GameNetwork = {}

local function alerta(str, callback)
	--local alert = native.showAlert( str, "...", { "OK", "callback" }, callback)
end

-- function to listen for system events
local function onSystemEvent( event ) 
	
	local initCallback =  function(event)
			-- "showSignIn" is only available on iOS 6+
	    if event.type == "showSignIn" then
	        -- This is an opportunity to pause your game or do other things you might need to do while the Game Center Sign-In controller is up.
	        -- For the iOS 6.0 landscape orientation bug, this is an opportunity to remove native objects so they won't rotate.
	        -- This is type "init" for all versions of Game Center.
	    elseif event.data then
	        loggedIntoGC = true
	    end
	    --alerta("initCallback event.type: "..event.type.."event.data: "..event.data)
	end
    if event.type == "applicationStart" then
    	local callbackIniciarGameCenter = function()
    		gameNetwork.init( "gamecenter", initCallback )
   		end
    	--alerta(event.type, callbackIniciarGameCenter)
        return true
    end
end

local function iniciarGameNetwork()
	if ( isAndroid ) then
		gameNetwork.init("google")

		gameNetwork.request("login",{
	   		userInitiated = false
		})
	else
		Runtime:addEventListener( "system", onSystemEvent )
	end

end	

function GameNetwork:setHighScore(score, lvl) 
	if(isAndroid) then
		local leaderboarListener = function() 
			gameNetwork.request("setHighScore", {
			  localPlayerScore = {
			    category = lvl[currentLvl].leaderBoardId,
			    value = score * 1000
			  }
			})
	 	end
		if gameNetwork.request("isConnected") then
			leaderboarListener()
		else
			gameNetwork.request("login",{
		    	userInitiated = true,
		   	 	listener = leaderboarListener
			});
		end
	else

	end
end

function GameNetwork:showLeaderboard()
	if(isAndroid) then
		onSuspending = function()
			leaderboardBtn.taped = false 
		end
		local leaderboarListener = function() gameNetwork.show("leaderboards") end
		if gameNetwork.request("isConnected") then
			leaderboarListener()
		else
			gameNetwork.request("login",{
		    	userInitiated = true,
		    	listener = leaderboarListener
			});
		end
	else
		gameNetwork.request("loadScores")
	end
end

iniciarGameNetwork();

_G.gameNetwork = gameNetwork
