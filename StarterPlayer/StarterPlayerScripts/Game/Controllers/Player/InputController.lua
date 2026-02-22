-- @ScriptType: ModuleScript
local TS = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")

local Player = game.Players.LocalPlayer

local Packages = RS:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

--* CustomScripts
local CT = require(RS.Modules.Custom.CustomTypes)

local Controls = require(Player.PlayerScripts.PlayerModule):GetControls()

-----* Ui stuff
local PlayerGui = Player:WaitForChild("PlayerGui")
local ControlsGui = PlayerGui:WaitForChild("ControlsGui")

local CntrlButtonsF = ControlsGui.BaseFrame
-------->>> Other scripts references

local InputController = Knit.CreateController({
	Name = "InputController",
})

Inputs = {
	--"KeyCode" = {"FunName" = function, "FunName" = function}
}

local tweenInfo = TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

------------------------------------------------------------->  Private Methods  <------------------------------------------------------

local function setButtonPosition(Button : ImageButton, funName, inputData : CT.InputDataType)
	local Parent : CanvasGroup = CntrlButtonsF:FindFirstChild(funName, true)
	if Parent then
		Button.Parent = Parent

		Button.Size = UDim2.new(0, 0, 0, 0)
		Button.Position = UDim2.new(.5, 0, .5, 0)
		Button.AnchorPoint = Vector2.new(0.5, 0.5)
		
		Button:TweenSize(UDim2.new(1, 0, 1, 0))
		
		--* Play Visible transparency effect
		Parent.GroupTransparency = 1
		local TweenC = TS:Create(Parent, tweenInfo, {GroupTransparency = 0})
		TweenC:Play()
		game.Debris:AddItem(TweenC, tweenInfo.Time + .1)
		
	else
		warn("[Controls] Button couldn't place ", funName, Button, inputData)
	end

end

local function setUpButton(Button :ImageButton, funName, inputData)

	if Button then
		Button.Position = inputData.UiData.Position or Button.Position
		Button.ScaleType = Enum.ScaleType.Fit
		
		Button.ActionIcon.ScaleType = Enum.ScaleType.Fit
		Button.ActionIcon.Image = inputData.UiData.Image or ""
		Button.ActionTitle.Text = inputData.UiData.Text or ""

		Button.ActionIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		Button.ActionIcon.Position = UDim2.new(.5, 0, .5, 0)
		Button.ActionIcon.Size = UDim2.new(.5, 0, .5, 0)

		setButtonPosition(Button, funName, inputData.UiData)
	end
	
end

function BindMultipleInputsAction(inputData: CustomTypes.InputDataType, funName:string, funToBind:() -> ())

	for i, keyCode in pairs(inputData.KeyCodes) do
		Inputs[keyCode][funName] = funToBind
	end

	CAS:BindAction(funName, funToBind, inputData.UiData ~= nil, table.unpack(inputData.KeyCodes))
	if inputData.UiData then

		local Button : ImageButton = CAS:GetButton(funName)
		setUpButton(Button, funName, inputData)

	end
end

function BindAction(inputData: CustomTypes.InputDataType, funName:string, funToBind:() -> ())
	--print(string.format("[BindAction]Binding action: %s with keyCode: %s",funName, tostring(keyCode)))
	Inputs[inputData.KeyCodes][funName] = funToBind

	CAS:BindAction(funName, funToBind, inputData.UiData ~= nil, inputData.KeyCodes)

	if inputData.UiData then
		local Button : ImageButton = CAS:GetButton(funName)
		setUpButton(Button, funName, inputData)
	end
end

function UnBindAction(funName:string)
	--print("UnBindAction: name:",funName)
	CAS:UnbindAction(funName)
end

function UnBindAllActionsToKeyCode(keyCode: Enum.KeyCode)
	if(Inputs[keyCode] == nil) then
		return
	end
	for name, action in pairs(Inputs[keyCode]) do
		UnBindAction(name)
	end

	Inputs[keyCode] = nil
	Inputs[keyCode] = {}
end

------------------------------------------------------------->  Public Methods  <------------------------------------------------------

function InputController:BindMultipleInputs(inputData: CustomTypes.InputDataType , funName:string, funToBind:() -> (), AddTogether:BoolValue)
	--print("[InputController]Received call to bind action with Multi keyCodes:", keyCodes," to funcName:",funName)

	local codes = unpack(inputData.KeyCodes)

	for i, keyCode in pairs(inputData.KeyCodes) do
		if(Inputs[keyCode] == nil) then
			Inputs[keyCode] = {}
		end

		if(Inputs[keyCode][funName]) then
			--warn("Function (",funName,") is already binded with keyCode:",keyCode)
		end
	end

	if(AddTogether) then
		BindMultipleInputsAction(inputData, funName, funToBind)
	else
		for i, keyCode in pairs(inputData.KeyCodes) do
			--print(string.format("Before removing previous binding to keyCode: %s. Pre-Bindings:",tostring(keyCode)),Inputs[keyCode])
			UnBindAllActionsToKeyCode(keyCode)
		end

		BindMultipleInputsAction(inputData, funName, funToBind)
	end
end

function InputController:BindInput(keyCode: Enum.KeyCode, funName:string, funToBind:() -> (), AddTogether:BoolValue)
	print(string.format("[InputController]Received call to bind action keyCode: %s  to funcName: %s",tostring(keyCode), funName))

	if(Inputs[keyCode] == nil) then
		Inputs[keyCode] = {}
	end

	if(Inputs[keyCode][funName]) then
		warn("This function is already binded with specified keyCode.")
		return
	end

	if(AddTogether) then
		BindAction(keyCode, funName, funToBind)
	else
		print(string.format("Before removing previous binding to keyCode: %s. Pre-Bindings:%s",tostring(keyCode), tostring(Inputs[keyCode])))
		UnBindAllActionsToKeyCode(keyCode)
		BindAction(keyCode, funName, funToBind)
	end
end

function InputController:UnBindInput(keyCode: Enum.KeyCode, funName:string)
	if(Inputs[keyCode] == nil) then
		--warn(string.format("Unable to UnBind the given action. Specified keyCode (%s) not event binded in Inputs.", tostring(keyCode)))
		return
	end
	if( Inputs[keyCode][funName] == nil) then
		--warn(string.format("[UnBindInput]FunctionName: %s was not binded with specified keyCode: %s", funName, tostring(keyCode)))
		return
	end
	Inputs[keyCode][funName] = nil
	UnBindAction(funName)
end

function InputController:UnBindAllActionsToKeyCodes(keyCodes:table)
	for i, key in pairs(keyCodes) do
		UnBindAllActionsToKeyCode(key)
	end
end

function InputController:KnitInit()
end

function InputController:KnitStart()
end

return InputController