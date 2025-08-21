-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local MPS = game:GetService("MarketplaceService")

local Packages = RS.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local CustomModules = RS.Modules.Custom
local CT = require(CustomModules.CustomTypes)
local CF = require(CustomModules.CommonFunctions)
local Constants = require(CustomModules.Constants)

local player = game.Players.LocalPlayer
local CustomizationUI = Component.new({Tag = "CustomizationUI", Ancestors = {player}})

type UI = {
	Base :Frame & {
		LeftButtons :Frame,
		CustomizeF :ImageLabel,	
	},

	LeftButtons :{
		Hair :ImageButton,
		Pant :ImageButton,
		Skin :ImageButton,
		Face :ImageButton,
		Jersey :ImageButton,
	},
	CustomizeF :{
		Template :{
			Item:ImageButton,
		},
		Container :{
			Face :Frame,	
			Skin :Frame,	
			Hair :Frame,
			Pant :Frame,
			Jersey :Frame,
		},
		Topbar :Frame &{
			Eye :ImageButton,
			Extra :ImageButton,
			Mouth :ImageButton,
			Eyebrows :ImageButton,
		},
		Buy :ImageButton &{Label :TextLabel},
	},

}

local ui :UI = {}

------ Other scripts
local UIController
local TWController
local IAPController

-- Variable 
local frameToOpen

local ROBUX_ICON = ""
local selectedItem :CT.ItemDataType = {}
local lastSelectedItem :CT.ItemDataType = {}
----------------------***************** Private Methods **********************----------------------
function refreshOwnItems()
	local profileSlotData :CT.ProfileSlotDataType = _G.SelectedSlotData:Get()
	local plrData :CT.PlayerDataModel = _G.PlayerData 

	local function refresh(_parent, _ownedData, _equippedData)
		for _, button in pairs(_parent:GetChildren()) do
			if not button:IsA("ImageButton") then continue end

			if _ownedData[button.Name] then
				button.LayoutOrder = -1
				button.UIStroke.Color = Color3.fromRGB(162, 162, 162)
				
				button.Label.Text = " "
			end

			if _equippedData.Id == button.Name then
				button.UIStroke.Color = Color3.fromRGB(120, 230, 98)
			elseif not _ownedData[button.Name] then
				button.UIStroke.Color = Color3.fromRGB(204, 104, 2)
			end
		end	
	end

	refresh(ui.CustomizeF.Container.Hair.Scroll, plrData.OwnedInventory.Styling.Hair, profileSlotData.Data.EquippedInventory.Styling.Hair)
	refresh(ui.CustomizeF.Container.Pant.Scroll, plrData.OwnedInventory.Styling.Pant, profileSlotData.Data.EquippedInventory.Styling.Pant)
	refresh(ui.CustomizeF.Container.Jersey.Scroll, plrData.OwnedInventory.Styling.Jersey, profileSlotData.Data.EquippedInventory.Styling.Jersey)

	refresh(ui.CustomizeF.Container.Skin.Scroll, {}, profileSlotData.Data.EquippedInventory.Styling.Skin)
	refresh(ui.CustomizeF.Container.Face.Eye.Scroll, {}, profileSlotData.Data.EquippedInventory.Styling.Eye)
	refresh(ui.CustomizeF.Container.Face.Mouth.Scroll,{}, profileSlotData.Data.EquippedInventory.Styling.Mouth)
	refresh(ui.CustomizeF.Container.Face.Extra.Scroll,{}, profileSlotData.Data.EquippedInventory.Styling.Extra)
	refresh(ui.CustomizeF.Container.Face.Eyebrows.Scroll,{}, profileSlotData.Data.EquippedInventory.Styling.Eyebrows)
end

