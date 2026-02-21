-- @ScriptType: ModuleScript
-- LevelUpService.lua
-- Sprint 3 (#17): Server-side level-up handler.
-- Listens for Progression.LEVEL changes on each player and fires the Replicate
-- remote to all OTHER clients so they can see the level-up VFX.

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Knit = require(RS.Packages.Knit)

local Replicate = RS.Remotes.Replicate

local LevelUpService = Knit.CreateService {
	Name = "LevelUpService",
	Client = {},
}

local playerLevelConns = {} -- userId -> connection

local function onPlayerAdded(plr)
	local function onCharAdded(char)
		-- Clean up previous connection for this player
		if playerLevelConns[plr.UserId] then
			playerLevelConns[plr.UserId]:Disconnect()
			playerLevelConns[plr.UserId] = nil
		end

		local progression = plr:WaitForChild("Progression", 10)
		if not progression then return end

		local levelValue = progression:WaitForChild("LEVEL", 10)
		if not levelValue then return end

		local lastLevel = levelValue.Value
		playerLevelConns[plr.UserId] = levelValue:GetPropertyChangedSignal("Value"):Connect(function()
			local newLevel = levelValue.Value
			if newLevel > lastLevel then
				-- Broadcast to all OTHER players so they see this player's VFX
				for _, otherPlayer in pairs(Players:GetPlayers()) do
					if otherPlayer ~= plr then
						Replicate:FireClient(otherPlayer, "LevelUp", plr, newLevel)
					end
				end
			end
			lastLevel = newLevel
		end)
	end

	plr.CharacterAdded:Connect(onCharAdded)
	if plr.Character then
		task.spawn(onCharAdded, plr.Character)
	end
end

local function onPlayerRemoving(plr)
	if playerLevelConns[plr.UserId] then
		playerLevelConns[plr.UserId]:Disconnect()
		playerLevelConns[plr.UserId] = nil
	end
end

function LevelUpService:KnitInit()
end

function LevelUpService:KnitStart()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	-- Handle existing players
	for _, plr in pairs(Players:GetPlayers()) do
		task.spawn(onPlayerAdded, plr)
	end
end

return LevelUpService
