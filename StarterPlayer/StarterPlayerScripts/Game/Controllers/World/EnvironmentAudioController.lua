-- @ScriptType: ModuleScript
-- EnvironmentAudioController.lua
-- Sprint 7 (#6): Proximity-based environmental audio.
-- Plays lava SFX near LavaZone-tagged parts and wind SFX at altitude.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Knit = require(RS.Packages.Knit)

local CustomModules = RS.Modules.Custom
local Constants = require(CustomModules.Constants)
local SFXHandler = require(CustomModules.SFXHandler)

local player = Players.LocalPlayer

local EnvironmentAudioController = Knit.CreateController {
	Name = "EnvironmentAudioController",
}

-- Config
local LAVA_RANGE = 60
local WIND_HEIGHT = 200
local POLL_INTERVAL = 0.5

-- State
local lavaZones: { BasePart } = {}
local activeLavaPart: BasePart? = nil
local activeLavaSound = false
local activeWindSound = false

local function addLavaZone(part: BasePart)
	if part:IsA("BasePart") then
		table.insert(lavaZones, part)
	end
end

local function removeLavaZone(part: BasePart)
	for i, zone in lavaZones do
		if zone == part then
			table.remove(lavaZones, i)
			break
		end
	end
end

local function findNearestLavaZone(position: Vector3): (BasePart?, number)
	local nearest: BasePart? = nil
	local nearestDist = math.huge
	for _, zone in lavaZones do
		local dist = (zone.Position - position).Magnitude
		if dist < nearestDist then
			nearestDist = dist
			nearest = zone
		end
	end
	return nearest, nearestDist
end

local function stopAllSounds()
	if activeLavaSound and activeLavaPart then
		SFXHandler:Stop(Constants.SFXs.Env_Lava, activeLavaPart)
		activeLavaSound = false
		activeLavaPart = nil
	end
	if activeWindSound then
		SFXHandler:Stop(Constants.SFXs.Env_WindHeight)
		activeWindSound = false
	end
end

local function poll()
	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local position = root.Position

	-- Lava proximity
	local nearest, dist = findNearestLavaZone(position)
	if nearest and dist < LAVA_RANGE then
		if not activeLavaSound or activeLavaPart ~= nearest then
			-- Stop old lava sound if switching parts
			if activeLavaSound and activeLavaPart then
				SFXHandler:Stop(Constants.SFXs.Env_Lava, activeLavaPart)
			end
			SFXHandler:PlayAlong(Constants.SFXs.Env_Lava, nearest)
			activeLavaPart = nearest
			activeLavaSound = true
		end
	else
		if activeLavaSound and activeLavaPart then
			SFXHandler:Stop(Constants.SFXs.Env_Lava, activeLavaPart)
			activeLavaSound = false
			activeLavaPart = nil
		end
	end

	-- Wind at altitude
	if position.Y > WIND_HEIGHT then
		if not activeWindSound then
			SFXHandler:Play(Constants.SFXs.Env_WindHeight, true)
			activeWindSound = true
		end
	else
		if activeWindSound then
			SFXHandler:Stop(Constants.SFXs.Env_WindHeight)
			activeWindSound = false
		end
	end
end

function EnvironmentAudioController:KnitInit()
end

function EnvironmentAudioController:KnitStart()
	-- Populate initial lava zones
	for _, part in CollectionService:GetTagged(Constants.Tags.LavaZone) do
		addLavaZone(part)
	end
	CollectionService:GetInstanceAddedSignal(Constants.Tags.LavaZone):Connect(addLavaZone)
	CollectionService:GetInstanceRemovedSignal(Constants.Tags.LavaZone):Connect(removeLavaZone)

	-- Reset sounds on respawn
	player.CharacterAdded:Connect(function()
		stopAllSounds()
	end)

	-- Start polling loop
	task.spawn(function()
		while true do
			poll()
			task.wait(POLL_INTERVAL)
		end
	end)
end

return EnvironmentAudioController
