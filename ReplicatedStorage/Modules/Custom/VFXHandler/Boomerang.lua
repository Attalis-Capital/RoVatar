-- @ScriptType: ModuleScript

local Tween = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Modules = RS.Modules
local misc = require(Modules.Packages.Misc)

local Replicate = RS.Remotes.Replicate

local SpinBlade = script.Boomerang
local Costs = require(script.Parent.Parent.Costs)
local Constants = require(RS.Modules.Custom.Constants)

local DamageCalc = require(RS.Modules.Custom.CommonFunctions.Utils.DamageCalc)

local BoomerangDamageRange = Costs.BoomerangDamageRange
local BoomerangXP = Costs.BoomerangXP

local function ToggleBoomerang(enable, character)
	if enable then
		local Boomerang = character:FindFirstChild("Boomerang")
		if Boomerang then
			Boomerang.Handle.Weapon.H.Transparency = 0
			Boomerang.Handle.Weapon.J.Transparency = 0
		end
	else
		local Boomerang = character:FindFirstChild("Boomerang")
		if Boomerang then
			Boomerang.Handle.Weapon.H.Transparency = 1
			Boomerang.Handle.Weapon.J.Transparency = 1
		end
	end
end

return function(plr, direction, mouseaim)

	local OnHit = false
	local Alive = true
	
	local Char = plr.Character
	local hrp = Char:WaitForChild("HumanoidRootPart")
	local Torso = Char:WaitForChild("UpperTorso")
	
	local Hits = {}

	local infNum = math.huge
	
	local beam = SpinBlade:Clone()
	beam.Anchored = false
	beam.CanCollide = false

	beam.CFrame = CFrame.new((hrp.CFrame*CFrame.new(0, 1, -1)).Position, mouseaim)
	beam.Parent = workspace

	local BV = Instance.new("BodyVelocity", beam)
	BV.MaxForce = Vector3.new(
		infNum,
		infNum,
		infNum
	)
	local DistanceF = math.clamp((mouseaim - hrp.Position).Magnitude, 40, 80)
	BV.Velocity = CFrame.new(hrp.Position, mouseaim).LookVector * DistanceF
	spawn(function()
		ToggleBoomerang(false, Char)
		wait((DistanceF/100)*2)
		BV:Destroy()

		local BV2 = Instance.new("BodyVelocity", beam)
		BV2.MaxForce = Vector3.new(
			infNum,
			infNum,
			infNum
		)
		local DistanceR =  math.clamp((mouseaim - hrp.Position).Magnitude, 40, 80)
		BV2.Velocity = CFrame.new(hrp.Position, mouseaim).LookVector * -DistanceR
		wait((DistanceR/100)*2)
		
		ToggleBoomerang(true, Char)
		beam:Destroy()
		
	end)

	beam.Touched:Connect(function(hit)
		
		local char = hit.Parent
		local hum = char:FindFirstChild("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")

		if hum and char.Name ~= plr.Name then
			if not hum:FindFirstChild(plr.Name) and (char:HasTag(Constants.Tags.PlayerAvatar) 
				or char:HasTag(Constants.Tags.NPCAI)) then
	
				if Hits[char.Name] then
					return
				end
				Hits[hit.Parent.Name] = true

				-- SafeZone: block PvP if either player is in safe zone
				local victimPlayer = Players:GetPlayerFromCharacter(hit.Parent)
				if victimPlayer and (plr.Character:GetAttribute("InSafeZone") or hit.Parent:GetAttribute("InSafeZone")) then return end

				hit.Parent.HumanoidRootPart.CFrame = CFrame.lookAt(hit.Parent.HumanoidRootPart.Position, beam.Position) * CFrame.Angles(0, math.pi, 0)
				misc.Ragdoll(char, 1.5)

				misc.UpKnockback(hit.Parent.HumanoidRootPart, 35, 65, 0.15, beam)
				Replicate:FireAllClients("Combat", "HitFX", hit.Parent.HumanoidRootPart, "Blade Hit")

				local Exp = plr.Progression:FindFirstChild("EXP")
				if Exp then
					Exp.Value += BoomerangXP
				end

				local baseDamage = math.random(BoomerangDamageRange.X, BoomerangDamageRange.Y)
				local Damage = DamageCalc.Calculate(baseDamage, DamageCalc.GetPlayerLevel(plr), 0)
				hum:TakeDamage(Damage)
				
				local color1 = Color3.fromRGB(187, 0, 5)
				local color2 = Color3.fromRGB(255, 239, 253)
				beam.Trail.Color = ColorSequence.new(color1, color2)
				
				local LastDamage = hum.Parent:FindFirstChild("DamageBy") or Instance.new('ObjectValue', hum.Parent)
				LastDamage.Name = "DamageBy"
				LastDamage.Value = plr.Character
				LastDamage:SetAttribute("Weapon", Constants.Weapons.Boomerang)
				
				task.delay(4, function()
					Hits[char.Name] = nil
				end)
				
			end
		end

	end)

end
