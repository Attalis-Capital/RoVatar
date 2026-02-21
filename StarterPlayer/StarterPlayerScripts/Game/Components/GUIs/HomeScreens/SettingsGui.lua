-- @ScriptType: ModuleScript
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local RunS = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")


local Packages = RS.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local CustomModules = RS.Modules.Custom
local CT = require(CustomModules.CustomTypes)
local CF = require(CustomModules.CommonFunctions)
local Constants = require(CustomModules.Constants)


local player = game.Players.LocalPlayer

local SettingsGui = Component.new({Tag = "SettingsGui", Ancestors = {player}})

type UI = { 
	Gui : ScreenGui,
	BaseFrame :TextButton, 
	Background : ImageLabel,
	
	CloseButton : ImageButton,
	OpenControlGuideBtn :ImageButton,
	
	ElementsContainer : ScrollingFrame,
	
	PopupToggle :TextButton,
	SfxToggle :TextButton,
	MusicToggle :TextButton,
	VfxToggle :TextButton,
	ShadowToggle :TextButton,
	UIToggle : TextButton,
}
local ui :UI = {}


------ Other scripts
local UIController
local TWController

------ Variables
local OnTxt = "ON" local OffTxt = "OFF"
local OnColor = Color3.fromRGB(38, 255, 9) local OffColor = Color3.fromRGB(249, 57, 68)
local OnImage = "rbxassetid://17575066019" local OffImage = "rbxassetid://17575582976"

------------- Helper ------------

local function ToggleBtn(btn:TextButton, enable)
	if enable == nil then
		btn.Label.Text = btn.Label.Text == OnTxt and OffTxt or OnTxt
		btn.BackgroundColor3 = btn.Label.Text == OnTxt and OnColor or OffColor
		btn.Image = btn.Label.Text == OnTxt and OnImage or OffImage
	else
		btn.Label.Text = enable and OnTxt or OffTxt
		btn.BackgroundColor3 = enable and OffColor or OnColor
		btn.Image = enable and OnImage or OffImage
	end
end

local conn 
local function CharacterAdded()
	local newChar = player.Character or player.CharacterAdded:Wait()

	for _, child in pairs(newChar:WaitForChild("HumanoidRootPart"):GetChildren()) do
		if child:IsA("Sound") then
			child.SoundGroup = SoundService.SFXGroup
		end
	end
	
	if conn then conn:Disconnect() end
	conn = newChar.PrimaryPart.ChildAdded:Connect(function(child)
		if child:IsA("Sound") then
			child.SoundGroup = SoundService.SFXGroup
		end
	end)	
end

task.spawn(function() CharacterAdded() end)
player.CharacterAdded:Connect(CharacterAdded)

----------------------***************** Private Methods **********************----------------------
local SettingData :CT.SettingsDataType = {}
SettingData.SFX = true
SettingData.Music = true
SettingData.Shadow = false
SettingData.UI = true



function CloseButton()
	SettingsGui:Toggle()
end

function PopupToggle()
	ToggleBtn(ui.PopupToggle)
end

function SfxToggle(refresh:boolean)
	if not refresh then SettingData.SFX = not SettingData.SFX end
	
	if SettingData.SFX then
		SoundService.SFXGroup.Volume = .5
	else
		SoundService.SFXGroup.Volume = 0
	end
	--print('[Test Setting ] SFX2', SettingData.SFX, refresh)
	
	ToggleBtn(ui.SfxToggle, SettingData.SFX)
end

function ShadowToggle(refresh:boolean)
	if not refresh then
		SettingData.Shadow = not SettingData.Shadow
	end
	Lighting.GlobalShadows = SettingData.Shadow 

	ToggleBtn(ui.ShadowToggle, SettingData.Shadow)
end

function MusicToggle(refresh:boolean) 
	if not refresh then SettingData.Music = not SettingData.Music end
	
	if SettingData.Music then
		SoundService.MusicGroup.Volume = .5
	else
		SoundService.MusicGroup.Volume = 0
	end
	--print('[Test Setting ] Music2', SettingData.Music, refresh)
	ToggleBtn(ui.MusicToggle, SettingData.Music)
end

function VfxToggle()
	ToggleBtn(ui.VfxToggle)
end

function UIToggle(refresh:boolean)
	if not refresh then SettingData.UI = not SettingData.UI end
	
	if SettingData.UI then
		SoundService.UIGroup.Volume = .5
	else
		SoundService.UIGroup.Volume = 0
	end
	--print('[Test Setting ] UI2 ', SettingData.UI)
	
	ToggleBtn(ui.UIToggle, SettingData.UI)
end

