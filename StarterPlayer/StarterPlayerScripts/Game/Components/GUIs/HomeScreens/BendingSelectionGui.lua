-- @ScriptType: ModuleScript
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local RunS = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Packages = RS.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local CustomModules = RS.Modules.Custom
local CT = require(CustomModules.CustomTypes)
local CF = require(CustomModules.CommonFunctions)
local Constants = require(CustomModules.Constants)
local NotificationData = require(CustomModules.NotificationData)

local player = game.Players.LocalPlayer

local BendingSelectionGui = Component.new({Tag = "BendingSelectionGui", Ancestors = {player}})

type ItemTemplate = {
	Select :ImageButton & {Label :TextLabel},
	Shadow :ImageLabel & {
		Lock :ImageButton,
		Label : TextLabel
	},
	Icon :ImageLabel,
	BG :ImageLabel,
	Description :TextLabel,
	Title :TextLabel,
}

type UI = {
	Gui : ScreenGui,
	BaseFrame :TextButton & {
		Templates :Folder & {Item : ItemTemplate},
		Background :ImageLabel & {
			Elements :ScrollingFrame,
		},
	},
}

local ui :UI = {}

------ Other scripts
local UIController
local TWController
local NotificationGui

------ Variables

------------- Helper ------------


----------------------***************** Private Methods **********************----------------------
function OnLevelChanged(_plrData)
	local myData :CT.PlayerDataModel = _plrData or _G.PlayerData
	print("[BendingSelectionGui] this is _plrData", _plrData)
	if not myData  then
		warn("No Data found in AbilitySelection[]");
		return
	end
	
	do --check unlocked abilities
		local activeProfile :CT.ProfileSlotDataType = CF.PlayerQuestData.GetPlayerActiveProfile(myData)
		local level = activeProfile.PlayerLevel
		print("[BendingSelectionGui] activeProfile is", activeProfile, "level is", level)

		local requiredLevel, itemId = GetNextAbilityRequiredLevel(level-1)
		
		print("[BendingSelectionGui] requiredLevel is", requiredLevel, "itemId is", itemId)
		print("[BendingSelectionGui] Constants are", Constants.LevelAbilities, "and Constants.LevelAbilities[level]",Constants.LevelAbilities[level])

		if requiredLevel then
			local abilities = CF.Tables.TableLength(activeProfile.Data.EquippedInventory.Abilities)
			print("[BendingSelectionGui] abilities are", abilities)
			
			--print(`SlotId: {activeProfile}, currentAb: {abilities}, requdLvl: {requiredLevel}, currLvl: {level}, abiliCount: {Constants.LevelAbilities[level]}`)
			if requiredLevel and ((Constants.LevelAbilities[requiredLevel] - 1 > abilities) or (level <= requiredLevel and Constants.LevelAbilities[level] and abilities < Constants.LevelAbilities[level])) then
				BendingSelectionGui:Toggle(true)
			else
				BendingSelectionGui:Toggle(false)
			end
		end
	end
end

function OnBendingSelected(itemData :CT.ItemDataType)
	local myData :CT.PlayerDataModel = _G.PlayerData
	
	local activeProfile :CT.ProfileSlotDataType = CF.PlayerQuestData.GetPlayerActiveProfile(myData)
	local level = activeProfile.PlayerLevel
	local abilities = CF.Tables.TableLength(activeProfile.Data.EquippedInventory.Abilities)
	local requiredLevel, itemId = GetNextAbilityRequiredLevel(level-1)
	
	print("[BendingSelectionGui] inside onBendingSelected", Constants.LevelAbilities, requiredLevel,Constants.LevelAbilities[requiredLevel])
	
	--as requiredLevel nil comes when player has maxedout the level and need to have all the 4 bending abilities so we bypass the checks
	if requiredLevel and ((Constants.LevelAbilities[requiredLevel] - 1 > abilities) or (level <= requiredLevel and Constants.LevelAbilities[level] and abilities < Constants.LevelAbilities[level])) then
		CF.PlayerData.UpdateProfileInventory(myData, itemData, workspace.ServerTime.Value)
		_G.PlayerDataStore:UpdateData(myData)
		BendingSelectionGui:Toggle(false)
		
		NotificationGui:ShowMessage(NotificationData.AbilityUnlocked)
		
		task.delay(.5, function()
			OnLevelChanged()
		end)
		
		if abilities == 4 then
			task.delay(1, function()
				NotificationGui:ShowMessage(NotificationData.AllAbilitiesUnlocked)
			end)
		end
	else
		warn("Ability could not equipped, ", itemData.Id, Constants.LevelAbilities[level], abilities, requiredLevel, level)
	end
	
end

