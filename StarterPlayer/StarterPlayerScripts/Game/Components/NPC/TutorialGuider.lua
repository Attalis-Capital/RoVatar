-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Packages = RS.Packages

local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

----Related scripts
local CF = require(RS.Modules.Custom.CommonFunctions)
local Constants = require(RS.Modules.Custom.Constants)
local SimplePath = require(RS.Modules.Custom.SimplePath)
local SFXHandler = require(RS.Modules.Custom.SFXHandler)
local CustomTypes = require(RS.Modules.Custom.CustomTypes)
local QuestModule = require(RS.Modules.Custom.QuestsModule)
local Conversation = require(RS.Modules.Custom.QuestsModule.Conversation)

local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

----- Create Component class
local TutorialGuider = Component.new({Tag = "TutorialGuider", Ancestors = {workspace}})

-----Other Knit classes
--Services
local QuestDataService 

--Controllers
local UIController
local PlayerController 

-- Components
local DialogueGui = nil
local QuestGui = nil

-- Variable
_G.Talking = false

---------------------->>>>>>>>>>>>>........... Common local functions
local char = player.Character or player.CharacterAdded:Wait()
local function OnCharacterAdded(newChar:Model)
	char = newChar or player.CharacterAdded:Wait()
end

player.CharacterAdded:Connect(OnCharacterAdded)
---------------------->>>>>>>>>>>>>........... Quests Public functions
local function Teleport(placeID)
	local playerGui = player:WaitForChild("PlayerGui")
	local teleportGui = playerGui:FindFirstChild("TeleportGui")
	teleportGui.Enabled = true
	teleportGui.Loading.Enabled = true

	-- set the loading gui for the destination place
	TeleportService:SetTeleportGui(teleportGui)

	TeleportService:Teleport(placeID)
end

function AssignQuest(_questData :CustomTypes.QuestDataType)
	local plrQuestData :CustomTypes.AllQuestsType = _G.QuestsData 
	
	
	if plrQuestData.TutorialQuestData and plrQuestData.TutorialQuestData.Objective and
		plrQuestData.TutorialQuestData.Objective == _questData.Objective then
		-- Already Assigned
		warn("[Quests] Task Already Assigned..<><><><><><><>? \n Something went Wrong !!!! Check this out !!!!")
		return
	else
		_questData.Type = Constants.QuestType.TutorialQuest
		_questData.StartTime = workspace.Timers.Datetime.Value

		plrQuestData.TutorialQuestData = _questData
		
		local plrData:CustomTypes.PlayerDataModel = _G.PlayerData
		plrData.AllProfiles[plrData.ActiveProfile].Data.Quests = plrQuestData
		_G.PlayerDataStore:UpdateData(plrData)
		--print("[Quests] [Player Quest Data ] Updated NPC QuestData ", plrQuestData)
		
		if _questData.Title then
			QuestGui:ShowTitle(_questData.Title)
		end
	end
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

local function CreateDialogue(self, Conversation :CustomTypes.ConversationsDataType)

	local DialogueData :CustomTypes.DialogueDataType = {}
	DialogueData.Narrator = self.Instance.Name
	DialogueData.Message = Conversation.Title
	DialogueData.Options = {}

	for key, optData:CustomTypes.ConversationsDataType in pairs(Conversation.Options) do

		local DialogueButton :CustomTypes.DialogueButtonType = {}
		DialogueButton.Txt = optData.Text
		DialogueButton.Image = optData.Image

		if optData.ClickAction.Assign then
			DialogueButton.OnAction = function()
				Talking = false
				self.Prompt.Enabled = true
				AssignQuest(optData.ClickAction.Assign)
				DialogueGui:Finish()
			end
		elseif optData.ClickAction.Dialogue then
			DialogueButton.OnAction = function()
				CreateDialogue(self, optData.ClickAction.Dialogue)
			end
		elseif optData.ClickAction.Teleport then
			DialogueButton.OnAction = function()
				Teleport(optData.ClickAction.Teleport)
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

function TutorialGuider:StartConversation()
	local plrQuestData :CustomTypes.PlayerQuestDataModel = _G.QuestsData
	
	-- Hide non-essential UI during tutorial for cleaner experience
	self:ToggleTutorialUI(false)
	
	local questData = plrQuestData.TutorialQuestData
	if questData.Id then
		if questData.IsCompleted then
			CreateDialogue(self, Conversation.Tutorial[3])
		else
			CreatePendingQuestDialogue(self, questData)
		end
	else
		-- Assign 
		CreateDialogue(self, Conversation.Tutorial[2])
	end
end

-- Hide/show non-essential UI during tutorial to reduce clutter
function TutorialGuider:ToggleTutorialUI(show: boolean)
	-- These screens are hidden during tutorial to avoid overwhelming new players
	local screensToHide = {
		Constants.UiScreenTags.ShopGui,
		Constants.UiScreenTags.BackPackGui,
		Constants.UiScreenTags.MapGui,
		Constants.UiScreenTags.GamePassGui,
		Constants.UiScreenTags.StoreGui,
	}
	
	for _, screenTag in ipairs(screensToHide) do
		pcall(function()
			UIController:ToggleScreen(screenTag, show)
		end)
	end
end

---------------------->>>>>>>>>>>>>........... Setup functions
function TutorialGuider:StartMoving()
	local PathPoints = self.Instance:WaitForChild("PathPoints") --1,2,3,4 ....1,2,3,4
	
	self.moveThread = task.spawn(function()
		while true do
			for i, v in pairs(PathPoints:GetChildren()) do
				local Point = PathPoints:FindFirstChild(i)
				self.Path:Run(Point.Position)
				self.Humanoid.MoveToFinished:Wait()
				local TimeToWait = Point:GetAttribute("Wait") or 5
				task.wait(TimeToWait)
			end
		end
	end)
end

function TutorialGuider:SetupPrompt()
	
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
			
			-- Restore UI when player walks away from tutorial NPC
			self:ToggleTutorialUI(true)
		end
		
		if Talking then
			Talking = false
			task.wait(.6)
			DialogueGui:Finish(true)
			
			-- Restore UI when dialogue is force-closed
			self:ToggleTutorialUI(true)
		end
	end)
	
	self.Prompt:GetPropertyChangedSignal("Enabled"):Connect(function()
		self.Instance.Head.Prompt.Enabled = not self.Prompt.Enabled
	end)
end

---------------- Component functions 
function TutorialGuider:Start()
	print(self, "Quest Start!")
	
	QuestDataService = Knit.GetService("QuestDataService")
	UIController = Knit.GetController("UIController")
	PlayerController = Knit.GetController("PlayerController")
	
	DialogueGui = UIController:GetGui(Constants.UiScreenTags.DialogueGui, 2)
	QuestGui = UIController:GetGui(Constants.UiScreenTags.QuestGui, 2)
	
	self.Root = self.Instance.PrimaryPart
	self.Humanoid = self.Instance.Humanoid
	-- Instansiate class for path finding
	--self.Path = SimplePath.new(self.Instance)
	
	-- Setup
	self:SetupPrompt()
	--self:StartMoving()
	
end

return TutorialGuider