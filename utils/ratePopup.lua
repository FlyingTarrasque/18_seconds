require("utils.ice")
local settings = ice:loadBox("settings")
local collection = "gamesPlayed"

RatePopup = {}
RatePopup_mt = { __index = RatePopup }

function RatePopup:new()
	local self = {}
	setmetatable(self, RatePopup_mt)

	return self
end

function RatePopup:getGamesPlayed()
	return settings:retrieve(collection) or 0
end

function RatePopup:incrementGamesPlayed()
	local xGamesPlayed = self:getGamesPlayed() + 1
	settings:store(collection, xGamesPlayed)
	settings:save()
end

function RatePopup:getRateStatus()
	return settings:retrieve("rated") or false
end

local onCompleteCallback = function(event)
	if "clicked" == event.action then
		local i = event.index
		if 1 == i then
			settings:store("rated", true)
			settings:save()
			if(system.getInfo("platformName") == "Android") then
				system.openURL("https://play.google.com/store/apps/details?id=" .. googlePlayIdApp)
			else
				system.openURL("itms-apps://itunes.apple.com/app/pages/id" .. appleStoreIdApp .. "?mt=8&uo=4")
			end
		end
	end
end

function RatePopup:show()
	self:incrementGamesPlayed()
	if(self:getGamesPlayed()%10 == 0 and self:getRateStatus() == false)then
		local alert = native.showAlert( "Check out my other apps!", "Please rate this app to help support future development!", { "OK", "I dont care =(" }, onCompleteCallback)
	end
end

_G.ratePopup = RatePopup:new()