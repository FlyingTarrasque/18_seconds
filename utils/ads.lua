local ads = require "ads"
require("constants")

local adType = "banner"
local messages = display.newText('', halfW, 100, "Arial", 12)

local showAds = function()
	local adX, adY = display.screenOriginX, display.actualContentHeight - 100
	ads.show(adType, {x=adX, y=adY, interval=30})
end

local function adListener(event)
	local msg = event.response
	print("Message received from the ads library: ", msg)
	--messages.text = msg

	if event.isError then
		print("Houve um erro.")
		showAds()
	else
		print("Banner deve ser aprensentado.")
	end
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

function Ads:showThe(newType)
	self:changeType(newType)
	showAds()
end

function Ads:hide()
	ads.hide()
end

_G.ads = Ads:new()