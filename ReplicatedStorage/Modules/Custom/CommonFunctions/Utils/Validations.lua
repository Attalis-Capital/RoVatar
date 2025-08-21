-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")

local CD = require(RS.Modules.Custom.Constants)
local CT = require(RS.Modules.Custom.CustomTypes)

local PlayerQuestData = require(RS.Modules.Custom.CommonFunctions.Utils.Player.PlayerQuestData)
local Validations

Validations= {
	QuestRemainingSec = function(QuestData : CT.QuestDataType)

		local Start = QuestData.StartTime
		local Duration = QuestData.Duration

		local currentTime = workspace.Timers.Datetime.Value

		local diff = os.difftime(currentTime, Start)

		local remainingSeconds
		if Duration and (QuestData.Type == CD.QuestType.NPCQuest or QuestData.Type == CD.QuestType.LevelQuest) then
			local DurationInSec = (Duration * 60 * 60)

			if diff >= DurationInSec then
				remainingSeconds = 0
			else
				remainingSeconds = DurationInSec - diff
			end
		else
			remainingSeconds = workspace.Timers.Remaining.Value
		end

		if remainingSeconds <= 0 then
			return 0
		else
			return remainingSeconds
		end
	end,
	
	IsQuestValid = function(QuestData : CT.QuestDataType)
		local remTime = Validations.QuestRemainingSec(QuestData)
		if remTime == 0 then
			return false
		else
			return true
		end
	end,
	
	_updateQuest = function(QuestData :CT.QuestDataType)

		if QuestData.IsCompleted then
			--print("Already Completed!", QuestData.Id)
			return 
		end

		if not Validations.IsQuestValid(QuestData) then
			--print('[Quest] Quest Not Valid ', QuestData)
			return
		end

		local Achieved =  QuestData.Achieved or 0
		local Target = #QuestData.Targets

		local IsAchieved = false
		local IsCompleted = false

		if Achieved < Target then
			Achieved += 1
			IsAchieved = true
			QuestData.Achieved = Achieved
		end

		if QuestData.Achieved == Target then
			if not QuestData.IsCompleted then
				IsCompleted = true
			end
			QuestData.IsCompleted = true
		end

		return IsAchieved, IsCompleted
	end,

	UpdateQuest = function(plrData :CT.PlayerDataModel, Objective, Achivement)
		local update = false
		local isAchieved, isCompleted = false, false

		local function _update(QuestData)
			if QuestData.Id and QuestData.Objective == Objective then
				local Achived = QuestData.Achieved or 0
				local target = QuestData.Targets[Achived + 1]
				if target and target.Id and target.Id == Achivement then
					local IsAchieved, IsCompleted = Validations._updateQuest(QuestData)
					isAchieved = IsAchieved or isAchieved
					isCompleted = IsCompleted or isCompleted
					update = true
				end
			end
		end

		local activeProfile :CT.ProfileSlotDataType = PlayerQuestData.GetPlayerActiveProfile(plrData)

		local NPCQuestData:CT.QuestDataType = activeProfile.Data.Quests.NPCQuestData
		local DailyQuestData:CT.QuestDataType = activeProfile.Data.Quests.DailyQuestData
		local LevelQuestData:CT.QuestDataType = activeProfile.Data.Quests.LevelQuestData
		local TutorialQuestData:CT.QuestDataType = activeProfile.Data.Quests.TutorialQuestData

		_update(NPCQuestData)
		_update(DailyQuestData)
		_update(LevelQuestData)
		_update(TutorialQuestData)

		if TutorialQuestData.IsCompleted then TutorialQuestData.IsClaimed = true end ---

		return update, isAchieved, isCompleted
	end,
}

return Validations
