-- @ScriptType: ModuleScript
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")

local Knit = require(RS.Packages.Knit)
local Signal = require(RS.Packages.Signal)

local CF = require(RS.Modules.Custom.CommonFunctions)
local CD = require(RS.Modules.Custom.Constants)
local CT = require(RS.Modules.Custom.CustomTypes)
local SFXHandler = require(RS.Modules.Custom.SFXHandler)
local QuestModule = require(RS.Modules.Custom.QuestsModule)
local DataReplicator = require(RS.Modules.Custom.DataReplicator)

---- Create Service
local QuestDataService = Knit.CreateService {
	Name = "QuestDataService",

	UpdateQuest = Signal.new(),
	Client = {
		UpdateQuest = Knit.CreateSignal(),
		RefreshDailyQuest = Knit.CreateSignal(),
	}
}

---- Other services

---- Variables

--------------------------------------------->>>>>>>>>>>> Private Methods <<<<<<<<<<<<----------------------------------------------
function IsSameDay(StartTime)

	if not StartTime then return false end

	warn("Time at server:",os.date("!*t",workspace:GetServerTimeNow()))
	local currentYear = tonumber(os.date("!%Y",workspace:GetServerTimeNow()))
	local currentDay = tonumber(os.date("!%j",workspace:GetServerTimeNow()))
	local currentDateTime = os.date("!*t",workspace:GetServerTimeNow())

	local savedYear = tonumber(os.date("!%Y",StartTime))
	local savedDay = tonumber(os.date("!%j", StartTime))
	local savedDateTime = os.date("!*t", StartTime)

	print(currentDay,currentYear, savedDay, savedYear)
	local previousDay = currentDay - 1
	print("in previousDay:",previousDay)

	-->>Special check for last day of year and current date is 1 jan
	if (currentDateTime.yday == 1) then
		if (savedDateTime.month == 12 and savedDateTime.day == 31 and savedDateTime.year == (currentYear - 1)) then
			return true
		end
	end

	-->>Other days check
	if(currentDay == savedDay) and (currentYear == savedYear) then
		warn("Player joined on same day")
		return true
	elseif (savedDay == previousDay) and (currentYear == savedYear) then
		warn("Player last login was yesterday")
		return false
	else
		warn("Player last login was before yesterday")
		return false
	end
end

----------------------------------
local QuestProbabilities = { -- Constant
	--[[ Sunday - Saturday]]
	[1] = {QuestModule.QuestObjectives.Kill, QuestModule.QuestObjectives.Kill, QuestModule.QuestObjectives.Kill, QuestModule.QuestObjectives.Visit},
	[2] = {QuestModule.QuestObjectives.Visit, QuestModule.QuestObjectives.Visit, QuestModule.QuestObjectives.Visit, QuestModule.QuestObjectives.Kill},
	[3] = {QuestModule.QuestObjectives.Find, QuestModule.QuestObjectives.Find, QuestModule.QuestObjectives.Visit, QuestModule.QuestObjectives.Kill},
	[4] = {QuestModule.QuestObjectives.Kill, QuestModule.QuestObjectives.Visit, QuestModule.QuestObjectives.Find},
	[5] = {QuestModule.QuestObjectives.Visit, QuestModule.QuestObjectives.Kill, QuestModule.QuestObjectives.Visit},
	[6] = {QuestModule.QuestObjectives.Find, QuestModule.QuestObjectives.Kill, QuestModule.QuestObjectives.Kill},
	[7] = {QuestModule.QuestObjectives.Kill, QuestModule.QuestObjectives.Visit, QuestModule.QuestObjectives.Visit},
}

