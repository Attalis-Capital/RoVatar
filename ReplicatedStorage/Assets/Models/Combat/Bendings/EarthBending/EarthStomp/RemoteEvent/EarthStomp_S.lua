-- @ScriptType: Script
local Players = game:GetService("Players")
script.Parent.OnServerEvent:Connect(function(plr,direction,mouseaim)
	local OnHit = false
	local Alive = true
	local RS = game:GetService("ReplicatedStorage")

	local Remotes = RS.Remotes
	local Replicate = Remotes.Replicate
	local hrp = plr.Character:WaitForChild("HumanoidRootPart")
	
	local Kick = game.ReplicatedStorage.FX.Earth.Spike:Clone()
	Kick.Parent = workspace
	Kick.CanCollide = false
	Kick.Anchored = true
	Kick.CFrame = CFrame.new(mouseaim) * CFrame.new(0,-1,0)
	Kick.Orientation = Kick.Orientation + Vector3.new(0,0,0)
	Kick.Transparency = 1
	local distance = (Kick.Position - hrp.Position).Magnitude
	local infNum = math.huge

	if	plr.Character:FindFirstChild("Stamina").Value >= 25 then
		plr.Character:FindFirstChild("Stamina").Value = 	plr.Character:FindFirstChild("Stamina").Value -25
	end

	if distance > 60 then return end
	local Hits = {}
	local Modules = game.ReplicatedStorage.Modules
	local misc = require(Modules.Misc)
	local CS = game:GetService("CollectionService")
	local tag = "Ragdoll"

	Kick.Transparency = 0
	local Tween = game:GetService("TweenService")


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


		
	
		local hitbox = game.ReplicatedStorage.FX.Earth.SpikeHit:Clone()
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
			
	hitbox.Touched:Connect(function(hit)
		if hit.Parent:FindFirstChild("Humanoid") and hit.Parent.Name ~= plr.Name then
			if not hit.Parent.Humanoid:FindFirstChild(plr.Name) then
				if Hits[hit.Parent.Name] then
					return
				end



				plr.CombatStats:FindFirstChild("EXP").Value = 	plr.CombatStats:FindFirstChild("EXP").Value +5


				hit.Parent.HumanoidRootPart.CFrame = CFrame.lookAt(hit.Parent.HumanoidRootPart.Position, Kick.Position) * CFrame.Angles(0, math.pi, 0)
				misc.Ragdoll(hit.Parent, 1.5)

				misc.UpKnockback(hit.Parent.HumanoidRootPart, 56, 125, 0.15, hitbox)

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
	hitbox:Destroy()
			
	wait(2)
	Kick:Destroy()
	
	
end)

