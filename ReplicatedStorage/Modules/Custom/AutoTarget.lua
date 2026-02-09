-- @ScriptType: ModuleScript
-- AutoTarget.lua
-- Finds the nearest valid enemy (NPC or player) within range for ability targeting.
-- Used by CharacterController to auto-lock when firing abilities without a manual target.

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local AutoTarget = {}

local DEFAULT_RANGE = 60
local DEFAULT_FOV_DOT = -0.5 -- ~120 degree cone in front of player (dot product threshold)

-- Get all valid target humanoids in workspace
local function getTargetModels()
	local targets = {}

	-- NPCs tagged with NPCAI under the attacking folder
	local attackingFolder = workspace:FindFirstChild("Scripted_Items")
	if attackingFolder then
		local npcsFolder = attackingFolder:FindFirstChild("NPCs")
		if npcsFolder then
			local attacking = npcsFolder:FindFirstChild("Attacking")
			if attacking then
				for _, npc in ipairs(attacking:GetDescendants()) do
					if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
						if CollectionService:HasTag(npc, "NPCAI") then
							local hum = npc:FindFirstChild("Humanoid")
							if hum and hum.Health > 0 then
								table.insert(targets, npc)
							end
						end
					end
				end
			end
		end
	end

	-- Other players (for PvP, SafeZone check done upstream)
	local localPlayer = Players.LocalPlayer
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= localPlayer and plr.Character then
			local hum = plr.Character:FindFirstChild("Humanoid")
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hum and hrp and hum.Health > 0 then
				table.insert(targets, plr.Character)
			end
		end
	end

	return targets
end

--- Find the nearest enemy to the player within range and FOV cone.
--- @param character Model - the local player's character
--- @param maxRange number? - optional max distance (default 60)
--- @param fovDot number? - optional dot product threshold for FOV filter (default -0.5)
--- @return Model? - the nearest enemy model, or nil
function AutoTarget.FindNearest(character, maxRange, fovDot)
	if not character then return nil end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	maxRange = maxRange or DEFAULT_RANGE
	fovDot = fovDot or DEFAULT_FOV_DOT

	local playerPos = root.Position
	local lookVector = root.CFrame.LookVector

	local nearest = nil
	local nearestDist = maxRange + 1

	for _, model in ipairs(getTargetModels()) do
		if model ~= character then
			local targetRoot = model:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				local offset = (targetRoot.Position - playerPos)
				local dist = offset.Magnitude

				if dist <= maxRange then
					-- FOV check: ensure target is roughly in front of player
					local direction = offset.Unit
					local dot = lookVector:Dot(direction)

					if dot > fovDot then
						if dist < nearestDist then
							nearestDist = dist
							nearest = model
						end
					end
				end
			end
		end
	end

	return nearest
end

--- Get the position of the nearest enemy's HumanoidRootPart.
--- Convenience wrapper for ability targeting.
--- @param character Model
--- @param maxRange number?
--- @return Vector3? - target position, or nil if no target found
function AutoTarget.FindNearestPosition(character, maxRange)
	local target = AutoTarget.FindNearest(character, maxRange)
	if target then
		local hrp = target:FindFirstChild("HumanoidRootPart")
		if hrp then
			return hrp.Position
		end
	end
	return nil
end

return AutoTarget
