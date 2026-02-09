-- @ScriptType: ModuleScript
local CollectionService = game:GetService("CollectionService") -- Get the CollectionService from the game
local Debris = game:GetService("Debris") -- Get the Debris service from the game
local RS = game:GetService("ReplicatedStorage") -- Get the ReplicatedStorage from the game
local RunS = game:GetService("RunService") -- Get the RunService from the game

local Packages = RS.Packages -- Get the Packages folder from ReplicatedStorage
local Knit = require(Packages.Knit) -- Require the Knit module from the Packages folder
local Component = require(Packages.Component) -- Require the Component module from the Packages folder

local CustomModules = RS.Modules.Custom -- Get the Custom folder from ReplicatedStorage
local CT = require(CustomModules.CustomTypes) -- Require the CustomTypes module from the Custom folder
local CF = require(CustomModules.CommonFunctions) -- Require the CommonFunctions module from the Custom folder
local Constants = require(CustomModules.Constants) -- Require the Constants module from the Custom folder
local SFXHandler = require(CustomModules.SFXHandler) -- Require the SFXHandler module from the Custom folder

local player = game.Players.LocalPlayer -- Get the local player

local DialogueGui = Component.new({Tag = "DialogueGui", Ancestors = {player}}) -- Create a new DialogueGui component

type UI = {
	Gui : ScreenGui,
	BaseFrame :TextButton,
	
	Container : CanvasGroup,

	DialogueFrame : {ContinueButton :TextButton, Narrator :TextLabel, Speech :TextLabel},
	OptionsFrame : {YesButton :TextButton, NoButton :TextButton},
	
	OptionBtnTemplate :TextButton,
}

local ui :UI = {} -- Define a UI table

-- Other scripts
local UIController -- Define UIController variable
local TWController

-- Configurations
local DefaultConfig = {
	AutoHideTimer = 10, -- in sec
	TypeSpeed = .025, -- speed of sentence completion
	AllowSkip = true, -- whether user can skip sentence animation
	Options = false, -- Yes/No options to user to continue the conversation
}

-- Variables

-- Helper function to create an option button
function CreateOption(self, parent: Instance, btnData: CT.DialogueButtonType)
	-- Set default configuration for the button
	local defaultConfi = {}
	defaultConfi.__index = defaultConfi
	defaultConfi.TxtColor = Color3.fromRGB(255, 255, 255)
	defaultConfi.BgColor = Color3.fromRGB(70, 70, 70)
	defaultConfi.LayoutOrder = 1

	-- Set the button data with the default configuration
	btnData = setmetatable(btnData, defaultConfi)

	-- Create a button based on the button data
	local btn = ui.OptionBtnTemplate:Clone()
	btn.Visible = true
	btn.Parent = parent
	btn.BackgroundColor3 = btnData.BgColor
	btn.Label.Text = btnData.Txt
	btn.Label.TextColor3 = btnData.TxtColor
	btn.LayoutOrder = btnData.LayoutOrder
	btn.Image = btnData.Image
	btn.Activated:Connect(function()
		-- Here we can toggle which should be called first.
		if(btnData.OnAction) then -- and self:Finish())
			btnData.OnAction()
		end
	end)
	
	TWController:SubsHover(btn)
	TWController:SubsClick(btn)
	
	return btn
end

-- Helper function to handle the continue button
function ContinueButton(self)
	ui.OptionsFrame.Visible = true
	if(not self._Data.AllowSkip) then
		return
	end

	if(self.SpeechThread) then
		task.cancel(self.SpeechThread)
	end

	if(ui.DialogueFrame.Speech.MaxVisibleGraphemes ~= -1) then
		ui.DialogueFrame.Speech.MaxVisibleGraphemes = -1
	else
		if(not self._Data.Options) then
			self:Finish()
		end
	end
end

-- Public methods for the DialogueGui component
function DialogueGui:Construct()
	
	UIController = Knit.GetController("UIController")
	TWController = Knit.GetController("TweenController")
	
	self.active = UIController:SubsUI(Constants.UiScreenTags.DialogueGui, self)
end

function DialogueGui:Start()
	-- Initialize the UIController and set the active status

	self.InProcess = false
	self.SpeechThread = nil
	self._Data = {}
	setmetatable(self._Data, DefaultConfig)

	if(self.active) then
		self:InitReferences()
		self:InitButtons()
	end
	
	BendingSelectionGui = UIController:GetGui(Constants.UiScreenTags.BendingSelectionGui, 2)
	
	TWController:SubsTween(ui.BaseFrame, Constants.TweenDir.Bottom, Constants.EasingStyle.Quad)
	TWController:SubsTween(ui.OptionsFrame, Constants.TweenDir.Bottom, Constants.EasingStyle.Quad)
	
	--self:Toggle(false)
	print(self," started:", self.active)
end

-- Initialize references for the UI elements
function DialogueGui:InitReferences()
	ui.Gui = self.Instance
	ui.BaseFrame = ui.Gui.BaseFrame

	ui.DialogueFrame = ui.BaseFrame.Container.DialogueFrame
	ui.OptionsFrame = ui.BaseFrame.Container.OptionsFrame

	ui.OptionBtnTemplate = ui.BaseFrame.Templates.OptionButton
end

