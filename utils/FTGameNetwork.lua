

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
local scores = ice:loadBox("scores")
local lvl = require("utils.lvlsConfig")

function FTGameNetwork:new()
	local self = {
		isAndroid = system.getInfo("platformName") == "Android",
	}
	setmetatable(self, FTGameNetwork_mt)
	return self
end

local initCallback =  function(event)
	print("callback gamecenter inciado")
	if(isAndroid) then
		leaderboard:sendBestScoresAndroid()
	else
		leaderboard:updateBestScoresIOS()	
	end
		-- "showSignIn" is only available on iOS 6+
    if event.type == "showSignIn" then
        -- This is an opportunity to pause your game or do other things you might need to do while the Game Center Sign-In controller is up.
        -- For the iOS 6.0 landscape orientation bug, this is an opportunity to remove native objects so they won't rotate.
        -- This is type "init" for all versions of Game Center.
    elseif event.data then
        loggedIntoGC = true
    end
end
-- function to listen for system events
local function onSystemEvent( event ) 
	print("on system event "..event.type)
	
    if event.type == "applicationStart" then
    	print("iniciando gamecenter")
    	gameNetwork.init( "gamecenter", initCallback )
        return true
    end
end

function FTGameNetwork:updateBestScoresIOS()
	print("carregando scores do gamecenter")
	local requestCallback = function(event)
		if(event.localPlayerScore  == nil) then
			return false  
		end

		local categories = {}
		categories[lvl["easy"].leaderBoardIdIOS] = "easy"
		categories[lvl["normal"].leaderBoardIdIOS] = "normal"
		categories[lvl["hard"].leaderBoardIdIOS] = "hard"
		
		local levelName = categories[event.localPlayerScore.category]
		local storeName = "best"..levelName
		print("levelName: "..levelName)
		local localScore = scores:retrieve(storeName) or 0
		print("localScore"..localScore)
		local gcScore = event.localPlayerScore.value / 1000 or 0
		print("gcScore"..gcScore)

		if(localScore > gcScore) then
			print("localScore maior... atualizando gamecenter")
			self:setHighScore(localScore, levelName)
		elseif(gcScore > localScore) then
			print("gamecenter maior... atualizando base local")
			scores:store(storeName, gcScore)
			scores:save()
		end
	end
	self:loadScore("easy",requestCallback)
	self:loadScore("normal",requestCallback)
	self:loadScore("hard",requestCallback)
end

function FTGameNetwork:sendBestScoresAndroid(levelName)
	print("enviando scores...")
	local function sendScore(levelName)
		local localScore = scores:retrieve("best"..levelName) or 0
		if localScore == 0 then
			return false
		end
		print("localScore level"..levelName..": "..localScore)
		self:setHighScore(localScore,levelName)
		print("score level"..levelName.." enviado!")
	end
	
	sendScore("easy")
	sendScore("normal")
	sendScore("hard")
end

function FTGameNetwork:loadScore(levelName,requestCallback)
	print("category: "..lvl[levelName].leaderBoardIdIOS)
	gameNetwork.request( "loadScores",{
	    leaderboard = {
	        category=lvl[levelName].leaderBoardIdIOS,
	        playerScope="Global",   -- Global, FriendsOnly
	        timeScope= FTGameNetwork.TimeScope.AllTime,    -- AllTime, Week, Today
	        range = {1,1}, --Just get one player 
            playerCentered = true
	    },
	    listener=requestCallback
	})
end

function FTGameNetwork:init()
	print("init.......")
	if ( self.isAndroid ) then
		gameNetwork.init("google", initCallback)

		gameNetwork.request("login",{
	   		userInitiated = false
		})
	else
		Runtime:addEventListener( "system", onSystemEvent )
	end
end	


function FTGameNetwork:setHighScore(score, levelName) 
	if levelName == nil then
		levelName = currentLvl
	end

	if(isAndroid) then
		local leaderboarListener = function() 
			gameNetwork.request("setHighScore", {
			  localPlayerScore = {
			    category = lvl[levelName].leaderBoardId,
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
				category = lvl[levelName].leaderBoardIdIOS, 
				value = score * 1000
			} 
		})
	end
end

function FTGameNetwork:show(onDimissCallback)
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
		gameNetwork.show( FTGameNetwork.View.Leaderboards, data)
	end
end

_G.leaderboard = FTGameNetwork:new()

return FTGameNetwork