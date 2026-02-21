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


local player = game.Players.LocalPlayer

local LoadingGui = Component.new({Tag = "LoadingGui", Ancestors = {player}})

type UI = {
	Gui : ScreenGui,
	BaseFrame :TextButton, 
	
	LoadingFrame : Frame & {Logo :ImageLabel},
	ProcessingFrame : Frame & {Icon : ImageLabel},
	
	ContentFrame : Frame & {
		GameLoadFrame : Frame & {
			BackButton : ImageButton & {Text :TextLabel},
			NewGameButton : ImageButton & {Text :TextLabel},
			LoadGameButton : ImageButton & {Text :TextLabel},
		},
		PlayFrame : Frame & {
			PlayButton :ImageButton & {Text :TextLabel},
			CreditButton :ImageButton & {Text :TextLabel},
			UpdatesButton :ImageButton & {Text :TextLabel},
		}
	}
}
local ui :UI = {}


------ Other scripts
local UIController
local TWController
local PlayerController
local CameraController

------ Variables
local LoadSlotGui
------------- Helper ------------


----------------------***************** Private Methods **********************----------------------
----- GameLoadFrame
function BackButton()
	ui.ContentFrame.PlayFrame.Visible = true
	ui.ContentFrame.GameLoadFrame.Visible = false
end

function NewGameButton()
	--print("Start New Game!!")
	--Call loadslot to open createslot frame
	--LoadSlotGui:ShowCreateSlotScreen()
	--LoadSlotGui:Toggle(false)
end

function LoadGameButton()
	
	--print("Show Load Game!!")
	--LoadSlotGui:ShowLoadGames()
	LoadingGui:Toggle(false)
end

----- PlayFrame
function CreditButton()
	
	--print("Show Credits!!")
end

function PlayButton()
	--print("Play!!")
	ui.ContentFrame.PlayFrame.Visible = false
	
	if(_G.PlayerData.ActiveProfile) then
		ui.ContentFrame.GameLoadFrame.Visible = true
	else
		NewGameButton()
	end
	
end

function UpdatesButton()
	--print("Show New Updates!!")
	
end


----- Processing Frame
local function createAndPlayTween(target, tweenInfo, properties, onComplete)
	local tween = TS:Create(target, tweenInfo, properties)
	tween:Play()
	game.Debris:AddItem(tween, tweenInfo.Time + 0.1)

	if onComplete then
		tween.Completed:Connect(onComplete)
	end
end

----------------------***************** Public Methods **********************----------------------
function LoadingGui:Construct()
	UIController = Knit.GetController("UIController")
	TWController = Knit.GetController("TweenController")
	PlayerController = Knit.GetController("PlayerController")
	CameraController = Knit.GetController('CameraController')

	self.active = UIController:SubsUI(Constants.UiScreenTags.LoadingGui, self)
end

function LoadingGui:Start()
	--warn(self," Starting...")
	
	--LoadSlotGui = UIController:GetGui(Constants.UiScreenTags.LoadSlotGui, 2)
	
	if(self.active) then
		self:InitReferences()
		self:InitButtons()
	end

	--self:Toggle(true)
	--task.delay(1,function()
		
	--	repeat wait(1)
			
	--	until workspace:GetAttribute("GameLoaded") == true
		
	--	self:ShowPlayContent()
	--	CameraController:HandHeldView(true)
	--end)
	
	--print(self," started:", self.active)
end

function LoadingGui:InitReferences()
	ui.Gui = self.Instance
	ui.BaseFrame = ui.Gui.BaseFrame
	
	ui.LoadingFrame = ui.BaseFrame.LoadingFrame
	ui.ContentFrame = ui.BaseFrame.ContentFrame
	ui.ProcessingFrame = ui.BaseFrame.ProcessingFrame
end

