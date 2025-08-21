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
local CF = require(CustomModules.CommonFunctions)
local Constants = require(CustomModules.Constants)
local SFXHandler = require(CustomModules.SFXHandler)
local NotificationData = require(CustomModules.NotificationData)

local player = game.Players.LocalPlayer

local ShopGui = Component.new({Tag = "ShopGui", Ancestors = {player}})

type UI = {
	Gui : ScreenGui,
	--Shop Gui
	ShopFrame :TextButton,
	
	Background :ImageLabel,
	
	ElementsContainer :ScrollingFrame,
	CloseBtn :ImageButton,
	
	Appa :ImageLabel,
	Glider :ImageLabel,
	
}

local ui :UI = {}


------ Other scripts
local UIController
local IAPController
local TWController
local QuestController
local NotificationGui

------ Variables


------------- Helper ------------

----------------------***************** Private Methods **********************----------------------

------------- Shop ------------
function ShopCloseButton()
	ShopGui:Toggle()
end

function BuyButtonClick(iData :CT.ItemDataType)
	warn("Pack purchase in shop:", iData)
	
	local plrData :CT.PlayerDataModel = _G.PlayerData
	if plrData.OwnedInventory.Transports[iData.Id] then
		---- 
		warn("Item already Exist!!")
		return
	end
	
	local activeProfile :CT.ProfileSlotDataType = CF.PlayerQuestData.GetPlayerActiveProfile(plrData)
	
	if activeProfile[iData.CurrencyType] >= iData.Price then
		activeProfile[iData.CurrencyType] -= iData.Price
		
		plrData.AllProfiles[plrData.ActiveProfile] = activeProfile
		
		CF.PlayerData.UpdateProfileInventory(plrData, iData, true)
		_G.PlayerDataStore:UpdateData(plrData)
		
		SFXHandler:Play(Constants.SFXs.Buy, true)
		SFXHandler:Play(Constants.SFXs.Purchased_Success, true)
		QuestController.UpdateQuest:Fire(Constants.QuestObjectives.Purchase, iData.Id)
		
		if iData.Id == Constants.Items.Glider.Id then
			NotificationGui:ShowMessage(NotificationData.GliderUnlocked)
		end
		
	end
end
------------- Shop ------------


----------------------***************** Public Methods **********************----------------------
function ShopGui:Construct()
	UIController = Knit.GetController("UIController")
	IAPController = Knit.GetController("IAPController")
	TWController = Knit.GetController("TweenController")
	QuestController = Knit.GetController("QuestController")
	
	self.active = UIController:SubsUI(Constants.UiScreenTags.ShopGui, self)
	
end

function ShopGui:Start()
	warn(self," Starting...")
	
	if(self.active) then
		self:InitReferences()
		self:InitButtons()
		--self:InitTrigger()
		task.delay(2, function()
			self:BindEvents()
		end)
		
		NotificationGui = UIController:GetGui(Constants.UiScreenTags.NotificationGui, 2)
	end
	
	-- Tweening
	do
		TWController:SubsTween(ui.ShopFrame, Constants.TweenDir.Bottom)
		TWController:SubsHover(ui.Background)
		TWController:SubsHover(ui.CloseBtn)
		TWController:SubsClick(ui.CloseBtn)

		for _, child in pairs(ui.ElementsContainer:GetChildren()) do
			if child:IsA("ImageLabel") then
				TWController:SubsHover(child)
				TWController:SubsHover(child.BuyButton)
				TWController:SubsClick(child.BuyButton)
			end
		end
	end
	
	self:Toggle(false)
	print(self," started:", self.active)
end

function ShopGui:InitReferences()
	ui.Gui = self.Instance
	
	--Shop Gui
	ui.ShopFrame = ui.Gui.ShopFrame
	ui.Background = ui.ShopFrame.Background
	
	ui.ElementsContainer = ui.Background.ElementsFrame
	ui.CloseBtn = ui.Background.CloseButton
	
	ui.Appa = ui.ElementsContainer.Appa
	ui.Glider = ui.ElementsContainer.Glider
end

function ShopGui:InitButtons()
	ui.CloseBtn.Activated:Connect(function()
		ShopCloseButton()
	end)

	ui.Appa.BuyButton.Activated:Connect(function()
		BuyButtonClick(Constants.GameInventory.Transports.Appa)
	end)

	ui.Glider.BuyButton.Activated:Connect(function()
		BuyButtonClick(Constants.GameInventory.Transports.Glider)
	end)
end

function ShopGui:BindEvents()
	
	local function _refresh()
		local plrData :CT.PlayerDataModel = _G.PlayerData
		--print("Inventory.Transports ", plrData)
		local Transports = CF.PlayerQuestData.GetPlayerActiveProfile(plrData).Data.EquippedInventory.Transports
		
		for _, ButtonCont in pairs(ui.ElementsContainer:GetChildren()) do
			if ButtonCont:IsA("ImageLabel") then
				local ID = ButtonCont:GetAttribute("ProductId")
				local itemData = Constants.Items[ID]
				if itemData.Id then

					if (player.Progression.LEVEL.Value >= Constants.Items[ID].RequiredLevel) then
						ButtonCont.Shadow.Visible = false
						--BuyButtonClick(Constants.GameInventory.Transports[ID])
					else
						ButtonCont.Shadow.Label.Text = "Requires Lvl "..Constants.Items[ID].RequiredLevel 
						ButtonCont.Shadow.Visible = true
					end
					
					if Transports[itemData.Id] then
						ButtonCont.BuyButton.Icon.Visible = false
						ButtonCont.BuyButton.Price.Text = "Owned"
						ButtonCont.BuyButton.Active = false
						ButtonCont.BuyButton.Image = " "
						ButtonCont.BuyButton.Gradiant.Enabled = true
						ButtonCont.BuyButton.BackgroundColor3 = Color3.fromRGB(138, 138, 138)
					else
						local activeProfile :CT.ProfileSlotDataType = CF.PlayerQuestData.GetPlayerActiveProfile(plrData)
						local saving = activeProfile[itemData.CurrencyType]
						if saving then
							ButtonCont.BuyButton.Icon.Visible = true
							ButtonCont.BuyButton.Price.Text = itemData.Price
							if saving > itemData.Price then
								ButtonCont.BuyButton.Active = true
								ButtonCont.BuyButton.Image = "rbxassetid://17575066019"
								ButtonCont.BuyButton.Gradiant.Enabled = false
								ButtonCont.BuyButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							else
								ButtonCont.BuyButton.Active = false
								ButtonCont.BuyButton.Image = " "
								ButtonCont.BuyButton.Gradiant.Enabled = true
								ButtonCont.BuyButton.BackgroundColor3 = Color3.fromRGB(138, 138, 138)
							end
						end					
					end
				end
			end
		end
		
	end
	
	----- Update explored maps buttons
	_G.PlayerDataStore:ListenSpecChange("OwnedInventory", function(newData)
		if newData then
			_refresh()
		end
	end)
	
	_G.PlayerDataStore:ListenSpecChange("AllProfiles", function(newData)
		if newData then
			_refresh()
		end
	end)
	
	_refresh()
end

function ShopGui:IsVisible()
	return ui.ShopFrame.Visible
end

function ShopGui:Toggle(enable:boolean)
	if(enable ~= nil) then
		enable = (enable)
	else
		enable = (not ui.ShopFrame.Visible)
	end
	
	if enable then
		QuestController.UpdateQuest:Fire(Constants.QuestObjectives.Find, Constants.QuestTargetIds.Shop)
	end
	
	ui.ShopFrame.Visible = enable
end

return ShopGui