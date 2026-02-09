-- @ScriptType: ModuleScript
-- SpawnProtectionService: Gives newly spawned players temporary invulnerability
-- and marks players inside designated SafeZone parts.
--
-- SETUP REQUIRED IN ROBLOX STUDIO:
-- 1. Create Part(s) in workspace named "SafeZone" (or tagged "SafeZone" via CollectionService)
-- 2. Set CanCollide = false, Transparency = 1, Anchored = true
-- 3. Size the part to cover the spawn/hub area
-- 4. The service will detect players inside these parts and set a "SafeZone" attribute

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Knit = require(RS.Packages.Knit)
local Costs = require(RS.Modules.Custom.Costs)

local SpawnProtectionService = Knit.CreateService {
	Name = "SpawnProtectionService",
	Client = {},
}

-- Configuration (from Costs.lua)
local FORCEFIELD_DURATION: number = Costs.SpawnProtectionDuration or 8
local SAFE_ZONE_CHECK_INTERVAL: number = 1

-- Track active safe zone parts
local safeZoneParts: {BasePart} = {}

----- Private Methods -----

local function giveForceField(character: Model)
	-- Remove existing ForceField if any
	local existing = character:FindFirstChildOfClass("ForceField")
	if existing then
		existing:Destroy()
	end

	local ff = Instance.new("ForceField")
	ff.Name = "SpawnProtection"
	ff.Visible = true
	ff.Parent = character

	-- Remove after duration
	task.delay(FORCEFIELD_DURATION, function()
		if ff and ff.Parent then
			ff:Destroy()
		end
	end)
end

local function isInsideSafeZone(position: Vector3): boolean
	for _, part in ipairs(safeZoneParts) do
		if part and part.Parent then
			-- Check if position is inside the part's bounding box
			local relativePos = part.CFrame:PointToObjectSpace(position)
			local halfSize = part.Size / 2
			if math.abs(relativePos.X) <= halfSize.X
				and math.abs(relativePos.Y) <= halfSize.Y
				and math.abs(relativePos.Z) <= halfSize.Z then
				return true
			end
		end
	end
	return false
end

local function updateSafeZoneStatus()
	for _, plr in ipairs(Players:GetPlayers()) do
		local char = plr.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local inZone = isInsideSafeZone(root.Position)
				-- Set attribute on both player and character for easy checking
				plr:SetAttribute("InSafeZone", inZone)
				char:SetAttribute("InSafeZone", inZone)
			end
		end
	end
end

local function collectSafeZoneParts()
	safeZoneParts = {}

	-- Collect by tag
	for _, part in ipairs(CS:GetTagged("SafeZone")) do
		if part:IsA("BasePart") then
			table.insert(safeZoneParts, part)
		end
	end

	-- Also collect by name in workspace
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "SafeZone" and not CS:HasTag(obj, "SafeZone") then
			CS:AddTag(obj, "SafeZone")
			table.insert(safeZoneParts, obj)
		end
	end

	print("[SpawnProtection] Found", #safeZoneParts, "safe zone parts")
end

local function onCharacterAdded(player: Player, character: Model)
	-- Give spawn protection ForceField
	giveForceField(character)
	
	-- Mark as in safe zone initially (spawn is assumed safe)
	player:SetAttribute("InSafeZone", true)
	character:SetAttribute("InSafeZone", true)
	
	-- After ForceField expires, rely on zone-based checking
	task.delay(FORCEFIELD_DURATION + 0.5, function()
		if character and character.Parent then
			local root = character:FindFirstChild("HumanoidRootPart")
			if root then
				local inZone = isInsideSafeZone(root.Position)
				player:SetAttribute("InSafeZone", inZone)
				character:SetAttribute("InSafeZone", inZone)
			end
		end
	end)
end

local function onPlayerAdded(player: Player)
	if player.Character then
		onCharacterAdded(player, player.Character)
	end
	player.CharacterAdded:Connect(function(char)
		onCharacterAdded(player, char)
	end)
end

----- Service Lifecycle -----

function SpawnProtectionService:KnitStart()
	-- Collect safe zone parts
	collectSafeZoneParts()

	-- Watch for new safe zone parts
	CS:GetInstanceAddedSignal("SafeZone"):Connect(function(instance)
		if instance:IsA("BasePart") then
			table.insert(safeZoneParts, instance)
		end
	end)

	-- Setup existing players
	for _, plr in ipairs(Players:GetPlayers()) do
		onPlayerAdded(plr)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)

	-- Periodic safe zone check (every 1s)
	task.spawn(function()
		while true do
			task.wait(SAFE_ZONE_CHECK_INTERVAL)
			updateSafeZoneStatus()
		end
	end)

	print("[SpawnProtection] Service started - ForceField duration:", FORCEFIELD_DURATION, "s")
end

function SpawnProtectionService:KnitInit()
	-- No-op, setup happens in KnitStart
end

----- Public API -----

-- Check if a player or character is currently protected
function SpawnProtectionService:IsProtected(playerOrCharacter: Instance): boolean
	-- Check ForceField first
	local char: Model
	if playerOrCharacter:IsA("Player") then
		char = playerOrCharacter.Character
	else
		char = playerOrCharacter
	end
	
	if char and char:FindFirstChildOfClass("ForceField") then
		return true
	end
	
	-- Check SafeZone attribute
	if playerOrCharacter:GetAttribute("InSafeZone") then
		return true
	end
	
	return false
end

return SpawnProtectionService
