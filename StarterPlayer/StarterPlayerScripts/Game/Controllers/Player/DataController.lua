-- @ScriptType: ModuleScript
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local Knit = require(RS.Packages.Knit)

local player = game.Players.LocalPlayer

local Constants = require(RS.Modules.Custom.Constants)
local CF = require(RS.Modules.Custom.CommonFunctions)
local CT = require(RS.Modules.Custom.CustomTypes)

local QuestTrackerHUD = require(RS.Modules.Custom.QuestTrackerHUD)

local DR = require(RS.Modules.Custom.DataReplicator)
DR.SetupAll()
_G.PlayerDataStore = DR.GetStore(Constants.DataStores.PlayerData.Name)
--_G.QuestsDataStore = DR.GetStore(Constants.DataStores.QuestsStore.Name)

-- Ready-gate: initialise with defaults so consumers never see nil before
-- the ListenChange callback fires. pcall guards against workspace.ServerTime
-- not existing yet on the client at require-time.
local ok, defaultModel = pcall(CF.PlayerData.GetPlayerDataModel)
if ok and defaultModel then
	_G.PlayerData = CF.Tables.CloneTable(defaultModel)
	local activeProfile = defaultModel.ActiveProfile
	if activeProfile and defaultModel.AllProfiles and defaultModel.AllProfiles[activeProfile] then
		_G.QuestsData = CF.Tables.CloneTable(defaultModel.AllProfiles[activeProfile].Data.Quests)
	else
		_G.QuestsData = { TutorialQuestData = {}, LevelQuestData = {}, DailyQuestData = {}, NPCQuestData = {} }
	end
else
	-- Minimal stub so nil-index crashes are avoided until real data arrives
	_G.PlayerData = {
		ActiveProfile = "",
		AllProfiles = {},
		LoginData = {},
		GamePurchases = { Passes = {}, Subscriptions = {} },
		OwnedInventory = {},
		PersonalProfile = {},
		CoupansData = {},
	}
	_G.QuestsData = { TutorialQuestData = {}, LevelQuestData = {}, DailyQuestData = {}, NPCQuestData = {} }
end

---------> Helper references
local HelperF = script.Parent.Parent.Parent.Helpers



local DataController = Knit.CreateController {
	Name = "DataController",
}


-------------------------------->>>>>>>>>  <<<<<<<<<<-------------------------------

local function Init()
	
	_G.PlayerDataStore:ListenChange(function(data:CT.PlayerDataModel)
		--warn("[DataChanged] CHange listened PlayerData")
		_G.PlayerData = CF.Tables.CloneTable(data) --Only use this to get the values (use _G.PlayerDataStore to set/update the data)
		local profile = data.ActiveProfile and data.AllProfiles and data.AllProfiles[data.ActiveProfile]
		if profile and profile.Data and profile.Data.Quests then
			_G.QuestsData = CF.Tables.CloneTable(profile.Data.Quests)
		end
	end)
	
	--_G.QuestsDataStore:ListenChange(function(data)
	--	warn("[DataChanged] CHange lifstened QuestData")
	--	_G.QuestsData = CF.Tables.CloneTable(data) --Only use this to get the values (use _G.QuestsDataStore to set/update the data)
	--end)
	
	--_G.PlayerData = CF.PlayerData.GetPlayerDataModel()
	--_G.QuestsData = CF.PlayerQuestData.GetPlayerQuestDataModel()
end

Init()

-- Initialise the always-visible quest tracker HUD after _G.PlayerDataStore
-- and _G.QuestsData are ready so the panel can populate immediately.
QuestTrackerHUD.Init()

function DataController:KnitInit()

end

function DataController:KnitStart()

end

return DataController