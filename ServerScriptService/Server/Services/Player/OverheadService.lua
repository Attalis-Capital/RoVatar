-- @ScriptType: ModuleScript
-- OverheadService.lua
-- Creates persistent BillboardGui above each player's head showing
-- DisplayName, save-slot name, and level. Updates on level-up.
-- Sprint 6b: Issue #5 — player overheads.

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local Knit = require(RS.Packages.Knit)

local BILLBOARD_NAME = "OverheadGui"
local MAX_DISTANCE = 50

local OverheadService = Knit.CreateService {
	Name = "OverheadService",
	Client = {},
}

local function createOverhead(player, character)
	local head = character:WaitForChild("Head", 5)
	if not head then return end

	-- Remove existing if respawning
	local existing = head:FindFirstChild(BILLBOARD_NAME)
	if existing then existing:Destroy() end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = BILLBOARD_NAME
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = false
	billboard.MaxDistance = MAX_DISTANCE
	billboard.ResetOnSpawn = false

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "DisplayName"
	nameLabel.Size = UDim2.new(1, 0, 0.45, 0)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.DisplayName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = billboard

	local slotLabel = Instance.new("TextLabel")
	slotLabel.Name = "SlotName"
	slotLabel.Size = UDim2.new(1, 0, 0.3, 0)
	slotLabel.Position = UDim2.new(0, 0, 0.45, 0)
	slotLabel.BackgroundTransparency = 1
	slotLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	slotLabel.TextStrokeTransparency = 0.7
	slotLabel.TextScaled = true
	slotLabel.Font = Enum.Font.Gotham
	slotLabel.Parent = billboard

	-- Set slot name from attribute (set by PlayerDataService)
	local slotName = player:GetAttribute("SlotName")
	slotLabel.Text = slotName or ""

	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "Level"
	levelLabel.Size = UDim2.new(1, 0, 0.25, 0)
	levelLabel.Position = UDim2.new(0, 0, 0.75, 0)
	levelLabel.BackgroundTransparency = 1
	levelLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	levelLabel.TextStrokeTransparency = 0.5
	levelLabel.TextScaled = true
	levelLabel.Font = Enum.Font.GothamBold
	levelLabel.Parent = billboard

	-- Set level from Progression folder
	local progression = player:FindFirstChild("Progression")
	if progression then
		local levelVal = progression:FindFirstChild("LEVEL")
		if levelVal then
			levelLabel.Text = "Lv. " .. levelVal.Value
			levelVal.Changed:Connect(function(newLevel)
				levelLabel.Text = "Lv. " .. newLevel
			end)
		end
	end

	-- Listen for SlotName attribute changes (e.g. profile switch)
	player:GetAttributeChangedSignal("SlotName"):Connect(function()
		local newSlotName = player:GetAttribute("SlotName")
		slotLabel.Text = newSlotName or ""
	end)

	billboard.Parent = head
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		task.spawn(createOverhead, player, character)
	end)
	if player.Character then
		task.spawn(createOverhead, player, player.Character)
	end
end

function OverheadService:KnitInit()
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
end

function OverheadService:KnitStart()
end

return OverheadService
