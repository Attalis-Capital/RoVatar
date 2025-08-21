-- @ScriptType: ModuleScript
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local RunS = game:GetService("RunService")
local TS = game:GetService("TweenService")

local Packages = RS.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)
local Timer = require(Packages.Timer)

local CustomModules = RS.Modules.Custom
local CT = require(CustomModules.CustomTypes)
local CF = require(CustomModules.CommonFunctions)
local Constants = require(CustomModules.Constants)
local SFXHandler = require(CustomModules.SFXHandler)

local player = game.Players.LocalPlayer

local QuestGui = Component.new({Tag = "QuestGui", Ancestors = {player}})

type Data = {
	Label : TextLabel,
	QuestData :CT.QuestDataType,
}

type QuestFrame = {
	RewardsFrame : Frame,
	ClaimButton : ImageButton,
	Description :TextLabel,
	ProgressTxt : TextLabel,
	TimerTxt : TextLabel,
	Title : TextLabel,
}

type UI = {
	Gui : ScreenGui,
	BaseFrame :TextButton,

	Background :ImageLabel,

	ElementsContainer :ScrollingFrame,

	CloseBtn :ImageButton,

	Templates : {
		DailyQuestF : QuestFrame,
		StoryQuestF : QuestFrame,
		Gold : ImageLabel,
		Gems : ImageLabel,
		Xp : ImageLabel,
	},

	QuestTitle :Frame & {
		Label :TextLabel,
		Shadow1 :TextLabel,
		Shadow2 :TextLabel,
	},

	---- TaskHintDisplay
	TaskHintDisplay : Frame & {
		Template :Folder,
		Scroll :ScrollingFrame,
		Toggle :ImageButton,
	}
}

local ui :UI = {}


------ Other scripts
local UIController
local TWController

local QuestDataService

------ \\\ Timer Calculations
local Container = {}

local countDownFunction = function(Data:Data)

	local QuestData : CT.QuestDataType = Data.QuestData
	local Label = Data.Label

	local remainingSeconds = CF.Validations.QuestRemainingSec(QuestData)

	local hours = math.floor(remainingSeconds / 3600)
	remainingSeconds = remainingSeconds % 3600
	local minutes = math.floor(remainingSeconds / 60)
	local seconds = remainingSeconds % 60

	local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)
	Label.Text = timeString

	if not CF.Validations.IsQuestValid(QuestData) then
		TimeOver(QuestData)
	end

end

local CountDown = Timer.new(1)
CountDown.Tick:Connect(function()
	if #Container > 0 then
		for _, Data : Data in pairs(Container) do
			countDownFunction(Data)
		end
	end
end)

------ /// Timer Calculations

