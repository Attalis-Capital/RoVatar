-- @ScriptType: ModuleScript
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local Knit = require(RS.Packages.Knit)

local player = game.Players.LocalPlayer

local Constants = require(RS.Modules.Custom.Constants)
local CF = require(RS.Modules.Custom.CommonFunctions)
local CT = require(RS.Modules.Custom.CustomTypes)

local DR = require(RS.Modules.Custom.DataReplicator)
DR.SetupAll()
_G.PlayerDataStore = DR.GetStore(Constants.DataStores.PlayerData.Name)
--_G.QuestsDataStore = DR.GetStore(Constants.DataStores.QuestsStore.Name)



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
		_G.QuestsData = CF.Tables.CloneTable(data.AllProfiles[data.ActiveProfile].Data.Quests)
	end)
	
	--_G.QuestsDataStore:ListenChange(function(data)
	--	warn("[DataChanged] CHange lifstened QuestData")
	--	_G.QuestsData = CF.Tables.CloneTable(data) --Only use this to get the values (use _G.QuestsDataStore to set/update the data)
	--end)
	
	--_G.PlayerData = CF.PlayerData.GetPlayerDataModel()
	--_G.QuestsData = CF.PlayerQuestData.GetPlayerQuestDataModel()
end

Init()

function DataController:KnitInit()

end

function DataController:KnitStart()

end

return DataController