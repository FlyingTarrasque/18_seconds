-- Project: GGGameCentre
--
-- Date: December 23, 2012
--
-- File name: GGGameCentre.lua
--
-- Author: Graham Ranson of Glitch Games - www.glitchgames.co.uk
--
-- Comments: 
--
--		GGGameCentre makes working with Game Center nice and easy.
--
-- Copyright (C) 2012 Graham Ranson, Glitch Games Ltd.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this 
-- software and associated documentation files (the "Software"), to deal in the Software 
-- without restriction, including without limitation the rights to use, copy, modify, merge, 
-- publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
-- to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or 
-- substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
--
----------------------------------------------------------------------------------------------------

local GGGameCentre = {}
local GGGameCentre_mt = { __index = GGGameCentre }

GGGameCentre.View = {}
GGGameCentre.View.Leaderboards = "leaderboards"
GGGameCentre.View.Achievements = "achievements" 
GGGameCentre.View.FriendRequest = "friendRequest"

GGGameCentre.TimeScope = {}
GGGameCentre.TimeScope.Today = "Today" 
GGGameCentre.TimeScope.Week = "Week"
GGGameCentre.TimeScope.AllTime = "AllTime"

local gameNetwork = require( "gameNetwork" )

--- Initiates a new GGGameCentre object.
-- @param listener An optional listener function for 'gameCentre' events.
-- @return The new object.
function GGGameCentre:new( listener )
    
    local self = {}
    
    setmetatable( self, GGGameCentre_mt )
	
	Runtime:addEventListener( "system", self )
	
	self.listener = listener
	
	self.loggedIn = false
	
	self.initCallback = function( event )
		if event.type == "showSignIn" then
			self:onShowSignIn()
		elseif event.data then
			self:onLogIn()
		end
	end
	
	self.dismissCallback = function( event )
		event.view = self.currentView
		self:onViewDismiss( event )
	end
	
	self.localPlayer = nil
	self.friends = nil
	
    return self
    
end

--- Initiates Game Center. Called internally.
function GGGameCentre:init()
	self.loggedIn = false
	gameNetwork.init( "gamecenter", self.initCallback )
	if self.listener then
		self.listener{ name = "gameCentre", phase = "init" }
	end
end

--- Shows a game center view.
-- @param view The view to show. For possibilites see GGGameCentre.View
-- @param data An optional data table.
function GGGameCentre:show( view, data )
	self.currentView = view
	data = data or {}
	data.listener = self.dismissCallback
	gameNetwork.show( view, data )
	
	if self.listener then
		self.listener{ name = "gameCentre", phase = "viewShow", view = view }
	end
end

--- Shows the achievements dialog.
function GGGameCentre:showAchievements()
	gameNetwork.show( GGGameCentre.View.Achievements )
end

--- Shows a leaderboard.
-- @param category The id of the leaderboard.
-- @param timeScope Time scope to display, optional. Check GGGameCentre.TimeScope for possibilities.
function GGGameCentre:showLeaderboards( category, timeScope )
	
	local data = {}
	data.category = category
	data.timeScope = timeScope
	
	gameNetwork.show( GGGameCentre.View.Leaderboards, data )
	
end

--- Shows the friend request dialog.
-- @param message String message to get displayed. Optional.
-- @param playerIDs Single player ID number or table of player ids. If a table then each id must have the prefix of "G:". Optional.
-- @param emailAddresses Single email address or table of email addresses. Optional.
function GGGameCentre:requestFriend( message, playerIDs, emailAddresses )

	local data = {}
	data.message = message
	
	if playerIDs then
		if type( playerIDs ) == "string" or type( playerIDs ) == "number" then
			data.playerIDs = { "G:" .. playerIDs }
		else
			data.playerIDs = playerIDs
		end
	end
	
	if emailAddresses then
		if type( emailAddresses ) == "string" then
			data.emailAddresses = { emailAddresses }
		else
			data.emailAddresses = emailAddresses
		end
	end
	
	self:show( GGGameCentre.View.FriendRequest, data )