local today_WeakDay = 0
local today_Quest = {}
function GetQuest()
	local function _processQuest(weakDay)
		local Collection = QuestProbabilities[weakDay]
		local Type = Collection[math.random(1, #Collection)]
		local Quest = CF.Tables.RandomValue(QuestModule.Quests.Daily[Type])
		if not Quest or Quest == {} then
			warn("[Error] Quest could not finalized≠!")
			Quest = QuestModule.Quests.Daily.Visit.KioshiIsland
		end
		return Quest
	end

	local WeakDay = os.date("!*t",workspace:GetServerTimeNow()).wday

	if WeakDay ~= today_WeakDay then
		today_WeakDay = WeakDay
		today_Quest = _processQuest(WeakDay)
	end

	return today_Quest	
end

-------------------------------------

local function PlaySound(player, Achieved, Completed)
	if Achieved then
		SFXHandler.Client.PlayAlong(player, CD.SFXs.Quest_Notice, player.Character)
	end

	if Completed then
		SFXHandler.Client.PlayAlong(player, CD.SFXs.Quest_Completed, player.Character)
	end
end

-------------------- Quests>>>>>>>>>>>>>


function UpdateQuest(player, Objective, Achivement)
	print("[Quest] update quest Request ", player, Objective, Achivement)
	if not Achivement then
		print("[Quest] update quest Request [Task Id not found]")
		return
	end
	_G.PlayerDataStore:GetData(player, function(plrData:CT.PlayerDataModel)
		--PlaySound(player, IsAchieved, IsCompleted)
		local IsUpdated, IsAchived, IsCompleted = CF.Validations.UpdateQuest(plrData, Objective, Achivement)

		PlaySound(player, IsAchived, IsCompleted)
		if IsUpdated then
			-- Update Data
			_G.PlayerDataStore:UpdateData(player, plrData)
		end
	end)
end

local function DailyQuest(plrData:CT.PlayerDataModel): boolean
	local activeProfile = CF.PlayerQuestData.GetPlayerActiveProfile(plrData)
	local changed = false
	local dailyQuest = activeProfile.Data.Quests.DailyQuestData
	local needsNewQuest = not IsSameDay(activeProfile.LastUpdatedOn)
		or not dailyQuest.Id
		or (dailyQuest.IsCompleted and dailyQuest.IsClaimed)
	if needsNewQuest then
		--Karna: * Check for old quest if Completed and not claimed then credit reward

		--* Assign Daily Quest to player
		local QuestData : CT.QuestDataType = CF.Tables.CloneTable(GetQuest())
		QuestData.StartTime = workspace.ServerTime.Value
		QuestData.Type = CD.QuestType.DailyQuest

		activeProfile.Data.Quests.DailyQuestData = QuestData
		changed = true
	end

	--restore new values
	plrData.AllProfiles[plrData.ActiveProfile] = activeProfile
	return changed
end

local refreshCooldowns = {}

local function RefreshDailyQuest(player)
	local now = workspace:GetServerTimeNow()
	if refreshCooldowns[player] and (now - refreshCooldowns[player]) < 60 then
		return
	end
	refreshCooldowns[player] = now

	_G.PlayerDataStore:GetData(player, function(plrData:CT.PlayerDataModel)
		local changed = DailyQuest(plrData)
		if changed then
			_G.PlayerDataStore:UpdateData(player, plrData)
		end
	end)
end

-------------------- Quests>>>>>>>>>>>>>

function QuestDataService:OnPlayerAdded(player:Player, plrData:CT.PlayerDataModel)

	--Check joining and data
	warn("Player Joined Quest DATA :	",plrData)
	local activeProfile = CF.PlayerQuestData.GetPlayerActiveProfile(plrData)

	---- Check and update NPC quests (Durations and Claiming...)
	if activeProfile.Data.Quests.TutorialQuestData.IsCompleted then
		local changed = DailyQuest(plrData)
		if changed then
			-- Persist immediately so daily quest isn't lost on quick disconnect
			_G.PlayerDataStore:UpdateData(player, plrData)
		end
	end

end


function QuestDataService:KnitInit()

	self.UpdateQuest:Connect(UpdateQuest)
	self.Client.UpdateQuest:Connect(UpdateQuest)

	self.Client.RefreshDailyQuest:Connect(RefreshDailyQuest)

	Players.PlayerRemoving:Connect(function(player)
		refreshCooldowns[player] = nil
	end)
end

function QuestDataService:KnitStart()
	
end


return QuestDataService