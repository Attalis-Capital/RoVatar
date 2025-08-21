-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local Packages = RS.Packages

local Knit = require(Packages.Knit)
local Component = require(Packages.Component)
----Related scripts
local Constants = require(RS.Modules.Custom.Constants)
local CustomTypes = require(RS.Modules.Custom.CustomTypes)
local CF = require(RS.Modules.Custom.CommonFunctions)
local NotificationData = require(RS.Modules.Custom.NotificationData)

----- Create Component class
local UpdateMap = Component.new({Tag = "UpdateMap", Ancestors = {workspace}})

-----Other Knit classes
--Services
--Controllers
local UiController
local QuestController
local NotificationGui
local PlayerController

-----* Variables
local Connections = {} -- {Key[MapName] > [Value][{TouchEvents,...}]}

local myPlayer = game.Players.LocalPlayer

-----** Workspace Objects
local ScriptedItems = workspace.Scripted_Items
local SI_Maps = ScriptedItems.Maps

---------------------->>>>>>>>>>>>>........... Common local functions

local function UpdateMapNames()
	for _, folder in pairs(SI_Maps:GetChildren()) do
		local mapName = Constants.Items[folder.Name].Name

		local namePlate = folder:FindFirstChild("NamePlate")
		if namePlate then
			local label = namePlate.BillboardGui.TextLabel
			label.Text = mapName
		end
	end
end

local function UpdateMapData(MapName:string, SpawnCF)
	if Constants.GameInventory.Maps[MapName] then
		-- Get Active Profile data
		local plrData: CustomTypes.PlayerDataModel = _G.PlayerData

		if plrData and plrData.ActiveProfile then

			local ActiveProfile = CF.PlayerQuestData.GetPlayerActiveProfile(plrData)
			local lastVistedMap = ActiveProfile.LastVisitedMap
			if lastVistedMap ~= MapName then
				local D = {
					LastVisitedMap = MapName,
					LastVisitedCF = CF.Transform.WrapObject(SpawnCF)
				}

				CF.PlayerData.UpdateActiveProfile(plrData, D)
				if not ActiveProfile.Data.EquippedInventory.Maps[lastVistedMap] then
					CF.PlayerData.UpdateInventory(plrData, Constants.GameInventory.Maps[lastVistedMap], true)
					NotificationGui:ShowMessage(NotificationData.NewIsland)
				end

				if not ActiveProfile.Data.EquippedInventory.Maps[MapName] then
					CF.PlayerData.UpdateInventory(plrData, Constants.GameInventory.Maps[MapName], true)
					NotificationGui:ShowMessage(NotificationData.NewIsland)
				else
					print("Already Explored Place by ", MapName)
				end

				_G.PlayerDataStore:UpdateData(plrData)

				QuestController.UpdateQuest:Fire(Constants.QuestObjectives.Visit, MapName)
				QuestController.UpdateQuest:Fire(Constants.QuestObjectives.Combined, MapName)
			end
		else
			warn("Player data not found to update Maps Data in active profile.")
		end
	else
		warn("Map name not found in Constants.", MapName)
	end
end

----------------------- Data Updations

local function Disconnect()
	for Key, Conns in pairs(Connections) do
		for _, Conn in pairs(Conns) do
			if Conn then
				Conn:Disconnect()
			end
		end
	end
	Connections = {}
end

local function BindEvents(ExceptMapName)
	if not _G.IsHub then
		return
	end

	if not ExceptMapName then
		return
	end

	--print("[Update Last Map Call], ", ExceptMapName)

	-- Disconnect All connections before binding new
	Disconnect()

	local function _bind(MapName)
		for _, trigger:Part in pairs(SI_Maps[MapName].Triggers:GetChildren()) do
			trigger.Transparency = 1
			local Conn = trigger.Touched:Connect(function(part)
				if part.Name == "HumanoidRootPart" then
					local Char = part.Parent
					local Player = game.Players:GetPlayerFromCharacter(Char)
					if Player and Player == myPlayer then
						UpdateMapData(MapName, SI_Maps[MapName].Spawn:FindFirstChild("Spawn").CFrame)
					end
				end
			end)

			if not Connections[MapName] then
				Connections[MapName] = {}
			end

			table.insert(Connections[MapName], Conn)
		end 
	end

	for _, MapData in pairs(Constants.GameInventory.Maps) do
		if MapData.Id ~= ExceptMapName then
			_bind(MapData.Id)
		end
	end

end

---------------- Component functions
--[[
This script handles character spawning Data -- -- when player changes their place via glider, boat or other vehicle. 
It will update the character active profile map data and last position. 
	]]
function UpdateMap:Start()
	local Maps = self.Instance

	QuestController = Knit.GetController("QuestController")
	UiController = Knit.GetController("UIController")
	NotificationGui = UiController:GetGui(Constants.UiScreenTags.NotificationGui, 2)

	task.delay(2, function()

		local plrDat: CustomTypes.PlayerDataModel = _G.PlayerData
		local LastMap = plrDat.ActiveProfile.LastVisitedMap

		--BindEvents(LastMap)

		local LastUpdated = workspace.ServerTime.Value --tick()

		_G.PlayerDataStore:ListenSpecChange("AllProfiles", function(new, old, full)

			local plrData: CustomTypes.PlayerDataModel = full
			local activeProfile :CustomTypes.ProfileSlotDataType = CF.PlayerQuestData.GetPlayerActiveProfile(plrData)

			if LastMap ~= activeProfile.LastVisitedMap then
				LastMap = activeProfile.LastVisitedMap
				task.delay(.5, function()
					BindEvents(LastMap)
				end)
			end
		end)

		UpdateMapNames()	
	end)

end

return UpdateMap