------------- Helper ------------
function TimeOver(OverQuest:CT.QuestDataType)
	-- First Remove from the Timer loop Container
	local Index = table.find(Container, OverQuest)
	if Index then
		--print("[Quest] Remove from the Container")
		table.remove(Container, Index)
	end

	-- Get playerQuestData : 
	local plrQuestData :CT.PlayerQuestDataModel = _G.QuestsData

	----- Check type > NPC Quest or Daily Quest
	if OverQuest.Type == Constants.QuestType.DailyQuest then
		-- Send Event to Server for next DailyQuest
		QuestDataService.RefreshDailyQuest:Fire()
		task.delay(1, Refresh) -- Data May be updated for daily Quests
	elseif OverQuest.Type == Constants.QuestType.NPCQuest then

		local QuestData :CT.QuestDataType = plrQuestData.NPCQuestData
		if QuestData.Id then
			-- check for completed
			if QuestData.IsCompleted then
				--warn("[something wrong!] [Quest] Already Completed ('_')")
				if QuestData.IsClaimed then
					plrQuestData.NPCQuestData = {}
				end
			else
				if (QuestData.Achieved) and (QuestData.Achieved >= CF.Tables.TableLength(QuestData.Targets)) then
					QuestData.IsCompleted = true
				end

				plrQuestData.NPCQuestData = {}
			end

			local plrData:CustomTypes.PlayerDataModel = _G.PlayerData
			plrData.AllProfiles[plrData.ActiveProfile].Data.Quests = plrQuestData
			_G.PlayerDataStore:UpdateData(plrData)
			Refresh()
		else
			--warn("[Quest] ...No Data Found! No Problem...")
		end
	elseif OverQuest.Type == Constants.QuestType.LevelQuest then

		local ActiveQuest :CT.QuestDataType = plrQuestData.LevelQuestData
		if ActiveQuest.Id then
			--print("[Quest-Update] Active Quest ", ActiveQuest)

			-- check for completed
			if ActiveQuest.IsCompleted then
				warn("[something wrong!] [Quest] Already Completed ('_')")
				if ActiveQuest.IsClaimed then

					plrQuestData.LevelQuestData = {}
				end
			else
				if (ActiveQuest.Achieved) and (ActiveQuest.Achieved >= CF.Tables.TableLength(ActiveQuest.Targets)) then

					ActiveQuest.IsCompleted = true
				end

				plrQuestData.LevelQuestData = {}
			end

			local plrData:CustomTypes.PlayerDataModel = _G.PlayerData
			plrData.AllProfiles[plrData.ActiveProfile].Data.Quests = plrQuestData
			_G.PlayerDataStore:UpdateData(plrData)
			Refresh()
		else
			--warn("[Quest] ...No Data Found! No Problem...")
		end
	end
end

function ClaimButton(QData:CT.QuestDataType)
	local plrData :CT.PlayerDataModel = _G.PlayerData
	local plrQuestData :CT.PlayerQuestDataModel = _G.QuestsData

	--print('[Quest] Claiming...', QData, plrQuestData, plrData)
	local Updated = CF.PlayerData.ClaimQuestReward(QData, plrData, plrQuestData)

	if Updated then

		--_G.QuestsDataStore:UpdateData(plrQuestData)
		_G.PlayerDataStore:UpdateData(plrData)

		SFXHandler:Play(Constants.SFXs.Reward, true)
		Refresh()
	else
		--print("[Quest] Something wrong!")
	end
end
-------------------------

local function _clear(parent)
	for _, child in pairs(parent:GetChildren()) do
		if child:IsA("ImageLabel") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end
end

function QuestGui:RefreshHints()
	--TaskHintDisplay
	_clear(ui.Scroll)

	local plrQuestData :CT.PlayerQuestDataModel = _G.QuestsData
	--print("[Quest Updated]", plrQuestData.LevelQuestData, ui.Scroll:GetChildren())

	local DailyQuest = plrQuestData.DailyQuestData
	local LevelQuest = plrQuestData.LevelQuestData
	local NPCQuest = plrQuestData.NPCQuestData
	local TutorialQuest = plrQuestData.TutorialQuestData
	local updated = false

	if _G.IsHub then

		if DailyQuest.Id and not DailyQuest.IsCompleted then
			local hintField = ui.Templates.HintField:Clone()
			hintField.Parent = ui.Scroll
			hintField.Visible = true
			updated = true
			local Achieved = DailyQuest.Achieved or 0
			local Title = DailyQuest.Targets[Achieved+1].Title or " "
			hintField.Label.Text = Title
			hintField.LayoutOrder = 0
		end

		if LevelQuest.Id and not LevelQuest.IsCompleted then
			local hintField = ui.Templates.HintField:Clone()
			hintField.Parent = ui.Scroll
			hintField.Visible = true

			local Achieved = LevelQuest.Achieved or 0
			local Title = LevelQuest.Targets[Achieved+1].Title or " "
			updated = true
			hintField.Label.Text = Title
			hintField.LayoutOrder = 1
		end

		if NPCQuest.Id and not NPCQuest.IsCompleted then
			local hintField = ui.Templates.HintField:Clone()
			hintField.Parent = ui.Scroll
			hintField.Visible = true
			updated = true
			local Achieved = NPCQuest.Achieved or 0
			local Title = NPCQuest.Targets[Achieved+1].Title or " "

			hintField.Label.Text = Title
			hintField.LayoutOrder = 3
		end
	else
		if TutorialQuest.Id and not TutorialQuest.IsCompleted then
			local hintField = ui.Templates.HintField:Clone()
			hintField.Parent = ui.Scroll
			hintField.Visible = true

			local Achieved = TutorialQuest.Achieved or 0
			local Title = TutorialQuest.Targets[Achieved+1].Title or " "

			hintField.Label.Text = Title
			hintField.LayoutOrder = 4
			updated = true
		end
	end

	if updated == false then
		self.HintsEnabled = updated
		ToggleHints(self.HintsEnabled)
	end