function LoadingGui:InitButtons()
	--Load Game
	ui.ContentFrame.GameLoadFrame.BackButton.Activated:Connect(BackButton)
	ui.ContentFrame.GameLoadFrame.NewGameButton.Activated:Connect(NewGameButton)
	ui.ContentFrame.GameLoadFrame.LoadGameButton.Activated:Connect(LoadGameButton)
	
	TWController:SubsHover(ui.ContentFrame.GameLoadFrame.BackButton)
	TWController:SubsHover(ui.ContentFrame.GameLoadFrame.NewGameButton)
	TWController:SubsHover(ui.ContentFrame.GameLoadFrame.LoadGameButton)
	
	TWController:SubsClick(ui.ContentFrame.GameLoadFrame.BackButton)
	TWController:SubsClick(ui.ContentFrame.GameLoadFrame.NewGameButton)
	TWController:SubsClick(ui.ContentFrame.GameLoadFrame.LoadGameButton)
	
	--Play Frame
	ui.ContentFrame.PlayFrame.CreditButton.Activated:Connect(CreditButton)
	ui.ContentFrame.PlayFrame.PlayButton.Activated:Connect(PlayButton)
	ui.ContentFrame.PlayFrame.UpdatesButton.Activated:Connect(UpdatesButton)
	
	TWController:SubsHover(ui.ContentFrame.PlayFrame.PlayButton, .05, .01)
	TWController:SubsHover(ui.ContentFrame.PlayFrame.CreditButton, .05, .01)
	TWController:SubsHover(ui.ContentFrame.PlayFrame.UpdatesButton, .05, .01)
	
	TWController:SubsClick(ui.ContentFrame.PlayFrame.PlayButton)
	TWController:SubsClick(ui.ContentFrame.PlayFrame.CreditButton)
	TWController:SubsClick(ui.ContentFrame.PlayFrame.UpdatesButton)
	
	TWController:SubsTween(ui.ContentFrame.PlayFrame, Constants.TweenDir.Left, Constants.EasingStyle.Quad, ui.ContentFrame.PlayFrame.Size)
	TWController:SubsTween(ui.ContentFrame.GameLoadFrame, Constants.TweenDir.Up, Constants.EasingStyle.Quad, ui.ContentFrame.GameLoadFrame.Size)
end


function LoadingGui:Toggle(enable:boolean)
	if(enable ~= nil) then
		enable = (enable)
	else
		enable = (not ui.BaseFrame.Visible)
	end
	
	ui.BaseFrame.Visible = enable
	--ui.LoadingFrame.Visible = enable
	ui.ContentFrame.Visible = (enable)
end

function LoadingGui:ToggleProcessing(enable:boolean)
	if(enable) then
		
		ui.ProcessingFrame.Transparency = 1
		ui.ProcessingFrame.Visible = true
		createAndPlayTween(ui.ProcessingFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0})

		ui.ProcessingFrame.Icon.Visible = true
		local startPosX = math.random(80, 120) / 100
		local startPosY = math.random(10, 100) / 100
		ui.ProcessingFrame.Icon.Position = UDim2.new(startPosX, 0, startPosY, 0)

		local startSize = math.random(10, 60) / 100
		ui.ProcessingFrame.Icon.Size = UDim2.new(startSize, 0, startSize, 0)
		ui.ProcessingFrame.Icon.ImageTransparency = 1

		createAndPlayTween(ui.ProcessingFrame.Icon, TweenInfo.new(1.2), {
			Position = UDim2.new(.5, 0, .5, 0),
			Size = UDim2.new(1, 0, 1, 0),
			ImageTransparency = 0
		})
	else

		createAndPlayTween(ui.ProcessingFrame, TweenInfo.new(0.2), {
			BackgroundTransparency = 1
		}, function()
			ui.ProcessingFrame.Visible = false
		end)
	end
end

function LoadingGui:ShowLoadContent()
	ui.ContentFrame.Visible = true
	ui.ContentFrame.GameLoadFrame.Visible = true
end

function LoadingGui:ShowPlayContent()
	--ui.LoadingFrame.Visible = false
	--ui.ContentFrame.Visible = true
	
	ui.ContentFrame.PlayFrame.Visible = true
	ui.ContentFrame.GameLoadFrame.Visible = false
end

return LoadingGui