-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")

local knit = require(RS.Packages.Knit)
local Signal = require(RS.Packages.Signal)

local Custom = RS.Modules.Custom
local CD = require(Custom.Constants)
local CT = require(Custom.CustomTypes)
local SFXHandler = require(Custom.SFXHandler)

local player = game.Players.LocalPlayer

-------> Other Scripts Ref
local IAPService
local UIController


local IAPController = knit.CreateController {
	Name = "IAPController",
	inProcessPurchases = {},
	onPurchaseCompleted = Signal.new(),
	onPurchaseClosed = Signal.new(),
}

local ActivePurchase :CT.ItemDataType = nil
-------------------------------------------------------------->  Private Methods  <------------------------------------------------------

-------->>>Server Callback
function OnPurchaseCompleted(_itemData :CT.ItemDataType)
	warn("[123][IAPController] Received PurchaseCompleted:", _itemData)
	if _itemData.Id then
		--SFXHandler:Play(CD.SFXs.IAP_Purchase, true)
		warn("[123] Fired ",_itemData)
		SFXHandler:Play(CD.SFXs.Purchased_Success, true)
		IAPController.onPurchaseCompleted:Fire(_itemData)
	end
end

function OnPromptClosed()
	warn("[IAPController] Received PromptClosed:")
	ActivePurchase = nil
	UIController:ToggleProcessing(false)
	IAPController.onPurchaseClosed:Fire()
end

-------------------------------------------------------------->  Public Methods  <-------------------------------------------------------

function IAPController:PurchaseItem(_itemData:CT.ItemDataType)
	--print("[IAPController] Sending purchase product request.",_itemData.Id)

	if(ActivePurchase) then
		
		warn("[IAPController] Item already in progress...", _itemData)
		SFXHandler:Play(CD.SFXs.Purchased_Error, true)
		return
	else
		
		if _G.LiveDevMode and _G.LiveDevMode:Get() then
			-- Admin Developer 
			OnPurchaseCompleted(_itemData)
			return
		end
		
		ActivePurchase = _itemData
		UIController:ToggleProcessing(true)
		IAPService:PurchaseItem(_itemData)
	end
end


function IAPController:GetProductInfo(productId :number, pType:string)
	--print("Sending purchase product request:", productId)
	local succ, dat = IAPService:GetProductInfo(productId, pType):await()
	if(succ) then
		return dat
	else
		return nil
	end
end


function IAPController:KnitInit()
	
end

function IAPController:KnitStart()
	
	IAPService = knit.GetService("IAPService")
	UIController = knit.GetController("UIController")
	
	IAPService.OnPurchaseCompleted:Connect(OnPurchaseCompleted)
	IAPService.OnPromptClosed:Connect(OnPromptClosed)
	
end

return IAPController