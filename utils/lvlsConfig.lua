local lvl = {}

local function configLvl(name, midleAreaScale, limitMax, limitMin, velocityx, velocityy, leaderBoardId)
	lvl[name] = {
		midleAreaScale = midleAreaScale,
		limitMax = limitMax,
		limitMin = limitMin,
		leaderBoardId = leaderBoardId,
		velocityy = velocityy,
		velocityx = velocityx
	}
end

configLvl("easy", 1.4, 500, 0, 400, 100, "CgkI5v67ttYBEAIQBQ")
configLvl("normal", 1, 432, 69, 400, 100, "CgkI5v67ttYBEAIQBA")
configLvl("hard", 1, 432, 69, 500, 200, "CgkI5v67ttYBEAIQAA")

return lvl