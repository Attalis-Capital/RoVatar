-- @ScriptType: Script
script.Parent.OnServerEvent:Connect(function(plr,direction,mouseaim)
	local OnHit = false
	local Alive = true
	local RS = game:GetService("ReplicatedStorage")

	local Remotes = RS.Remotes
	local Replicate = Remotes.Replicate
	local hrp = plr.Character:WaitForChild("HumanoidRootPart")

	-- Server-side level check
	local Costs = require(game:GetService("ReplicatedStorage").Modules.Custom.Costs)
	if plr.Progression and plr.Progression:FindFirstChild("LEVEL") then
		if plr.Progression.LEVEL.Value < Costs.AirKickLvl then return end
	end

	-- Server-side cooldown
	if not plr:GetAttribute("AirKickCD") then
		plr:SetAttribute("AirKickCD", true)
		task.delay(Costs.Abilities, function()
			plr:SetAttribute("AirKickCD", nil)
		end)
	else
		return
	end

	local Hits = {}
	local Modules = RS.Modules
	local misc = require(Modules.Packages.Misc)
	local CS = game:GetService("CollectionService")


local TS = game:GetService("TweenService")
	local Tween = game:GetService("TweenService")

wait(0.2)
	if	plr.Character:FindFirstChild("Stamina").Value >= Costs.AirKickStamina then
		plr.Character:FindFirstChild("Stamina").Value = 	plr.Character:FindFirstChild("Stamina").Value -Costs.AirKickStamina
	end
	local h = RS.Assets.VFXs.Air.AirThrust:Clone()
	local BV = Instance.new("BodyVelocity")
	BV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
	BV.Velocity = CFrame.new(plr.Character.HumanoidRootPart.Position,mouseaim).LookVector * 90
	BV.Parent = h
	game.Debris:AddItem(BV,4)
	h.CanCollide = false
	h.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,5,-23) * CFrame.fromEulerAnglesXYZ(0,0,0)

	h.CastShadow = false
	h.Parent = workspace
	spawn(function()
		for i, v in pairs(h.Attachment:GetChildren()) do
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
			for i, v in pairs(h.Attachment:GetChildren()) do
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
	wait(0.15)
	h.Touched:Connect(function(hit)
		if hit.Parent:FindFirstChild("Humanoid") and hit.Parent.Name ~= plr.Name then
			if not hit.Parent.Humanoid:FindFirstChild(plr.Name) then
				if Hits[hit.Parent.Name] then
					return
				end
			
		

				local Exp = plr.Progression:FindFirstChild("EXP")
				if Exp then
					Exp.Value += Costs.AirKickXp
				end


				hit.Parent.HumanoidRootPart.CFrame = CFrame.lookAt(hit.Parent.HumanoidRootPart.Position, h.Position) * CFrame.Angles(0, math.pi, 0)
				misc.Ragdoll(hit.Parent, 1.5)

				misc.StrongKnockback(hit.Parent.HumanoidRootPart, 35, 45, 0.15, h)
				misc.UpKnockback(hit.Parent.HumanoidRootPart, 35, 65, 0.15, h)
				Hits[hit.Parent.Name] = true
				local Damage = math.random(Costs.AirKickDamageRange.X, Costs.AirKickDamageRange.Y)
				hit.Parent.Humanoid:TakeDamage(Damage)
				local LastDamage = hit.Parent:FindFirstChild("DamageBy") or Instance.new('ObjectValue', hit.Parent)
				LastDamage.Name = "DamageBy"
				LastDamage.Value = plr.Character
				LastDamage:SetAttribute("Weapon", "AirKick")

				wait(4)

				Hits[hit.Parent.Name] = nil



end
			end
		
	end)

	wait(0.5)


	wait(3.5)
	
h:Destroy()

end)

