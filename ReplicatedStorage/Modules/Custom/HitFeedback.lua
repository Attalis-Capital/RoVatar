-- @ScriptType: ModuleScript
-- HitFeedback.lua
-- Client-side hit/kill feedback: XP popup numbers, screen flash, kill banner.
-- Listens for Replicate events and EXP value changes.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local HitFeedback = {}

-- Screen flash overlay (created once, reused)
local flashGui = nil
local flashFrame = nil

local function ensureFlashGui()
	if flashGui and flashGui.Parent then return end

	local playerGui = player:WaitForChild("PlayerGui")

	flashGui = Instance.new("ScreenGui")
	flashGui.Name = "HitFlashGui"
	flashGui.DisplayOrder = 100
	flashGui.IgnoreGuiInset = true
	flashGui.ResetOnSpawn = false
	flashGui.Parent = playerGui

	flashFrame = Instance.new("Frame")
	flashFrame.Name = "FlashOverlay"
	flashFrame.Size = UDim2.fromScale(1, 1)
	flashFrame.Position = UDim2.fromScale(0, 0)
	flashFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	flashFrame.BackgroundTransparency = 1
	flashFrame.BorderSizePixel = 0
	flashFrame.ZIndex = 10
	flashFrame.Parent = flashGui
end

--- Flash the screen briefly on hit.
--- @param color Color3 - flash colour (white for hit, red for damage taken, gold for kill)
--- @param intensity number - starting opacity (0-1)
--- @param duration number - fade duration in seconds
function HitFeedback.ScreenFlash(color, intensity, duration)
	ensureFlashGui()

	color = color or Color3.fromRGB(255, 255, 255)
	intensity = intensity or 0.3
	duration = duration or 0.2

	flashFrame.BackgroundColor3 = color
	flashFrame.BackgroundTransparency = 1 - intensity

	local tween = TweenService:Create(
		flashFrame,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 }
	)
	tween:Play()
end

--- Show a floating XP popup above the player's head.
--- @param amount number - XP gained
function HitFeedback.ShowXPPopup(amount)
	if not amount or amount <= 0 then return end

	local char = player.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head then return end

	-- Create BillboardGui on the head
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "XPPopup"
	billboard.Adornee = head
	billboard.Size = UDim2.fromOffset(100, 40)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.Name = "XPLabel"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "+" .. tostring(math.floor(amount)) .. " XP"
	label.TextColor3 = Color3.fromRGB(100, 255, 100)
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.TextStrokeTransparency = 0.3
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = billboard

	-- Animate: float up and fade out
	local floatTween = TweenService:Create(
		billboard,
		TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ StudsOffset = Vector3.new(0, 6, 0) }
	)
	local fadeTween = TweenService:Create(
		label,
		TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ TextTransparency = 1, TextStrokeTransparency = 1 }
	)

	floatTween:Play()
	fadeTween:Play()

	game.Debris:AddItem(billboard, 1.6)
end

--- Show a kill notification banner at the top of the screen.
--- @param enemyName string - name of the defeated enemy
function HitFeedback.ShowKillBanner(enemyName)
	ensureFlashGui()

	-- Gold screen flash for kills
	HitFeedback.ScreenFlash(Color3.fromRGB(255, 215, 0), 0.35, 0.4)

	local playerGui = player:WaitForChild("PlayerGui")

	local bannerGui = Instance.new("ScreenGui")
	bannerGui.Name = "KillBanner"
	bannerGui.DisplayOrder = 101
	bannerGui.IgnoreGuiInset = true
	bannerGui.ResetOnSpawn = false
	bannerGui.Parent = playerGui

	local banner = Instance.new("TextLabel")
	banner.Name = "BannerLabel"
	banner.Size = UDim2.new(0.5, 0, 0.06, 0)
	banner.Position = UDim2.new(0.25, 0, 0.12, 0)
	banner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	banner.BackgroundTransparency = 0.5
	banner.BorderSizePixel = 0
	banner.Text = "DEFEATED " .. (enemyName or "Enemy")
	banner.TextColor3 = Color3.fromRGB(255, 200, 50)
	banner.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	banner.TextStrokeTransparency = 0.2
	banner.Font = Enum.Font.GothamBold
	banner.TextScaled = true
	banner.ZIndex = 11
	banner.Parent = bannerGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = banner

	-- Fade in
	banner.TextTransparency = 1
	banner.BackgroundTransparency = 1

	local fadeIn = TweenService:Create(banner, TweenInfo.new(0.2), {
		TextTransparency = 0,
		TextStrokeTransparency = 0.2,
		BackgroundTransparency = 0.5,
	})
	fadeIn:Play()

	-- Hold then fade out
	task.delay(1.5, function()
		local fadeOut = TweenService:Create(banner, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			TextTransparency = 1,
			TextStrokeTransparency = 1,
			BackgroundTransparency = 1,
		})
		fadeOut:Play()
		game.Debris:AddItem(bannerGui, 0.6)
	end)
end

--- Show a floating damage number on a target (used for hit confirmation).
--- @param targetRoot BasePart - the target's HumanoidRootPart
--- @param damage number - damage dealt
--- @param isCritical boolean? - if true, shows larger/different color
function HitFeedback.ShowDamageNumber(targetRoot, damage, isCritical)
	if not targetRoot then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DmgPopup"
	billboard.Adornee = targetRoot
	billboard.Size = UDim2.fromOffset(80, 30)
	billboard.StudsOffset = Vector3.new(math.random(-2, 2), 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = targetRoot

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = tostring(math.floor(damage))
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextStrokeTransparency = 0.3

	if isCritical then
		label.TextColor3 = Color3.fromRGB(255, 100, 50)
		label.TextStrokeColor3 = Color3.fromRGB(100, 0, 0)
		billboard.Size = UDim2.fromOffset(100, 40)
	else
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	end

	label.Parent = billboard

	local floatTween = TweenService:Create(
		billboard,
		TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ StudsOffset = billboard.StudsOffset + Vector3.new(0, 3, 0) }
	)
	local fadeTween = TweenService:Create(
		label,
		TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ TextTransparency = 1, TextStrokeTransparency = 1 }
	)

	floatTween:Play()
	fadeTween:Play()

	game.Debris:AddItem(billboard, 1.3)
end

return HitFeedback