local function openBarF(_barName)
	local barToOpen = ui.CustomizeF.Container.Face:FindFirstChild(_barName)
	barToOpen.Scroll.CanvasPosition = Vector2.zero

	ui.CustomizeF.Topbar.Eye.UIStroke.Thickness = barToOpen == ui.CustomizeF.Container.Face.Eye and 2 or 1
	ui.CustomizeF.Topbar.Extra.UIStroke.Thickness = barToOpen == ui.CustomizeF.Container.Face.Extra and 2 or 1
	ui.CustomizeF.Topbar.Mouth.UIStroke.Thickness = barToOpen == ui.CustomizeF.Container.Face.Mouth and 2 or 1
	ui.CustomizeF.Topbar.Eyebrows.UIStroke.Thickness = barToOpen == ui.CustomizeF.Container.Face.Eyebrows and 2 or 1

	ui.CustomizeF.Topbar.Eye.UIStroke.Color = barToOpen == ui.CustomizeF.Container.Face.Eye and Color3.fromRGB(120, 230, 98) or Color3.fromRGB(204, 104, 2)
	ui.CustomizeF.Topbar.Extra.UIStroke.Color = barToOpen == ui.CustomizeF.Container.Face.Extra and Color3.fromRGB(120, 230, 98) or Color3.fromRGB(204, 104, 2)
	ui.CustomizeF.Topbar.Mouth.UIStroke.Color = barToOpen == ui.CustomizeF.Container.Face.Mouth and Color3.fromRGB(120, 230, 98) or Color3.fromRGB(204, 104, 2)
	ui.CustomizeF.Topbar.Eyebrows.UIStroke.Color = barToOpen == ui.CustomizeF.Container.Face.Eyebrows and Color3.fromRGB(120, 230, 98) or Color3.fromRGB(204, 104, 2)

	ui.CustomizeF.Container.Face.Eye.Visible = barToOpen == ui.CustomizeF.Container.Face.Eye
	ui.CustomizeF.Container.Face.Extra.Visible = barToOpen == ui.CustomizeF.Container.Face.Extra
	ui.CustomizeF.Container.Face.Mouth.Visible = barToOpen == ui.CustomizeF.Container.Face.Mouth
	ui.CustomizeF.Container.Face.Eyebrows.Visible = barToOpen == ui.CustomizeF.Container.Face.Eyebrows
end

local function openInvF(_invName)
	frameToOpen = ui.CustomizeF.Container:FindFirstChild(_invName)

	if frameToOpen ~= ui.CustomizeF.Container.Face then
		frameToOpen.Scroll.CanvasPosition = Vector2.zero
		ui.CustomizeF.Topbar.Visible = false
	else
		ui.CustomizeF.Topbar.Visible = true
		openBarF("Eye")
	end

	ui.CustomizeF.Label.Text = frameToOpen.Name

	ui.CustomizeF.Visible = true
	ui.CustomizeF.Container.Hair.Visible = frameToOpen == ui.CustomizeF.Container.Hair
	ui.CustomizeF.Container.Face.Visible = frameToOpen == ui.CustomizeF.Container.Face
	ui.CustomizeF.Container.Pant.Visible = frameToOpen == ui.CustomizeF.Container.Pant
	ui.CustomizeF.Container.Jersey.Visible = frameToOpen == ui.CustomizeF.Container.Jersey
	ui.CustomizeF.Container.Skin.Visible = frameToOpen == ui.CustomizeF.Container.Skin
	
	refreshOwnItems()
end