end

local function _updateCell(Cell : QuestFrame, QuestData : CT.QuestDataType, IsDailyQuest)

	Cell.Visible = true
	Cell.Title.Text = QuestData.Title or QuestData.Name
	Cell.Description.Text = QuestData.Description

	---- Spawning Rewards Gems, Gold, XP
	for key, Value:CT.RewardDetailsType in pairs(QuestData.Reward) do

		local reward
		if Value.Type == Constants.QuestRewardType.XP then
			reward = ui.Templates.Xp:Clone()
		elseif Value.Type == Constants.QuestRewardType.Gold then
			reward = ui.Templates.Gold:Clone()
		elseif Value.Type == Constants.QuestRewardType.Gems then
			reward = ui.Templates.Gems:Clone()
		elseif Value.Type == Constants.QuestRewardType.LevelUp then
			reward = ui.Templates.LevelUp:Clone()
		end
		
		reward.Visible = true
		reward.Parent = Cell.RewardsFrame
		reward.Amount.Text = "+"..Value.Value
	end

	---- Checks for visibility and Reward claiming.
	if QuestData.IsCompleted then

		Cell.TimerTxt.Visible = false

		ui.TaskHintDisplay.Toggle.Visible = false
		if not QuestData.IsClaimed then
			Cell.ProgressTxt.Visible = false
			Cell.ClaimButton.Visible = true
			Cell.ClaimButton.Activated:Connect(function()
				ClaimButton(QuestData)

				--11 dec due to client requirement
				CloseButton()
			end)
		else
			if QuestData.Type == Constants.QuestType.NPCQuest then
				Cell.Visible = false
			end

			Cell.ProgressTxt.Visible = true
			Cell.ClaimButton.Visible = false
			Cell.ProgressTxt.Text = "✓ COMPLETED"

			--11 dec due to client requirement
			Cell.Visible = false
		end
	else
		ui.TaskHintDisplay.Toggle.Visible=true
		Cell.TimerTxt.Visible = true
		Cell.ProgressTxt.Visible = true
		Cell.ClaimButton.Visible = false

		Cell.ProgressTxt.Text = math.ceil(((QuestData.Achieved or 0) / CF.Tables.TableLength(QuestData.Targets)) * 100) .. "% COMPLETE"

		---- Setup Remaining Time
		local Data : Data = {}
		Data.Label = Cell.TimerTxt
		Data.QuestData = QuestData

		countDownFunction(Data) -- exact action on screen visible
		table.insert(Container, Data) -- Functions table call each fun every sec..
	end

	------ Subs for tweening Effects
	task.spawn(function()
		TWController:SubsHover(Cell)
		TWController:SubsHover(Cell:FindFirstChild("ClaimButton"))
		TWController:SubsHover(Cell:FindFirstChild("RewardsFrame"))

		TWController:SubsClick(Cell:FindFirstChild("ClaimButton"))
	end)
end

