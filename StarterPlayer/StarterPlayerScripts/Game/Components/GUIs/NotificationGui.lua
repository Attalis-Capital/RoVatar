-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local Knit = require(RS.Packages.Knit)
local Component = require(RS.Packages.Component)

local CT = require(RS.Modules.Custom.CustomTypes)
local CD = require(RS.Modules.Custom.Constants)

local player = game.Players.LocalPlayer
local NotificationGui = Component.new({Tag = "NotificationGui", Ancestors = {player}})

-------CONSTANTS
local AUTOHIDETIME = 10
local MAX_NOTIFICATIONS = 3
local ActiveNotifications = {} -- stores non-popup notification frames

type PopupT = Frame & {
	Main :ImageButton & {
		Actions :{No:TextButton & {Label :TextLabel}, Yes:TextButton & {Label :TextLabel}},
		Title:TextLabel,
		Description:TextLabel,
	}
}

type ui = {
	Base:Frame & {
		Templates :Folder & {Popup: PopupT},
		Container :Frame,
	},
}

-->Variables
local UI :ui = {}

-------------->>>>>> Other Script Ref
local UIController
local NotificationService

----------------------------------------->>>>>>>>> Private Methods <<<<<<<<<<----------------------------------------


local Toggler = {
	Show = function(showFrame,startPos, FinalPos, Complete:()->())

		showFrame.Position = startPos
		showFrame.Visible = true

		local tweenInfo = TweenInfo.new(.4,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out,
			0,
			false,
			0)
		local Tween = TS:Create(showFrame, tweenInfo, { Position = FinalPos }) 
		Tween:Play()

		Tween.Completed:Connect(function()
			if Complete then
				Complete()
			end
			Tween:Destroy()
		end)
	end;

	Close = function(Frame,FinalPos, Complete:()->())

		local tweenInfo = TweenInfo.new(.2,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out,
			0,
			false,
			0)
		local Tween = TS:Create(Frame, tweenInfo, { Position = FinalPos })
		if Frame.Parent then
			Frame.Parent.Name = "Notification" -- doing this so that if another same notification comes in the 0.2 second interval window then it is not stopped
		end
		Tween:Play()

		Tween.Completed:Connect(function()
			Frame.Visible = false
			if Complete then
				Complete()
			end
			Tween:Destroy()
		end)
	end;

	ShowPopup = function(frame, startingSize, finalSize, Completed:()->())
		frame.Size = startingSize
		frame.Visible = true

		local tweenInfo = TweenInfo.new(.4,
			Enum.EasingStyle.Bounce,
			Enum.EasingDirection.Out,
			0,
			false,
			0)
		local Tween = TS:Create(frame, tweenInfo, { Size = finalSize }) 
		Tween:Play()

		Tween.Completed:Once(function()
			if Completed then
				Completed()
			end
			Tween:Destroy()
		end)
	end,

	ClosePopup = function(Frame, FinalSize, Complete:()->())
		
		Frame.Description.Text = ""
		
		local tweenInfo = TweenInfo.new(.5,
			Enum.EasingStyle.Bounce,
			Enum.EasingDirection.Out,
			0,
			false,
			0)
		local Tween = TS:Create(Frame, tweenInfo, { Size = FinalSize }) 
		Tween:Play()

		Tween.Completed:Connect(function()
			Frame.Visible = false
			Tween:Destroy()
		end)
	end;
}

function PruneOldNotifications(Popup :PopupT)
		
	table.insert(ActiveNotifications, Popup)

	if #ActiveNotifications > MAX_NOTIFICATIONS then
	
		local oldest = table.remove(ActiveNotifications, 1) -- removes and returns first item
		Toggler.Close(oldest, UDim2.new(2,0,0.5,0),function()
			oldest:Destroy() 
		end)
		
	end
end

function TogglePopup(Popup :PopupT, visible: BoolValue, _caller, _autoHideTime)
	local isPopup = Popup.Name == "Popup"
	local Main = Popup.Main

	if(visible) then

		if isPopup then
			local FinalSize = UDim2.new(0.4, 0,0.3, 0)
			local startSize = UDim2.new(0, 0, 0, 0)
			--print("[[notificationGui]]")
			Toggler.ShowPopup(Main, startSize, FinalSize,  function()
				
				if _autoHideTime then
					local thread = task.delay(_autoHideTime or AUTOHIDETIME, function()
						Toggler.ClosePopup(Main, startSize)

						if _caller then NotificationService.NoEvent:Fire(_caller) end

						task.wait(.7)
						Popup:Destroy()
					end)
				end
			end)
		else

			local FinalPos = UDim2.new(0, 0, 0.5, 0)
			local startPos = UDim2.new(2, 0, 0.5, 0)

			Toggler.Show(Main, startPos, FinalPos,  function()
				local thread = task.delay(_autoHideTime or AUTOHIDETIME, function()
					local FinalPos = startPos
					Toggler.Close(Main, FinalPos)

					if _caller then NotificationService.NoEvent:Fire(_caller) end

					task.wait(.7)
					Popup:Destroy()
				end)
			end)

		end
	else
		if isPopup then
			local FinalSize = UDim2.new(0, 0, 0, 0)
			Toggler.ClosePopup(Main, FinalSize)
			task.wait(.5)
			Popup:Destroy()
		else
			local FinalPos = UDim2.new(2, 0, 0.5, 0)
			Toggler.Close(Main, FinalPos)
			task.wait(.5)
			Popup:Destroy()
		end
	end
