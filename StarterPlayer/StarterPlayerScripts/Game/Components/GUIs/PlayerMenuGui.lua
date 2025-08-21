-- @ScriptType: ModuleScript
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local RunS = game:GetService("RunService")

local Packages = RS.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local CustomModules = RS.Modules.Custom
local CT = require(CustomModules.CustomTypes)
local Costs = require(RS.Modules.Custom.Costs)
local CF = require(CustomModules.CommonFunctions)
local Constants = require(CustomModules.Constants)
local SFXHandler = require(CustomModules.SFXHandler)
local NotificationData = require(CustomModules.NotificationData)
local TooltipModule = require(RS.Modules.Packages.TooltipModule)

local player = game.Players.LocalPlayer

local PlayerMenuGui = Component.new({Tag = "PlayerMenuGui", Ancestors = {player}})

-- # Blueprint of the exact ui in the "PlayerGui"
type AbilityButtonType = {
	Fillers : {
		Inner : InnerGradient & ImageLabel,
		Outer :	OuterGradient & ImageLabel,
	}, 
	Lock:ImageLabel,
	Logo:ImageLabel,
	Keybind:TextLabel,
}

type UI = {
	Gui : ScreenGui,
	BaseFrame :TextButton, 
	Selection : ImageLabel,
	
	ControlsGuideBtn :ImageButton,
	
	HotbarFrame : {
		--WealthFrame : {
		--	Gems : {ValueText : TextLabel},
		--	Coins : {ValueText : TextLabel},
		--},
		ButtonsFrame : {
			BagButton: AbilityButtonType & ImageButton,
			Boomerang : AbilityButtonType & ImageButton,
			AirBending: AbilityButtonType & ImageButton,
			FireBending : AbilityButtonType & ImageButton,
			EarthBending: AbilityButtonType & ImageButton,
			WaterBending: AbilityButtonType & ImageButton,
			MeteoriteSword : AbilityButtonType & ImageButton,
		}
	},
	
	StatsFrame : {
		ProfileFrame : {
			Stats : {
				HealthFrame : {Text :TextLabel, Bar :Frame},
				StaminaFrame : {Text :TextLabel, Bar :Frame},
				StrengthFrame : {Text :TextLabel, Bar :Frame},
			},
			LevelFrame : {
				LevelTxt :TextLabel,
			},
			ProfilePic : ImageLabel,
			--XP : TextLabel,
			Container : {
				WealthFrame : {
				Gems : {ValueText : TextLabel},
					Coins : {ValueText : TextLabel},
				},
				XP : TextLabel,
			},
		}
	} & Frame,
	
	HealthFrame : TextLabel,
	StaminaFrame : TextLabel,
	StrengthFrame : TextLabel,
}

local ui :UI = {}

------ Other scripts
local UIController
local TWController
local CharacterController
------ Variables

-----* Constans - [Image]
local ActiveImage = "rbxassetid://17576240700"
local NonActiveImage = "rbxassetid://17576251155"

------------- Helper ------------
local function ToggleScreen(screen)
	UIController:ToggleScreen(screen)
end

-- Filling Ability's Gradient
local function fillUp(uiGradient, percent)
	if percent <= .001 then
		percent = 0
	end
	
	if percent > 1 then
		percent = 1
	end
	
	if percent == 0 or percent == 1 then
		uiGradient.Transparency = NumberSequence.new(1-percent)
	else
		uiGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(percent-.001, 0),
			NumberSequenceKeypoint.new(percent, 1),
			NumberSequenceKeypoint.new(1, 1)
		})
	end
end

local function BagPackButton()
	local includeList = {
		Constants.UiScreenTags.QuestGui, 
		Constants.UiScreenTags.SettingsGui, 
		Constants.UiScreenTags.StoreGui,
		Constants.UiScreenTags.GamePassGui, 
		Constants.UiScreenTags.MapGui,
		Constants.UiScreenTags.ShopGui,
		Constants.UiScreenTags.ControlsGuideGui,
	}

	local openedUI = UIController:GetOpenedUI(includeList)
	if not openedUI then
		UIController:ToggleScreen(Constants.UiScreenTags.BackPackGui)
	end
end

function ProfileButton()
	-- Toggle All Opened UIs
	--ToggleScreen(Constants.UiScreenTags.LoadGameGui, true)
end

local function AirBending()
	if ui.HotbarFrame.ButtonsFrame.AirBending:GetAttribute("Active") then		
		CharacterController:AirBending()
	end
end

local function FireBending()
	if ui.HotbarFrame.ButtonsFrame.FireBending:GetAttribute("Active") then	
		CharacterController:FireBending()
	end
