-- @ScriptType: ModuleScript
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local RunS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Packages = RS.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local CustomModules = RS.Modules.Custom
local CT = require(CustomModules.CustomTypes)
local CF = require(CustomModules.CommonFunctions)
local Constants = require(CustomModules.Constants)

local player = game.Players.LocalPlayer

local MainMenuGui = Component.new({Tag = "MainMenuGui", Ancestors = {player}})

type UI = {
	Gui : ScreenGui,
	BaseFrame :TextButton, 
	
	LeftButtons :Frame,
	
	ToggleBtn :ImageButton,
	QuestsBtn :ImageButton,
	SettingsBtn :ImageButton,
	StoreButton :ImageButton,
	GamePassBtn :ImageButton,
	MapBtn :ImageButton,
	ProfileBtn :ImageButton
}
local ui :UI = {}


------ Other scripts
local UIController
local TWController

------ Variables



------------- Helper ------------
local includeList = {
	Constants.UiScreenTags.QuestGui,
	Constants.UiScreenTags.SettingsGui,
	Constants.UiScreenTags.GamePassGui,
	Constants.UiScreenTags.MapGui,
	Constants.UiScreenTags.ShopGui,
	Constants.UiScreenTags.ControlsGuideGui,
}

local function ToggleScreen(screen, bool)
	if bool then
		local openedUI = UIController:GetOpenedUI(includeList)
		if openedUI then
			--print("TOGGGLING ", openedUI, screen)
			UIController:ToggleScreen(openedUI, false)
		end
	end
	
	UIController:ToggleScreen(screen, bool)
end
------------- Helper ------------

----------------------***************** Private Methods **********************----------------------

function QuestsButton()
	ToggleScreen(Constants.UiScreenTags.QuestGui, true)
end

function SettingsButton()
	ToggleScreen(Constants.UiScreenTags.SettingsGui, true)
end

function StoreButton()
	ToggleScreen(Constants.UiScreenTags.StoreGui, true)
end

function GamePassButton()
	ToggleScreen(Constants.UiScreenTags.GamePassGui, true)
end

function MapButton()
	ToggleScreen(Constants.UiScreenTags.MapGui, true)
end

function ProfileButton()
	ToggleScreen(Constants.UiScreenTags.LoadSlotGui, true)
end

----------------------***************** Public Methods **********************----------------------
function MainMenuGui:Construct()
	UIController = Knit.GetController("UIController")
	TWController = Knit.GetController("TweenController")

	self.active = UIController:SubsUI(Constants.UiScreenTags.MainMenuGui, self)
end

function MainMenuGui:Start()
	--warn(self," Starting...")
	
	if(self.active) then
		self:InitReferences()
		self:InitButtons()
		self:InitTrigger()
	end
	
	TWController:SubsTween(ui.BaseFrame, Constants.TweenDir.Left, Constants.EasingStyle.Quad)
	
	TWController:SubsHover(ui.MapBtn, .02)
	TWController:SubsHover(ui.GamePassBtn, .02)
	TWController:SubsHover(ui.QuestsBtn, .02)
	TWController:SubsHover(ui.SettingsBtn, .02)
	TWController:SubsHover(ui.ToggleBtn, .02)

	TWController:SubsClick(ui.MapBtn)
	TWController:SubsClick(ui.GamePassBtn)
	TWController:SubsClick(ui.QuestsBtn)
	TWController:SubsClick(ui.SettingsBtn)
	TWController:SubsClick(ui.ToggleBtn)
	
	self:Toggle(false)
	--print("MainMenuGui started:", self.active)
end

