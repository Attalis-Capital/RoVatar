-- @ScriptType: ModuleScript
-- Stateless damage scaling helper
local RS = game:GetService("ReplicatedStorage")
local Costs = require(RS.Modules.Custom.Costs)

local DamageCalc = {}

-- Scale base damage by player level and element level
-- Formula: baseDamage * (1 + 0.02 * playerLevel) * (1 + 0.03 * elementLevel)
function DamageCalc.Calculate(baseDamage: number, playerLevel: number, elementLevel: number): number
	local plrMul = 1 + Costs.PlayerLevelDamageScale * playerLevel
	local elMul = 1 + Costs.ElementLevelDamageScale * elementLevel
	return math.floor(baseDamage * plrMul * elMul)
end

-- Read element level from player attributes (fast path, no GetData)
function DamageCalc.GetElementLevel(plr: Player, element: string): number
	return plr:GetAttribute("ElementLevel_" .. element) or 1
end

-- Read player level from Progression folder
function DamageCalc.GetPlayerLevel(plr: Player): number
	local prog = plr:FindFirstChild("Progression")
	if prog then
		local lvl = prog:FindFirstChild("LEVEL")
		if lvl then return lvl.Value end
	end
	return 1
end

return DamageCalc