end

local function WaterBending()
	if ui.HotbarFrame.ButtonsFrame.WaterBending:GetAttribute("Active") then
		CharacterController:WaterBending()
	end
end

local function EarthBending()
	if ui.HotbarFrame.ButtonsFrame.EarthBending:GetAttribute("Active") then			
		CharacterController:EarthBending()
	end
end

local function MeteoriteSword()
	if ui.HotbarFrame.ButtonsFrame.MeteoriteSword:GetAttribute("Active") then		
		CharacterController:MeteoriteSword()
	else
		local data :CT.NotificationDataType = NotificationData.LockedAbility_Alert
		NotificationGui:ShowMessage(data)
	end
end

local function Boomerang()
	if ui.HotbarFrame.ButtonsFrame.Boomerang:GetAttribute("Active") then		
		CharacterController:Boomerang()
	else
		local data :CT.NotificationDataType = NotificationData.LockedAbility_Alert
		NotificationGui:ShowMessage(data)
	end
end

------------- Helper ------------

local function UpdateButton(Button :ImageButton, enable:boolean)
	
	if enable then
		Button:SetAttribute("Active", true)
		
		--Button.Active = true
		Button.ImageColor3 = Color3.fromRGB(255, 255, 255)
		
		Button.Lock.Visible = false
		Button.Keybind.Visible = true
		Button.Logo.ImageTransparency = 0
		
		Button.Fillers.Outer.Visible = false
	else
		Button:SetAttribute("Active", false)
		
		--Button.Active = false
		Button.ImageColor3 = Color3.fromRGB(0, 0, 0)
		
		Button.Lock.Visible = true
		Button.Keybind.Visible = false
		Button.Logo.ImageTransparency = .5
		
		Button.Fillers.Outer.Visible = false
	end
end

local function UpdateLevelBar(Button :ImageButton, Percent:number) --[0-1]
	local Gradient = Button:FindFirstChild("OuterGradient", true)
	if Gradient then
		fillUp(Gradient, Percent)
	end
end

local function UpdateCoolDownBar(Button :ImageButton, Percent:number) --[0-1])
	local Gradient = Button:FindFirstChild("InnerGradient", true)
	if Gradient then
		fillUp(Gradient, Percent)
	end
end

----------------------***************** Private Methods **********************----------------------

local function Update(stat:Frame, val:number, maxVal:number)
	if not val then
		stat.TextLabel.Text = "Issue"
	else
		stat.TextLabel.Text = math.ceil((val/maxVal) * 100).."%"
		local Size = UDim2.new(math.clamp(val/maxVal, 0, 1), 0, stat.Bar.Size.Y.Scale, 0)
		stat.Bar:TweenSize(Size, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, .2, true)
	end
end

function OnCharacterAdded(Character)
	--print("[Character Added]")
	Character:WaitForChild'Humanoid'.HealthChanged:Connect(function(Health)
		Update(ui.HealthFrame, Health, 100)
	end)
	Update(ui.HealthFrame, Character.Humanoid.Health, 100)
end

