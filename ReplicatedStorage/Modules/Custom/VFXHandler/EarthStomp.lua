-- @ScriptType: ModuleScript

local Tween = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local Modules = RS.Modules
local misc = require(Modules.Packages.Misc)
local Costs = require(script.Parent.Parent.Costs)
local Constants = require(RS.Modules.Custom.Constants)

local EarthSpike = RS.Assets.VFXs.Earth.Spike
local EarthSpikeHit = RS.Assets.VFXs.Earth.SpikeHit

local DamageCalc = require(RS.Modules.Custom.CommonFunctions.Utils.DamageCalc)
local ElementXp = require(RS.Modules.Custom.CommonFunctions.Utils.ElementXp)

local EarthStompStamina = Costs.EarthStompStamina
local EarthStompXp = Costs.EarthStompXp
local EarthStompLvl = Costs.EarthStompLvl
local EarthStompDamageRange = Costs.EarthStompDamageRange
local EarthStompElementXp = Costs.EarthStompElementXp
local EarthStompMaxDistance = 200


return function(plr, direction, mouseaim)

	if plr.Character:FindFirstChild("Stamina").Value < EarthStompStamina then return end
	if plr.Progression.LEVEL.Value < EarthStompLvl then return end

	plr.Character:FindFirstChild("Stamina").Value -= EarthStompStamina

	local OnHit = false
	local Alive = true

	local hrp = plr.Character:WaitForChild("HumanoidRootPart")

	local Kick = EarthSpike:Clone()
	Kick.Parent = workspace
	Kick.CanCollide = false
	Kick.Anchored = true
	Kick.CFrame = CFrame.new(mouseaim) * CFrame.new(0,-1,0)
	Kick.Orientation = Kick.Orientation + Vector3.new(0,0,0)
	Kick.Transparency = 1
	
	local distance = (Kick.Position - hrp.Position).Magnitude
	local infNum = math.huge

	if distance > EarthStompMaxDistance then
		Debris:AddItem(Kick, 0.1)
		return
	end
	
	Kick.Transparency = 0

	--- Play Tween on Kick
	local part = Kick
	local tweenInfo = TweenInfo.new(
		0.8, -- Time
		Enum.EasingStyle.Bounce, -- EasingStyle
		Enum.EasingDirection.Out, -- EasingDirection
		0, -- RepeatCount (when less than zero the tween will loop indefinitely)
		true, -- Reverses (tween will reverse once reaching it's goal)
		0 -- DelayTime
	)
	local tweenInfo2 = TweenInfo.new(
		1, -- Time
		Enum.EasingStyle.Bounce, -- EasingStyle
		Enum.EasingDirection.Out, -- EasingDirection
		0, -- RepeatCount (when less than zero the tween will loop indefinitely)
		false, -- Reverses (tween will reverse once reaching it's goal)
		0 -- DelayTime
	)
	local tween = Tween:Create(part, tweenInfo, { Size = Vector3.new(7, 50, 7) })
	tween:Play()
	spawn(function()
		local tween2 = Tween:Create(part, tweenInfo2, { Transparency = 1 })
		wait(1.2)
		tween2:Play()
	end)

	--Play SpikeHit and Particle effects
	local hitbox = EarthSpikeHit:Clone()
	hitbox.Parent = workspace
	hitbox.CFrame = Kick.CFrame * CFrame.new(0,0,0)

	spawn(function()
		for i, v in pairs(Kick.Attachment:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(v:GetAttribute("EmitCount"))
			else
				Tween:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0.75, Range = 20}):Play()
				task.delay(0.26, function()
					Tween:Create(v, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0, Range = 0}):Play()
				end)
			end
		end

	end)

	-- Listen for SpikeHit touch
	local Hits = {}
	hitbox.Touched:Connect(function(hit)
		local char = hit.Parent
		local hum = char:FindFirstChild("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")

		if hum and char.Name ~= plr.Name then
			if not hum:FindFirstChild(plr.Name) and (char:HasTag(Constants.Tags.PlayerAvatar) 
				or char:HasTag(Constants.Tags.NPCAI)) then
				if Hits[char] then
					return
				end
				Hits[char] = true
				local Exp = plr.Progression:FindFirstChild("EXP")
				if Exp then
					Exp.Value += EarthStompXp
				end
				ElementXp.Award(plr, "Earth", EarthStompElementXp)

				hrp.CFrame = CFrame.lookAt(hrp.Position, Kick.Position) * CFrame.Angles(0, math.pi, 0)
				misc.Ragdoll(char, 1.5)

				misc.UpKnockback(hrp, 56, 125, 0.15, hitbox)

				local baseDamage = math.random(EarthStompDamageRange.X, EarthStompDamageRange.Y)
				local Damage = DamageCalc.Calculate(baseDamage, DamageCalc.GetPlayerLevel(plr), DamageCalc.GetElementLevel(plr, "Earth"))
				char.Humanoid:TakeDamage(Damage)
				
				local LastDamage = char:FindFirstChild("DamageBy") or Instance.new('ObjectValue', char)
				LastDamage.Name = "DamageBy"
				LastDamage.Value = plr.Character
				LastDamage:SetAttribute("Weapon", Constants.Weapons.Earth)
				
				wait(4)

				Hits[char] = nil
			end
		end
	end)
	
	wait(0.5)
	hitbox:Destroy()

	wait(2)
	Kick:Destroy()
end