local lastQuestsCount = 0
function Refresh()
	local plrQuestData :CT.PlayerQuestDataModel = _G.QuestsData
	Container = {}
	CountDown:Start()
	_clear(ui.ElementsContainer)

	if _G.IsHub then
		------- Daily Quests -----
		local DailyQuest = plrQuestData.DailyQuestData
		if DailyQuest.Id then

			local DailyQuestF = ui.Templates.DailyQuestF
			DailyQuestF = DailyQuestF:Clone()
			DailyQuestF.Parent = ui.ElementsContainer
			_updateCell(DailyQuestF, DailyQuest, true) -- third parameter for the Daily Quest Check
		end

		------- Level Quests -----
		local LevelQuest = plrQuestData.LevelQuestData
		if LevelQuest.Objective then
			local StoryQuestF = ui.Templates.StoryQuestF
			StoryQuestF = StoryQuestF:Clone()
			StoryQuestF.Parent = ui.ElementsContainer

			_updateCell(StoryQuestF, LevelQuest, false) -- third parameter for the Daily Quest Check
		end

		------- NPC Quests ------
		local NPCQuests = plrQuestData.NPCQuestData

		--for _, QuestData in pairs(NPCQuests) do
		if NPCQuests.Objective then

			local StoryQuestF = ui.Templates.StoryQuestF
			StoryQuestF = StoryQuestF:Clone()
			StoryQuestF.Parent = ui.ElementsContainer

			_updateCell(StoryQuestF, NPCQuests, false)
		end
	else
		----- Tutorial Quests -----
		local TutorialQuest = plrQuestData.TutorialQuestData

		if TutorialQuest.Id then

			local TutorialQuestF = ui.Templates.DailyQuestF
			TutorialQuestF = TutorialQuestF:Clone()
			TutorialQuestF.Parent = ui.ElementsContainer

			_updateCell(TutorialQuestF, TutorialQuest, false) -- third parameter for the Daily Quest Check
		end

		----- NPC Completed Quest -----
		--local NPCQuests = plrQuestData.NPCQuestData.CompletedQuests

		--for _, QuestData in pairs(NPCQuests) do
		--	local StoryQuestF = ui.Templates.StoryQuestF
		--	StoryQuestF = StoryQuestF:Clone()
		--	StoryQuestF.Parent = ui.ElementsContainer

		--	StoryQuestF.LayoutOrder = 100
		--	_updateCell(StoryQuestF, QuestData, false)
		--end
	end

	QuestGui:RefreshHints()

	local IsQuestActive = false
	local currentActiveQuests = 0
	for _, questCell in pairs(ui.ElementsContainer:GetChildren()) do
		if questCell:IsA("ImageLabel") then
			if questCell.Visible then
				IsQuestActive = true
				currentActiveQuests += 1
			end
		end
	end

	----
	if not game.Workspace:GetAttribute("GameLoaded") or not game.Workspace:GetAttribute("GameStarted") then
		ToggleHints(false)
	else
		if currentActiveQuests > lastQuestsCount then
			ToggleHints(IsQuestActive)
		end
	end

	lastQuestsCount = currentActiveQuests

	MainMenuGui:ToggleQuestMarker(IsQuestActive)
end

----------------------***************** Private Methods **********************----------------------

function CloseButton()
	CountDown:Stop()
	QuestGui:Toggle(false)
end

local tweenInfo = TweenInfo.new(.5)
function ToggleHints(enable)
	if enable then

		ui.Toggle.Icon.Rotation = -90
		ui.TaskHintDisplay:TweenPosition(UDim2.new(1, 0 ,0.068, 0), nil, nil, .5, true)
	else

		ui.Toggle.Icon.Rotation = 90
		ui.TaskHintDisplay:TweenPosition(UDim2.new(1.308, 0 ,0.068, 0), nil, nil, .5, true)
	end
end

----------------------***************** Public Methods **********************----------------------

