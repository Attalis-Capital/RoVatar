-- @ScriptType: ModuleScript
local CS = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Packages = RS.Packages

local Knit = require(Packages.Knit)
local Component = require(Packages.Component)
----Related scripts
local CF = require(RS.Modules.Custom.CommonFunctions)
local Constants = require(RS.Modules.Custom.Constants)
local SFXHandler = require(RS.Modules.Custom.SFXHandler)
local SimplePath = require(RS.Modules.Custom.SimplePath)
local CustomTypes = require(RS.Modules.Custom.CustomTypes)
local QuestModule = require(RS.Modules.Custom.QuestsModule)
local Conversations = require(RS.Modules.Custom.QuestsModule.Conversation)

local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

----- Create Component class
local QuestGuy = Component.new({Tag = "QuestGuy", Ancestors = {workspace}})

-----Other Knit classes

--Controllers
local UIController
local QuestController

-- Components
local DialogueGui = nil
local QuestGui = nil

-- Variable
local Talking = false
---------------------->>>>>>>>>>>>>........... Common local functions

---------------------->>>>>>>>>>>>>........... Quests Public functions

function RespawnNPC(Model)
	local new = Model:Clone()
	new:SetAttribute("Duplicate", true)
	
	new.Parent = Model.Parent
	Model:Destroy()
end

function Claim(QData:CT.QuestDataType)
	local plrData :CT.PlayerDataModel = _G.PlayerData
	local plrQuestData :CT.PlayerQuestDataModel = _G.QuestsData

	local Updated = CF.PlayerData.ClaimQuestReward(QData, plrData, plrQuestData)

	if Updated then
		SFXHandler:Play(Constants.SFXs.Reward, true)

		_G.PlayerDataStore:UpdateData(plrData)
		--_G.QuestsDataStore:UpdateData(plrQuestData)
	else
		--print("[Quest] Something wrong!")
	end
end

function QuestGuy:AssignQuest(Quest)
	-- Check for Active Quest in PlayerData

	local plrQuestData :CustomTypes.AllQuestsType = _G.QuestsData

	if plrQuestData.NPCQuestData.Id then
		-- Already Assigned
		warn("[Quests] Task Already Assigned..")
		return 
	else
		Quest.Type = Constants.QuestType.NPCQuest
		Quest.StartTime = workspace.Timers.Datetime.Value

		plrQuestData.NPCQuestData = Quest

		local plrData:CustomTypes.PlayerDataModel = _G.PlayerData
		plrData.AllProfiles[plrData.ActiveProfile].Data.Quests = plrQuestData
		_G.PlayerDataStore:UpdateData(plrData)
		--print("[Quests] [Player Quest Data ] Updated NPC QuestData ", plrQuestData)
		
		if Quest.Title then
			QuestGui:ShowTitle(Quest.Title)
		end
	end
end

