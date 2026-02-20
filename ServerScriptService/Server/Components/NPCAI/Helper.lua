-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local Constants = require(RS.Modules.Custom.Constants)

local Helper = {}

Helper.GetBlockProbability = function(_opponantLevel)
	local minLevel, maxLevel = 1, 25
	local minProb, maxProb = 0.1, 0.9

	if _opponantLevel <= minLevel then return minProb end
	if _opponantLevel >= maxLevel then return maxProb end

	local t = (_opponantLevel - minLevel) / (maxLevel - minLevel)
	return minProb + (maxProb - minProb) * t
end

Helper.GetAttackCoolDown = function(level)
	local cooldownPoints = {
		{level = 1, value = 2.5},
		{level = 3, value = 2.2},
		{level = 5, value = 1.8},
		{level = 8, value = 1.5},
		{level = 10, value = 1.2},
		{level = 25, value = 0.8},
		{level = 50, value = 0.6},
	}

	if level >= 50 then return 0.6 end
	if level <= 1 then return 2.5 end

	for i = 1, #cooldownPoints - 1 do
		local a = cooldownPoints[i]
		local b = cooldownPoints[i + 1]

		if level >= a.level and level < b.level then
			local t = (level - a.level) / (b.level - a.level)
			return a.value + (b.value - a.value) * t
		end
	end

	return 2.5
end

Helper.GetBlockCoolDown = function(_opponentLevel)
	local minLevel, maxLevel = 1, 25
	local minCD, maxCD = 3, 8

	if _opponentLevel <= minLevel then return maxCD end
	if _opponentLevel >= maxLevel then return minCD end

	local t = (_opponentLevel - minLevel) / (maxLevel - minLevel)
	local curved = math.pow(1 - t, 2) -- ease-in-out style

	return minCD + (maxCD - minCD) * curved
end

Helper.GetTargetPlayerLevel = function(_target)
	local TargetLevel = game.Players:FindFirstChild(_target.Name) do
		if TargetLevel then
			return TargetLevel.Progression.LEVEL.Value
		end
	end

	return 1
end

Helper.GetTarget = function(_npc, _trigger, _root)
	local Trigger :Part = _trigger
	local Position :Vector3 = _root.Position

	local Targets = {}

	local overlaps :OverlapParams = OverlapParams.new()
	overlaps.FilterDescendantsInstances = {_npc}

	for _, part in pairs(workspace:GetPartsInPart(Trigger, overlaps)) do
		if part.Parent:IsA("Model") and part.Parent:HasTag(Constants.Tags.PlayerAvatar) then
			if not table.find(Targets, part.Parent) then
				table.insert(Targets, part.Parent)
			end
		end
	end

	local Target = Helper.GetNearest(Position, Targets)
	return Target
end

Helper.GetNearest = function(position, targets)

	local myPos = position

	local nearestDistance = math.huge
	local nearest : Model = nil

	for i, char in pairs(targets) do
		if char then	
			if(char.PrimaryPart.Position - myPos).Magnitude < nearestDistance then
				nearestDistance = (char.PrimaryPart.Position - myPos).Magnitude
				nearest = char
			end			
		end
	end

	return nearest, nearestDistance
end

Helper.GetDamageRange = function(_opponentLevel)
	local minLevel, maxLevel = 1, 25
	local minMult, maxMult = 3, 15

	if _opponentLevel <= minLevel then
		return minMult
	elseif _opponentLevel >= maxLevel then
		return maxMult
	else
		local t = (_opponentLevel - minLevel) / (maxLevel - minLevel)
		return minMult + t * (maxMult - minMult)
	end
end

return Helper
