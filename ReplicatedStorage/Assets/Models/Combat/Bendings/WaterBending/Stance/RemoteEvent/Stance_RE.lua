-- @ScriptType: Script
script.Parent.OnServerEvent:Connect(function(plr,direction,mouseaim)

	local Costs = require(game:GetService("ReplicatedStorage").Modules.Custom.Costs)
	if plr.Progression and plr.Progression:FindFirstChild("LEVEL") then
		if plr.Progression.LEVEL.Value < Costs.WaterStanceLvl then return end
	end

	if not plr:GetAttribute("WaterStanceCD") then
		plr:SetAttribute("WaterStanceCD", true)
		task.delay(Costs.Abilities, function()
			plr:SetAttribute("WaterStanceCD", nil)
		end)
	else
		return
	end

	local char = plr.Character
	local FX = char.HumanoidRootPart:FindFirstChild("Ground")
	local Tween = game:GetService("TweenService")
    FX.CanCollide = false
	if	plr.Character:FindFirstChild("Stamina").Value >= Costs.WaterStanceStamina then
		plr.Character:FindFirstChild("Stamina").Value = 	plr.Character:FindFirstChild("Stamina").Value -Costs.WaterStanceStamina
	end
	local Exp = plr.Progression:FindFirstChild("EXP")
	if Exp then
		Exp.Value += Costs.WaterStanceXp
	end
	local FX2 = char.HumanoidRootPart:FindFirstChild("Shock1")
	local FX3 = char.HumanoidRootPart:FindFirstChild("Shock2")
	local FX4 = char.HumanoidRootPart:FindFirstChild("Shock3")
	local tweenInfo = TweenInfo.new(
		1, -- Time
		Enum.EasingStyle.Bounce, -- EasingStyle
		Enum.EasingDirection.Out, -- EasingDirection
		0, -- RepeatCount (when less than zero the tween will loop indefinitely)
		false, -- Reverses (tween will reverse once reaching it's goal)
		0 -- DelayTime
	)
	local hum = char:WaitForChild("Humanoid")
	hum.MaxHealth = hum.MaxHealth - 50
	hum.Health = hum.Health - 10
	local tween = Tween:Create(FX, tweenInfo, { Size = Vector3.new(0.1,0.1,0.1) })
	local tween2 = Tween:Create(FX2, tweenInfo, { Size = Vector3.new(0.1,0.1,0.1) })
	local tween3 = Tween:Create(FX3, tweenInfo, { Size = Vector3.new(0.1,0.1,0.1) })
	local tween4 = Tween:Create(FX4, tweenInfo, { Size = Vector3.new(0.1,0.1,0.1) })
	tween:Play()
	tween2:Play()
	tween3:Play()
	tween4:Play()
	local tweena = Tween:Create(FX, tweenInfo, { Transparency = 1 })
	local tweens = Tween:Create(FX2, tweenInfo, { Transparency = 1 })
	local tweend = Tween:Create(FX3, tweenInfo, { Transparency = 1 })
	local tweenf = Tween:Create(FX4, tweenInfo, { Transparency = 1 })
	tweena:Play()
	tweens:Play()
	tweend:Play()
	tweenf:Play()
	FX.Anchored = false
	game.Debris:AddItem(FX,2)
	game.Debris:AddItem(FX2,2)
	game.Debris:AddItem(FX3,2)
	game.Debris:AddItem(FX4,2)

end)