-- Initialize buttons for the UI
function DialogueGui:InitButtons()
	ui.DialogueFrame.ContinueButton.Activated:Connect(function()
		ContinueButton(self)
	end)
	
	-- Click anywhere on the dialogue area to advance (not just the small continue button)
	-- This fixes the issue where clicking outside the continue button cancels dialogue
	ui.BaseFrame.Activated:Connect(function()
		if self.InProcess then
			ContinueButton(self)
		end
	end)
end

-- Show the dialogue based on the provided data
function DialogueGui:ShowDialogue(data : CT.DialogueDataType)
	if (self.InProcess and not data.ForceStart) then
		warn("[DialogueGui] is already processing dialogue!")
		return
	end

	self._Data = data
	self.InProcess = true
	
	if(self.SpeechThread) and data.ForceStart then
		task.cancel(self.SpeechThread)
	end
	
	self:Toggle(true)

	self:UpdateTxts(self._Data)
	self:UpdateOptions()
end

-- Skip all remaining dialogue and close - used by tutorial skip button
function DialogueGui:SkipAll()
	if self.SpeechThread then
		local status = coroutine.status(self.SpeechThread)
		if status ~= "dead" then
			coroutine.close(self.SpeechThread)
		end
	end
	
	if self._Data and self._Data.OnSkip then
		self._Data.OnSkip()
	end
	
	self:Toggle(false)
	self.InProcess = false
end

-- Update the text elements in the dialogue
function DialogueGui:UpdateTxts(data: CT.DialogueDataType)
	self._Data = data

	ui.DialogueFrame.Narrator.Text = data.Narrator
	ui.DialogueFrame.Speech.Text = data.Message

	ui.DialogueFrame.ContinueButton.Active = data.AllowSkip

	self:AnimateSpeech(function()
		--print('COMPLETED!!!!')
		ui.DialogueFrame.ContinueButton.Active = true
		ui.OptionsFrame.Visible = true
		
		if(data.AutoHideTimer) then
			task.delay(data.AutoHideTimer, function()
				self:Toggle(false)
			end)
		end
	end)
end

-- Update the options for the dialogue
function DialogueGui:UpdateOptions()
	for i, child:Instance in pairs(ui.OptionsFrame:GetChildren()) do
		if(child:IsA("GuiButton")) then
			child:Destroy()
		end
	end
	
	if(self._Data.Options) then
		for i, op in pairs(self._Data.Options) do
			CreateOption(self, ui.OptionsFrame, op)
		end
		--ui.OptionsFrame.Visible = true
	else
		--ui.OptionsFrame.Visible = false
	end
	ui.OptionsFrame.Visible = false
end

-- Animate the speech in the dialogue
function DialogueGui:AnimateSpeech(onComplete: () -> ())
	self.SpeechThread = task.spawn(function()
		ui.DialogueFrame.Speech.MaxVisibleGraphemes = 0
		for i = 0, (ui.DialogueFrame.Speech.Text:len()), 1 do
			ui.DialogueFrame.Speech.MaxVisibleGraphemes += 1

			SFXHandler:Play(Constants.SFXs.Printing, true)
			task.wait(self._Data.TypeSpeed or .025)
		end

		if(onComplete) then
			onComplete()
		end
	end)
end

-- Finish the dialogue
function DialogueGui:Finish(forceClose : boolean)
	local valid = true

	local status = coroutine.status(self.SpeechThread)
	--print("speed status:", status)
	if(status ~= "dead") then
		valid = false
		
		coroutine.close(self.SpeechThread)
	end

	if(valid or forceClose) then
		if(self._Data.OnComplete) then
			self._Data.OnComplete()
		end
		self:Toggle(false)

		self.InProcess = false
	end

	return valid
end

------ Welcome Message 
-- Testing
function DialogueGui:Welcome()
	local plrData :CT.PlayerDataModel = _G.PlayerData
	
	local activeProfileData = plrData.AllProfiles[plrData.ActiveProfile]
	
	local mapName = Constants.GameInventory.Maps[activeProfileData.LastVisitedMap].Name
	local d :CT.DialogueDataType = {}
	
	d.Message = "Hello ".. activeProfileData.SlotName .."! Welcome to "..mapName.."... \n"
	
	d.Narrator = "John"
	d.TypeSpeed = .025
	d.AllowSkip = true
	d.OnComplete = function()
		warn("On dialogue completed!!")
	end

	local bb :CT.DialogueButtonType = {}
	bb.Txt = "Okay"
	bb.TxtColor = Color3.fromRGB(255, 255, 255)
	bb.Image = "rbxassetid://17575066019"
	bb.OnAction = function()
		--print("on Yes button Click...")
		
		self:Finish()
		
		BendingSelectionGui:RefreshOnLevelChanged()
		
	end

	d.Options = {bb}
	self:ShowDialogue(d)
	
end

-- Toggle the visibility of the dialogue
function DialogueGui:Toggle(enable:boolean)
	if enable then
		enable = (enable)
	else
		enable = (not ui.BaseFrame.Visible)
	end
	if enable then
		UIController:ToggleScreen(Constants.UiScreenTags.PlayerMenuGui, false)
		UIController:ToggleScreen(Constants.UiScreenTags.MainMenuGui, false)
	else
		UIController:ToggleScreen(Constants.UiScreenTags.PlayerMenuGui, true)
		UIController:ToggleScreen(Constants.UiScreenTags.MainMenuGui, true)
	end
	
	if ui.BaseFrame.Visible ~= enable then
		ui.BaseFrame.Visible = enable	
	end
	
end

return DialogueGui