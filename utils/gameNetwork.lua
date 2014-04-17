local gameNetwork = require "gameNetwork"

gameNetwork.init("gamecenter")
local function initCallback( event )
    if event.data then
        loggedIntoGC = true
        native.showAlert( "Success!", "User has logged into Game Center", { "OK" } )
    else
        loggedIntoGC = false
        native.showAlert( "Fail", "User is not logged into Game Center", { "OK" } )
    end
   userInitiated = false
end
gameNetwork.request("login",initCallback)

_G.gameNetwork = gameNetwork
