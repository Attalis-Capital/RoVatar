-- @ScriptType: ModuleScript
-- DeathScreen.lua
-- Client-side death/respawn experience. Shows a "You Died" overlay with
-- respawn countdown, then fades back in on respawn.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local DeathScreen = {}

-- UI references
local deathGui = nil
local overlayFrame = nil
local deathLabel = nil
local respawnLabel = nil
local tipLabel = nil

-- Tips shown on death screen
local DEATH_TIPS = {
	"Hold Q to block incoming attacks",
	"Meditate (N) to restore your energy",
	"Sprint (Shift) to escape tough fights",
	"Combo your fist attacks for a powerful finisher",
	"Use bending abilities from a safe distance",
	"Block first, then counterattack when the enemy stops",
	"Keep your stamina above zero - you need it to escape",
	"Earth Stomp is great for hitting multiple enemies",
}

local function getRandomTip()
	return DEATH_TIPS[math.random(1, #DEATH_TIPS)]
end

local function ensureDeathGui()
	if deathGui and deathGui.Parent then return end

	local playerGui = player:WaitForChild("PlayerGui")

	deathGui = Instance.new("ScreenGui")
	deathGui.Name = "DeathScreenGui"
	deathGui.DisplayOrder = 200
	deathGui.IgnoreGuiInset = true
	deathGui.ResetOnSpawn = false
	deathGui.Enabled = false
	deathGui.Parent = playerGui

	overlayFrame = Instance.new("Frame")
	overlayFrame.Name = "DeathOverlay"
	overlayFrame.Size = UDim2.fromScale(1, 1)
	overlayFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
	overlayFrame.BackgroundTransparency = 1
	overlayFrame.BorderSizePixel = 0
	overlayFrame.ZIndex = 1
	overlayFrame.Parent = deathGui

	deathLabel = Instance.new("TextLabel")
	deathLabel.Name = "DeathText"
	deathLabel.Size = UDim2.new(0.6, 0, 0.12, 0)
	deathLabel.Position = UDim2.new(0.2, 0, 0.35, 0)
	deathLabel.BackgroundTransparency = 1
	deathLabel.Text = "YOU DIED"
	deathLabel.TextColor3 = Color3.fromRGB(200, 30, 30)
	deathLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	deathLabel.TextStrokeTransparency = 0
	deathLabel.Font = Enum.Font.GothamBlack
	deathLabel.TextScaled = true
	deathLabel.TextTransparency = 1
	deathLabel.ZIndex = 2
	deathLabel.Parent = deathGui

	respawnLabel = Instance.new("TextLabel")
	respawnLabel.Name = "RespawnText"
	respawnLabel.Size = UDim2.new(0.4, 0, 0.05, 0)
	respawnLabel.Position = UDim2.new(0.3, 0, 0.48, 0)
	respawnLabel.BackgroundTransparency = 1
	respawnLabel.Text = "Respawning in 5..."
	respawnLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	respawnLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	respawnLabel.TextStrokeTransparency = 0.3
	respawnLabel.Font = Enum.Font.Gotham
	respawnLabel.TextScaled = true
	respawnLabel.TextTransparency = 1
	respawnLabel.ZIndex = 2
	respawnLabel.Parent = deathGui

	tipLabel = Instance.new("TextLabel")
	tipLabel.Name = "TipText"
	tipLabel.Size = UDim2.new(0.5, 0, 0.04, 0)
	tipLabel.Position = UDim2.new(0.25, 0, 0.56, 0)
	tipLabel.BackgroundTransparency = 1
	tipLabel.Text = ""
	tipLabel.TextColor3 = Color3.fromRGB(180, 180, 120)
	tipLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	tipLabel.TextStrokeTransparency = 0.5
	tipLabel.Font = Enum.Font.GothamMedium
	tipLabel.TextScaled = true
	tipLabel.TextTransparency = 1
	tipLabel.ZIndex = 2
	tipLabel.Parent = deathGui
end

--- Show the death screen with fade-in and countdown.
function DeathScreen.Show()
	ensureDeathGui()

	deathGui.Enabled = true
	tipLabel.Text = "TIP: " .. getRandomTip()

	-- Fade in overlay
	overlayFrame.BackgroundTransparency = 1
	local overlayFade = TweenService:Create(
		overlayFrame,
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ BackgroundTransparency = 0.3 }
	)
	overlayFade:Play()

	-- Fade in text
	task.delay(0.3, function()
		local textFade = TweenService:Create(
			deathLabel,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad),
			{ TextTransparency = 0, TextStrokeTransparency = 0 }
		)
		textFade:Play()
	end)

	task.delay(0.6, function()
		local respawnFade = TweenService:Create(
			respawnLabel,
			TweenInfo.new(0.3),
			{ TextTransparency = 0, TextStrokeTransparency = 0.3 }
		)
		respawnFade:Play()

		local tipFade = TweenService:Create(
			tipLabel,
			TweenInfo.new(0.3),
			{ TextTransparency = 0, TextStrokeTransparency = 0.5 }
		)
		tipFade:Play()
	end)

	-- Countdown (uses game.Players.RespawnTime which is typically 5)
	local respawnTime = Players.RespawnTime or 5
	task.spawn(function()
		for i = respawnTime, 1, -1 do
			if respawnLabel then
				respawnLabel.Text = "Respawning in " .. tostring(i) .. "..."
			end
			task.wait(1)
		end
		if respawnLabel then
			respawnLabel.Text = "Respawning..."
		end
	end)
end

--- Hide the death screen with fade-out (called on respawn).
function DeathScreen.Hide()
	if not deathGui or not deathGui.Enabled then return end

	-- Fade out everything
	local fadeTime = 0.5

	if overlayFrame then
		TweenService:Create(overlayFrame, TweenInfo.new(fadeTime), { BackgroundTransparency = 1 }):Play()
	end
	if deathLabel then
		TweenService:Create(deathLabel, TweenInfo.new(fadeTime), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	end
	if respawnLabel then
		TweenService:Create(respawnLabel, TweenInfo.new(fadeTime), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	end
	if tipLabel then
		TweenService:Create(tipLabel, TweenInfo.new(fadeTime), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	end

	task.delay(fadeTime + 0.1, function()
		if deathGui then
			deathGui.Enabled = false
		end
	end)
end

--- Initialize death screen listeners. Call once from a controller.
function DeathScreen.Init()
	ensureDeathGui()

	local function onCharacterAdded(char)
		-- Hide death screen on respawn
		DeathScreen.Hide()

		-- Listen for death
		local humanoid = char:WaitForChild("Humanoid")
		humanoid.Died:Once(function()
			DeathScreen.Show()
		end)
	end

	-- Connect to current and future characters
	if player.Character then
		onCharacterAdded(player.Character)
	end
	player.CharacterAdded:Connect(onCharacterAdded)
end

return DeathScreen
