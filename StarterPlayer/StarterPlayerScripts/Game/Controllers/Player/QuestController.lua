-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")

local Knit = require(RS.Packages.Knit)
local Signal = require(RS.Packages.Signal)

local CT = require(RS.Modules.Custom.CustomTypes)
local CF = require(RS.Modules.Custom.CommonFunctions)
local Constants = require(RS.Modules.Custom.Constants)
local SFXHandler = require(RS.Modules.Custom.SFXHandler)
local QuestsModule = require(RS.Modules.Custom.QuestsModule)

local Assets = RS.Assets.Models.Quests

local player = game.Players.LocalPlayer
local Char, Root
---------> Helper references
local HelperF = script.Parent.Parent.Parent.Helpers

---------> Workspace objects
local Beam = workspace.Terrain:WaitForChild("Guide")
local NPCs = workspace.Scripted_Items.NPCs.Attacking
---------> Other scripts
local PlayerDataService
local QuestDataService

local QuestController = Knit.CreateController {
	Name = "QuestController",

	UpdateQuest = Signal.new(),
}

-------------------------------->>>>>>>>> Private Method <<<<<<<<<<-------------------------------
local function PlaySound(player, Achieved, Completed)
	if Achieved then
		SFXHandler:Play(Constants.SFXs.Quest_Notice, true)
	end

	if Completed then
		SFXHandler:Play(Constants.SFXs.Quest_Completed, true)
	end
end

function UpdateQuest(Objective, Achivement)
	local plrData : CT.AllQuestsType = _G.PlayerData
	local plrQuestData : CT.AllQuestsType = _G.QuestsData
	
	local NPCQuestActive = plrQuestData.NPCQuestData.Id and plrQuestData.NPCQuestData.Objective == Objective or false
	local DailyQuestActive = plrQuestData.DailyQuestData.Id and plrQuestData.DailyQuestData.Objective == Objective or false
	local LevelQuestActive = plrQuestData.LevelQuestData.Id and plrQuestData.LevelQuestData.Objective == Objective or false

	if NPCQuestActive or DailyQuestActive or LevelQuestActive then

		local IsUpdated, IsAchived, IsCompleted = CF.Validations.UpdateQuest(plrData, Objective, Achivement)	

		if IsUpdated then 
			_G.PlayerDataStore:UpdateData(plrData)
		end
		
		PlaySound(player, IsAchived, IsCompleted)
		return true
	end

	return false
end

------# Data handling
local DebrisObjects = {}
local function ClearDebris(specificItem)
	if specificItem then
		if specificItem.Gui then
			specificItem.Gui:Destroy()
		end
		if specificItem.Conn then
			specificItem.Conn:Disconnect()
		end
		if specificItem.Item then
			specificItem.Item:Destroy()
		end
	else
		for _, data in pairs(DebrisObjects) do
			if data.Gui then
				data.Gui:Destroy()
			end
			if data.Conn then
				data.Conn:Disconnect()
			end
			if data.Item then
				data.Item:Destroy()
			end
		end
		DebrisObjects = {}
	end

end

local function Disconnect(conns)
	for _, conn in pairs(conns) do
		if conn then
			conn:Disconnect()
		end
	end
end

local trainingConnections = {}
function BindTrainActions(ActiveQuest)
	
	local Achived = ActiveQuest.Achieved or 0
	local Target = ActiveQuest.Targets[Achived + 1]
	
	if ActiveQuest.IsCompleted then return end
	if Target then
		
		if Target.Id == Constants.QuestTargetIds.ManaDeplete then
			trainingConnections.ManaDeplete = player.CombatStats.Strength:GetPropertyChangedSignal("Value"):Connect(function()
				if player.CombatStats.Strength.Value < 30 then
					QuestController.UpdateQuest:Fire(Constants.QuestObjectives.Train, Constants.QuestTargetIds.ManaDeplete)
				end
			end)
		elseif Target.Id == Constants.QuestTargetIds.ManaRestored then
			trainingConnections.ManaRestored = player.CombatStats.Strength:GetPropertyChangedSignal("Value"):Connect(function()
				if player.CombatStats.Strength.Value >= 100 then
					QuestController.UpdateQuest:Fire(Constants.QuestObjectives.Train, Constants.QuestTargetIds.ManaRestored)
				end
			end)
		end
	end
end

function SpawnItem(ActiveQuest :CT.QuestDataType)
	local Achived = (ActiveQuest.Achieved == nil and 1 or (ActiveQuest.Achieved + 1))
	local Target = ActiveQuest.Targets[Achived]
	if ActiveQuest.IsCompleted then return end

	if Target then
		local TargetItem = Assets.Find:FindFirstChild(Target.Id) do
			if not TargetItem then return end
			
			TargetItem = TargetItem:Clone()
			local Parent = workspace.Scripted_Items.QuestData.Find
			TargetItem.Parent = Parent
			local prompt:BillboardGui = TargetItem.Handle.Prompt
			prompt.Parent = player:WaitForChild("PlayerGui")
			prompt.Adornee = TargetItem.Handle
			
			local debris = {}
			debris.Item = TargetItem
			debris.Gui = prompt
			debris.Conn = prompt.Base.Button.Activated:Connect(function()
				-- Hide Object Effect
				local success = UpdateQuest(ActiveQuest.Objective, Target.Id)
				if success then
					ClearDebris(debris)
				end
			end)

			table.insert(DebrisObjects, debris)
		end
	end
