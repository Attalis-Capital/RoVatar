-- @ScriptType: ModuleScript
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local Knit = require(RS.Packages.Knit)

local CustomTypes = require(RS.Modules.Custom.CustomTypes)
local CommonFunctions = require(RS.Modules.Custom.CommonFunctions)


local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DevScreen
local MainFrame

local ResetPlayerInfoBtn :TextButton
local XpBtn :TextButton
local LiveDevModeBtn :TextButton
local ClientLogsBtn :TextButton
local ServerLogsBtn :TextButton

--Reset
local ResetFrame 
local playerIdTextBox
local myDataResetBtn :TextButton

--Xp Add
local XpFrame :Frame
local XpTextBox :TextBox
local AddXpBtn :TextButton
local AddXpBtn :TextButton

-- Execute
local RunScriptF

---------> Other scripts references
local DevService
_G.LiveDevMode = CommonFunctions.Value(false)


local DevController = Knit.CreateController {
	Name = "DevController",
}

local Permissions = {
	EditXP = "EditXP",
	LiveMode = "LiveMode",
	DataReset = "DataReset",

}

local Ranks = {
	Admin = {
		Permissions.EditXP,
		Permissions.LiveMode,
		Permissions.DataReset,
	},
	Tester = {
		Permissions.LiveMode,
		Permissions.DataReset,
	},

}

local Team = {
	[20408842] = Ranks.Admin, -- rkumar
	[7907420796] = Ranks.Admin, -- Akhsay
	[8601516755] = Ranks.Admin, --Neman_mora
	[7543437207] = Ranks.Admin, --ChicMic_Studios
	[3719953502] = Ranks.Admin, -- Dilpreet_Singh360
}


local myPermisions = Team[player.UserId]

function OnInputBegan(input, _gameProcessed)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if(input.KeyCode == Enum.KeyCode.F2) then
			MainFrame.Visible = not MainFrame.Visible

			ResetPlayerInfoBtn.Visible = false
			XpBtn.Visible = false
			LiveDevModeBtn.Visible = false

			if MainFrame.Visible then
				if myPermisions then

					if table.find(myPermisions, Permissions.DataReset) then
						ResetPlayerInfoBtn.Visible = true
					end

					if table.find(myPermisions, Permissions.EditXP) then
						XpBtn.Visible = true
					end

					if table.find(myPermisions, Permissions.LiveMode) then
						LiveDevModeBtn.Visible = true
					end

				end
			end
		end
	end
end

-------------------------------->>>>>>>>> Buttons callbacks <<<<<<<<<<-------------------------------

function ResetPlayerInfoClick()
	ResetFrame.Visible = not ResetFrame.Visible
end

function XpBtnClick()
	XpFrame.Visible = not XpFrame.Visible
end

function OnExecuteRequest()
	local Code = RunScriptF.CodeBox.Text
	if Code then
		DevService.ExecuteCode:Fire(Code)
	end
end

function OnFocusLost()
	--print("DevScript--> ResetPlayerInfo clicked:", tonumber(playerIdTextBox.Text))
	DevService:ResetPlayerInfoClick(tonumber(playerIdTextBox.Text))
end

function ResetMyData()
	--print("DevScript--> ResetPlayerInfo clicked:", player.Name)
	DevService:ResetPlayerInfoClick()
end

function AddXpInData()
	--print("DevScript--> XpBtn clicked:", XpTextBox.Text)
	if(tonumber(XpTextBox.Text)) then
		local d :CustomTypes.PlayerDataModel = _G.PlayerData
		
		CommonFunctions.PlayerData.UpdateXpInPlayerData(d, tonumber(XpTextBox.Text))
		
		_G.PlayerDataStore:UpdateData(d)
		
	end
end

local logsOn = false
function ToggleClientLogs()
	logsOn = not logsOn
	

	ClientLogsBtn.BackgroundColor3 = (logsOn) and Color3.fromRGB(0, 253, 0) or Color3.fromRGB(255, 43, 34)
end

function ToggleServerLogs()
	local on = DevService:ToggleServerLogs()
	
	ServerLogsBtn.BackgroundColor3 = (on) and Color3.fromRGB(0, 253, 0) or Color3.fromRGB(255, 43, 34)
end

function UpdateLiveDevMode()
	_G.LiveDevMode:Set(not _G.LiveDevMode:Get())
	LiveDevModeBtn.BackgroundColor3 = (_G.LiveDevMode:Get() == true) and Color3.fromRGB(0, 253, 0) or Color3.fromRGB(255, 43, 34)
	
	--Update Value on server too
	DevService.UpdateLiveDevMode:Fire(_G.LiveDevMode:Get())
	
	RunScriptF.Visible = _G.LiveDevMode:Get() == true
	RunScriptF.CodeBox.Text = ""
end




function DevController:initRef()

	DevScreen = playerGui:WaitForChild("DevScreen")
	MainFrame = DevScreen:FindFirstChild("BackGround")

	ResetPlayerInfoBtn = MainFrame.ResetPlayerDataBtn
	XpBtn = MainFrame.XpBtn
	LiveDevModeBtn = MainFrame.LiveDevMode
	ClientLogsBtn = MainFrame.ClientLogsBtn
	ServerLogsBtn = MainFrame.ServerLogsBtn

	--Reset
	ResetFrame = MainFrame.ResetFrame
	playerIdTextBox = ResetFrame.PlayerId
	myDataResetBtn = ResetFrame.MyButton

	--Xp Add
	XpFrame = MainFrame.XpFrame
	XpTextBox = XpFrame.XpBox
	AddXpBtn = XpFrame.AddButton
	AddXpBtn = XpFrame.AddButton

	-- Execute
	RunScriptF = MainFrame.RunScriptF
end

function DevController:KnitInit()

	DevService = Knit.GetService("DevService")

end

function DevController:KnitStart()
	
	if(not Team[player.UserId]) then
		return
	end
	
	--print("DevScript Knit Started......")
	
	self:initRef()
	--Update Value on server too
	DevService.UpdateLiveDevMode:Fire(_G.LiveDevMode:Get())
	
	UIS.InputBegan:Connect(OnInputBegan)
	
	ResetPlayerInfoBtn.Activated:Connect(ResetPlayerInfoClick)
	XpBtn.Activated:Connect(XpBtnClick)
	AddXpBtn.Activated:Connect(AddXpInData)
	playerIdTextBox.FocusLost:Connect(OnFocusLost)
	myDataResetBtn.Activated:Connect(ResetMyData)

	LiveDevModeBtn.Activated:Connect(UpdateLiveDevMode)
	ClientLogsBtn.Activated:Connect(ToggleClientLogs)
	ServerLogsBtn.Activated:Connect(ToggleServerLogs)
	--UpdateLiveDevMode()
	
	RunScriptF.Execute.Activated:Connect(OnExecuteRequest)
end

return DevController