function BindValueChanged()
	-------------**** local functions
	local function _refreshLevel(NewLevel)
		
		ui.StatsFrame.ProfileFrame.LevelFrame.LevelTxt.Text = NewLevel

		---- Calculating completion percentage 
		local AirKickPER = NewLevel/Costs.AirKickLvl
		local EarthStompPER = NewLevel/Costs.EarthStompLvl
		local FireDropKickPER = NewLevel/Costs.FireDropKickLvl
		local WaterStancePER = NewLevel/Costs.WaterStanceLvl

		---- Update required Level to complete on UI
		UpdateLevelBar(ui.HotbarFrame.ButtonsFrame.AirBending, AirKickPER)
		UpdateLevelBar(ui.HotbarFrame.ButtonsFrame.EarthBending, EarthStompPER)
		UpdateLevelBar(ui.HotbarFrame.ButtonsFrame.FireBending, FireDropKickPER)
		UpdateLevelBar(ui.HotbarFrame.ButtonsFrame.WaterBending, WaterStancePER)
		
		------ Clear it later
		local CanBendAir = NewLevel >= Costs.AirKickLvl
		local CanBendEarth = NewLevel >= Costs.EarthStompLvl
		local CanBendFire = NewLevel >= Costs.FireDropKickLvl
		local CanBendWater = NewLevel >= Costs.WaterStanceLvl
		
		--UpdateButton(ui.HotbarFrame.ButtonsFrame.AirBending, CanBendAir)
		--UpdateButton(ui.HotbarFrame.ButtonsFrame.FireBending, CanBendFire)
		--UpdateButton(ui.HotbarFrame.ButtonsFrame.EarthBending, CanBendEarth)
		--UpdateButton(ui.HotbarFrame.ButtonsFrame.WaterBending, CanBendWater)
	end
	
	local function _refreshAbilities(newData :CT.AbilitiesType)
		UpdateButton(ui.HotbarFrame.ButtonsFrame.FireBending, 
			CF.PlayerQuestData.GetPlayerActiveProfile(newData).Data.EquippedInventory.Abilities[Constants.GameInventory.Abilities.FireBending.Id])
		UpdateButton(ui.HotbarFrame.ButtonsFrame.AirBending,
			CF.PlayerQuestData.GetPlayerActiveProfile(newData).Data.EquippedInventory.Abilities[Constants.GameInventory.Abilities.AirBending.Id])
		UpdateButton(ui.HotbarFrame.ButtonsFrame.EarthBending, 
			CF.PlayerQuestData.GetPlayerActiveProfile(newData).Data.EquippedInventory.Abilities[Constants.GameInventory.Abilities.EarthBending.Id])
		UpdateButton(ui.HotbarFrame.ButtonsFrame.WaterBending, 
				CF.PlayerQuestData.GetPlayerActiveProfile(newData).Data.EquippedInventory.Abilities[Constants.GameInventory.Abilities.WaterBending.Id])
	end
	
	local function _refreshWealth(newData:CT.ProfileSlotDataType)
		local Gold = newData.Gold
		local Gems = newData.Gems
		
		ui.StatsFrame.ProfileFrame.Container.WealthFrame.Coins.ValueText.Text = Gold or "-"
		ui.StatsFrame.ProfileFrame.Container.WealthFrame.Gems.ValueText.Text = Gems or "-"
		
		local plrLevel = newData.PlayerLevel
		local lvlData = Constants.GameLevelsData[plrLevel]
		local targetXp = lvlData.XpRequired
		
		--If next level is present then show targetXp ELSE don't show targetXp
		if(Constants.GameLevelsData[plrLevel + 1]) then
			ui.StatsFrame.ProfileFrame.Container.XP.Text = "XP : ".. newData.XP .."/" .. targetXp
		else
			ui.StatsFrame.ProfileFrame.Container.XP.Text = "XP : ".. newData.XP
		end
	end
	
	local function _refreshGamePasses(newData)
		local IsBoomerangActive = newData[Constants.IAPItems.Boomerang.Id]
		local IsSwordActive = newData[Constants.IAPItems.MeteoriteSword.Id]

		UpdateButton(ui.HotbarFrame.ButtonsFrame.Boomerang, IsBoomerangActive)
		UpdateButton(ui.HotbarFrame.ButtonsFrame.MeteoriteSword, IsSwordActive)
	end
	
	------ Init All Values
	local plrData : CT.PlayerDataModel = _G.PlayerData
	local activeProfile :CT.ProfileSlotDataType = CF.PlayerQuestData.GetPlayerActiveProfile(plrData)
	
	----ABILITIES
	--_refreshAbilities(activeProfile.Data.EquippedInventory.Abilities)
	
	----LEVEL
	local Level = activeProfile.PlayerLevel
	_refreshLevel(Level)
	
	----WEALTH
	_refreshWealth(activeProfile)
	
	----- *** Level Change Update On UI
	_G.PlayerDataStore:ListenSpecChange("AllProfiles", function(NewData, oldData, fullData:CT.PlayerDataModel)
		if NewData then
			local activeProfileData = CF.PlayerQuestData.GetPlayerActiveProfile(fullData)
			_refreshLevel(activeProfileData.PlayerLevel)
			_refreshAbilities(fullData)
			_refreshWealth(activeProfileData)
			
			if Level < activeProfileData.PlayerLevel then
				Level = activeProfileData.PlayerLevel
				SFXHandler:Play(Constants.SFXs.LevelUp, true)
			end
		end
	end)
	
	-----* On Game Passes change [Items]
	_refreshGamePasses(plrData.GamePurchases.Passes)
	_G.PlayerDataStore:ListenSpecChange("GamePurchases.Passes", function(newData)
		_refreshGamePasses(newData)
	end)
	
	---------*****  Binding Stamina  *****-----------
	local StrengthValue = player.CombatStats.Strength
	local StaminaValue = player.CombatStats.Stamina
	local StateValue = player.States.Move
	
	local TICK = tick()
	StaminaValue:GetPropertyChangedSignal("Value"):Connect(function()
		Update(ui.StaminaFrame, StaminaValue.Value, 100)
	
		if (tick() - TICK) >= 5 then
			TICK = tick()
			local plrData :CT.PlayerDataModel = _G.PlayerData
			local activeProfile :CT.ProfileSlotDataType = CF.PlayerQuestData.GetPlayerActiveProfile(plrData)

			activeProfile.Data.CombatStats.Stamina = StaminaValue.Value
			activeProfile.Data.CombatStats.Strength = StrengthValue.Value
			
			plrData.AllProfiles[plrData.ActiveProfile] = activeProfile
			_G.PlayerDataStore:UpdateData(plrData)
		end
	end)
	
	---------*****  Binding Strength  *****-----------
	local TICK2 = tick()
	local LastStrength = StaminaValue.Value
	StrengthValue:GetPropertyChangedSignal("Value"):Connect(function()
		
		Update(ui.StrengthFrame, StrengthValue.Value, 100)
		
		if (LastStrength > StrengthValue.Value) or ((tick() - TICK2) >= 2) then
			TICK2 = tick()
			LastStrength = StrengthValue.Value
			
			local plrData :CT.PlayerDataModel = _G.PlayerData
			local activeProfile :CT.ProfileSlotDataType = CF.PlayerQuestData.GetPlayerActiveProfile(plrData)
			
			activeProfile.Data.CombatStats.Stamina = StaminaValue.Value
			activeProfile.Data.CombatStats.Strength = StrengthValue.Value

			plrData.AllProfiles[plrData.ActiveProfile] = activeProfile
			_G.PlayerDataStore:UpdateData(plrData)
		end
	end)