function Refresh()
	local myData :CT.PlayerDataModel = _G.PlayerData
	local activeProfile :CT.ProfileSlotDataType = CF.PlayerQuestData.GetPlayerActiveProfile(myData)
	local playerLevel = activeProfile.PlayerLevel

	for _, item:ItemTemplate in pairs(ui.BaseFrame.Background.Elements:GetChildren()) do
		if item:IsA("CanvasGroup") then
			local abilityData = Constants.GameInventory.Abilities[item.Name]
			local requiredLevel = if abilityData then abilityData.RequiredLevel else 0

			if activeProfile.Data.EquippedInventory.Abilities[item.Name] then
				-- Already owned
				item.Shadow.Visible = false
				item.Select.Image = " "
				item.Select.Active = false
				item.Select.Label.Text = "Owned"
				item.Select.Gradiant.Enabled = true
				item.Select.BackgroundTransparency = 0
				item.Select.BackgroundColor3 = Color3.fromRGB(138, 138, 138)
			elseif requiredLevel > 0 and playerLevel < requiredLevel then
				-- Locked — player hasn't reached required level
				item.Shadow.Visible = true
				item.Shadow.Label.Text = "Requires Lvl " .. requiredLevel
				item.Select.Active = false
				item.Select.Label.Text = "Locked"
				item.Select.Gradiant.Enabled = false
				item.Select.BackgroundTransparency = 1
				item.Select.Image = "rbxassetid://17575066019"
				item.Select.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			else
				-- Unlocked, selectable
				item.Shadow.Visible = false
				item.Select.Active = true
				item.Select.Label.Text = "Select"
				item.Select.Gradiant.Enabled = false
				item.Select.BackgroundTransparency = 1
				item.Select.Image = "rbxassetid://17575066019"
				item.Select.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	end
end

function GetNextAbilityRequiredLevel(currentLevel)
	local nextLevel = math.huge
	local itemId = nil
	
	for _, itemData in pairs(Constants.GameInventory.Abilities) do
		if itemData.RequiredLevel > currentLevel and itemData.RequiredLevel < nextLevel then
			nextLevel = itemData.RequiredLevel
			itemId = itemData.Id
		end
	end

	if nextLevel == math.huge then
		return nil
	end

	return nextLevel, itemId
end


----------------------***************** Public Methods **********************----------------------
function BendingSelectionGui:RefreshOnLevelChanged()
	OnLevelChanged()
end

function BendingSelectionGui:BindEvents()	
	_G.PlayerDataStore:ListenSpecChange("AllProfiles", function(newVal, oldVal, FullData:CustomTypes.PlayerDataModel)
		local oldActiveProfile :CustomTypes.ProfileSlotDataType = oldVal[FullData.ActiveProfile]
		local newActiveProfile :CustomTypes.ProfileSlotDataType = newVal[FullData.ActiveProfile]

		if (not oldActiveProfile) or (oldActiveProfile.PlayerLevel == newActiveProfile.PlayerLevel) then
			return
		end
		
		OnLevelChanged(FullData)
	end)
end

function BendingSelectionGui:Construct()
	UIController = Knit.GetController("UIController")
	TWController = Knit.GetController("TweenController")
	
	self.active = UIController:SubsUI(Constants.UiScreenTags.BendingSelectionGui, self)
	
end

function BendingSelectionGui:Start()
	warn(self," Starting...")
	
	--Check Module "active" validation with UIController
	do
		if(not self.active) then
			return
		end

		self:InitReferences()
		self:InitButtons()
		
		NotificationGui = UIController:GetGui(Constants.UiScreenTags.NotificationGui, 2)
		
		task.delay(2, function()
			self:BindEvents()
		end)
	end
end

function BendingSelectionGui:InitReferences()
	ui.Gui = self.Instance
	
	ui.BaseFrame = ui.Gui.BaseFrame
	ui.Template = ui.BaseFrame.Templates
end

function BendingSelectionGui:InitButtons()
	--Enable Tweening
	do
		TWController:SubsTween(ui.BaseFrame, Constants.TweenDir.Bottom)
		
		local function _spawn(itemData :CT.ItemDataType)
			local item :ItemTemplate = ui.BaseFrame.Templates.Item:Clone()
			item.Parent = ui.BaseFrame.Background.Elements
			item.Name = itemData.Id
			
			item.Visible = true
			item.Select.Visible = false
			item.Title.Text = itemData.Name
			item.Icon.Image = itemData.Image
			item.Description.Text = itemData.Description
			item.LayoutOrder = itemData.RequiredLevel
			
			item.Select.Activated:Connect(function()
				OnBendingSelected(itemData)
			end)
			
			if UserInputService.TouchEnabled then
				item.Select.Visible = true
			else
				
			TWController:SubsHover(item.BG, nil, nil, function(hover)
				if hover then
					item.Select.Visible = true
				else
					item.Select.Visible = false				
				end
			end)
			end
		end
		
		_spawn(Constants.GameInventory.Abilities.AirBending)
		_spawn(Constants.GameInventory.Abilities.FireBending)
		_spawn(Constants.GameInventory.Abilities.EarthBending)
		_spawn(Constants.GameInventory.Abilities.WaterBending)
	end
	
	self:Toggle(false)
end

function BendingSelectionGui:IsVisible()
	return ui.BaseFrame.Visible
end

function BendingSelectionGui:Toggle(enable:boolean)
	if(enable ~= nil) then
		enable = (enable)
	else
		enable = (not ui.BaseFrame.Visible)
	end
	
	if(enable) then
		Refresh()
	end
	ui.BaseFrame.Visible = enable
end


return BendingSelectionGui