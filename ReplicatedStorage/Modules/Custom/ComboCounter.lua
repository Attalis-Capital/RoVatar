-- @ScriptType: ModuleScript
-- ComboCounter.lua
-- Client-side combo counter HUD. Tracks consecutive hits and displays
-- a combo counter in the lower-center of the screen. Resets after timeout.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local ComboCounter = {}
ComboCounter.__index = ComboCounter

-- State
local comboCount = 0
local comboTimer = 0
local COMBO_TIMEOUT = 2.5 -- seconds before combo resets
local lastHitTime = 0

-- UI elements
local comboGui = nil
local comboLabel = nil
local comboSubLabel = nil
local comboFrame = nil

local function ensureComboGui()
	if comboGui and comboGui.Parent then return end

	local playerGui = player:WaitForChild("PlayerGui")

	comboGui = Instance.new("ScreenGui")
	comboGui.Name = "ComboCounterGui"
	comboGui.DisplayOrder = 90
	comboGui.IgnoreGuiInset = true
	comboGui.ResetOnSpawn = false
	comboGui.Parent = playerGui

	comboFrame = Instance.new("Frame")
	comboFrame.Name = "ComboFrame"
	comboFrame.Size = UDim2.new(0.15, 0, 0.1, 0)
	comboFrame.Position = UDim2.new(0.425, 0, 0.78, 0)
	comboFrame.BackgroundTransparency = 1
	comboFrame.BorderSizePixel = 0
	comboFrame.Parent = comboGui

	comboLabel = Instance.new("TextLabel")
	comboLabel.Name = "ComboNumber"
	comboLabel.Size = UDim2.new(1, 0, 0.65, 0)
	comboLabel.Position = UDim2.new(0, 0, 0, 0)
	comboLabel.BackgroundTransparency = 1
	comboLabel.Text = "0"
	comboLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
	comboLabel.TextStrokeColor3 = Color3.fromRGB(80, 40, 0)
	comboLabel.TextStrokeTransparency = 0.2
	comboLabel.Font = Enum.Font.GothamBlack
	comboLabel.TextScaled = true
	comboLabel.TextTransparency = 1
	comboLabel.Parent = comboFrame

	comboSubLabel = Instance.new("TextLabel")
	comboSubLabel.Name = "ComboText"
	comboSubLabel.Size = UDim2.new(1, 0, 0.35, 0)
	comboSubLabel.Position = UDim2.new(0, 0, 0.65, 0)
	comboSubLabel.BackgroundTransparency = 1
	comboSubLabel.Text = "COMBO"
	comboSubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	comboSubLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	comboSubLabel.TextStrokeTransparency = 0.4
	comboSubLabel.Font = Enum.Font.GothamBold
	comboSubLabel.TextScaled = true
	comboSubLabel.TextTransparency = 1
	comboSubLabel.Parent = comboFrame
end

local function getComboColor(count)
	if count >= 10 then
		return Color3.fromRGB(255, 50, 50) -- Red for 10+
	elseif count >= 6 then
		return Color3.fromRGB(255, 150, 0) -- Orange for 6-9
	elseif count >= 3 then
		return Color3.fromRGB(255, 200, 50) -- Gold for 3-5
	else
		return Color3.fromRGB(255, 255, 255) -- White for 1-2
	end
end

local function showCombo()
	ensureComboGui()

	if comboCount < 2 then
		-- Don't show for single hits
		return
	end

	comboLabel.Text = tostring(comboCount)
	comboLabel.TextColor3 = getComboColor(comboCount)

	-- Pop-in animation
	comboLabel.TextTransparency = 0
	comboSubLabel.TextTransparency = 0
	comboLabel.TextStrokeTransparency = 0.2
	comboSubLabel.TextStrokeTransparency = 0.4

	-- Scale punch effect
	local originalSize = comboFrame.Size
	comboFrame.Size = UDim2.new(
		originalSize.X.Scale * 1.3, 0,
		originalSize.Y.Scale * 1.3, 0
	)
	comboFrame.Position = UDim2.new(
		0.425 - 0.015 * 1.3, 0,
		0.78 - 0.01 * 1.3, 0
	)

	local scaleTween = TweenService:Create(
		comboFrame,
		TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = originalSize,
			Position = UDim2.new(0.425, 0, 0.78, 0),
		}
	)
	scaleTween:Play()
end

local function hideCombo()
	if not comboLabel then return end

	local fadeTween = TweenService:Create(
		comboLabel,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ TextTransparency = 1, TextStrokeTransparency = 1 }
	)
	local fadeSubTween = TweenService:Create(
		comboSubLabel,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ TextTransparency = 1, TextStrokeTransparency = 1 }
	)
	fadeTween:Play()
	fadeSubTween:Play()
end

--- Register a hit. Increments the combo counter and resets the timeout.
function ComboCounter.RegisterHit()
	local now = tick()

	if (now - lastHitTime) > COMBO_TIMEOUT then
		-- Combo expired, start fresh
		comboCount = 0
	end

	comboCount = comboCount + 1
	lastHitTime = now

	showCombo()
end

--- Reset the combo counter (called on death, respawn, etc).
function ComboCounter.Reset()
	comboCount = 0
	lastHitTime = 0
	hideCombo()
end

--- Get current combo count.
function ComboCounter.GetCount()
	return comboCount
end

--- Initialize the combo timeout checker. Call once from a controller.
function ComboCounter.Init()
	ensureComboGui()

	-- Heartbeat check for combo timeout
	RunService.Heartbeat:Connect(function()
		if comboCount > 0 and (tick() - lastHitTime) > COMBO_TIMEOUT then
			comboCount = 0
			hideCombo()
		end
	end)

	-- Reset on character death/respawn
	player.CharacterAdded:Connect(function()
		ComboCounter.Reset()
	end)
end

return ComboCounter