local function _refresh(Data:CT.SettingsDataType)
	--print("Setting refresh:", Data, _G.PlayerData)
	SettingData = Data or CF.PlayerQuestData.GetPlayerActiveProfile(_G.PlayerData).Data.Settings

	SfxToggle(true)
	ShadowToggle(true)
	MusicToggle(true)
	UIToggle(true)
end

----------------------***************** Public Methods **********************----------------------
function SettingsGui:Construct()
	UIController = Knit.GetController("UIController")
	TWController = Knit.GetController("TweenController")
	
	self.active = UIController:SubsUI(Constants.UiScreenTags.SettingsGui, self)
	
end

function SettingsGui:Start()
	--warn(self," Starting...")
	
	if(self.active) then
		self:InitReferences()
		self:InitButtons()
	end
	
	TWController:SubsTween(ui.BaseFrame, Constants.TweenDir.Left)
	
	TWController:SubsHover(ui.Background)
	TWController:SubsHover(ui.CloseButton)
	
	TWController:SubsHover(ui.PopupToggle)
	TWController:SubsHover(ui.SfxToggle)
	TWController:SubsHover(ui.ShadowToggle)
	TWController:SubsHover(ui.MusicToggle)
	TWController:SubsHover(ui.VfxToggle)
	TWController:SubsHover(ui.UIToggle)
	
	TWController:SubsClick(ui.PopupToggle)
	TWController:SubsClick(ui.SfxToggle)
	TWController:SubsClick(ui.ShadowToggle)
	TWController:SubsClick(ui.MusicToggle)
	TWController:SubsClick(ui.VfxToggle)
	TWController:SubsClick(ui.UIToggle)
	
	TWController:SubsClick(ui.CloseButton)
	
	--self:Toggle(false)
	--print(self," started:", self.active)
	
	task.delay(2, function()
		_refresh()
	end)
	_G.PlayerDataStore:ListenSpecChange("AllProfiles", function(NewData, oldData, fullData:CT.PlayerDataModel)
		local activeProfile :CT.ProfileSlotDataType = CF.PlayerQuestData.GetPlayerActiveProfile(fullData)
		_refresh(activeProfile.Data.Settings)
	end)
	
end

function SettingsGui:InitReferences()
	ui.Gui = self.Instance
	ui.BaseFrame = ui.Gui.BaseFrame
	
	ui.Background = ui.BaseFrame.Background
	
	--Close Btn
	ui.CloseButton = ui.Background.CloseButton
	ui.OpenControlGuideBtn = ui.Background.ControlsGuide.Button
	
	ui.ElementsContainer = ui.Background.ElementsFrame
	
	--Buttons
	ui.PopupToggle = ui.ElementsContainer.PopUpFrame.ToggleButton
	ui.SfxToggle = ui.ElementsContainer.SfxFrame.ToggleButton
	ui.ShadowToggle = ui.ElementsContainer.ShadowFrame.ToggleButton
	ui.MusicToggle = ui.ElementsContainer.MusicFrame.ToggleButton
	ui.VfxToggle = ui.ElementsContainer.VfxFrame.ToggleButton
	ui.UIToggle = ui.ElementsContainer.UIFrame.ToggleButton
end

function SettingsGui:InitButtons()
	ui.CloseButton.Activated:Connect(function()
		CloseButton()
	end)
	
	ui.OpenControlGuideBtn.Activated:Connect(function()
		CloseButton()
		UIController:ToggleScreen(Constants.UiScreenTags.ControlsGuideGui, true)
	end)
	
	ui.PopupToggle.Activated:Connect(function()
		PopupToggle()
	end)
	
	ui.SfxToggle.Activated:Connect(function()
		SfxToggle()
	end)
	
	ui.ShadowToggle.Activated:Connect(function()
		ShadowToggle()
	end)
	
	ui.MusicToggle.Activated:Connect(function()
		MusicToggle()
	end)
	
	ui.UIToggle.Activated:Connect(function()
		UIToggle()
	end)
	
	ui.VfxToggle.Activated:Connect(function()
		VfxToggle()
	end)

end

function SettingsGui:IsVisible()
	return ui.BaseFrame.Visible
end

function SettingsGui:Toggle(enable:boolean)
	if(enable ~= nil) then
		enable = (enable)
	else
		enable = (not ui.BaseFrame.Visible)
	end
	ui.BaseFrame.Visible = enable
	
	if enable then
		_refresh()
	else
		local plrData : CT.PlayerDataModel = _G.PlayerData		
		plrData.AllProfiles[plrData.ActiveProfile].Data.Settings = SettingData

		_G.PlayerDataStore:UpdateData(plrData)
	end
end

return SettingsGui