-- @ScriptType: ModuleScript
-- HitFeedback.lua
-- Client-side hit/kill feedback: XP popup numbers, screen flash, kill banner.
-- Sprint 3: Added level-up banner (#17) and ability unlock banner (#18).
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

----------------------------------------------------------------------
-- Sprint 3 (#17): Level-up celebration banner
----------------------------------------------------------------------

--- Show a prominent level-up banner in the centre of the screen.
--- @param newLevel number - the level the player just reached
function HitFeedback.ShowLevelUpBanner(newLevel)
	ensureFlashGui()

	-- Bright golden flash
	HitFeedback.ScreenFlash(Color3.fromRGB(255, 215, 0), 0.5, 0.6)

	local playerGui = player:WaitForChild("PlayerGui")

	local bannerGui = Instance.new("ScreenGui")
	bannerGui.Name = "LevelUpBanner"
	bannerGui.DisplayOrder = 110
	bannerGui.IgnoreGuiInset = true
	bannerGui.ResetOnSpawn = false
	bannerGui.Parent = playerGui

	-- Main banner frame
	local banner = Instance.new("Frame")
	banner.Name = "BannerFrame"
	banner.Size = UDim2.new(0.5, 0, 0.12, 0)
	banner.Position = UDim2.new(0.25, 0, 0.35, 0)
	banner.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
	banner.BackgroundTransparency = 0.3
	banner.BorderSizePixel = 0
	banner.AnchorPoint = Vector2.new(0, 0)
	banner.Parent = bannerGui

	local bannerCorner = Instance.new("UICorner")
	bannerCorner.CornerRadius = UDim.new(0, 12)
	bannerCorner.Parent = banner

	local bannerStroke = Instance.new("UIStroke")
	bannerStroke.Color = Color3.fromRGB(255, 215, 80)
	bannerStroke.Thickness = 2
	bannerStroke.Transparency = 0.3
	bannerStroke.Parent = banner

	-- "LEVEL UP!" text
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0.45, 0)
	titleLabel.Position = UDim2.fromScale(0, 0.05)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "LEVEL UP!"
	titleLabel.TextColor3 = Color3.fromRGB(255, 215, 80)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextScaled = true
	titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	titleLabel.TextStrokeTransparency = 0.1
	titleLabel.Parent = banner

	-- Level number
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "Level"
	levelLabel.Size = UDim2.new(1, 0, 0.45, 0)
	levelLabel.Position = UDim2.fromScale(0, 0.5)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Text = "Level " .. tostring(newLevel)
	levelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	levelLabel.Font = Enum.Font.GothamBold
	levelLabel.TextScaled = true
	levelLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	levelLabel.TextStrokeTransparency = 0.2
	levelLabel.Parent = banner

	-- Animate: scale in from small
	banner.Size = UDim2.new(0, 0, 0, 0)
	banner.Position = UDim2.new(0.5, 0, 0.41, 0)

	local scaleIn = TweenService:Create(banner, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.5, 0, 0.12, 0),
		Position = UDim2.new(0.25, 0, 0.35, 0),
	})
	scaleIn:Play()

	-- Hold then fade out
	task.delay(2.5, function()
		local fadeOut = TweenService:Create(banner, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
		})
		local titleFade = TweenService:Create(titleLabel, TweenInfo.new(0.5), {
			TextTransparency = 1, TextStrokeTransparency = 1,
		})
		local levelFade = TweenService:Create(levelLabel, TweenInfo.new(0.5), {
			TextTransparency = 1, TextStrokeTransparency = 1,
		})
		local strokeFade = TweenService:Create(bannerStroke, TweenInfo.new(0.5), {
			Transparency = 1,
		})

		fadeOut:Play()
		titleFade:Play()
		levelFade:Play()
		strokeFade:Play()

		game.Debris:AddItem(bannerGui, 0.6)
	end)
end

