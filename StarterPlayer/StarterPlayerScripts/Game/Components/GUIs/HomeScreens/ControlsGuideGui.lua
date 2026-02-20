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


local ControlsGuideGui = Component.new({Tag = "ControlsGuideGui", Ancestors = {player}})

type UI = { 
	Gui : ScreenGui,
	BaseFrame :TextButton, 
	Background : ImageLabel,
	
	CloseButton : ImageButton,
	
	ElementsContainer : ScrollingFrame,
	
}
local ui :UI = {}


------ Other scripts
local UIController
local TWController

------ Variables


----------------------***************** Private Methods **********************----------------------


function CloseButton()
	ControlsGuideGui:Toggle(false)
end

----------------------***************** Public Methods **********************----------------------
function ControlsGuideGui:Construct()
	UIController = Knit.GetController("UIController")
	TWController = Knit.GetController("TweenController")
	
	self.active = UIController:SubsUI(Constants.UiScreenTags.ControlsGuideGui, self)
	
end

function ControlsGuideGui:Start()
	warn(self," Starting...")

	if(not self.active) then
		return
	end

	self:InitReferences()
	self:BindEvents()
	self:ShowOnFirstSpawn()

	print(self," started:", self.active)
end

function ControlsGuideGui:ShowOnFirstSpawn()
	-- Show controls guide automatically for first-time players
	if player:GetAttribute("HasSeenControls") then
		return
	end

	task.delay(2, function()
		-- Re-check in case attribute was set during the delay
		if player:GetAttribute("HasSeenControls") then
			return
		end

		-- Check persisted data — returning players with the flag set skip the guide
		local myData :CT.PlayerDataModel = _G.PlayerData
		if myData then
			local activeProfile = CF.PlayerQuestData.GetPlayerActiveProfile(myData)
			if activeProfile and activeProfile.Data.Settings
				and activeProfile.Data.Settings.HasSeenControls then
				player:SetAttribute("HasSeenControls", true)
				return
			end
		end

		-- Show the guide
		self:Toggle(true)
		player:SetAttribute("HasSeenControls", true)

		-- Persist to player data so it survives sessions
		if myData then
			local activeProfile = CF.PlayerQuestData.GetPlayerActiveProfile(myData)
			if activeProfile and activeProfile.Data.Settings then
				activeProfile.Data.Settings.HasSeenControls = true
				_G.PlayerDataStore:UpdateData(myData)
			end
		end
	end)
end

function ControlsGuideGui:InitReferences()
	ui.Gui = self.Instance
	ui.BaseFrame = ui.Gui.BaseFrame
	
	ui.Background = ui.BaseFrame.Background
	
	--Close Btn
	ui.CloseButton = ui.Background.CloseButton
	
	ui.ElementsContainer = ui.Background.ElementsFrame
	
	--Controls
	
end

function ControlsGuideGui:BindEvents()

	-- Buttons
	ui.CloseButton.Activated:Connect(function()
		CloseButton()
	end)
	-- Buttons
	
	
	--UI Effects
	TWController:SubsTween(ui.BaseFrame, Constants.TweenDir.Up)

	TWController:SubsHover(ui.CloseButton)

	TWController:SubsClick(ui.CloseButton)
	--UI Effects

end

function ControlsGuideGui:IsVisible()
	return ui.BaseFrame.Visible
end

function ControlsGuideGui:Toggle(enable:boolean)
	if(enable ~= nil) then
		enable = (enable)
	else
		enable = (not ui.BaseFrame.Visible)
	end
	ui.BaseFrame.Visible = enable
	
end

return ControlsGuideGui