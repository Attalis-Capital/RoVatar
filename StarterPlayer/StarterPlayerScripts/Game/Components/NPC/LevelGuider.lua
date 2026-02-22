-- @ScriptType: ModuleScript
local TeleportService = game:GetService("TeleportService")
local RS = game:GetService("ReplicatedStorage")
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
local LevelGuider = Component.new({Tag = "LevelGuider", Ancestors = {workspace}})

-----Other Knit classes
--Services
local QuestDataService 
local MultiplaceHandlerService

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

function RespawnNPC(Model)
	local new = Model:Clone()
	new:SetAttribute("Duplicate", true)
	
	new.Parent = Model.Parent
	Model:Destroy()
end

function Claim(QData:CT.QuestDataType)
	local plrData :CT.PlayerDataModel = _G.PlayerData
	local plrQuestData :CT.PlayerQuestDataModel = _G.QuestsData

	--print('[Quest] Claiming...', QData, plrQuestData, plrData)
	local Updated = CF.PlayerData.ClaimQuestReward(QData, plrData, plrQuestData)

	if Updated then
		SFXHandler:Play(Constants.SFXs.Reward, true)

		_G.PlayerDataStore:UpdateData(plrData)
		--_G.QuestsDataStore:UpdateData(plrQuestData)
	else
		--print("[Quest] Something wrong!")
	end
end

local function Teleport(placeID)
	local playerGui = player:WaitForChild("PlayerGui")
	local teleportGui = playerGui:FindFirstChild("TeleportGui")
	--teleportGui.Enabled = true
	--teleportGui.Loading.Enabled = true

	-- set the loading gui for the destination place
	--TeleportService:SetTeleportGui(teleportGui)

	CF.UI.Blink(player, 50)
	MultiplaceHandlerService.Teleport:Fire(placeID, true)
end

function AssignQuest(QuestData :CustomTypes.QuestDataType)
	local plrQuestData :CustomTypes.PlayerQuestDataModel = _G.QuestsData 
	local _questData :CustomTypes.QuestDataType = QuestData

	if plrQuestData.LevelQuestData and plrQuestData.LevelQuestData.Objective and
		plrQuestData.LevelQuestData.Objective == _questData.Objective then
		-- Already Assigned
		warn("[Quests] Task Already Assigned..<><><><><><><>? \n Something went Wrong !!!! Check this out !!!!")
		return
	else
		_questData.Type = Constants.QuestType.LevelQuest
		_questData.StartTime = workspace.Timers.Datetime.Value

		plrQuestData.LevelQuestData = _questData

		local plrData:CustomTypes.PlayerDataModel = _G.PlayerData
		plrData.AllProfiles[plrData.ActiveProfile].Data.Quests = plrQuestData
		_G.PlayerDataStore:UpdateData(plrData)
		--print("[Quests] [Player Quest Data ] Updated NPC QuestData ", plrQuestData)
		
		if _questData.Title then
			QuestGui:ShowTitle(_questData.Title)
		end
	end
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

local function CreateNoTaskToAssignDialogue(self)

	local DialogueData :CustomTypes.DialogueDataType = {}
	DialogueData.Narrator = self.Instance.Name

	if CF.PlayerQuestData.GetJourneyQuestProgress(_G.PlayerData) > CF.Tables.TableLength(QuestModule.Quests.NPC.Combined) then
		DialogueData.Message = "I don't have any quests for you right now. You can speak to the Pink Guiders for more tasks."
	else
		DialogueData.Message = "I don't have any quests for you right now. You can speak to Oryn for more tasks."
	end

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

function LevelGuider:StartConversation()
	local Level = player.Progression.LEVEL.Value
	local plrQuestData :CustomTypes.PlayerQuestDataModel = _G.QuestsData

	local conversation:CustomTypes.ConversationsDataType = Conversation.LevelUP[Level]
	local QuestData = plrQuestData.LevelQuestData

	local IsTutorialCompleted = plrQuestData.TutorialQuestData.Id and plrQuestData.TutorialQuestData.IsCompleted  
	if IsTutorialCompleted then
		if QuestData.Objective then
			local IsCompleted = QuestData.IsCompleted
			local IsClaimed = QuestData.IsClaimed

			if IsCompleted and not IsClaimed then
				-- Show Message to Claim the Reward first
				CreateClaimQuestDialogue(self, QuestData)
			else
				-- Not Completed Show the Progression
				CreatePendingQuestDialogue(self, QuestData)
			end
		else
			if conversation then
				local plrData = _G.PlayerData
				if Level == 6 then
					if CF.PlayerQuestData.GetPlayerActiveProfile(plrData).Data.EquippedInventory.Transports[Constants.Items.Glider.Id] then
						CreateNoTaskToAssignDialogue(self)
					else
						CreateDialogue(self, conversation)
					end 
				else
					CreateDialogue(self, conversation)
				end
			else
				CreateNoTaskToAssignDialogue(self)
			end
		end
	else
		CreateDialogue(self, Conversation.Tutorial[1])
	end
end

---------------------->>>>>>>>>>>>>........... Setup functions
function LevelGuider:StartMoving()
	local PathPoints = self.Instance:WaitForChild("PathPoints") --1,2,3,4 ....1,2,3,4

	local path = PathPoints:GetChildren()

	local pathStage = 1
	self.RunConn = game:GetService("RunService").RenderStepped:Connect(function()
		if self.Humanoid.Health > 0 then
			--if(self.ActionState == ActionStates.Idle) then
			local part :Part = path[pathStage]

			self.Humanoid:MoveTo(part.Position)
			local FinalPos = Vector3.new(part.Position.X, self.Root.Position.Y, part.Position.Z)
			local SelfPos = self.Root.Position

			local Distance = (FinalPos - SelfPos).Magnitude

			if Distance < 1 then
				if pathStage == #path then
					pathStage = 1
				else
					pathStage += 1
				end
			end

			--end
		end
	end)

	--self.moveThread = task.spawn(function()
	--	while true do
	--		for i, v in pairs(PathPoints:GetChildren()) do
	--			local Point = PathPoints:FindFirstChild(i)
	--			print("Point :", Point)
	--			self.Path:Run(Point.Position)
	--			self.Humanoid.MoveToFinished:Wait()
	--			print("Point : Reached", Point)
	--			local TimeToWait = Point:GetAttribute("Wait") or 5
	--			task.wait(TimeToWait)
	--		end
	--	end
	--end)
end

function LevelGuider:SetupPrompt()

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

		--print("[PROMPT] SHOW")
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
function LevelGuider:Start()
	
	-- Doing this because the moveTo run properly from client side and each npc can be easily handle on client.
	if not self.Instance:GetAttribute("Duplicate") then
		RespawnNPC(self.Instance)
		return
	end

	print(self, "Quest Start!")
	
	QuestDataService = Knit.GetService("QuestDataService")
	MultiplaceHandlerService = Knit.GetService("MultiplaceHandlerService")
	UIController = Knit.GetController("UIController")
	PlayerController = Knit.GetController("PlayerController")

	DialogueGui = UIController:GetGui(Constants.UiScreenTags.DialogueGui, 2)
	QuestGui = UIController:GetGui(Constants.UiScreenTags.QuestGui, 2)

	self.Root = self.Instance.PrimaryPart
	self.Humanoid = self.Instance.Humanoid
	-- Instansiate class for path finding
	self.Path = SimplePath.new(self.Instance)

	-- Setup
	self:SetupPrompt()
	self:StartMoving()

end

return LevelGuider