function CreateTooLowLevelDialogue(self)
	-- Your level is too low. Complete more quests to reach #Conversations.LevelUP.
	-- Start by talking to Kaen for tutorial quests that will help you level up.

	local DialogueData :CustomTypes.DialogueDataType = {}
	DialogueData.Narrator = self.Instance.Name
	DialogueData.Message = "Your level is too low. Complete more quests to reach "..(#Conversations.LevelUP + 1)..". \nStart by talking to Kaen for tutorial quests that will help you level up." 

	local DialogueButton :CustomTypes.DialogueButtonType = {}
	DialogueButton.Txt = "Ok"
	DialogueButton.Image = "rbxassetid://17575066019"

	DialogueButton.OnAction = function()
		Talking = false
		self.Prompt.Enabled = true
		DialogueGui:Finish()
	end

	DialogueData.Options = {
		[1] = DialogueButton
	}

	DialogueData.AllowSkip = true
	DialogueData.ForceStart = true

	DialogueGui:ShowDialogue(DialogueData)
end


local function CreateNoTaskToAssignDialogue(self)

	local DialogueData :CustomTypes.DialogueDataType = {}
	DialogueData.Narrator = self.Instance.Name
	
	local otherGurus = {"Pink Guiders", "Oryn"}
	otherGurus = otherGurus[math.random(1, #otherGurus)]
	
	DialogueData.Message = `I don't have any quests for you right now. You can speak to the {otherGurus} for more tasks.`
	
	local DialogueButton :CustomTypes.DialogueButtonType = {}
	DialogueButton.Txt = "Ok"
	DialogueButton.Image = "rbxassetid://17575066019"

	DialogueButton.OnAction = function()
		Talking = false
		self.Prompt.Enabled = true
		DialogueGui:Finish()
	end

	DialogueData.Options = {
		[1] = DialogueButton
	}

	DialogueData.AllowSkip = true
	DialogueData.ForceStart = true

	DialogueGui:ShowDialogue(DialogueData)
end

local function CreateTalkToAnotherNPCDialogue(self, referringNPCName)

	local DialogueData :CustomTypes.DialogueDataType = {}
	DialogueData.Narrator = self.Instance.Name
	
	local otherGurus = {referringNPCName}
	otherGurus = otherGurus[math.random(1, #otherGurus)]
	
	DialogueData.Message = `I don't have any quests for you right now. You can speak to the {otherGurus} for the tasks.`
	
	local DialogueButton :CustomTypes.DialogueButtonType = {}
	DialogueButton.Txt = "Ok"
	DialogueButton.Image = "rbxassetid://17575066019"

	DialogueButton.OnAction = function()
		Talking = false
		self.Prompt.Enabled = true
		DialogueGui:Finish()
	end

	DialogueData.Options = {
		[1] = DialogueButton
	}

	DialogueData.AllowSkip = true
	DialogueData.ForceStart = true

	DialogueGui:ShowDialogue(DialogueData)
end


local function CreatePendingQuestDialogue(self, QuestData :CustomTypes.QuestDataType)

	local DialogueData :CustomTypes.DialogueDataType = {}
	DialogueData.Narrator = self.Instance.Name
	DialogueData.Message = QuestData.PendingMsg

	local DialogueButton :CustomTypes.DialogueButtonType = {}
	DialogueButton.Txt = "Ok"
	DialogueButton.Image = "rbxassetid://17575066019"

	DialogueButton.OnAction = function()
		Talking = false
		self.Prompt.Enabled = true
		DialogueGui:Finish()
	end

	DialogueData.Options = {
		[1] = DialogueButton
	}

	DialogueData.AllowSkip = true
	DialogueData.ForceStart = true

	DialogueGui:ShowDialogue(DialogueData)
end

local function CreateClaimQuestDialogue(self, QuestData :CustomTypes.QuestDataType)

	local DialogueData :CustomTypes.DialogueDataType = {}
	DialogueData.Narrator = self.Instance.Name
	DialogueData.Message = QuestData.CompleteMsg

	local DialogueButton :CustomTypes.DialogueButtonType = {}
	DialogueButton.Txt = "Claim"
	DialogueButton.Image = "rbxassetid://17575066019"

	DialogueButton.OnAction = function()
		Talking = false
		self.Prompt.Enabled = true
		DialogueGui:Finish()
		Claim(QuestData)
	end

	DialogueData.Options = {
		[1] = DialogueButton
	}

	DialogueData.AllowSkip = true
	DialogueData.ForceStart = true

	DialogueGui:ShowDialogue(DialogueData)
	
end

local function CreateDialogue(self, Conversation :CustomTypes.ConversationsDataType)

	local DialogueData :CustomTypes.DialogueDataType = {}
	DialogueData.Narrator = self.Instance.Name
	DialogueData.Message = Conversation.Title
	DialogueData.Options = {}

	for key, optData:CustomTypes.ConversationsDataType in pairs(Conversation.Options) do

		local DialogueButton :CustomTypes.DialogueButtonType = {}
		DialogueButton.Txt = optData.Text
		DialogueButton.Image = optData.Image
		
		print(optData)
		
		if optData.ClickAction.Assign then
			DialogueButton.OnAction = function()
				Talking = false
				self.Prompt.Enabled = true
				self:AssignQuest(optData.ClickAction.Assign)
				DialogueGui:Finish()
			end
		elseif optData.ClickAction.Dialogue then
			DialogueButton.OnAction = function()
				CreateDialogue(self, optData.ClickAction.Dialogue)
			end
		else
			DialogueButton.OnAction = function()
				Talking = false
				self.Prompt.Enabled = true
				DialogueGui:Finish()
			end
		end

		table.insert(DialogueData.Options, DialogueButton)
	end

	DialogueData.AllowSkip = true
	DialogueData.ForceStart = true

	DialogueGui:ShowDialogue(DialogueData)
end

function QuestGuy:StartConversation()
	local level = player.Progression.LEVEL.Value
	local plrData = _G.PlayerData
	local hasGlider = CF.PlayerQuestData.GetPlayerActiveProfile(plrData).Data.EquippedInventory.Transports[Constants.Items.Glider.Id]
	
	local GuideName = self.Instance.Name
	QuestController.UpdateQuest:Fire(Constants.QuestObjectives.Combined, GuideName)
	
	print(`Plr level: {level} and hasGlider {hasGlider}`)
	if Conversations.LevelUP[level] and not hasGlider then
		-- Your level is too low. Complete more quests to reach #Conversations.LevelUP. 
		-- Start by talking to Kaen for tutorial quests that will help you level up.
		CreateTooLowLevelDialogue(self)
	else
		
		local ALLCONVERSATIONS = Conversations.NPC[self.Type]
		
		-- Get Conversation randomly
		local index = math.random(1, #ALLCONVERSATIONS)
		local dialogues = ALLCONVERSATIONS[index]
		
		local plrQuestData :CustomTypes.PlayerQuestDataModel = _G.QuestsData

		local activeQuest = plrQuestData.NPCQuestData
		if activeQuest.Id then
			-- Please complete the Quest First
			if not activeQuest.IsCompleted then
				CreatePendingQuestDialogue(self, activeQuest)
			elseif not activeQuest.IsClaimed then
				CreateClaimQuestDialogue(self, activeQuest)
			else
				warn("[Quest] Something went wrong!")
			end
		else
			--Special check for sequence-wise quests
			if self.Type == Constants.QuestObjectives.Visit or self.Type == Constants.QuestObjectives.Combined then
				local journeyQuestProgress = CF.PlayerQuestData.GetJourneyQuestProgress(_G.PlayerData)

				if journeyQuestProgress <= CF.Tables.TableLength(QuestModule.Quests.NPC.Combined) then
					local assigner = Conversations.NPC.Combined[journeyQuestProgress].Assigner
					if assigner == self.Instance.Name then
						dialogues = Conversations.NPC.Combined[journeyQuestProgress]
					else
						CreateTalkToAnotherNPCDialogue(self, assigner)
						return
					end
				end
			elseif (self.Type == Constants.QuestObjectives.Train) then
				local kataraQuestProgress = CF.PlayerQuestData.GetKataraQuestProgress(_G.PlayerData)
				if kataraQuestProgress <= CF.Tables.TableLength(QuestModule.Quests.NPC.Train) then
					dialogues = Conversations.NPC.Train[kataraQuestProgress]
				else
					CreateNoTaskToAssignDialogue(self)
					return
				end
			end
			
			CreateDialogue(self, dialogues)
		end
	end
end

---------------------->>>>>>>>>>>>>........... Setup functions

function QuestGuy:StartMoving()
	local PathPoints = self.Instance:WaitForChild("PathPoints") --1,2,3,4 ....1,2,3,4
	self.moveThread = task.spawn(function()
		while true do
			for i, v in pairs(PathPoints:GetChildren()) do
				local Point = PathPoints:FindFirstChild(i)
				--self.Path:Run(Point.Position)
				self.Humanoid:MoveTo(Point.Position)
				self.Humanoid.MoveToFinished:Wait()
				local TimeToWait = Point:GetAttribute("Wait") or 5
				task.wait(TimeToWait)
			end
		end
	end)
end

function QuestGuy:SetupPrompt()

	self.Prompt = self.Instance:FindFirstChild("Prompt") do
		self.Prompt.Parent = PlayerGui
		self.Prompt.Talk.MouseButton1Click:Connect(function()
			Talking = true
			self.Prompt.Enabled = false
			self:StartConversation()
		end)
	end

	local Proximity:ProximityPrompt = self.Instance:FindFirstChild("Proximity")
	Proximity.PromptShown:Connect(function()
		-- Stop NPC from moving and Enable Prompt to talk
		if not Talking then
			self.Humanoid.WalkSpeed = 0
			self.Prompt.Enabled = true
			--self.Root.CFrame = CFrame.lookAt(self.Root.Position, char.PrimaryPart.Position)
		end
	end)

	self.Humanoid.WalkSpeed = 10
	Proximity.PromptHidden:Connect(function()
		if not Talking then
			self.Humanoid.WalkSpeed = 10
			self.Prompt.Enabled = false

			--Karna Stop Dialogue
		end

		if Talking then
			Talking = false
			task.wait(.6)
			DialogueGui:Finish(true)
		end
	end)

	self.Prompt:GetPropertyChangedSignal("Enabled"):Connect(function()
		self.Instance.Head.Prompt.Enabled = not self.Prompt.Enabled
	end)
end
---------------- Component functions
function QuestGuy:Start()
	print(self, "Quest Start!")
	
	-- Doing this because the moveTo run properly from client side and each npc can be easily handle on cliet.
	if not self.Instance:GetAttribute("Duplicate") then
		RespawnNPC(self.Instance)
		return
	end
	
	UIController = Knit.GetController("UIController")
	QuestController = Knit.GetController("QuestController")

	DialogueGui = UIController:GetGui(Constants.UiScreenTags.DialogueGui, 2)
	QuestGui = UIController:GetGui(Constants.UiScreenTags.QuestGui, 2)

	self.Root = self.Instance.PrimaryPart
	self.Humanoid = self.Instance.Humanoid
	self.Type = self.Instance:GetAttribute("QuestType")

	self.Path = SimplePath.new(self.Instance)

	-- Setup
	self:SetupPrompt()
	self:StartMoving()
end

return QuestGuy