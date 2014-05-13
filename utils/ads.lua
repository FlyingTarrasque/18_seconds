local ads = require "ads"
local RevMob = require("utils.revmob")

require("utils.ice")
require("constants")

local adType = "banner"
local messages = display.newText('', halfW, 100, "Arial", 12)
local settings = ice:loadBox("settings")
local PLACEMENT_IDS = { [REVMOB_ID_IOS] = '5371649e5b9a4c0016c77a4d', [REVMOB_ID_ANDROID] = '537164a8142dfb2626900d26' }
local REVMOB_IDS = { [REVMOB_ID_IOS] = '5371649e5b9a4c0016c77a49', [REVMOB_ID_ANDROID] = '537164a8142dfb2626900d22' }

local showAds = function()
	--ads.hide()
	local adX, adY = 0, display.actualContentHeight-10
	ads.show(adType, {x=adX, y=adY, interval=30})
end


local function adListener(event)
	local msg = event.response
	--print("Message received from the ads library: ", msg)
	--messages.text = msg

	if event.isError then
		--print("Houve um erro.")
		showAds()
	else
		--print("Banner deve ser aprensentado.")
	end
end

local revmobListener = function(event)
	if(event.type == "adClosed") then
		showAds()
	end
  	print("Event: " .. event.type)
end

Ads = {}
Ads_mt = { __index = Ads }

function Ads:new()
	local self = {
		provider = "admob",
		appIOSID = "ca-app-pub-4502761084086592/8523664468",
		appAndroidID = "ca-app-pub-4502761084086592/7186532061"
	}
	if ( system.getInfo("platformName") == "Android" ) then
		ads.init(self.provider, self.appAndroidID, adListener)
	else
		ads.init(self.provider, self.appIOSID, adListener)
	end
	
	--INIT REVBMOB
	RevMob.startSession(REVMOB_IDS)
	
	setmetatable(self, Ads_mt)

	return self
end

function Ads:changeType(newType)
	if(newType)then
		adType = newType
	end
end

function Ads:show()
	showAds()
end

function Ads:showFullscreenAdmob()
	print("mostrando interstitial")
	if ( system.getInfo("platformName") == "Android" ) then
		local fullscreenIOSID = "ca-app-pub-4502761084086592/3468850462"
		ads.show("interstitial", {interval=3, appId=fullscreenIOSID})
	else
		local fullscreenIOSID = "ca-app-pub-4502761084086592/3468850462"
		ads.show("interstitial", {interval=3, appId=fullscreenIOSID})
	end
end

function Ads:preLoadFullscreenRevMob()
	self.fullscreen = RevMob.createFullscreen(revmobListener, PLACEMENT_IDS)
end

function Ads:showFullscreenRevMob()
	ads.hide()
	if(self.fullscreen ~= nil) then
		self.fullscreen:show()
	else
		RevMob.showFullscreen(revmobListener, PLACEMENT_IDS)
	end
end

function Ads:showThe(newType)
	self:changeType(newType)
	showAds()
end

function Ads:hide()
	ads.hide()
end

_G.ads = Ads:new()