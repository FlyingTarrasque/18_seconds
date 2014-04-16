local settings = ice:loadBox("settings")
local actualVersion = settings:retrieve("version") or 0
local migrations = {}
migrations[1] = function()
		local scores = ice:loadBox("scores")
		local lvl = require("utils.lvlsConfig")

		local setHighScore = function(name)
			local score = scores:retrieve("best" .. name) or 0
			if score > 0 then
				return false
			end

			print("Updating leaderboard from " .. name)

			local leaderboarListener = function()
				gameNetwork.request("setHighScore", {
				  localPlayerScore = {
				    category = lvl[name].leaderBoardId,
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
		end
		print("executando migration para leaderboads...")
		setHighScore("easy")
		setHighScore("normal")
		setHighScore("hard")
	end	

local executeMigrations = function()
	if actualVersion < version then

		for newVersion = actualVersion, version do
			print("executando migration -> " .. newVersion)
			local migration = migrations[newVersion]
	 		if(migration) then
	 			migration()
	 			actualVersion = newVersion
	 		end
		end
		settings:store("version", actualVersion)
		settings:save()
	end
end

return executeMigrations