-- @ScriptType: ModuleScript
-- BreadcrumbController.lua
-- Sprint 3 (#15): Breadcrumb navigation system.
-- Shows a 3D marker at quest target position + screen-edge arrow when off-screen.
-- Quest target positions come from workspace objects.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local Knit = require(RS.Packages.Knit)

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local BreadcrumbController = Knit.CreateController {
	Name = "BreadcrumbController",
}

-- State
local activeMarker = nil -- 3D part in workspace
local arrowGui = nil
local arrowImage = nil
local distanceLabel = nil
local markerBillboard = nil
local updateConn = nil
local targetPosition = nil -- Vector3

-- Config
local MARKER_COLOR = Color3.fromRGB(255, 215, 80)
local ARROW_SIZE = 40
local SCREEN_EDGE_MARGIN = 60

local function createArrowGui()
	if arrowGui and arrowGui.Parent then return end

	local playerGui = player:WaitForChild("PlayerGui")

	arrowGui = Instance.new("ScreenGui")
	arrowGui.Name = "BreadcrumbArrow"
	arrowGui.DisplayOrder = 55
	arrowGui.IgnoreGuiInset = true
	arrowGui.ResetOnSpawn = false
	arrowGui.Enabled = false
	arrowGui.Parent = playerGui

	-- Arrow indicator (using ImageLabel with rotation)
	arrowImage = Instance.new("ImageLabel")
	arrowImage.Name = "Arrow"
	arrowImage.Size = UDim2.fromOffset(ARROW_SIZE, ARROW_SIZE)
	arrowImage.BackgroundTransparency = 1
	arrowImage.Image = "rbxassetid://6031091004" -- standard arrow/chevron
	arrowImage.ImageColor3 = MARKER_COLOR
	arrowImage.AnchorPoint = Vector2.new(0.5, 0.5)
	arrowImage.Parent = arrowGui

	-- Distance text below arrow
	distanceLabel = Instance.new("TextLabel")
	distanceLabel.Name = "Distance"
	distanceLabel.Size = UDim2.fromOffset(80, 18)
	distanceLabel.AnchorPoint = Vector2.new(0.5, 0)
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.TextColor3 = MARKER_COLOR
	distanceLabel.Font = Enum.Font.GothamBold
	distanceLabel.TextSize = 11
	distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	distanceLabel.TextStrokeTransparency = 0.3
	distanceLabel.Parent = arrowGui
end

local function create3DMarker(position)
	-- Clean up old marker
	if activeMarker then
		activeMarker:Destroy()
		activeMarker = nil
	end

	-- Glowing sphere at target
	local marker = Instance.new("Part")
	marker.Name = "QuestBreadcrumb"
	marker.Shape = Enum.PartType.Ball
	marker.Size = Vector3.new(3, 3, 3)
	marker.Position = position + Vector3.new(0, 5, 0)
	marker.Anchored = true
	marker.CanCollide = false
	marker.Material = Enum.Material.Neon
	marker.Color = MARKER_COLOR
	marker.Transparency = 0.3
	marker.CastShadow = false
	marker.Parent = workspace

	-- Billboard with icon above marker
	markerBillboard = Instance.new("BillboardGui")
	markerBillboard.Name = "MarkerLabel"
	markerBillboard.Adornee = marker
	markerBillboard.Size = UDim2.fromOffset(60, 30)
	markerBillboard.StudsOffset = Vector3.new(0, 3, 0)
	markerBillboard.AlwaysOnTop = true
	markerBillboard.Parent = marker

	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.fromScale(1, 1)
	icon.BackgroundTransparency = 1
	icon.Text = "!"
	icon.TextColor3 = MARKER_COLOR
	icon.Font = Enum.Font.GothamBold
	icon.TextSize = 22
	icon.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	icon.TextStrokeTransparency = 0.2
	icon.Parent = markerBillboard

	-- Gentle bob animation
	local bobTween = TweenService:Create(
		marker,
		TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Position = position + Vector3.new(0, 7, 0) }
	)
	bobTween:Play()

	activeMarker = marker
	return marker
end

