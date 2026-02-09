-- @ScriptType: ModuleScript
-- SafeZoneUtils: Prevents PVP damage in designated safe zones
-- Sprint 1 - First-Session Survival
-- 
-- HOW IT WORKS:
-- 1. SafeZoneEnforcer (server script) monitors player positions
-- 2. When a player enters a SafeZone, sets character attribute "InSafeZone" = true
-- 3. Combat scripts check for this attribute before applying PvP damage
-- 4. NPC/PvE damage is unaffected
--
-- STUDIO SETUP REQUIRED:
-- 1. Create a Part in Workspace named "SafeZone" around the spawn area
-- 2. Set Anchored = true, CanCollide = false, Transparency = 0.8
-- 3. Add CollectionService tag "SafeZone" to the part
-- 4. Size it to cover the spawn area (e.g. 100x50x100 studs)

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local SafeZoneUtils = {}

-- Cache safe zone parts
local safeZoneParts = {}

local function refreshSafeZones()
	safeZoneParts = CollectionService:GetTagged("SafeZone")
end

CollectionService:GetInstanceAddedSignal("SafeZone"):Connect(refreshSafeZones)
CollectionService:GetInstanceRemovedSignal("SafeZone"):Connect(refreshSafeZones)
refreshSafeZones()

-- Check if a position is inside any SafeZone part
function SafeZoneUtils.IsPositionInSafeZone(position: Vector3): boolean
	for _, zonePart in ipairs(safeZoneParts) do
		if zonePart and zonePart:IsA("BasePart") then
			local relativePos = zonePart.CFrame:PointToObjectSpace(position)
			local halfSize = zonePart.Size / 2
			if math.abs(relativePos.X) <= halfSize.X
				and math.abs(relativePos.Y) <= halfSize.Y
				and math.abs(relativePos.Z) <= halfSize.Z then
				return true
			end
		end
	end
	return false
end

-- Check if a character is in a safe zone (uses cached attribute for performance)
function SafeZoneUtils.IsInSafeZone(character: Model): boolean
	if not character then return false end
	return character:GetAttribute("InSafeZone") == true
end

-- Should PvP damage be blocked? Returns true to PREVENT damage
-- Only blocks player-vs-player. PvE is always allowed.
function SafeZoneUtils.ShouldBlockPvPDamage(attackerChar: Model, victimChar: Model): boolean
	if not attackerChar or not victimChar then return false end
	
	-- Only block if both are players
	local attackerPlayer = Players:GetPlayerFromCharacter(attackerChar)
	local victimPlayer = Players:GetPlayerFromCharacter(victimChar)
	if not attackerPlayer or not victimPlayer then return false end
	
	-- Block if either is in safe zone
	return SafeZoneUtils.IsInSafeZone(attackerChar) or SafeZoneUtils.IsInSafeZone(victimChar)
end

-- Server-side: Start monitoring all players for safe zone entry/exit
-- Call this once from a server script
function SafeZoneUtils.StartEnforcement()
	local CHECK_INTERVAL = 0.5 -- seconds between position checks
	
	task.spawn(function()
		while true do
			for _, player in ipairs(Players:GetPlayers()) do
				local char = player.Character
				if char then
					local hrp = char:FindFirstChild("HumanoidRootPart")
					if hrp then
						local inZone = SafeZoneUtils.IsPositionInSafeZone(hrp.Position)
						char:SetAttribute("InSafeZone", inZone)
					end
				end
			end
			task.wait(CHECK_INTERVAL)
		end
	end)
end

return SafeZoneUtils
