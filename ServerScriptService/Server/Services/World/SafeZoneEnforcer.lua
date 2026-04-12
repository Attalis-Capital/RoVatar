-- @ScriptType: Script
-- SafeZoneEnforcer: Server script that monitors player positions and sets InSafeZone attribute
-- Location: ServerScriptService/Server/Services/World/SafeZoneEnforcer.lua
-- Sprint 1 - First-Session Survival
-- Inlined from: ReplicatedStorage/Modules/Custom/SafeZoneUtils.lua (cleanup sprint)
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

-- Cache safe zone parts
local safeZoneParts = {}

local function refreshSafeZones()
	safeZoneParts = CollectionService:GetTagged("SafeZone")
end

CollectionService:GetInstanceAddedSignal("SafeZone"):Connect(refreshSafeZones)
CollectionService:GetInstanceRemovedSignal("SafeZone"):Connect(refreshSafeZones)
refreshSafeZones()

-- Check if a position is inside any SafeZone part
local function IsPositionInSafeZone(position: Vector3): boolean
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

-- Start monitoring all players for safe zone entry/exit
local CHECK_INTERVAL = 0.5 -- seconds between position checks

task.spawn(function()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			local char = player.Character
			if char then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					local inZone = IsPositionInSafeZone(hrp.Position)
					char:SetAttribute("InSafeZone", inZone)
				end
			end
		end
		task.wait(CHECK_INTERVAL)
	end
end)

print("[SafeZoneEnforcer] Started - PvP disabled in SafeZone areas")
