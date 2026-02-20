-- @ScriptType: ModuleScript

local Tween = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local Modules = RS.Modules
local misc = require(Modules.Packages.Misc)
local Costs = require(script.Parent.Parent.Costs)
local Constants = require(RS.Modules.Custom.Constants)

local FireDropKick = RS.Assets.VFXs.Fire.DropKick
local Fire_Fire = RS.Assets.VFXs.Fire.Fire

local FireDropKickStamina = Costs.FireDropKickStamina
local FireDropKickXp = Costs.FireDropKickXp
local FireDropKickLvl = Costs.FireDropKickLvl
local FireDropKickDamageRange = Costs.FireDropKickDamageRange


return function(plr, direction, mouseaim)

	if plr.Character:FindFirstChild("Stamina").Value < FireDropKickStamina then return end
	if plr.CombatStats.Level.Value < FireDropKickLvl then return end

	plr.Character:FindFirstChild("Stamina").Value -= FireDropKickStamina


	local hrp = plr.Character:WaitForChild("HumanoidRootPart")


	local h = FireDropKick:Clone()

	h.Anchored = true
	h.CanCollide = false
	h.CFrame = hrp.CFrame * CFrame.new(0,-5,-45) * CFrame.fromEulerAnglesXYZ(-80,0,0)

	h.CastShadow = false
	h.Parent = workspace
	
	--Spawn VFX
	spawn(function()
		for i, v in pairs(h.Ex1:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(v:GetAttribute("EmitCount"))
			else
				Tween:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0.75, Range = 20}):Play()
				task.delay(0.26, function()
					Tween:Create(v, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0, Range = 0}):Play()
				end)
			end
		end

		spawn(function()
			for i, v in pairs(h.Ex2:GetChildren()) do
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
		wait(0.4)
		for i, v in pairs(h.Ex1:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = true
			else
				Tween:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0.75, Range = 20}):Play()
				task.delay(0.26, function()
					Tween:Create(v, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0, Range = 0}):Play()
				end)
			end
		end

		spawn(function()
			for i, v in pairs(h.Ex2:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = true
				else
					Tween:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0.75, Range = 20}):Play()
					task.delay(0.26, function()
						Tween:Create(v, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0, Range = 0}):Play()
					end)
				end
			end

		end)
		wait(0.62)
		for i, v in pairs(h.Ex1:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			else
				Tween:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0.75, Range = 20}):Play()
				task.delay(0.26, function()
					Tween:Create(v, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0, Range = 0}):Play()
				end)
			end
		end

		spawn(function()
			for i, v in pairs(h.Ex2:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				else
					Tween:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0.75, Range = 20}):Play()
					task.delay(0.26, function()
						Tween:Create(v, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0, Range = 0}):Play()
					end)
				end
			end

		end)
	end)
	
	--wait(0.15)
	local Hits = {}
	--print("FireDROP Spawned")
	h.Touched:Connect(function(hit:Instance)
		local char = hit.Parent
		local hum = char:FindFirstChild("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")

		if hum and char.Name ~= plr.Name then
			--print("FireDROP Checking ", not char.Humanoid:FindFirstChild(plr.Name), ((char:HasTag(Constants.Tags.PlayerAvatar) or char:HasTag(Constants.Tags.NPCAI))) )
			if not char.Humanoid:FindFirstChild(plr.Name) and (char:HasTag(Constants.Tags.PlayerAvatar) 
				or char:HasTag(Constants.Tags.NPCAI)) then

				if Hits[char] then
					--print("FireDROP Returning")
					return
				end
				
				local Exp = plr.Progression:FindFirstChild("EXP")
				if Exp then
					Exp.Value += FireDropKickXp
				end
				
				hrp.CFrame = CFrame.lookAt(hrp.Position, h.Position) * CFrame.Angles(0, math.pi, 0)
				--print('FireDROP Stared')
				misc.Ragdoll(char, 3)

				misc.StrongKnockback(hrp, 35, 45, 0.15, h)
				misc.UpKnockback(hrp, 35, 41, 0.15, h)
				Hits[char] = true
				
				--print("FireDROP ENDED")
				
				local Damage = math.random(FireDropKickDamageRange.X, FireDropKickDamageRange.Y)
				char.Humanoid:TakeDamage(Damage)
				
				local LastDamage = char:FindFirstChild("DamageBy") or Instance.new('ObjectValue', char)
				LastDamage.Name = "DamageBy"
				LastDamage.Value = plr.Character
				LastDamage:SetAttribute("Weapon", Constants.Weapons.Fire)
				
				local ef = Fire_Fire:Clone()
				ef.Parent = char:FindFirstChild("UpperTorso")
				Debris:AddItem(ef, 4)

				wait(4)

				Hits[char] = nil
			end
		end
	end)
	
	task.delay(2.5, function()
		
		h:Destroy()
	end)

end