local function onInvButtonClick(_itemData :CT.ItemDataType)
	local profileSlotData :CT.ProfileSlotDataType = _G.SelectedSlotData:Get()
	--print("profileSlotData -> Before : ", profileSlotData.Data.EquippedInventory.Styling)

	if _itemData.ProductId then
		local having = CF.PlayerData.DoesPlayerHaveItem(_G.PlayerData, _itemData)
		--print("Having : ", having, _G.PlayerData, _itemData)
		if having then
			selectedItem = nil
			ui.CustomizeF.Buy.Visible = false

			if CF.PlayerData.DoesPlayerEquipItem(profileSlotData, _itemData) then
				CF.PlayerData.EquipItem(profileSlotData, _itemData, false)
			else
				CF.PlayerData.EquipItem(profileSlotData, _itemData, true)
			end

			_G.SelectedSlotData:Set(profileSlotData, true)
		else
			if lastSelectedItem and lastSelectedItem.Id == _itemData.Id then
				selectedItem = nil
				ui.CustomizeF.Buy.Visible = false
			else
				ui.CustomizeF.Buy.Visible = true
				ui.CustomizeF.Buy.Label.Text = ROBUX_ICON.." ".._itemData.Price
				selectedItem = _itemData
			end
		end
	else
		selectedItem = nil
		ui.CustomizeF.Buy.Visible = false

		if CF.PlayerData.DoesPlayerEquipItem(profileSlotData, _itemData) then
			CF.PlayerData.EquipItem(profileSlotData, _itemData, false)
		else
			CF.PlayerData.EquipItem(profileSlotData, _itemData, true)
		end

		_G.SelectedSlotData:Set(profileSlotData, true)
	end

	if ui.CustomizeF.Buy.Visible == true then
		_G.UnPurchasedItem = _itemData.ItemType
		CF.Inventory.ApplyInventory(workspace.Scripted_Items.LoadGame.Default, _itemData, true)
	else
		_G.UnPurchasedItem = nil
		CF.Inventory.ApplyFullInventory(workspace.Scripted_Items.LoadGame.Default, profileSlotData)
	end
	
	refreshOwnItems()
	lastSelectedItem = selectedItem
end

local function onBuyButtonClick()
	local itemData = selectedItem
	if itemData and itemData.ProductId then
		warn("[123]Request for Customization purchase ID:", itemData.Id)
		local conn 
		conn = IAPController.onPurchaseCompleted:Connect(function(_itemData :CT.ItemDataType)
			--print("[123]Customization purchase successfull: COMPARING ", _itemData)
			if(itemData.Id == _itemData.Id) then
				conn:Disconnect()
				local pDat = _G.PlayerData
				CF.PlayerData.UpdateInventory(pDat, _itemData, "Purchase")
				--print("[123]Customization purchase successfull:", _itemData.Name, pDat, pDat)
				_G.PlayerDataStore:UpdateData(pDat)
				
				onInvButtonClick(_itemData)
			end
		end)

		IAPController:PurchaseItem(itemData)
	else
		warn("[Customization] error in product ", itemData.Id)
	end
end

local function spawnItems(_parent, _items:{[string] :CT.ItemDataType})
	for _, itemData :CT.ItemDataType in pairs(_items) do

		local order = itemData.Id:match("%d+$") -- Extracts the trailing digits
		if order == '00' then
			continue
		end
		
		if itemData.Price == "0" then
			order = 0
		end
		
		local _button = ui.CustomizeF.Template.Item:Clone()
		_button.Parent = _parent
		_button.LayoutOrder = order
		_button.Visible = true
		
		local price = itemData.Price
		_button.Label.Text = price and ROBUX_ICON.." "..price or " "
		
		_button.Name = itemData.Id
		_button.Icon.Image = itemData.Image or ""

		if itemData.ItemType == Constants.ItemType.Skin then
			local colorCont = string.split(itemData.Color, ", ")
			_button.Icon.ImageColor3 = Color3.fromRGB(table.unpack(colorCont))
			_button.LayoutOrder = itemData.LayoutOrder
		end

		_button.Activated:Connect(function()
			onInvButtonClick(itemData)
		end)
	end
end

----------------------***************** Public Methods **********************----------------------
function CustomizationUI:Toggle(enable:boolean)
	if(enable ~= nil) then
		enable = (enable)
	else
		enable = (not ui.Base.Visible)
	end

	if enable then
		-- Setup and refresh the Profile UI
		ui.Base.Visible = enable
		refreshOwnItems()
	end
end

function CustomizationUI:Init()
	ui.Base = self.Instance

	ui.CustomizeF = ui.Base.CustomizeF
	ui.LeftButtons = ui.Base.LeftButtons
