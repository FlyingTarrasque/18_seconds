local gameNetwork = require "gameNetwork"

-- Init game network to use Google Play game services
gameNetwork.init("google")

-- Tries to automatically log in the user without displaying the login screen if the user doesn't want to login
gameNetwork.request("login",{
   userInitiated = false
})

local function unlockAchievementListener(event)
   gameNetwork.request("unlockAchievement", {
      achievement = {
         identifier = achievementId -- The id of the achievement to unlock for the current user
      }
   })
end

local function showLeaderboardListener(event)
   gameNetwork.show("leaderboards") -- Shows all the leaderboards.
end

local function showAchievementsListener(event)
   gameNetwork.show("achievements") -- Shows the locked and unlocked achievements.
end

local loginLogoutButton


-- Checks if the auto login worked and if it did then change the text on the button
if gameNetwork.request("isConnected") then
   loginLogoutButton:setLabel("Logout")
end

_G.gameNetwork = gameNetwork
