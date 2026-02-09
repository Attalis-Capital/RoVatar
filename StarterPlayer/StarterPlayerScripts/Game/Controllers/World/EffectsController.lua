-- @ScriptType: ModuleScript
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local Knit = require(RS.Packages.Knit)

local player = game.Players.LocalPlayer

-- Effects --
local Effects = script.Parent.Parent.Parent.Helpers.Effects

-- EVENTS --
local Replicate = RS.Remotes.Replicate

-- Sprint 2: Combat Feel modules
local HitFeedback = require(RS.Modules.Custom.HitFeedback)
local ComboCounter = require(RS.Modules.Custom.ComboCounter)
local DeathScreen = require(RS.Modules.Custom.DeathScreen)

local EffectsController = Knit.CreateController {
	Name = "EffectsController",
}


-------------------------------->>>>>>>>>  <<<<<<<<<<-------------------------------

local function InitXPListener()
	-- Listen for EXP changes to show XP popups
	local function onCharAdded(char)
		local plr = game.Players.LocalPlayer
		local combatStats = plr:WaitForChild("CombatStats", 10)
		if not combatStats then return end

		local expValue = combatStats:WaitForChild("EXP", 10)
		if not expValue then return end

		local lastExp = expValue.Value
		expValue:GetPropertyChangedSignal("Value"):Connect(function()
			local newExp = expValue.Value
			local gained = newExp - lastExp
			if gained > 0 then
				HitFeedback.ShowXPPopup(gained)
			end
			lastExp = newExp
		end)
	end

	if player.Character then
		task.spawn(function() onCharAdded(player.Character) end)
	end
	player.CharacterAdded:Connect(function(char) 
		task.spawn(function() onCharAdded(char) end)
	end)
end

local function Init()

	local Combat = require(Effects.Combat)

	-- Sprint 2: Initialise combat feel systems
	ComboCounter.Init()
	DeathScreen.Init()
	InitXPListener()

	-- REMOTE HANDLER --
	Replicate.OnClientEvent:Connect(function(Action, ...)

			print("[Effect] ", Action)
		if workspace:GetAttribute("GameStarted") then
			if Action == "CamShake" then
				require(Effects.CameraShake)(...)
			elseif Action == "Hit" then
				require(Effects.Hit)(...)
			elseif Action == "Combat" then
				--require(Effects.Combat)(...)
				Combat.Perform(...)

				-- Sprint 2: Register hits for combo counter and screen flash
				local args = {...}
				local subAction = args[1]
				if subAction == "HitFX" then
					ComboCounter.RegisterHit()
					HitFeedback.ScreenFlash(Color3.fromRGB(255, 255, 255), 0.15, 0.15)
				end
			elseif Action == "DamageIndicator" then
				-- Existing damage indicator handling
				local args = {...}
				local targetModel = args[1]
				local damage = args[2]
				if targetModel and targetModel:FindFirstChild("HumanoidRootPart") then
					HitFeedback.ShowDamageNumber(targetModel.HumanoidRootPart, damage)
				end
			elseif Action == "EnemyKilled" then
				-- Sprint 2: Kill feedback
				local args = {...}
				local enemyName = args[1] or "Enemy"
				HitFeedback.ShowKillBanner(enemyName)
			end
		end
	end)

end


function EffectsController:KnitInit()

end

function EffectsController:KnitStart()
	Init()
end

return EffectsController