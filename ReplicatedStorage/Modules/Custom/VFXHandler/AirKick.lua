-- @ScriptType: ModuleScript

local Tween = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")

local Modules = RS.Modules
local misc = require(Modules.Packages.Misc)

local AirThrust = RS.Assets.VFXs.Air.AirThrust
local Costs = require(script.Parent.Parent.Costs)
local Constants = require(RS.Modules.Custom.Constants)

local AirKickCost = Costs.AirKickStamina
local AirKickXp = Costs.AirKickXp
local AirKickLvl = Costs.AirKickLvl
local AirKickDamageRange = Costs.AirKickDamageRange

return function(plr, direction, mouseaim)

	if plr.Character:FindFirstChild("Stamina").Value < AirKickCost then return end
	if plr.CombatStats.Level.Value < AirKickLvl then return end
	plr.Character:FindFirstChild("Stamina").Value -= AirKickCost

	local OnHit = false
	local Alive = true

	local hrp = plr.Character:WaitForChild("HumanoidRootPart")

	local Hits = {}
	
	local _velocity = CFrame.new(hrp.Position, mouseaim).LookVector * 90
	wait(0.2)
	
	local airThrust = AirThrust:Clone()
	local BV = Instance.new("BodyVelocity")
	BV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
	BV.Velocity = _velocity
	BV.Parent = airThrust
	
	game.Debris:AddItem(BV,4)
	
	airThrust.CanCollide = false
	airThrust.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,5,-13) * CFrame.fromEulerAnglesXYZ(0,0,0)

	airThrust.CastShadow = false
	airThrust.Parent = workspace
	
	spawn(function()
		for i, v in pairs(airThrust.Attachment:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = true
			else
				Tween:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0.75, Range = 20}):Play()
				task.delay(0.26, function()
					Tween:Create(v, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0, Range = 0}):Play()
				end)
			end
		end
		
		wait(3)
		
		spawn(function()
			for i, v in pairs(airThrust.Attachment:GetChildren()) do
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
	
	airThrust.Touched:Connect(function(hit)
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
					Exp.Value += AirKickXp
				end
				
				--hrp.CFrame = CFrame.lookAt(hrp.Position, airThrust.Position) * CFrame.Angles(0, math.pi, 0)
				misc.Ragdoll(char, 1.5)
				
				misc.StrongKnockback(hrp, 35, 45, 0.15, airThrust)
				misc.UpKnockback(hrp, 35, 65, 0.15, airThrust)
				
				local Damage = math.random(AirKickDamageRange.X, AirKickDamageRange.Y)
				hum:TakeDamage(Damage)
				
				local LastDamage = hum.Parent:FindFirstChild("DamageBy") or Instance.new('ObjectValue', hum.Parent)
				LastDamage.Name = "DamageBy"
				LastDamage.Value = plr.Character
				LastDamage:SetAttribute("Weapon", Constants.Weapons.Air)
				
				task.delay(4, function()
					Hits[char] = nil
				end)
			end
		end
	end)

	wait(4)

	airThrust:Destroy()
end