function QuestGui:ShowTitle(title)

	local function tween(visible)
		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

		if visible then
			ui.QuestTitle.Position = UDim2.fromScale(.5, -.5)
			ui.QuestTitle.Size = UDim2.fromScale(.75, 0)
			ui.QuestTitle.Visible = true
			local tween = TS:Create(ui.QuestTitle, tweenInfo, {Position = UDim2.fromScale(.5, .115), Size = UDim2.fromScale(.75, .16)})
			tween:Play()

			game.Debris:AddItem(tween, tweenInfo.Time + .1)
		else
			ui.QuestTitle.Position = UDim2.fromScale(.5, .115)
			ui.QuestTitle.Size = UDim2.fromScale(.75, .16)
			local tween = TS:Create(ui.QuestTitle, tweenInfo, {Position = UDim2.fromScale(.5, -.5), Size = UDim2.fromScale(.75, .05)})
			tween:Play()

			tween.Completed:Once(function()
				ui.QuestTitle.Visible = false
				tween:Destroy()
			end)
		end
	end


	ui.QuestTitle.Label.Text = title
	ui.QuestTitle.Shadow1.Text = title
	ui.QuestTitle.Shadow2.Text = title

	SFXHandler:Play(Constants.SFXs.Quest_Assign, true)

	tween(true)

	task.delay(5, function()
		tween(false)	
	end)
end

function QuestGui:Construct()
	UIController = Knit.GetController("UIController")
	TWController = Knit.GetController("TweenController")

	QuestDataService = Knit.GetService("QuestDataService")

	self.active = UIController:SubsUI(Constants.UiScreenTags.QuestGui, self)

end

function QuestGui:Start()

	if(self.active) then
		self:InitReferences()
		self:InitButtons()
	end

	MainMenuGui = UIController:GetGui(Constants.UiScreenTags.MainMenuGui, 2)

	TWController:SubsTween(ui.BaseFrame, Constants.TweenDir.Left)

	TWController:SubsHover(ui.Background)
	TWController:SubsHover(ui.CloseBtn)

	TWController:SubsClick(ui.CloseBtn)

	self:Toggle(false)

	task.delay(2, function()
		Refresh()
		_G.PlayerDataStore:ListenChange(function(newData)
			if newData then
				Refresh()
				task.delay(1, function()
					self:RefreshHints()
				end)
			end
		end)
	end)

end

function QuestGui:InitReferences()
	ui.Gui = self.Instance
	ui.BaseFrame = ui.Gui.BaseFrame

	ui.Background = ui.BaseFrame.Background

	ui.CloseBtn = ui.Background.CloseButton
	ui.ElementsContainer = ui.Background.ElementsFrame

	ui.Templates = ui.Background.Templates

	ui.TaskHintDisplay = ui.Gui.TaskHintDisplay
	ui.Toggle = ui.TaskHintDisplay.Toggle
	ui.Scroll = ui.TaskHintDisplay.Scroll

	ui.QuestTitle = ui.Gui.QuestTitle

	self.HintsEnabled = ui.TaskHintDisplay.Visible
end

function QuestGui:InitButtons()
	ui.CloseBtn.Activated:Connect(function()
		CloseButton()
	end)

	ui.TaskHintDisplay.Visible = true
	local tweenInfo = TweenInfo.new(.5)

	ui.Toggle.Activated:Connect(function()
		self.HintsEnabled = not self.HintsEnabled
		ToggleHints(self.HintsEnabled)
	end)
end

function QuestGui:IsVisible()
	return ui.BaseFrame.Visible
end

function QuestGui:Toggle(enable:boolean)
	if(enable ~= nil) then
		enable = (enable)
	else
		enable = (not ui.BaseFrame.Visible)
	end
	ui.BaseFrame.Visible = enable

	if enable then
		Refresh() -- Karna: Call with Quest Data Update Event. 
	end

end

return QuestGui