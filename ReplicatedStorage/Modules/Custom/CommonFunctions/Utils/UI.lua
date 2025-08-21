-- @ScriptType: ModuleScript
return {
	GetTextLength = function(txtLabel:TextLabel)
		local params = Instance.new("GetTextBoundsParams")
		params.Text = txtLabel.Text
		params.Font = txtLabel.FontFace
		params.Size = txtLabel.TextSize
		local size = game.TextService:GetTextBoundsAsync(params)
		return size
	end,

	TweenGradient = function(Gradient:UIGradient, targetValue:number)
		-- Clamp the target value to [0, 1]
		targetValue = math.clamp(targetValue, 0, 1)

		-- Initialize percent based on targetValue:
		local percent = (targetValue == 1) and 0 or 1
		local lerpStep = 0.1  -- Adjust this value to control the speed of interpolation
		local epsilon = 0.01

		while math.abs(percent - targetValue) > epsilon do
			-- Perform manual linear interpolation
			percent = percent + (targetValue - percent) * lerpStep

			if percent <= 0 or percent >= 1 then
				Gradient.Transparency = NumberSequence.new(1 - percent)
			else
				Gradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(math.max(0, percent - 0.01), 0),
					NumberSequenceKeypoint.new(percent, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			end

			task.wait(0.005)
		end

		-- Ensure final transparency is set exactly to the target
		Gradient.Transparency = NumberSequence.new(1 - targetValue)
	end,

	Blink = function(player :Player, _time :number)
		------ 
		_time = _time or .75 

		local GUI = Instance.new("ScreenGui", player.PlayerGui)
		GUI.IgnoreGuiInset = true
		GUI.ResetOnSpawn = false
		GUI.DisplayOrder = 100
		local Frame = Instance.new("Frame", GUI)
		Frame.Size = UDim2.new(1, 0, 1, 0)
		Frame.AnchorPoint = Vector2.new(.5, .5)
		Frame.Position = UDim2.new(.5, 0, .5, 0)
		Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

		local TS = game:GetService("TweenService")

		local tween1 = TS:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
		tween1:Play()
		game.Debris:AddItem(tween1, 0.15)
		task.delay(_time, function()
			local tween2 = TS:Create(Frame, TweenInfo.new(.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
			tween2:Play()
			game.Debris:AddItem(tween2, .76)
			game.Debris:AddItem(GUI, .76)
		end)
	end,

	ToggleBlackScreen = function(player :Player, enable) 
		local TS = game:GetService("TweenService")

		local GUI = player.PlayerGui:FindFirstChild("BlackScreenGui") or Instance.new("ScreenGui", player.PlayerGui)
		GUI.IgnoreGuiInset = true
		GUI.ResetOnSpawn = false
		GUI.DisplayOrder = 100
		GUI.Name = "BlackScreenGui"

		local Frame = GUI:FindFirstChild('Frame') or Instance.new("Frame", GUI)
		Frame.Size = UDim2.new(1, 0, 1, 0)
		Frame.AnchorPoint = Vector2.new(.5, .5)
		Frame.Position = UDim2.new(.5, 0, .5, 0)
		Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

		if enable then
			local tween1 = TS:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
			tween1:Play()
		else
			local tween2 = TS:Create(Frame, TweenInfo.new(.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
			tween2:Play()
			game.Debris:AddItem(tween2, .76)
			game.Debris:AddItem(GUI, .76)
		end
	end,
}