end

function OnYesButtonClicked(Popup, _caller)
	TogglePopup(Popup, false, _caller)

	if(typeof(_caller) == "function") then
		_caller()
	else
		NotificationService.OkYesEvent:Fire(_caller)
	end
end

function OnNoButtonClicked(Popup, _caller)
	TogglePopup(Popup, false, _caller)

	if(typeof(_caller) == "function") then
		_caller()
	else
		NotificationService.NoEvent:Fire(_caller)
	end
end

----------------------------------------->>>>>>>>> Public Methods <<<<<<<<<<----------------------------------------
--For server
function NotificationGui:ShowMessageFromServer(_popupData: CT.NotificationDataType, _caller)
	if(_popupData == nil) then
		return
	end

	local Popup = nil
	local isPopup = _popupData.Type and _popupData.Type == CD.NotificationType.Popup
	 
	if isPopup then
		Popup = UI.Base.Templates.Popup:Clone()
		Popup.Parent = UI.Base 
	else
		if UI.Base.Container:FindFirstChild(_popupData.Title) then
			return
		end
		Popup = UI.Base.Templates.Notification:Clone()
		Popup.Name = _popupData.Title
		Popup.Parent = UI.Base.Container
		
		-- prune before adding the 4th notification
		PruneOldNotifications(Popup, UI.Base.Container)
		
	end
	
	Popup.Visible = true
	Popup.Main.Description.Text = _popupData.Description
	Popup.Main.Title.Text = _popupData.Title

	Popup.Main.Title.Visible = _popupData.Title and true or false
	Popup.Main.Description.Visible = _popupData.Description and true or false

	Popup.Main.Actions.Yes.Label.Text = _popupData.yesBtnText or "Yes"
	Popup.Main.Actions.Yes.LabelShadow.Text = _popupData.yesBtnText or "Yes"
	Popup.Main.Actions.No.Label.Text = _popupData.noBtnText or "No"
	Popup.Main.Actions.No.LabelShadow.Text = _popupData.noBtnText or "No"

	Popup.Main.Actions.Visible =  (_popupData.yesBtnText or _popupData.noBtnText) and true or false
		
	if Popup then
		

	TogglePopup(Popup, true, _caller, _popupData.AutoHideTime)
	Popup.Main.Actions.Yes.Activated:Connect(function()
		OnYesButtonClicked(Popup, _caller)
	end)

	Popup.Main.Actions.No.Activated:Connect(function()
		OnNoButtonClicked(Popup, _caller)
	end)
	end
end

--For client-side
function NotificationGui:ShowMessage(_popupData: CT.NotificationDataType, yesCallback, noCallback)
	if(_popupData == nil) then
		return
	end

	local Popup = nil
	local isPopup = _popupData.Type and _popupData.Type == CD.NotificationType.Popup
	if isPopup then
		Popup = UI.Base.Templates.Popup:Clone()
		Popup.Parent = UI.Base 
	else
		if UI.Base.Container:FindFirstChild(_popupData.Title) then
			return
		end
		Popup = UI.Base.Templates.Notification:Clone()
		Popup.Name = _popupData.Title
		Popup.Parent = UI.Base.Container
		
		PruneOldNotifications(Popup, UI.Base.Container)
	end

	Popup.Visible = true
	Popup.Main.Description.Text = _popupData.Description or ""
	Popup.Main.Title.Text = _popupData.Title or ""

	Popup.Main.Title.Visible = _popupData.Title and true or false
	Popup.Main.Description.Visible = _popupData.Description and true or false

	Popup.Main.Actions.Yes.Label.Text = _popupData.yesBtnText or "Yes"
	Popup.Main.Actions.Yes.LabelShadow.Text = _popupData.yesBtnText or "Yes"
	Popup.Main.Actions.No.Label.Text = _popupData.noBtnText or "No"
	Popup.Main.Actions.No.LabelShadow.Text = _popupData.noBtnText or "No"

	Popup.Main.Actions.Visible =  (yesCallback or noCallback) and true or false
	
	if Popup then
		
	TogglePopup(Popup, true, nil, _popupData.AutoHideTime)
	Popup.Main.Actions.Yes.Activated:Connect(function()
		OnYesButtonClicked(Popup, yesCallback)
	end)

	Popup.Main.Actions.No.Activated:Connect(function()
		OnNoButtonClicked(Popup, noCallback)
	end)

	end
	return Popup
end

function NotificationGui:Construct()
	UIController = Knit.GetController("UIController")
	NotificationService = Knit.GetService("NotificationService")

	self.active = UIController:SubsUI(CD.UiScreenTags.NotificationGui, self)
end

function NotificationGui:BindEvents()
	NotificationService.ShowMessageEvent:Connect(function(...) NotificationGui:ShowMessageFromServer(...) end)
end

function NotificationGui:InitRefrences()
	------------- Gui References -------------
	UI.Base = self.Instance.Base
	------------- Gui References -------------	
end

function NotificationGui:Start()
	if(not self.active) then
		warn(">>>Error in GUI Activation<<<", self)
		return
	end

	self:InitRefrences()
	self:BindEvents()
end


return NotificationGui