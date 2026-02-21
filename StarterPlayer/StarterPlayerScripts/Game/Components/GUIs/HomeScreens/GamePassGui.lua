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


local player = game.Players.LocalPlayer

local GamePassGui = Component.new({Tag = "GamePassGui", Ancestors = {player}})

type UI = {
	Gui : ScreenGui,
	--GamePass Gui
	GamePassFrame :TextButton & {
		Templates :Folder & {Item : ImageLabel},
		Background :ImageLabel & {
			ElementsFrame :ScrollingFrame,
			CloseButton :ImageButton,
		},
	},
	GamePassTemplate : CanvasGroup & {
		BuyButton :ImageButton & {Price :TextLabel},
		Shadow :ImageLabel & {
			Lock :ImageButton,
			Label : TextLabel
		},
		Icon :ImageLabel,
		BG :ImageLabel,
		Description :TextLabel,
		Title :TextLabel,
	},
}

local ui :UI = {}


------ Other scripts
local UIController
local TWController
local IAPController

------ Variables
local ProductsLiveData = {}

------------- Helper ------------


----------------------***************** Private Methods **********************----------------------
function FetchLiveData(pData:CT.ItemDataType)
	
	ProductsLiveData[pData.Id] = IAPController:GetProductInfo(pData.ProductId, pData.ProductType)
	if(ProductsLiveData[pData.Id]) then
		ProductsLiveData[pData.Id]["_Updated_"] = tick()
	end
end
------------- GamePasses ------------
function GamePassCloseButton()
	ui.GamePassFrame.Visible = false
end

function BuyGamePass(iData:CT.ItemDataType)
	--warn("Request for GamePass purchase ID:", iData.Id)
	local conn = nil
	conn = IAPController.onPurchaseCompleted:Connect(function(itemData)
		if(itemData.Id == iData.Id) then
			conn:Disconnect()
			local pDat = _G.PlayerData
			--print("[TESTING PASSES] - ", _G.PlayerData.GamePurchases.Passes)
			--print("GamePass purchase successfull:", iData.Name, pDat)
			CF.PlayerData.UpdateInventory(pDat, iData, true)
			_G.PlayerDataStore:UpdateData(pDat)
			
			UpdateGamePasses()
		end
	end)
	
	IAPController:PurchaseItem(iData)
end

function UpdateGamePasses()
	--Clear
	for i, v in pairs(ui.GamePassFrame.Background.ElementsFrame:GetChildren()) do
		if(v:IsA("CanvasGroup")) then
			v:Destroy()
		end
	end
	
	local plrData :CT.PlayerDataModel = _G.PlayerData
	
	--Spawn Passes
	for i, data :CT.ItemDataType in pairs(Constants.IAPItems) do
		
		if(data.ProductCategory == Constants.ProductCategories.GamePass) then
			local item = ui.GamePassTemplate:Clone()
			
			TWController:SubsHover(item.BuyButton)
			TWController:SubsClick(item.BuyButton)
			
			item:SetAttribute("ProductId", data.ProductId)
			
			--Try fetch live feed of product from Roblox.
			do
				if(not ProductsLiveData[data.Id]) then
					FetchLiveData(data)
				else
					if(tick() - ProductsLiveData[data.Id]["_Updated_"] > 3600) then
						FetchLiveData(data)
					end
				end
			end
			local liveData :CT.ItemDataType = ProductsLiveData[data.Id]
			
			--Update item with data
			item.Name = liveData and liveData.Name or data.Name
			item.LayoutOrder = data.ProductId
			item.BG.ImageColor3 = data.Color
			item.Title.Text = liveData and liveData.Name or data.Name
			item.Description.Text = liveData and liveData.Description or data.Description
			item.Icon.Image = "rbxassetid://"..(liveData and liveData.IconImageAssetId or data.Image)
			item.BuyButton.Price.Text = liveData and liveData.PriceInRobux or data.Price
			item.BuyButton.Price.ImageLabel.Visible = true
			item.Parent = ui.GamePassFrame.Background.ElementsFrame
			
			--Purchaes validation and UI update
			if(plrData.GamePurchases.Passes[data.Id]) then
				--Already owns
				item.BuyButton.Price.Text = "OWNED"
				item.BuyButton.Price.ImageLabel.Visible = false
			else
				if(player.Progression.LEVEL.Value >= data.RequiredLevel) then
					item.Shadow.Visible = false
					--Let purchase
					item.BuyButton.Activated:Connect(function()
						BuyGamePass(data)
					end)
				else
					item.Shadow.Visible = true
					item.Shadow.Label.Text = "Requires Lvl "..data.RequiredLevel
				end
			end

			item.Visible = true
		end
		
	end
	
end


------------- GamePasses ------------


----------------------***************** Public Methods **********************----------------------
function GamePassGui:Construct()
	UIController = Knit.GetController("UIController")
	TWController = Knit.GetController("TweenController")
	IAPController = Knit.GetController("IAPController")
	
	self.active = UIController:SubsUI(Constants.UiScreenTags.GamePassGui, self)
	
end

function GamePassGui:Start()
	--warn(self," Starting...")
	
	--Check Module "active" validation with UIController
	do
		if(not self.active) then
			return
		end
		
		self:InitReferences()
		self:InitButtons()
	end
	
	--Enable Tweening
	do
		TWController:SubsTween(ui.GamePassFrame, Constants.TweenDir.Left)
		TWController:SubsHover(ui.GamePassFrame.Background.CloseButton)
		TWController:SubsClick(ui.GamePassFrame.Background.CloseButton)
		
		for _, child in pairs(ui.GamePassFrame.Background.ElementsFrame:GetChildren()) do
			if child:IsA("CanvasGroup") then
				TWController:SubsHover(child.BG)
				TWController:SubsHover(child.Icon)
				TWController:SubsHover(child.BuyButton)
			end
		end
	end
	
	task.delay(2, function()
		UpdateGamePasses()
	end)
	self:Toggle(false)
	--print(self," started:", self.active)
end

function GamePassGui:InitReferences()
	ui.Gui = self.Instance
	
	--GamePass Gui
	ui.GamePassFrame = ui.Gui.GamePasses
	ui.GamePassTemplate = ui.GamePassFrame.Templates.Item
end

function GamePassGui:InitButtons()
	
	ui.GamePassFrame.Background.CloseButton.Activated:Connect(GamePassCloseButton)
	
end

function GamePassGui:IsVisible()
	return ui.GamePassFrame.Visible
end

function GamePassGui:Toggle(enable:boolean)
	if(enable ~= nil) then
		enable = (enable)
	else
		enable = (not ui.GamePassFrame.Visible)
	end
	
	if(enable) then
		--UpdateGamePasses()
	end
	ui.GamePassFrame.Visible = enable
end


return GamePassGui