end

function CustomizationUI:Bind()
	-- Tweens
	do
		TWController:SubsTween(ui.Base, Constants.TweenDir.Left, Constants.EasingStyle.Quad, ui.LeftButtons.Size)
		TWController:SubsTween(ui.CustomizeF, Constants.TweenDir.Left, Constants.EasingStyle.Quad, ui.CustomizeF.Size)
		--TWController:SubsTween(ui.CustomizeF.Topbar, Constants.TweenDir.Top, Constants.EasingStyle.Quad, ui.CustomizeF.Topbar.Size)

		TWController:SubsHover(ui.LeftButtons.Face)
		TWController:SubsHover(ui.LeftButtons.Hair)
		TWController:SubsHover(ui.LeftButtons.Pant)
		TWController:SubsHover(ui.LeftButtons.Skin)
		TWController:SubsHover(ui.LeftButtons.Jersey)

		TWController:SubsHover(ui.CustomizeF.Buy)
		TWController:SubsHover(ui.CustomizeF.Topbar.Eye)
		TWController:SubsHover(ui.CustomizeF.Topbar.Extra)
		TWController:SubsHover(ui.CustomizeF.Topbar.Mouth)
		TWController:SubsHover(ui.CustomizeF.Topbar.Eyebrows)
	end

	ui.Base:GetPropertyChangedSignal("Visible"):Connect(function()
		if ui.Base.Visible then
			refreshOwnItems()
		end
		
		ui.CustomizeF.Visible = false
	end)

	-- Left Buttons to open Cutomization
	for _, button:ImageButton in pairs(ui.LeftButtons:GetChildren()) do
		if button:IsA("ImageButton") then
			button.Activated:Connect(function()
				if ui.CustomizeF.Visible then
					if frameToOpen.Name == button.Name then
						ui.CustomizeF.Visible = false
					else
						openInvF(button.Name)
					end
				else
					openInvF(button.Name)
				end
			end)
		end
	end

	-- Bind Top Bar buttons
	for _, button:ImageButton in pairs(ui.CustomizeF.Topbar:GetChildren()) do
		if button :IsA("ImageButton") then
			button.Activated:Connect(function()
				openBarF(button.Name)
			end)
		end
	end

	-- Bind Buy button
	ui.CustomizeF.Buy.Activated:Connect(onBuyButtonClick)

	-- Spawn Inventory items
	do
		spawnItems(ui.CustomizeF.Container.Hair.Scroll, Constants.GameInventory.Styling.Hair)
		spawnItems(ui.CustomizeF.Container.Pant.Scroll, Constants.GameInventory.Styling.Pant)
		spawnItems(ui.CustomizeF.Container.Skin.Scroll, Constants.GameInventory.Styling.Skin)
		spawnItems(ui.CustomizeF.Container.Jersey.Scroll, Constants.GameInventory.Styling.Jersey)

		spawnItems(ui.CustomizeF.Container.Face.Eye.Scroll, Constants.GameInventory.Styling.Eye)
		spawnItems(ui.CustomizeF.Container.Face.Mouth.Scroll, Constants.GameInventory.Styling.Mouth)
		spawnItems(ui.CustomizeF.Container.Face.Extra.Scroll , Constants.GameInventory.Styling.Extra)
		spawnItems(ui.CustomizeF.Container.Face.Eyebrows.Scroll, Constants.GameInventory.Styling.Eyebrows)
	end
	
	_G.SelectedSlotData.OnChange:Connect(function()
		refreshOwnItems()
	end)
end

function CustomizationUI:Construct()
	UIController = Knit.GetController("UIController")
	IAPController = Knit.GetController("IAPController")
	TWController = Knit.GetController("TweenController")

	self.active = UIController:SubsUI(Constants.UiScreenTags.CustomizationUI, self)
	
end

function CustomizationUI:Start()
	warn(self," Starting...")


	if(self.active) then
		self:Init()
		self:Bind()
	end
end

return CustomizationUI