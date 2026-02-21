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

local player = game.Players.LocalPlayer

local StoreGui = Component.new({Tag = "StoreGui", Ancestors = {player}})

type UI = {
	Gui : ScreenGui,
	--Shop Gui
	StoreFrame :TextButton,
	
	Background :ImageLabel,
	
	ElementsContainer :ScrollingFrame,
	CloseBtn :ImageButton,
	
	Gemsx2F :ImageLabel,
	GemsPackF :ImageLabel,
	MegaLuckF :ImageLabel,
	MegaLuck2F :ImageLabel,
	
}

local ui :UI = {}


------ Other scripts
local UIController
local IAPController
local TWController

------ Variables


------------- Helper ------------

local function ToggleBtn(btn:TextButton)
	
end


----------------------***************** Private Methods **********************----------------------

------------- Shop ------------
function ShopCloseButton()
	StoreGui:Toggle()
end

function BuyButtonClick(packF:ImageLabel)
	--warn("Pack purchase in shop:",packF)
	local pId = packF:GetAttribute("ProductId")
	if(not pId) then warn("ProductId not found on pack.") return end
	
	local iData : CT.ItemDataType = Constants.Items[pId]
	local conn = nil
	conn = IAPController.onPurchaseCompleted:Connect(function(itemData)
		conn:Disconnect()
		if(itemData.Id == iData.Id) then
			--print("ShopItem purchase successfull:", iData.Name)
			local pDat = _G.PlayerData
			
			if(iData.ProductCategory == Constants.ProductCategories.Gems) then
				CF.PlayerData.UpateGemsInPlayerData(pDat, iData.Amount)
				
			elseif(iData.ProductCategory == Constants.ProductCategories.Gold) then
				
				CF.PlayerData.UpdateGoldInPlayerData(pDat, iData.Amount)
			end
			
			_G.PlayerDataStore:UpdateData(pDat)
		end
	end)
	
	IAPController:PurchaseItem(iData)
end

------------- Shop ------------


----------------------***************** Public Methods **********************----------------------
function StoreGui:Construct()
	UIController = Knit.GetController("UIController")
	IAPController = Knit.GetController("IAPController")
	TWController = Knit.GetController("TweenController")
	
	self.active = UIController:SubsUI(Constants.UiScreenTags.StoreGui, self)
	
end

function StoreGui:Start()
	--warn(self," Starting...")
	
	if(self.active) then
		self:InitReferences()
		self:InitButtons()
		self:InitTrigger()
	end
	
	-- Tweening
	do
		TWController:SubsTween(ui.StoreFrame, Constants.TweenDir.Left)
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
	--print(self," started:", self.active)
end

function StoreGui:InitTrigger()
	local Trigger = workspace.Scripted_Items.Store:WaitForChild("Trigger")

	Trigger.Touched:Connect(function(hit)
		if hit.Name ~= "HumanoidRootPart" then return end
		local char = hit.Parent:FindFirstChild("Humanoid") and hit.Parent or nil
		
		if char and char:HasTag(Constants.Tags.PlayerAvatar) then
			
			if char == player.Character then
				if not ui.StoreFrame.Visible then
					StoreGui:Toggle(true)
				end
			end
		end
	end)

	Trigger.TouchEnded:Connect(function(hit)
		if hit.Name ~= "HumanoidRootPart" then return end
		local char = hit.Parent:FindFirstChild("Humanoid") and hit.Parent or nil 
		if char and char:HasTag(Constants.Tags.PlayerAvatar) then
			if char == player.Character then
				if ui.StoreFrame.Visible then
					StoreGui:Toggle(false)
				end
			end
		end
	end)

end

function StoreGui:InitReferences()
	ui.Gui = self.Instance
	
	--Shop Gui
	ui.StoreFrame = ui.Gui.StoreFrame
	ui.Background = ui.StoreFrame.Background
	
	ui.ElementsContainer = ui.Background.ElementsFrame
	ui.CloseBtn = ui.Background.CloseButton
	
	ui.Gemsx2F = ui.ElementsContainer.Gems2xFrame
	ui.GemsPackF = ui.ElementsContainer.GemsPackFrame
	ui.MegaLuckF = ui.ElementsContainer.MegaLuckFrame
	ui.MegaLuck2F = ui.ElementsContainer.MegaLuck2Frame
	
end

function StoreGui:InitButtons()
	
	ui.CloseBtn.Activated:Connect(function()
		ShopCloseButton()
	end)

	ui.Gemsx2F.BuyButton.Activated:Connect(function()
		BuyButtonClick(ui.Gemsx2F)
	end)

	ui.GemsPackF.BuyButton.Activated:Connect(function()
		BuyButtonClick(ui.GemsPackF)
	end)

	ui.MegaLuckF.BuyButton.Activated:Connect(function()
		BuyButtonClick(ui.MegaLuckF)
	end)

	ui.MegaLuck2F.BuyButton.Activated:Connect(function()
		BuyButtonClick(ui.MegaLuck2F)
	end)

end

function StoreGui:IsVisible()
	return ui.StoreFrame.Visible
end

function StoreGui:Toggle(enable:boolean)
	if(enable ~= nil) then
		enable = (enable)
	else
		enable = (not ui.StoreFrame.Visible)
	end
	--print("Open Screen Called ", enable)
	ui.StoreFrame.Visible = enable
end


return StoreGui