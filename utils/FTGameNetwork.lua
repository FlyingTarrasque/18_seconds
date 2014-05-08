

_G.loggedIntoGC = false

FTGameNetwork = {}
FTGameNetwork_mt = { __index = FTGameNetwork }

FTGameNetwork.View = {}
FTGameNetwork.View.Leaderboards = "leaderboards"
FTGameNetwork.View.Achievements = "achievements" 
FTGameNetwork.View.FriendRequest = "friendRequest"

FTGameNetwork.TimeScope = {}
FTGameNetwork.TimeScope.Today = "Today" 
FTGameNetwork.TimeScope.Week = "Week"
FTGameNetwork.TimeScope.AllTime = "AllTime"

local gameNetwork = require "gameNetwork"

function FTGameNetwork:new()
	local self = {
		isAndroid = system.getInfo("platformName") == "Android",
	}
	setmetatable(self, FTGameNetwork_mt)
	return self
end

-- function to listen for system events
local function onSystemEvent( event ) 
	print("on system event "..event.type)
	local initCallback =  function(event)
		print("callback gamecenter inciado")
			-- "showSignIn" is only available on iOS 6+
	    if event.type == "showSignIn" then
	        -- This is an opportunity to pause your game or do other things you might need to do while the Game Center Sign-In controller is up.
	        -- For the iOS 6.0 landscape orientation bug, this is an opportunity to remove native objects so they won't rotate.
	        -- This is type "init" for all versions of Game Center.
	    elseif event.data then
	        loggedIntoGC = true
	    end
	end
    if event.type == "applicationStart" then
    	print("iniciando gamecenter")
    	gameNetwork.init( "gamecenter", initCallback )
        return true
    end
end

function FTGameNetwork:init()
	print("init.......")
	if ( self.isAndroid ) then
		gameNetwork.init("google")

		gameNetwork.request("login",{
	   		userInitiated = false
		})
	else
		Runtime:addEventListener( "system", onSystemEvent )
	end
end	


function FTGameNetwork:setHighScore(score, lvl) 
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
		gameNetwork.request( "setHighScore", { 
			localPlayerScore = { 
				category = lvl[currentLvl].leaderBoardIdIOS, 
				value = score * 1000
			} 
		})
	end
end

function FTGameNetwork:show(lvl, onDimissCallback)
	print("showLeaderboard")
	if(isAndroid) then
		onSuspending = function()
			leaderboardBtn.taped = false 
		end
		local leaderboarListener = function() gameNetwork.show(FTGameNetwork.View.Leaderboards) end
		if gameNetwork.request("isConnected") then
			leaderboarListener()
		else
			gameNetwork.request("login",{
		    	userInitiated = true,
		    	listener = leaderboarListener
			});
		end
	else
		local data = {
			leaderboard ={
				timeScope = FTGameNetwork.TimeScope.AllTime,
				category = lvl[currentLvl].leaderBoardIdIOS
			},
			listener = onDimissCallback
		}
		if(lvl ~= nil) then
			gameNetwork.show( FTGameNetwork.View.Leaderboards, data)
		else
			gameNetwork.show( FTGameNetwork.View.Leaderboards, {listener=onDimissCallback})
		end
		
	end
end

_G.leaderboard = FTGameNetwork:new()

return FTGameNetwork