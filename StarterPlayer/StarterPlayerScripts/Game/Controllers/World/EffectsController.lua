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

-- Inlined from: Game/Helpers/Effects/CameraShake.lua (cleanup sprint)
local cameraShaker = require(RS.Modules.Packages.CameraShaker)
local camera = workspace.CurrentCamera
local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	camera.CFrame = camera.CFrame * shakeCFrame
end)
local function CameraShake(Position, shakeStrength, maxMagnitude)
	local shakeMagnitude = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Position).Magnitude
	if shakeMagnitude < maxMagnitude then
		camShake:Start()
		if shakeMagnitude >= 0 and shakeMagnitude < maxMagnitude/4 then
			camShake:ShakeOnce(shakeStrength/1.5, shakeStrength * 2, 0, 0.7)
		elseif shakeMagnitude > maxMagnitude/4 and shakeMagnitude < maxMagnitude/3 then
			camShake:ShakeOnce(shakeStrength/5, shakeStrength * 1.5, 0, 1)
		elseif shakeMagnitude > maxMagnitude/3 and shakeMagnitude < maxMagnitude/2 then
			camShake:ShakeOnce(shakeStrength/7.5, shakeStrength * 1, 0, 1.2)
		elseif shakeMagnitude > maxMagnitude/3.5 and shakeMagnitude < maxMagnitude then
			camShake:ShakeOnce(shakeStrength/10, shakeStrength * 0.5, 0, 1.5)
		end
	end
end

-- Sprint 3: Progression modules
local VFXHandler = require(RS.Modules.Custom.VFXHandler)
local SFXHandler = require(RS.Modules.Custom.SFXHandler)
local Constants = require(RS.Modules.Custom.Constants)
local Costs = require(RS.Modules.Custom.Costs)

local EffectsController = Knit.CreateController {
	Name = "EffectsController",
}


-------------------------------->>>>>>>>>  <<<<<<<<<<-------------------------------

-- Sprint 3 (#19): Store connection reference to prevent XP listener leak
local xpListenerConn = nil

local function InitXPListener()
	-- Listen for EXP changes to show XP popups
	local function onCharAdded(char)
		-- (#19) Disconnect previous listener before creating a new one
		if xpListenerConn then
			xpListenerConn:Disconnect()
			xpListenerConn = nil
		end

		local plr = game.Players.LocalPlayer
		local progression = plr:WaitForChild("Progression", 10)
		if not progression then return end

		local expValue = progression:WaitForChild("EXP", 10)
		if not expValue then return end

		local lastExp = expValue.Value
		xpListenerConn = expValue:GetPropertyChangedSignal("Value"):Connect(function()
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

-- Sprint 3 (#17): Level-up celebration listener
local levelListenerConn = nil

local function InitLevelUpListener()
	local function onCharAdded(char)
		-- Disconnect previous listener
		if levelListenerConn then
			levelListenerConn:Disconnect()
			levelListenerConn = nil
		end

		local plr = game.Players.LocalPlayer
		local progression = plr:WaitForChild("Progression", 10)
		if not progression then return end

		local levelValue = progression:WaitForChild("LEVEL", 10)
		if not levelValue then return end

		local lastLevel = levelValue.Value
		levelListenerConn = levelValue:GetPropertyChangedSignal("Value"):Connect(function()
			local newLevel = levelValue.Value
			if newLevel > lastLevel then
				-- Play client-side VFX and SFX
				VFXHandler:PlayEffect(plr, "LevelUp", newLevel)
				SFXHandler:Play(Constants.SFXs.LevelUp, true)

				-- Show level-up banner
				HitFeedback.ShowLevelUpBanner(newLevel)

				-- Server broadcasts LevelUp to other players via LevelUpService

				-- (#18) Check for ability unlock at this level
				local unlocks = {
					[Costs.AirKickLvl] = "Air Bending",
					[Costs.FireDropKickLvl] = "Fire Bending",
					[Costs.EarthStompLvl] = "Earth Bending",
					[Costs.WaterStanceLvl] = "Water Bending",
				}

				local unlockedAbility = unlocks[newLevel]
				if unlockedAbility then
					task.delay(2.5, function()
						HitFeedback.ShowAbilityUnlockBanner(unlockedAbility, newLevel)
						SFXHandler:Play(Constants.SFXs.LevelUp, true)
						VFXHandler:PlayEffect(plr, "LevelUp", newLevel)
					end)
				end
			end
			lastLevel = newLevel
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

	-- Sprint 3: Initialise progression systems
	InitLevelUpListener()

	-- REMOTE HANDLER --
	Replicate.OnClientEvent:Connect(function(Action, ...)

			print("[Effect] ", Action)
		if workspace:GetAttribute("GameStarted") then
			if Action == "CamShake" then
				CameraShake(...)
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
			elseif Action == "LevelUp" then
				-- Sprint 3 (#17): Another player levelled up - show their VFX
				local args = {...}
				local targetPlayer = args[1]
				local newLevel = args[2]
				if targetPlayer and targetPlayer ~= player then
					VFXHandler:PlayEffect(targetPlayer, "LevelUp", newLevel)
				end
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