----------------------------------------------------------------------
-- Sprint 3 (#18): Ability unlock ceremony banner
----------------------------------------------------------------------

--- Show a special ability unlock notification.
--- @param abilityName string - e.g. "Air Bending"
--- @param level number - the level at which it unlocked
function HitFeedback.ShowAbilityUnlockBanner(abilityName, level)
	ensureFlashGui()

	-- Bright cyan flash for ability unlock
	HitFeedback.ScreenFlash(Color3.fromRGB(0, 200, 255), 0.5, 0.8)

	local playerGui = player:WaitForChild("PlayerGui")

	local bannerGui = Instance.new("ScreenGui")
	bannerGui.Name = "AbilityUnlockBanner"
	bannerGui.DisplayOrder = 115
	bannerGui.IgnoreGuiInset = true
	bannerGui.ResetOnSpawn = false
	bannerGui.Parent = playerGui

	-- Ability-specific colours
	local abilityColors = {
		["Air Bending"] = Color3.fromRGB(200, 230, 255),
		["Fire Bending"] = Color3.fromRGB(255, 120, 40),
		["Earth Bending"] = Color3.fromRGB(140, 180, 80),
		["Water Bending"] = Color3.fromRGB(60, 160, 255),
	}
	local accentColor = abilityColors[abilityName] or Color3.fromRGB(200, 200, 255)

	local banner = Instance.new("Frame")
	banner.Name = "UnlockFrame"
	banner.Size = UDim2.new(0.45, 0, 0.14, 0)
	banner.Position = UDim2.new(0.275, 0, 0.33, 0)
	banner.BackgroundColor3 = Color3.fromRGB(5, 5, 15)
	banner.BackgroundTransparency = 0.2
	banner.BorderSizePixel = 0
	banner.Parent = bannerGui

	local bannerCorner = Instance.new("UICorner")
	bannerCorner.CornerRadius = UDim.new(0, 14)
	bannerCorner.Parent = banner

	local bannerStroke = Instance.new("UIStroke")
	bannerStroke.Color = accentColor
	bannerStroke.Thickness = 2.5
	bannerStroke.Transparency = 0.2
	bannerStroke.Parent = banner

	-- "NEW ABILITY UNLOCKED" header
	local headerLabel = Instance.new("TextLabel")
	headerLabel.Name = "Header"
	headerLabel.Size = UDim2.new(1, 0, 0.3, 0)
	headerLabel.Position = UDim2.fromScale(0, 0.05)
	headerLabel.BackgroundTransparency = 1
	headerLabel.Text = "NEW ABILITY UNLOCKED"
	headerLabel.TextColor3 = accentColor
	headerLabel.Font = Enum.Font.GothamBold
	headerLabel.TextScaled = true
	headerLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	headerLabel.TextStrokeTransparency = 0.1
	headerLabel.Parent = banner

	-- Ability name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "AbilityName"
	nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
	nameLabel.Position = UDim2.fromScale(0, 0.35)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = abilityName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.TextStrokeTransparency = 0.15
	nameLabel.Parent = banner

	-- Subtitle
	local subLabel = Instance.new("TextLabel")
	subLabel.Name = "Subtitle"
	subLabel.Size = UDim2.new(1, 0, 0.2, 0)
	subLabel.Position = UDim2.fromScale(0, 0.75)
	subLabel.BackgroundTransparency = 1
	subLabel.Text = "Unlocked at Level " .. tostring(level)
	subLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
	subLabel.Font = Enum.Font.Gotham
	subLabel.TextScaled = true
	subLabel.Parent = banner

	-- Animate: slide in from top
	banner.Position = UDim2.new(0.275, 0, -0.2, 0)
	banner.BackgroundTransparency = 1

	local slideIn = TweenService:Create(banner, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.275, 0, 0.33, 0),
		BackgroundTransparency = 0.2,
	})
	local headerFadeIn = TweenService:Create(headerLabel, TweenInfo.new(0.3), {
		TextTransparency = 0, TextStrokeTransparency = 0.1,
	})
	local nameFadeIn = TweenService:Create(nameLabel, TweenInfo.new(0.3), {
		TextTransparency = 0, TextStrokeTransparency = 0.15,
	})

	headerLabel.TextTransparency = 1
	headerLabel.TextStrokeTransparency = 1
	nameLabel.TextTransparency = 1
	nameLabel.TextStrokeTransparency = 1
	subLabel.TextTransparency = 1

	slideIn:Play()
	task.delay(0.2, function()
		headerFadeIn:Play()
	end)
	task.delay(0.4, function()
		nameFadeIn:Play()
		TweenService:Create(subLabel, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
	end)

	-- Hold then fade out
	task.delay(4, function()
		local fadeOut = TweenService:Create(banner, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
			Position = UDim2.new(0.275, 0, 0.28, 0),
		})
		local hFade = TweenService:Create(headerLabel, TweenInfo.new(0.4), {
			TextTransparency = 1, TextStrokeTransparency = 1,
		})
		local nFade = TweenService:Create(nameLabel, TweenInfo.new(0.4), {
			TextTransparency = 1, TextStrokeTransparency = 1,
		})
		local sFade = TweenService:Create(subLabel, TweenInfo.new(0.4), { TextTransparency = 1 })
		local stFade = TweenService:Create(bannerStroke, TweenInfo.new(0.4), { Transparency = 1 })

		fadeOut:Play()
		hFade:Play()
		nFade:Play()
		sFade:Play()
		stFade:Play()

		game.Debris:AddItem(bannerGui, 0.7)
	end)
end

return HitFeedback