end

--- Sets a new high score.
-- @param leaderboard String id of the leaderboard to add the score to.
-- @param score The value to set the score to.
function GGGameCentre:setHighScore( leaderboard, score )
	gameNetwork.request( "setHighScore", { localPlayerScore = { category = leaderboard, value = score } } )
end

--- Unlocks an achievement.
-- @param id String id of the achievement to unlock.
-- @param percent Optional number representing the completion percentage of the achievement, 100 will fully unlock it. Default is 100.
-- @param showBanner Optional boolean to set whether a banner should automatically be shown when the achievement reaches 100 percent. iOS 5+ only. Default is true.
-- @param listener Optional listener callback. Will fill event.data with a table that corresponds to the Apple GKAchievement class that you just unlocked. 
function GGGameCentre:unlockAchievement( id, percent, showBanner, listener )
	
	if percent == nil then
		percent = 100
	end
	
	if showBanner == nil then
		showBanner = true
	end
	
	gameNetwork.request( "unlockAchievement", { achievement = { identifier = id, percentComplete = percent, showsCompletionBanner = showBanner }, listener = listener } )

end

--- Resets all achievements for the current player. There is no undoing this.
function GGGameCentre:resetAchievements()
	gameNetwork.request( "resetAchievements", {} )
end

--- Loads the local player and calls the listener function with a 'loadLocalPlayer' phase and 'player' attached. 
function GGGameCentre:loadLocalPlayer()

	local listener = function( event )
		self.localPlayer = event.data
		if self.listener then
			self.listener{ name = "gameCentre", phase = "loadLocalPlayer", player = self.localPlayer }
		end
	end
	
	gameNetwork.request( "loadLocalPlayer", { listener = listener } )

end

--- Gets the local player, assuming it's already been loaded via GGGameCentre:loadLocalPlayer()
function GGGameCentre:getLocalPlayer()
	return self.localPlayer
end

--- Loads the friends of the local player and calls the listener function with a 'loadFriends' phase and 'friends' table attached. 
function GGGameCentre:loadFriends()

	local listener = function( event )
		self.friends = event.data
		if self.listener then
			self.listener{ name = "gameCentre", phase = "loadFriends", friends = self.friends }
		end
	end
	
	gameNetwork.request( "loadFriends", { listener = listener } )

end

--- Gets the friends of the local player, assuming they've already been loaded via GGGameCentre:getFriends()
function GGGameCentre:getFriends()
	return self.friends
end

--- Called called when sign in dialog is shown. Called internally.
function GGGameCentre:onShowSignIn()
	if self.listener then
		self.listener{ name = "gameCentre", phase = "showSignIn" }
	end
end

--- Called on log in to Game Center. Called internally.
function GGGameCentre:onLogIn()
	self.loggedIn = true
	if self.listener then
		self.listener{ name = "gameCentre", phase = "logIn" }
	end
end

--- Called on log out from Game Center. Called internally.
function GGGameCentre:onLogOut()
	self.loggedIn = false
	if self.listener then
		self.listener{ name = "gameCentre", phase = "logOut" }
	end
end

--- Called when a View is dismissed. Called internally.
-- @param event The event table.
function GGGameCentre:onViewDismiss( event )
	if self.listener then
		self.listener{ name = "gameCentre", phase = "viewDismiss", view = event.view }
	end
end

--- Checks if the player is logged into game center.
-- @return True if logged in and false otherwise.
function GGGameCentre:isLoggedIn()
	return self.loggedIn
end

--- Listener for System event. Called internally.
function GGGameCentre:system( event )
	if event.type == "applicationStart" or event.type == "applicationResume" then
        self:init()
        return true
    end
end

--- Destroys this GGGameCentre object.
function GGGameCentre:destroy()
	Runtime:removeEventListener( "system", self )
	self.loggedIn = nil
	self.initCallback = nil
	self.dismissCallback = nil
	self.currentView = nil
	self.listener = nil
	self.localPlayer = nil
	self.friends = nil
end

return GGGameCentre