end

function RefreshForHub()
	local function _checkQuest(Quest :CT.QuestDataType) -- Check Find Quest if there something to interact...
		if Quest.Id then
			local Objective = Quest.Objective
			if Objective == Constants.QuestObjectives.Find or Objective == Constants.QuestObjectives.Combined then
				SpawnItem(Quest)
			elseif Objective == Constants.QuestObjectives.Train then
				BindTrainActions(Quest)
			else
				--print("[no need to manage] ", Quest.Type)
			end
			
		end
	end
	
	ClearDebris()
	Disconnect(trainingConnections)
	
	local plrQuestData:CT.AllQuestsType = _G.QuestsData
	--print("[TEST DELAY] QuestController ", plrQuestData)
	--print("QuestData:", plrQuestData)
	---------------------- [[Check for tutorial]]
	if plrQuestData.TutorialQuestData.Id and plrQuestData.TutorialQuestData.IsCompleted then
		--- Quest Completed
		local LevelUpQuestData = plrQuestData.LevelQuestData
		local DailyQuestData = plrQuestData.DailyQuestData
		local NPCQuestData = plrQuestData.NPCQuestData

		_checkQuest(LevelUpQuestData)
		_checkQuest(DailyQuestData)
		_checkQuest(NPCQuestData)

		Beam.Enabled = false

		--Special check only for Zephir Guide
		local specialNPCName = "Zephir Guide"
		if(NPCQuestData.Id == QuestsModule.Quests.NPC.Combined.The_Zephir_Reclamation.Id) then
			local achieved = NPCQuestData.Achieved or 1

			if NPCQuestData.Targets[achieved + 1] then
				if NPCQuestData.Targets[achieved + 1].Id == QuestsModule.TargetIds[specialNPCName] then

					local _NPCs = CS:GetTagged(Constants.Tags.QuestGuy)
					local _npc = nil
					for i, npc in pairs(_NPCs) do
						if(npc.Name == specialNPCName) then
							_npc = npc
							break
						end
					end

					if(not _npc) then
						print("Returning not found! ", _npc)
						return
					end

					local Attachment = _npc:WaitForChild("HumanoidRootPart"):WaitForChild("RootRigAttachment")
					Beam.Attachment0 = Attachment
					Beam.Attachment1 = Root.RootRigAttachment
					Beam.Enabled = true
				end 
			end
		end
	else
		-- Show Beam Towards the NPC
		Beam.Enabled = true
	end
end

function RefreshForTutorial()
	local plrQuestData:CT.AllQuestsType = _G.QuestsData

	if plrQuestData.TutorialQuestData.Id and not plrQuestData.TutorialQuestData.IsCompleted then
		--
		local npcs = NPCs.Tutorial:GetChildren()
		local NPC = npcs[1]

		if NPC:WaitForChild("Humanoid").Health <= 0 then
			Beam.Enabled = false
			task.delay(1, function()
				RefreshForTutorial()
			end)
		else
			Beam.Enabled = true
		end

		local Attachment = NPC:WaitForChild("HumanoidRootPart"):WaitForChild("RootRigAttachment")

		Beam.Attachment0 = Attachment
		Beam.Attachment1 = Root.RootRigAttachment
		--Beam.Enabled = true
	else
		local NPCs = CS:GetTagged(Constants.Tags.TutorialGuider)
		local NPC = NPCs[1]

		local Attachment = NPC:WaitForChild("HumanoidRootPart"):WaitForChild("RootRigAttachment")
		Beam.Attachment0 = Attachment
		Beam.Attachment1 = Root.RootRigAttachment
		--print("[NPC]NPC Guru", NPC, Attachment)
		Beam.Enabled = true
	end
end

local function ListenChanges()
	
	local refreshFunc = _G.IsHub and RefreshForHub or RefreshForTutorial
	
	_G.PlayerDataStore:ListenChange(function(newData)
		if newData then
			task.delay(.5, function()
				refreshFunc()
			end)
		end
	end)
	
	refreshFunc()
end

local function CharacterAdded()
	Char = player.Character or player.CharacterAdded:Wait()
	Root = Char:WaitForChild('HumanoidRootPart')
	Beam.Attachment1 = Root.RootRigAttachment
end

-------------------------------->>>>>>>>> Public Methods <<<<<<<<<<-------------------------------
function QuestController:KnitInit()
	QuestDataService = Knit.GetService("QuestDataService")

	self.UpdateQuest:Connect(UpdateQuest)
	player.CharacterAdded:Connect(CharacterAdded)
	CharacterAdded()
end

function QuestController:KnitStart()
	-- Update[Toggle] Quests Items
	task.delay(2, function()
		ListenChanges()
	end)
	
	if not _G.IsHub then
		NPCs.ChildAdded:Connect(function(child)
			RefreshForTutorial()
		end)
	end
end

return QuestController