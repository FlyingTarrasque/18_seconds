local gameNetwork = require "gameNetwork"

gameNetwork.init("google")

gameNetwork.request("login",{
   userInitiated = false
})

_G.gameNetwork = gameNetwork
