-- @ScriptType: ModuleScript
-- QuestTrackerHUD.lua
-- Sprint 3 (#14): Always-visible right-side quest tracker panel.
-- Reads active quests from _G.QuestsData and updates on data changes.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local QuestTrackerHUD = {}

local trackerGui = nil
local questContainer = nil

-- Colour palette
local COLORS = {
	panelBg = Color3.fromRGB(20, 20, 30),
	headerText = Color3.fromRGB(255, 215, 80),
	titleText = Color3.fromRGB(255, 255, 255),
	descText = Color3.fromRGB(180, 180, 190),
	progressText = Color3.fromRGB(100, 255, 100),
	completedText = Color3.fromRGB(80, 255, 80),
	divider = Color3.fromRGB(60, 60, 80),
}

local function createTrackerGui()
	if trackerGui and trackerGui.Parent then return end

	local playerGui = player:WaitForChild("PlayerGui")

	trackerGui = Instance.new("ScreenGui")
	trackerGui.Name = "QuestTrackerHUD"
	trackerGui.DisplayOrder = 50
	trackerGui.IgnoreGuiInset = true
	trackerGui.ResetOnSpawn = false
	trackerGui.Parent = playerGui

	-- Main container - right side, vertically centred
	local panel = Instance.new("Frame")
	panel.Name = "TrackerPanel"
	panel.Size = UDim2.new(0, 260, 0, 0) -- Height auto-sized
	panel.Position = UDim2.new(1, -275, 0, 120)
	panel.BackgroundColor3 = COLORS.panelBg
	panel.BackgroundTransparency = 0.35
	panel.BorderSizePixel = 0
	panel.AutomaticSize = Enum.AutomaticSize.Y
	panel.Parent = trackerGui

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 10)
	panelCorner.Parent = panel

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Color = Color3.fromRGB(60, 60, 80)
	panelStroke.Thickness = 1
	panelStroke.Transparency = 0.5
	panelStroke.Parent = panel

	-- Header
	local header = Instance.new("TextLabel")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 28)
	header.BackgroundTransparency = 1
	header.Text = "QUESTS"
	header.TextColor3 = COLORS.headerText
	header.Font = Enum.Font.GothamBold
	header.TextSize = 14
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = panel

	local headerPadding = Instance.new("UIPadding")
	headerPadding.PaddingLeft = UDim.new(0, 12)
	headerPadding.PaddingTop = UDim.new(0, 8)
	headerPadding.Parent = header

	-- Quest list container
	questContainer = Instance.new("Frame")
	questContainer.Name = "QuestList"
	questContainer.Size = UDim2.new(1, 0, 0, 0)
	questContainer.Position = UDim2.new(0, 0, 0, 32)
	questContainer.BackgroundTransparency = 1
	questContainer.AutomaticSize = Enum.AutomaticSize.Y
	questContainer.Parent = panel

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 4)
	listLayout.Parent = questContainer

	local containerPadding = Instance.new("UIPadding")
	containerPadding.PaddingLeft = UDim.new(0, 10)
	containerPadding.PaddingRight = UDim.new(0, 10)
	containerPadding.PaddingBottom = UDim.new(0, 10)
	containerPadding.Parent = questContainer
end