end

----------------------***************** Public Methods **********************----------------------
function PlayerMenuGui:Construct()
	UIController = Knit.GetController("UIController")
	TWController = Knit.GetController("TweenController")
	CharacterController = Knit.GetController("CharacterController")
	
	self.Conn = {}
	self.active = UIController:SubsUI(Constants.UiScreenTags.PlayerMenuGui, self)
	
end

function PlayerMenuGui:Start()
	warn(self," Starting...")
	
	if(not self.active) then
		return
	end
	
	self:InitReferences()
	self:BindEvents()
		
	NotificationGui = UIController:GetGui(Constants.UiScreenTags.NotificationGui, 2)
		
	-- Setup thumbnail
	pcall(function()
		local ImageId, success = game.Players:GetUserThumbnailAsync(player.UserId,
			Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		
		if success then
			ui.StatsFrame.ProfileFrame.ProfilePic.Image = ImageId
		end
	end)
	
	
	-- Toggle
	self:Toggle(false)
end

function PlayerMenuGui:InitReferences()
	ui.Gui = self.Instance
	ui.BaseFrame = ui.Gui.BaseFrame
	
	ui.Selection = ui.BaseFrame.Templates.Selection
	
	ui.ControlsGuideBtn = ui.BaseFrame.ControlsGuideBtn
	
	ui.StatsFrame = ui.BaseFrame.StatsFrame
	ui.HotbarFrame = ui.BaseFrame.HotbarFrame
	
	ui.HealthFrame = ui.StatsFrame.ProfileFrame.Stats.HealthFrame
	ui.StaminaFrame = ui.StatsFrame.ProfileFrame.Stats.StaminaFrame
	ui.StrengthFrame = ui.StatsFrame.ProfileFrame.Stats.StrengthFrame
	
	task.delay(2, function()
		BindValueChanged()
	end)
end

function PlayerMenuGui:BindEvents()
	-- Action Calback on Input Begin and End
	local function BindAction(Button:ImageButton, OnAction :()->())
		--Button.InputBegan:Connect(function(inputObject:InputObject)
		--	if inputObject.UserInputState == Enum.UserInputState.Begin then	
		--		if OnAction and _G.ActiveBending == "None" then
		--			OnAction(true)
		--		end
		--	end
		--end)
		--Button.InputEnded:Connect(function(inputObject:InputObject)
		--	if inputObject.UserInputState == Enum.UserInputState.End then	
		--		if OnAction then
		--			OnAction(false)
		--		end
		--	end
		--end)
		Button.Activated:Connect(function()
			if OnAction then
				OnAction()
			end
		end)
	end
	
	do --Activation
		ui.ControlsGuideBtn.Activated:Connect(function()
			local includeList = {
				Constants.UiScreenTags.QuestGui,
				Constants.UiScreenTags.SettingsGui,
				Constants.UiScreenTags.StoreGui,
				Constants.UiScreenTags.GamePassGui,
				Constants.UiScreenTags.MapGui,
				Constants.UiScreenTags.ShopGui,
				Constants.UiScreenTags.ControlsGuideGui,
			}
			local openedUI = UIController:GetOpenedUI(includeList)
			if openedUI then
				UIController:ToggleScreen(openedUI, false)
			end
			
			UIController:ToggleScreen(Constants.UiScreenTags.ControlsGuideGui)
		end)

		ui.HotbarFrame.ButtonsFrame.BagButton.Activated:Connect(BagPackButton)

		-- Bind Actions According to the Level Up Type
		BindAction(ui.HotbarFrame.ButtonsFrame.AirBending, AirBending) -- [Button], [CallBack Function]
		BindAction(ui.HotbarFrame.ButtonsFrame.FireBending, FireBending) -- [Button], [CallBack Function]
		BindAction(ui.HotbarFrame.ButtonsFrame.WaterBending, WaterBending) -- [Button], [CallBack Function]
		BindAction(ui.HotbarFrame.ButtonsFrame.EarthBending, EarthBending) -- [Button], [CallBack Function]

		BindAction(ui.HotbarFrame.ButtonsFrame.Boomerang, Boomerang) -- [Button], [CallBack Function]
		BindAction(ui.HotbarFrame.ButtonsFrame.MeteoriteSword, MeteoriteSword) -- [Button], [CallBack Function]

		ui.StatsFrame.ProfileFrame.Activated:Connect(ProfileButton)

	end
	
	
	--Effects
	do
		TWController:SubsTween(ui.BaseFrame, Constants.TweenDir.Bottom, Constants.EasingStyle.Quad)

		TWController:SubsHover(ui.StatsFrame.ProfileFrame.ProfilePic)
		TWController:SubsHover(ui.StatsFrame.ProfileFrame)
		TWController:SubsHover(ui.ControlsGuideBtn)

		TWController:SubsClick(ui.StatsFrame.ProfileFrame)
		TWController:SubsClick(ui.ControlsGuideBtn)

		for _, Button in pairs(ui.HotbarFrame.ButtonsFrame:GetChildren()) do
			if Button:IsA("ImageButton") or Button:IsA("TextButton") then
				TWController:SubsClick(Button)
				
				local ability = Constants.Items[Button.Name]
				
				TWController:SubsHover(Button, nil, nil, function(hovering)
					local toolTip = Button:FindFirstChild("ToolTip")
					if ability and toolTip then
						Button.ToolTip.Text = ability.Name

						if hovering then
							Button.ToolTip.Visible = true
						else
							Button.ToolTip.Visible = false
						end
					end
				end)
			end
		end
	end
	
	--Character
	do
		OnCharacterAdded(player.Character)
		player.CharacterAdded:Connect(OnCharacterAdded)

	end
end

function PlayerMenuGui:Toggle(enable:boolean)
	if(enable ~= nil) then
		enable = (enable)
	else
		enable = (not ui.BaseFrame.Visible)
	end
	ui.BaseFrame.Visible = enable
end

-------- Called from Character Controller

function PlayerMenuGui:CoolDown(Bending, CoolDownTime)
	
	local Button : AbilityButtonType = ui.HotbarFrame.ButtonsFrame[Bending]
	
	if self.Conn[Bending] then
		--print("Can't overide Cooldown with ", Bending)
		return
	end
	
	Button.Active = false
	Button.Fillers.Inner.Visible = true
	Button.Fillers.CoolDownText.Visible = true
	Button.Logo.ImageTransparency = .5
	
	local TICK = tick()
	local TICK1 = tick()
	local DecCount = CoolDownTime
	Button.Fillers.CoolDownText.Text = DecCount 
	self.Conn[Bending] = game["Run Service"].Heartbeat:Connect(function(dt)
		local Diff = tick() - TICK1
		if Diff >= 1 then
			TICK1 = tick()
			DecCount -= 1
			Button.Fillers.CoolDownText.Text = DecCount
		end
		
		if tick() - TICK >= CoolDownTime then
			self.Conn[Bending]:Disconnect()
			self.Conn[Bending] = nil
			Button.Active = true
			Button.Logo.ImageTransparency = 0
			Button.Fillers.Inner.Visible = false
			Button.Fillers.CoolDownText.Visible = false
			return
		end
		local percentage = ((tick() - TICK) / CoolDownTime) --/ 100
		UpdateCoolDownBar(Button, percentage)
	end)
	
	
end

function PlayerMenuGui:ToggleSelection(enable, Bending)
	if enable then
		local Button : AbilityButtonType = ui.HotbarFrame.ButtonsFrame[Bending]
		ui.Selection.Parent = Button
		ui.Selection.Visible = true
	else
		ui.Selection.Visible = false
	end
end

return PlayerMenuGui