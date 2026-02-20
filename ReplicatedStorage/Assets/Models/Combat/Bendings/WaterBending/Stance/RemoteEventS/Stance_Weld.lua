-- @ScriptType: Script
-- DISABLED: Old Bendings system retired in favour of VFXHandler dispatch
script.Parent.OnServerEvent:Connect(function(plr)
	if true then return end -- Security: disable legacy handler
	local char = plr.Character
	local Tween = game:GetService("TweenService")
	local Effect = game.ReplicatedStorage.Assets.VFXs.Water.Shock1
	local Effect3 = game.ReplicatedStorage.Assets.VFXs.Water.Shock2
	local Effect4 = game.ReplicatedStorage.Assets.VFXs.Water.Shock3
	local Effect2 = game.ReplicatedStorage.Assets.VFXs.Water.Ground
	local FX2 = Effect2:Clone()
	FX2.Anchored = true
	FX2.CanCollide = false
	FX2.Parent = char.HumanoidRootPart
	FX2.CFrame = char:FindFirstChild("HumanoidRootPart").CFrame * CFrame.new(0,-1,0)
	local tweenInfo5 = TweenInfo.new(
		0.7, -- Time
		Enum.EasingStyle.Bounce, -- EasingStyle
		Enum.EasingDirection.Out, -- EasingDirection
		0, -- RepeatCount (when less than zero the tween will loop indefinitely)
		false, -- Reverses (tween will reverse once reaching it's goal)
		0 -- DelayTime
	)
	
	local hum = char:FindFirstChild("Humanoid")
	hum.MaxHealth = hum.MaxHealth + 50
	hum.Health = hum.Health + 10
	local FX3 = Effect3:Clone()
	FX3.Anchored = true
	FX3.CanCollide = false
	FX3.Parent = char.HumanoidRootPart
	FX3.CFrame = char:FindFirstChild("HumanoidRootPart").CFrame
	FX3.Orientation = Vector3.new(43.838, -90, -0)
	local tweenzy = Tween:Create(FX3, tweenInfo5, { Size = Vector3.new(19.986, 2.681, 28.743) })
	tweenzy:Play()
	
	local FX34 = Effect4:Clone()
	FX34.Anchored = true
	FX34.CanCollide = false
	FX34.Parent = char.HumanoidRootPart
	FX34.CFrame = char:FindFirstChild("HumanoidRootPart").CFrame
	FX34.Orientation = Vector3.new(88.596, 90, 180)
	local tweenzsy = Tween:Create(FX34, tweenInfo5, { Size = Vector3.new(26.598, 33.073, 25.33) })
	tweenzsy:Play()
	local FX = Effect:Clone()
	FX.Anchored = true
	FX.CanCollide = false
	FX.Parent = char.HumanoidRootPart
	FX.CFrame = char:FindFirstChild("HumanoidRootPart").CFrame
	local Tween = game:GetService("TweenService")
	FX.Orientation = Vector3.new(35.671, 90, 180)
	local tweenzs1y = Tween:Create(FX, tweenInfo5, { Size = Vector3.new(19.986, 2.681, 28.743) })
	tweenzs1y:Play()

	local part = FX
	local part2 = FX2
	local tweenInfo2 = TweenInfo.new(
		3, -- Time
		Enum.EasingStyle.Bounce, -- EasingStyle
		Enum.EasingDirection.Out, -- EasingDirection
		-1, -- RepeatCount (when less than zero the tween will loop indefinitely)
		true, -- Reverses (tween will reverse once reaching it's goal)
		0 -- DelayTime
	)
	local tweenz = Tween:Create(part2, tweenInfo2, { Size = Vector3.new(34.942, 3.014, 30.253) })
	local tweenz1 = Tween:Create(FX3, tweenInfo2, { Size = Vector3.new(26.942, 3.014, 33.253) })
	local tweenz2 = Tween:Create(FX34, tweenInfo2, { Size = Vector3.new(34.942, 38.014, 30.253) })
	local tweenz3 = Tween:Create(FX, tweenInfo2, { Size = Vector3.new(25.942, 3.014, 35.253) })
	tweenz:Play()
	spawn(function()
		wait(1)
		tweenz2:Play()
		tweenz3:Play()
		tweenz1:Play()
		
		local ts = game:GetService("TweenService") --TweenService
		local object = FX3 --Path to what object you're tweening
		local info = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0) -- -1 is for repeat count which will be infinite, false is for bool reverses which means it will not go backwards
		local goals = {Orientation = Vector3.new(0, 360, 0)} --Rotating it 360 degrees will make it go back to the original starting point, and with an infinite repeat count, it will go forever.
		local tween = ts:Create(object, info, goals)
		tween:Play()
		
		
	
		local object23 = FX34 --Path to what object you're tweening
		local info23 = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0) -- -1 is for repeat count which will be infinite, false is for bool reverses which means it will not go backwards
		local goals23 = {Orientation = Vector3.new(0, 360, 0)} --Rotating it 360 degrees will make it go back to the original starting point, and with an infinite repeat count, it will go forever.
		local tween23 = ts:Create(object23, info23, goals23)
		tween23:Play()
		
		local object234 = FX --Path to what object you're tweening
		local info234 = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0) -- -1 is for repeat count which will be infinite, false is for bool reverses which means it will not go backwards
		local goals234 = {Orientation = Vector3.new(0, 360, 0)} --Rotating it 360 degrees will make it go back to the original starting point, and with an infinite repeat count, it will go forever.
		local tween234 = ts:Create(object234, info234, goals234)
		tween234:Play()
	end)
	
	
	
	local tweenInfo = TweenInfo.new(
		1, -- Time
		Enum.EasingStyle.Bounce, -- EasingStyle
		Enum.EasingDirection.Out, -- EasingDirection
		0, -- RepeatCount (when less than zero the tween will loop indefinitely)
		false, -- Reverses (tween will reverse once reaching it's goal)
		0 -- DelayTime
	)



end)