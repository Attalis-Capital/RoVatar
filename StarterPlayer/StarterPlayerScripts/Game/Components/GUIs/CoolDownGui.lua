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

local CoolDownGui = Component.new({Tag = "CoolDownGui", Ancestors = {player}})


type UI = {
	Gui : ScreenGui,
	BaseFrame :Frame,
	
	Templates : Folder,
}

local ui :UI = {}

------ Other scripts
local UIController
local TWController

------ Variables

----------------------***************** Private Methods **********************----------------------
function CoolDownGui:StartCoolDown(timer, name)
	
	if ui.BaseFrame:FindFirstChild(name) then
		return
	end
	
	if timer <= 0 then
		return
	end
	
	local coolDown = ui.Templates.CoolDown:Clone()
	coolDown.Parent = ui.BaseFrame
	
	coolDown.Visible = true
	local bar = coolDown.InnerFrame.Bar
	local label = coolDown.InnerFrame.Label
	label.Text = name
	
	local tweenInfo = TweenInfo.new(
		timer,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0,
		false
	)
	
	local tween	= TS:Create(bar, tweenInfo, {Size = UDim2.new(0,0,1,0)})
	
	tween:Play()
	Debris:AddItem(tween,timer + 0.1) 
	
	task.delay(timer + 0.1, function()
		coolDown:Destroy()
	end)
	
end
----------------------***************** Public Methods **********************----------------------
function CoolDownGui:Construct()
	--warn(self," Starting...")
	UIController = Knit.GetController("UIController")
	TWController = Knit.GetController("TweenController")

	self.active = UIController:SubsUI(Constants.UiScreenTags.CoolDownGui, self)	
end

function CoolDownGui:Start()
	if(self.active) then
		self:InitReferences()
	end
	
	TWController:SubsTween(ui.BaseFrame, Constants.TweenDir.Up)
	TWController:SubsHover(ui.BaseFrame)
	
	self:Toggle(true)
	--print(self," started:", self.active)
end

function CoolDownGui:InitReferences()
	ui.Gui = self.Instance
	ui.BaseFrame = ui.Gui.BaseFrame
	
	ui.Templates = ui.BaseFrame.Templates
end

function CoolDownGui:Toggle(enable:boolean)
	if(enable ~= nil) then
		enable = (enable)
	else
		enable = (not ui.BaseFrame.Visible)
	end
	ui.BaseFrame.Visible = enable
end

return CoolDownGui