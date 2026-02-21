-- @ScriptType: ModuleScript
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local Packages = RS.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local CustomModules = RS.Modules.Custom
local CT = require(CustomModules.CustomTypes)
local CF = require(CustomModules.CommonFunctions)
local Constants = require(CustomModules.Constants)
local SFXHandler = require(CustomModules.SFXHandler)

local player = game.Players.LocalPlayer

local MapGui = Component.new({Tag = "MapGui", Ancestors = {player}})

type UI = {
	Gui : ScreenGui,
	BaseFrame :TextButton,
	
	Background :ImageLabel,
	CloseBtn :ImageButton,
	
	Map : ImageButton
}

local ui :UI = {}

------ Other scripts
local UIController
local TWController
local QuestController

------ Variables

------------- Helper ------------


----------------------***************** Private Methods **********************----------------------
function CloseButton()
	MapGui:Toggle()
end

local function MapButtonClick(MapId)
	--print("Map Button Click ", MapId)
	MapGui:Toggle()
	
	---- Teleport directly to that location
	local Character = player.Character
	if Character then
		local cf = workspace.Scripted_Items.Maps[MapId].Spawn.Spawn
		CF.Transform.PivotTo(player.Character, cf, true)
	end
end

local function Tween(sound, targetVolume, initialVolume, callback:()->())
	local tweenInfo = TweenInfo.new(.5)
	sound.Volume = initialVolume
	local tween = TS:Create(sound, tweenInfo, {Volume = targetVolume})
	tween:Play()
	tween.Completed:Wait()
	tween:Destroy()
	
	if callback then
		callback()
	end
end

----------------------***************** Public Methods **********************----------------------



function MapGui:Construct()
	UIController = Knit.GetController("UIController")
	TWController = Knit.GetController("TweenController")
	QuestController = Knit.GetController("QuestController")
	
	self.active = UIController:SubsUI(Constants.UiScreenTags.MapGui, self)
	
end

function MapGui:Start()
	--warn(self," Starting...")
	
	if(self.active) then
		self:InitReferences()
		self:InitButtons()
	end
	
	TWController:SubsTween(ui.BaseFrame, Constants.TweenDir.Left)
	
	TWController:SubsHover(ui.Background)
	TWController:SubsHover(ui.CloseBtn)
	TWController:SubsClick(ui.CloseBtn)
	
	self:Toggle(false)
	
	task.delay(2, function()
		self:BindEvents()
	end)
	
	--print(self," started:", self.active)
end

function MapGui:InitReferences()
	ui.Gui = self.Instance
	ui.BaseFrame = ui.Gui.BaseFrame
	
	ui.Background = ui.BaseFrame.Background
	
	ui.CloseBtn = ui.Background.CloseButton
	
	ui.Map = ui.Background.Map
end

function MapGui:InitButtons()
	----- Close Button
	ui.CloseBtn.Activated:Connect(function()
		CloseButton()
	end)
	
	----- All maps button bindings
	for _, Button in pairs(ui.Map:GetChildren()) do
		if Button:IsA("TextButton") then
			
			Button.Text = Constants.Items[Button.Name].Name
			
			Button.Activated:Connect(function()
				MapButtonClick(Button.Name)
			end)
			
			---- TWEEN BINDINGS
			TWController:SubsHover(Button)
			TWController:SubsClick(Button)
		end
	end
	
end

function MapGui:BindEvents()
	
	local EnvironmentSound = nil
	local lastActiveMapId = nil
	local function _refresh()
		local plrData :CT.PlayerDataModel = _G.PlayerData
		
		if not plrData or not plrData.ActiveProfile then
			return
		end
		
		local MapData = CF.PlayerQuestData.GetPlayerActiveProfile(plrData).Data.EquippedInventory.Maps
		local ActiveMapID = CF.PlayerQuestData.GetPlayerActiveProfile(plrData).LastVisitedMap
		
		for _, Button:TextButton in pairs(ui.Map:GetChildren()) do
			local ID = Button.Name
			
			if MapData and MapData[ID] then
				Button.Active = true
				Button.TextTransparency = 0
				Button.TextColor3 = Color3.fromRGB(247, 247, 247)
			else
				Button.Active = false
				Button.TextTransparency = .5
				Button.TextColor3 = Color3.fromRGB(206, 205, 207)
			end
			
			if ActiveMapID == ID then
				Button.TextTransparency = 0
				Button.TextColor3 = Color3.fromRGB(67, 249, 93)
				
				if not lastActiveMapId or lastActiveMapId ~= ID then
					lastActiveMapId = ID
					if EnvironmentSound then
						Tween(EnvironmentSound, 0, EnvironmentSound.Volume, function()
							
							EnvironmentSound:Destroy()
							EnvironmentSound = SFXHandler:Play(Constants.SFXs[ID], true)
							Tween(EnvironmentSound, 1, 0)
						end)
					else
						EnvironmentSound = SFXHandler:Play(Constants.SFXs[ID], true)
						Tween(EnvironmentSound, 1, 0)
					end
				end
			end
		end
		
	end
	
	_refresh()
	
	----- Update explored maps buttons
	_G.PlayerDataStore:ListenSpecChange("AllProfiles", function(newData)
		if newData then
			--print("[MAPGUI] New Data ", newData)
			_refresh()
		else
			warn("[ERROR] No MAP Data Found!!!!")
		end
	end)
end

function MapGui:IsVisible()
	return ui.BaseFrame.Visible
end

function MapGui:Toggle(enable:boolean)
	if(enable ~= nil) then
		enable = (enable)
	else
		enable = (not ui.BaseFrame.Visible)
	end
	ui.BaseFrame.Visible = enable
	
	if enable then
		QuestController.UpdateQuest:Fire(Constants.QuestObjectives.Combined, Constants.QuestTargetIds.OpenMap)
	end
	
end

return MapGui