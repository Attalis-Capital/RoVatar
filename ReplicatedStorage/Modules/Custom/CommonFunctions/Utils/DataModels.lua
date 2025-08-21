-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")

local CD = require(RS.Modules.Custom.Constants)
local CT = require(RS.Modules.Custom.CustomTypes)



local VersionHandler = {}

--[[ Convert version 1.0 into 1.1 ]]
function VersionHandler:UpdateData1To1Dot1(plrData:CT.PlayerDataModel, newDataModel :CT.PlayerDataModel, profileSlotData:CT.ProfileSlotDataType)

	--print("plr new model:", plrData, newDataModel)

	newDataModel.LoginData = plrData.LoginData
	
	if(plrData.Profile and plrData.Profile.Official) then
		newDataModel.PersonalProfile = {
			UserId = plrData.Profile.Official.UserID,
			AvatarURL = plrData.Profile.Personal.AvatarURL,
			DisplayName = plrData.Profile.Personal.DisplayName,
		}
	else
		newDataModel.PersonalProfile = {
			UserId = 0,
			AvatarURL = "",
			DisplayName = "",
		}
	end
	
	if(plrData.Inventory) then
		newDataModel.OwnedInventory = plrData.Inventory
	end

	newDataModel.GamePurchases = plrData.GamePurchases

	newDataModel.CoupansData = plrData.CoupansData

	newDataModel.ActiveProfile = (typeof(plrData.ActiveProfile) == "string") and plrData.ActiveProfile or plrData.ActiveProfile.SlotId
	
	newDataModel.AllProfiles = {}
	newDataModel.AllProfiles[newDataModel.ActiveProfile] = plrData.AllProfiles[newDataModel.ActiveProfile]

	--[[XP, level , etc]]
	if(plrData.Profile and plrData.Profile.Official) then
		newDataModel.AllProfiles[newDataModel.ActiveProfile].Gems = plrData.Profile.Official.Gems
		newDataModel.AllProfiles[newDataModel.ActiveProfile].Gold = plrData.Profile.Official.Gold
		newDataModel.AllProfiles[newDataModel.ActiveProfile].XP = plrData.Profile.Official.XP
		newDataModel.AllProfiles[newDataModel.ActiveProfile].PlayerLevel = plrData.Profile.Official.PlayerLevel
		newDataModel.AllProfiles[newDataModel.ActiveProfile].TotalXP = plrData.Profile.Official.TotalXP
	else
		newDataModel.AllProfiles[newDataModel.ActiveProfile].Gems = profileSlotData.Gems
		newDataModel.AllProfiles[newDataModel.ActiveProfile].Gold = profileSlotData.Gold
		newDataModel.AllProfiles[newDataModel.ActiveProfile].XP = profileSlotData.XP
		newDataModel.AllProfiles[newDataModel.ActiveProfile].PlayerLevel = profileSlotData.PlayerLevel
		newDataModel.AllProfiles[newDataModel.ActiveProfile].TotalXP = profileSlotData.TotalXP
	end
	
	-- "Data" in profile slot
	if(not newDataModel.AllProfiles[newDataModel.ActiveProfile].Data) then
		newDataModel.AllProfiles[newDataModel.ActiveProfile].Data = profileSlotData.Data
	end
	newDataModel.AllProfiles[newDataModel.ActiveProfile].Data.Quests = {
		LevelQuestData = {},
		DailyQuestData = {},
		NPCQuestData = {},
		TutorialQuestData = {},
	}
	
	--Default Profile
	newDataModel.AllProfiles[CD.DefaultSlotId] = profileSlotData
	newDataModel.AllProfiles[CD.DefaultSlotId].SlotId = CD.DefaultSlotId
	

	--[[glider]]
	if(newDataModel.OwnedInventory.Transports[CD.GameInventory.Transports.Glider.Id]) then
		newDataModel.OwnedInventory.Transports[CD.GameInventory.Transports.Glider.Id] = nil
		newDataModel.AllProfiles[newDataModel.ActiveProfile].Data.EquippedInventory.Transports[CD.GameInventory.Transports.Glider.Id] = true
	end
	--[[appa]]
	if(newDataModel.OwnedInventory.Transports[CD.GameInventory.Transports.Appa.Id]) then
		newDataModel.OwnedInventory.Transports[CD.GameInventory.Transports.Appa.Id] = nil
		newDataModel.AllProfiles[newDataModel.ActiveProfile].Data.EquippedInventory.Transports[CD.GameInventory.Transports.Appa.Id] = true
	end
	--[[abilities]]
	if(newDataModel.OwnedInventory.Abilities) then
		newDataModel.AllProfiles[newDataModel.ActiveProfile].Data.EquippedInventory.Abilities = newDataModel.OwnedInventory.Abilities
		newDataModel.OwnedInventory.Abilities = {}
	end
	--[[maps]]
	if(newDataModel.OwnedInventory.Abilities) then
		newDataModel.AllProfiles[newDataModel.ActiveProfile].Data.EquippedInventory.Abilities = newDataModel.OwnedInventory.Abilities
		newDataModel.OwnedInventory.Abilities = {}
	end


	warn("New updated version of player data:", newDataModel)

	plrData = newDataModel

	return plrData
end



return VersionHandler