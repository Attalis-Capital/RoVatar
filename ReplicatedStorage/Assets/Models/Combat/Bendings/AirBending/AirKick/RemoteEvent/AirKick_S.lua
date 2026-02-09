-- @ScriptType: Script
local Players = game:GetService("Players")
script.Parent.OnServerEvent:Connect(function(plr,direction,mouseaim)
	local OnHit = false
	local Alive = true
	local RS = game:GetService("ReplicatedStorage")

	local Remotes = RS.Remotes
	local Replicate = Remotes.Replicate
	local hrp = plr.Character:WaitForChild("HumanoidRootPart")


	local Hits = {}
	local Modules = RS.Modules
	local misc = require(Modules.Packages.Misc)
	local CS = game:GetService("CollectionService")


local TS = game:GetService("TweenService")
	local Tween = game:GetService("TweenService")

wait(0.2)
	if	plr.Character:FindFirstChild("Stamina").Value >= 25 then
		plr.Character:FindFirstChild("Stamina").Value = 	plr.Character:FindFirstChild("Stamina").Value -25
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
			
		

				plr.CombatStats:FindFirstChild("EXP").Value = 	plr.CombatStats:FindFirstChild("EXP").Value +5
				
			
				hit.Parent.HumanoidRootPart.CFrame = CFrame.lookAt(hit.Parent.HumanoidRootPart.Position, h.Position) * CFrame.Angles(0, math.pi, 0)
				misc.Ragdoll(hit.Parent, 1.5)

				misc.StrongKnockback(hit.Parent.HumanoidRootPart, 35, 45, 0.15, h)
				misc.UpKnockback(hit.Parent.HumanoidRootPart, 35, 65, 0.15, h)
				Hits[hit.Parent.Name] = true
				local Damage = math.random(15,23)
				-- SafeZone: block PvP if either player is in safe zone
				local victimPlayer = Players:GetPlayerFromCharacter(hit.Parent)
				if victimPlayer and (plr.Character:GetAttribute("InSafeZone") or hit.Parent:GetAttribute("InSafeZone")) then return end
				hit.Parent.Humanoid:TakeDamage(Damage)
			
		
				wait(4)

				Hits[hit.Parent.Name] = nil



end
			end
		
	end)

	wait(0.5)


	wait(3.5)
	
h:Destroy()

end)