local function createQuestEntry(questData, questType, layoutOrder)
	if not questData or not questData.Id then return nil end
	if questData.IsCompleted then return nil end

	local entry = Instance.new("Frame")
	entry.Name = "Quest_" .. questType
	entry.Size = UDim2.new(1, 0, 0, 0)
	entry.BackgroundTransparency = 1
	entry.AutomaticSize = Enum.AutomaticSize.Y
	entry.LayoutOrder = layoutOrder

	local entryLayout = Instance.new("UIListLayout")
	entryLayout.SortOrder = Enum.SortOrder.LayoutOrder
	entryLayout.Padding = UDim.new(0, 2)
	entryLayout.Parent = entry

	-- Quest type tag
	local typeLabel = Instance.new("TextLabel")
	typeLabel.Name = "TypeTag"
	typeLabel.Size = UDim2.new(1, 0, 0, 14)
	typeLabel.BackgroundTransparency = 1
	typeLabel.Text = questType:upper()
	typeLabel.TextColor3 = COLORS.headerText
	typeLabel.Font = Enum.Font.GothamBold
	typeLabel.TextSize = 10
	typeLabel.TextXAlignment = Enum.TextXAlignment.Left
	typeLabel.LayoutOrder = 1
	typeLabel.Parent = entry

	-- Quest title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 16)
	title.BackgroundTransparency = 1
	title.Text = questData.Title or questData.Id
	title.TextColor3 = COLORS.titleText
	title.Font = Enum.Font.GothamBold
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.LayoutOrder = 2
	title.Parent = entry

	-- Current target description
	local achieved = questData.Achieved or 0
	local targets = questData.Targets
	local totalTargets = targets and #targets or 0
	local currentTarget = targets and targets[achieved + 1]

	local desc = Instance.new("TextLabel")
	desc.Name = "Description"
	desc.Size = UDim2.new(1, 0, 0, 0)
	desc.AutomaticSize = Enum.AutomaticSize.Y
	desc.BackgroundTransparency = 1
	desc.TextWrapped = true
	desc.TextColor3 = COLORS.descText
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 11
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.LayoutOrder = 3
	desc.Parent = entry

	if currentTarget then
		desc.Text = currentTarget.Title or questData.Description or ""
	else
		desc.Text = questData.Description or ""
	end

	-- Progress bar
	if totalTargets > 0 then
		local progressFrame = Instance.new("Frame")
		progressFrame.Name = "ProgressBar"
		progressFrame.Size = UDim2.new(1, 0, 0, 12)
		progressFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		progressFrame.BackgroundTransparency = 0.3
		progressFrame.BorderSizePixel = 0
		progressFrame.LayoutOrder = 4
		progressFrame.Parent = entry

		local progressCorner = Instance.new("UICorner")
		progressCorner.CornerRadius = UDim.new(0, 4)
		progressCorner.Parent = progressFrame

		local fillFraction = math.clamp(achieved / totalTargets, 0, 1)

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.Size = UDim2.new(fillFraction, 0, 1, 0)
		fill.BackgroundColor3 = COLORS.progressText
		fill.BackgroundTransparency = 0.3
		fill.BorderSizePixel = 0
		fill.Parent = progressFrame

		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(0, 4)
		fillCorner.Parent = fill

		local progressLabel = Instance.new("TextLabel")
		progressLabel.Name = "ProgressText"
		progressLabel.Size = UDim2.fromScale(1, 1)
		progressLabel.BackgroundTransparency = 1
		progressLabel.Text = achieved .. " / " .. totalTargets
		progressLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		progressLabel.Font = Enum.Font.GothamBold
		progressLabel.TextSize = 9
		progressLabel.ZIndex = 2
		progressLabel.Parent = progressFrame
	end

	-- Divider
	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.BackgroundColor3 = COLORS.divider
	divider.BackgroundTransparency = 0.5
	divider.BorderSizePixel = 0
	divider.LayoutOrder = 5
	divider.Parent = entry

	return entry
end

function QuestTrackerHUD.Refresh()
	if not questContainer then return end

	-- Clear existing entries
	for _, child in pairs(questContainer:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local questsData = _G.QuestsData
	if not questsData then return end

	local order = 0
	local hasActiveQuest = false

	-- Display active quests in priority order
	local questSources = {
		{ data = questsData.TutorialQuestData, label = "Tutorial" },
		{ data = questsData.NPCQuestData, label = "Story" },
		{ data = questsData.LevelQuestData, label = "Level" },
		{ data = questsData.DailyQuestData, label = "Daily" },
	}

	for _, source in ipairs(questSources) do
		if source.data and source.data.Id and not source.data.IsCompleted then
			order = order + 1
			local entry = createQuestEntry(source.data, source.label, order)
			if entry then
				entry.Parent = questContainer
				hasActiveQuest = true
			end
		end
	end

	-- Show/hide panel based on active quests
	if trackerGui then
		trackerGui.Enabled = hasActiveQuest
	end
end

function QuestTrackerHUD.Init()
	createTrackerGui()
	QuestTrackerHUD.Refresh()

	-- Listen to data changes
	if _G.PlayerDataStore then
		_G.PlayerDataStore:ListenChange(function(newData)
			if newData then
				task.delay(0.2, function()
					QuestTrackerHUD.Refresh()
				end)
			end
		end)
	end
end

return QuestTrackerHUD
