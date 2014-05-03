local lvl = {}

local function configLvl(name, midleAreaScale, limitMax, limitMin, velocityx, velocityy, leaderBoardId,leaderBoardIdIOS)
	lvl[name] = {
		midleAreaScale = midleAreaScale,
		limitMax = limitMax,
		limitMin = limitMin,
		leaderBoardId = leaderBoardId,
		velocityy = velocityy,
		velocityx = velocityx,
		leaderBoardIdIOS = leaderBoardIdIOS
	}
end

configLvl("easy", 1.4, 500, 0, 400, 100, "CgkI5v67ttYBEAIQBQ", "18sec_level_easy")
configLvl("normal", 1, 432, 69, 400, 160, "CgkI5v67ttYBEAIQBA", "18sec_level_normal")
configLvl("hard", 1, 432, 69, 500, 200, "CgkI5v67ttYBEAIQAA", "18sec_level_hard")

return lvl