local function updateArrowPosition()
	if not targetPosition then return end
	if not arrowGui then return end

	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local viewportSize = camera.ViewportSize
	local screenPos, onScreen = camera:WorldToViewportPoint(targetPosition + Vector3.new(0, 5, 0))

	local dist = (root.Position - targetPosition).Magnitude
	local distText = dist < 1000 and (math.floor(dist) .. "m") or (string.format("%.1fkm", dist / 1000))

	if onScreen and screenPos.Z > 0 then
		-- Target is on screen: hide arrow
		arrowGui.Enabled = false
		-- Show 3D marker billboard
		if markerBillboard then
			markerBillboard.Enabled = true
		end
	else
		-- Target is off screen: show arrow at screen edge
		arrowGui.Enabled = true
		if markerBillboard then
			markerBillboard.Enabled = false
		end

		-- Calculate direction from screen centre to target's projected position
		local centreX = viewportSize.X / 2
		local centreY = viewportSize.Y / 2

		local dirX = screenPos.X - centreX
		local dirY = screenPos.Y - centreY

		-- If behind camera, flip direction
		if screenPos.Z < 0 then
			dirX = -dirX
			dirY = -dirY
		end

		local angle = math.atan2(dirY, dirX)

		-- Clamp to screen edge with margin
		local maxX = (viewportSize.X / 2) - SCREEN_EDGE_MARGIN
		local maxY = (viewportSize.Y / 2) - SCREEN_EDGE_MARGIN

		local edgeX = centreX + math.cos(angle) * maxX
		local edgeY = centreY + math.sin(angle) * maxY

		-- Clamp within bounds
		edgeX = math.clamp(edgeX, SCREEN_EDGE_MARGIN, viewportSize.X - SCREEN_EDGE_MARGIN)
		edgeY = math.clamp(edgeY, SCREEN_EDGE_MARGIN, viewportSize.Y - SCREEN_EDGE_MARGIN)

		arrowImage.Position = UDim2.fromOffset(edgeX, edgeY)
		arrowImage.Rotation = math.deg(angle)

		distanceLabel.Position = UDim2.fromOffset(edgeX, edgeY + ARROW_SIZE / 2 + 2)
		distanceLabel.Text = distText
	end
end

function BreadcrumbController:SetTarget(position)
	targetPosition = position

	if position then
		createArrowGui()
		create3DMarker(position)

		-- Start render loop if not already running
		if not updateConn then
			updateConn = RunService.RenderStepped:Connect(updateArrowPosition)
		end
	else
		BreadcrumbController:ClearTarget()
	end
end

function BreadcrumbController:ClearTarget()
	targetPosition = nil

	if updateConn then
		updateConn:Disconnect()
		updateConn = nil
	end

	if activeMarker then
		activeMarker:Destroy()
		activeMarker = nil
	end

	if arrowGui then
		arrowGui.Enabled = false
	end
end

function BreadcrumbController:KnitInit()
end

function BreadcrumbController:KnitStart()
	createArrowGui()

	-- Integrate with quest data: find the current target's workspace position
	local function refreshBreadcrumb()
		local questsData = _G.QuestsData
		if not questsData then
			BreadcrumbController:ClearTarget()
			return
		end

		-- Find first active non-completed quest with a locatable target
		local activeQuests = {
			questsData.TutorialQuestData,
			questsData.NPCQuestData,
			questsData.LevelQuestData,
			questsData.DailyQuestData,
		}

		for _, quest in ipairs(activeQuests) do
			if quest and quest.Id and not quest.IsCompleted then
				local achieved = quest.Achieved or 0
				local targets = quest.Targets
				local currentTarget = targets and targets[achieved + 1]

				if currentTarget then
					-- Try to find a workspace object matching the target ID
					local targetObj = workspace:FindFirstChild(currentTarget.Id, true)
					if targetObj then
						local pos = targetObj:IsA("Model") and targetObj:GetPivot().Position or targetObj.Position
						BreadcrumbController:SetTarget(pos)
						return
					end
				end
			end
		end

		-- No locatable target found
		BreadcrumbController:ClearTarget()
	end

	-- Initial refresh
	task.delay(3, refreshBreadcrumb)

	-- Listen for data changes
	if _G.PlayerDataStore then
		_G.PlayerDataStore:ListenChange(function(newData)
			if newData then
				task.delay(0.5, refreshBreadcrumb)
			end
		end)
	end
end

return BreadcrumbController