function MainMenuGui:InitReferences()
	ui.Gui = self.Instance
	ui.BaseFrame = ui.Gui.BaseFrame

	ui.LeftButtons = ui.BaseFrame.LeftButtons

	ui.QuestsBtn = ui.LeftButtons.QuestsButton
	ui.SettingsBtn = ui.LeftButtons.SettingsButton
	ui.StoreButton = ui.LeftButtons.StoreButton
	ui.GamePassBtn = ui.LeftButtons.GamePassButton
	ui.MapBtn = ui.LeftButtons.MapButton
	ui.ProfileBtn = ui.LeftButtons.ProfileButton
	ui.ToggleBtn = ui.LeftButtons.ToggleButton

	-- Hide merged/unused buttons — Store merged into GamePasses, Profile deferred
	ui.StoreButton.Visible = false
	ui.ProfileBtn.Visible = false
end

function MainMenuGui:InitButtons()
	
	ui.QuestsBtn.Activated:Connect(function()
		QuestsButton()
	end)
	
	ui.SettingsBtn.Activated:Connect(function()
		SettingsButton()
	end)
	
	ui.StoreButton.Activated:Connect(function()
		StoreButton()
	end)

	ui.GamePassBtn.Activated:Connect(function()
		GamePassButton()
	end)
	
	ui.MapBtn.Activated:Connect(function()
		MapButton()
	end)
	
	ui.ProfileBtn.Activated:Connect(function()
		ProfileButton()
	end)
	
	ui.ToggleBtn.Activated:Connect(function()
		local buttons = {ui.SettingsBtn, ui.QuestsBtn, ui.MapBtn, ui.GamePassBtn}
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		if ui.ToggleBtn.Icon.Rotation == 180 then
			TweenService:Create(ui.ToggleBtn.Icon, tweenInfo, {Rotation = 0}):Play()
			for _, btn in ipairs(buttons) do
				btn.Visible = false
				task.wait(.015)
			end
		else
			TweenService:Create(ui.ToggleBtn.Icon, tweenInfo, {Rotation = 180}):Play()
			for i = #buttons, 1, -1 do
				buttons[i].Visible = true
				task.wait(.015)
			end
		end
	end)
	
	game.UserInputService.InputBegan:Connect(function(input :InputObject, gameProcessed)
		if gameProcessed then return end
		
		if ui.BaseFrame.Visible == false then
			return
		end
		
		if input.KeyCode == Enum.KeyCode.M then
			MapButton()
		end
	end)
	
end

function MainMenuGui:InitTrigger()
	local function bind(trigger, screen)
		trigger.Touched:Connect(function(hit)
			if hit.Name ~= "HumanoidRootPart" then return end
			local char = hit.Parent:FindFirstChild("Humanoid") and hit.Parent or nil 
			if char and char:HasTag(Constants.Tags.PlayerAvatar) then
				if char == player.Character then
					
					local openedUI = UIController:GetOpenedUI(includeList)
					if not openedUI or (openedUI ~= screen) then
						ToggleScreen(screen, true)
					end
				end
			end
		end)

		trigger.TouchEnded:Connect(function(hit)
			if hit.Name ~= "HumanoidRootPart" then return end
			local char = hit.Parent:FindFirstChild("Humanoid") and hit.Parent or nil 
			if char and char:HasTag(Constants.Tags.PlayerAvatar) then
				if char == player.Character then
					
					local openedUI = UIController:GetOpenedUI(includeList)
					if openedUI and (openedUI == screen) then
						ToggleScreen(screen, false)
					end
				end
			end
		end)
	end
	
	local shopTrigger = workspace.Scripted_Items.Shop:WaitForChild("Trigger")
	bind(shopTrigger, Constants.UiScreenTags.ShopGui)
	
	local storeTrigger = workspace.Scripted_Items.Store:WaitForChild("Trigger")
	bind(storeTrigger, Constants.UiScreenTags.GamePassGui)
end

function MainMenuGui:ToggleQuestMarker(enable)
	ui.QuestsBtn.Marker.Visible = enable
end

function MainMenuGui:Toggle(enable:boolean)
	if(enable ~= nil) then
		enable = (enable)
	else
		enable = (not ui.BaseFrame.Visible)
	end
	ui.BaseFrame.Visible = enable
end

return MainMenuGui