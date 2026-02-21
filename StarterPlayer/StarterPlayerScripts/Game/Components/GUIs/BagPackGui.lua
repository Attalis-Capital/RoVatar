-- @ScriptType: ModuleScript
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")

local Packages = RS.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local CustomModules = RS.Modules.Custom
local CT = require(CustomModules.CustomTypes)
local CF = require(CustomModules.CommonFunctions)
local Constants = require(CustomModules.Constants)
local SFX = require(CustomModules.SFXHandler)

local player = game.Players.LocalPlayer

local BagPackGui = Component.new({Tag = "BagPackGui", Ancestors = {player}})

type UI = {
	Gui : ScreenGui,
	BaseFrame :TextButton,
	
	Background :ImageButton,
	Template : Folder,
	SearchBar : ImageLabel & {
		CrossButton : ImageButton,
		TextBox : TextBox,
	},
	ElementsFrame : ScrollingFrame
}

local ui :UI = {}

------ Other scripts
local UIController
local TWController

local TransportService
------ Variables

local function onVehicleButtonClick(data : CT.ItemDataType)
	
	local CanFly1 = player.States.Meditate.Value == Constants.MeditateStates.Idle
	local CanFly2 = player.States.Move.Value ~= Constants.MoveStates.Running
	
	if not _G.Flying and _G.ActiveBending == "None" and CanFly1 and CanFly2 then
		--_G.Flying = data.VehicleType
		--print("jjjjjj")
		TransportService.SpawnVehicle:Fire(data.VehicleType)
		
		BagPackGui:Toggle(false)
	else
		warn(data.VehicleType, "Not Available!!");
	end
end

function Bind_OnChanges()

	local plrData:CT.PlayerDataModel = _G.PlayerData

	local function CleanUp(Parent)
		for _, child in pairs(Parent:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
	end

	local function _refreshTransports(plrData:CT.PlayerDataModel)
		-- Clean up
		CleanUp(ui.ElementsFrame)
		
		local function _spawn(newData)
			-- Respawning all elements (vehicles)
			for vehicleId, Bool in pairs(newData) do
				local data :CT.ItemDataType = Constants.GameInventory.Transports[vehicleId]
				if data then
					if not ui.ElementsFrame:FindFirstChild(Constants.GameInventory.Transports[vehicleId].Name) then
						local newButton = ui.Template.ItemButton:Clone()

						TWController:SubsHover(newButton.Button, .1, .1)
						TWController:SubsClick(newButton.Button)

						newButton.Name = Constants.GameInventory.Transports[vehicleId].Name
						newButton.Parent = ui.ElementsFrame
						newButton.Visible = true
						newButton.Button.Icon.Image = data.Image
						newButton.Button.Activated:Connect(function()
							onVehicleButtonClick(data)
						end)
					end
				else
					warn('Transport Vehicle Data Not found!!!')
				end
			end
		end
		--print("[plrData ]", plrData)
		_spawn(plrData.OwnedInventory.Transports)
		_spawn(CF.PlayerQuestData.GetPlayerActiveProfile(plrData).Data.EquippedInventory.Transports)
	end

	_G.PlayerDataStore:ListenSpecChange("OwnedInventory", function(newData , old, full) -- Transports Data
		--print(newData)
		if newData then
			_refreshTransports(full)
		end
	end)
	
	_G.PlayerDataStore:ListenSpecChange("AllProfiles", function(newData , old, full) -- Transports Data
		--print(newData)
		if newData then
			_refreshTransports(full)
		end
	end)
	
	-----------***** Binding Inventory
	_refreshTransports(plrData)
end

----------------------***************** Private Methods **********************----------------------
function CloseButton()
	BagPackGui:Toggle()
end

----------------------***************** Public Methods **********************----------------------
function BagPackGui:Start()
	--warn(self," Starting...")
	UIController = Knit.GetController("UIController")
	TWController = Knit.GetController("TweenController")
	TransportService = Knit.GetService("TransportService")
	self.active = UIController:SubsUI(Constants.UiScreenTags.BackPackGui, self)
	
	if(self.active) then
		self:InitReferences()
		self:InitButtons()
	end
	
	TWController:SubsTween(ui.BaseFrame, Constants.TweenDir.Bottom)
	TWController:SubsHover(ui.Background)
	
	self:Toggle(false)
	
	task.delay(2, Bind_OnChanges)
end

function BagPackGui:InitReferences()
	ui.Gui = self.Instance
	ui.BaseFrame = ui.Gui.BaseFrame
	
	ui.Background = ui.BaseFrame.Background
	ui.Template = ui.BaseFrame.Template
	
	ui.ElementsFrame = ui.Background.ElementsFrame
	ui.SearchBar = ui.Background.SearchBar
end

function BagPackGui:InitButtons()
	ui.Background.Activated:Connect(function()
		self:Toggle()
	end)
	ui.BaseFrame.Activated:Connect(function()
		SFX:Play(Constants.SFXs.Activate, true)
		self:Toggle(false)
	end)
end

function BagPackGui:Toggle(enable:boolean)
	if(enable ~= nil) then
		enable = (enable)
	else
		enable = (not ui.BaseFrame.Visible)
	end
	
	ui.BaseFrame.Visible = enable
end

return BagPackGui