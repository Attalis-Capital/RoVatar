-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")

local CD = require(RS.Modules.Custom.Constants)
local CT = require(RS.Modules.Custom.CustomTypes)

local PlayerQuestData 

PlayerQuestData = {
	GetJourneyQuestProgress = function(plrData :CT.PlayerDataModel)
		local plrQuestData :CT.AllQuestsType = PlayerQuestData.GetPlrActiveQuests(plrData)

		return plrQuestData.JourneyQuestProgress or 1 --default value 1
	end,

	GetKataraQuestProgress = function(plrData :CT.PlayerDataModel)
		local plrQuestData :CT.AllQuestsType = PlayerQuestData.GetPlrActiveQuests(plrData)

		return plrQuestData.KataraQuestProgress or 1 --default value 1
	end,

	GetPlayerQuestDataModel = function()
		local QuestDataModel : CT.AllQuestsType = {}

		QuestDataModel.NPCQuestData = {}
		QuestDataModel.DailyQuestData = {}
		QuestDataModel.LevelQuestData = {}
		QuestDataModel.TutorialQuestData = {}


		return QuestDataModel
	end,

	GetActiveQuestDataStoreVersion = function()
		return CD.QuestDataStoreVersions[#CD.QuestDataStoreVersions]
	end,

	CheckAndUpdatePlayerQuestData = function(playerQuestData)
		warn("Checking playerData structure:",playerQuestData)
		warn("Active Quest Data Store Structure:", PlayerQuestData.GetPlayerQuestDataModel())
		local newDataModel = PlayerQuestData.GetPlayerQuestDataModel()

		local function CopyTable(t)
			assert(type(t) == "table", "First argument must be a table")
			local tCopy = table.create(#t)
			for k,v in pairs(t) do
				if (type(v) == "table") then
					tCopy[k] = CopyTable(v)
				else
					tCopy[k] = v
				end
			end
			return tCopy
		end

		local function Sync(tbl, templateTbl)
			assert(type(tbl) == "table", "First argument must be a table")
			assert(type(templateTbl) == "table", "Second argument must be a table")

			for k,v in pairs(tbl) do
				local vTemplate = templateTbl[k]

				if (type(v) ~= type(vTemplate)) then
					if (type(vTemplate) == "table") then
						tbl[k] = CopyTable(vTemplate)
					end

					-- Synchronize sub-tables:
				elseif (type(v) == "table") then
					Sync(v, vTemplate)
				end
			end


			-- Add any missing keys:
			for k,vTemplate in pairs(templateTbl) do

				local v = tbl[k]

				if (v == nil) then
					if (type(vTemplate) == "table") then
						tbl[k] = CopyTable(vTemplate)
					else
						tbl[k] = vTemplate
					end
				end

				if(typeof(vTemplate) ~= typeof(v)) then
					--print("Type not same. Key:",k)
					tbl[k] = vTemplate
				end
			end

		end

		local function remove(mainTbl, tmpTbl)
			for k, v in pairs(mainTbl) do
				local keyFound = false
				for kk, vv in pairs(tmpTbl) do
					if(kk == k) then
						keyFound = true
					end
				end

				--Remove the key if NOT found
				if(keyFound == false) then
					--print("Key not found in new tmp table.")
					--print("[Key]",k)
					mainTbl[k] = nil
				else
					if(typeof(v) == "table" and typeof(tmpTbl[k] == "table")) then
						remove(v, tmpTbl[k])
					end
				end
			end
		end

		Sync(playerQuestData, newDataModel)
	end,
	
	

	GetPlayerActiveProfile = function(plrData:CT.PlayerDataModel) :CT.ProfileSlotDataType
		return plrData.AllProfiles[plrData.ActiveProfile]
	end,
	
	GetPlrActiveQuests = function(plrData:CT.PlayerDataModel) :CT.AllQuestsType
		return plrData.AllProfiles[plrData.ActiveProfile].Data.Quests
	end,
}
return PlayerQuestData
