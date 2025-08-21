-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local MPS = game:GetService("MarketplaceService")
local StarterGui = game:GetService("StarterGui")

local Knit = require(RS.Packages.Knit)

local player = game.Players.LocalPlayer
local Controls = require(player:WaitForChild("PlayerScripts").PlayerModule):GetControls()

local CustomModules = RS.Modules.Custom
local CT = require(CustomModules.CustomTypes)
local CF = require(CustomModules.CommonFunctions)
local Constants = require(CustomModules.Constants)

---------> Helper references
local HelperF = script.Parent.Parent.Parent.Helpers

---------> Other scripts


local PlayerController = Knit.CreateController {
	Name = "PlayerController",
}

-------------------------------->>>>>>>>>  <<<<<<<<<<-------------------------------
local function init()
	require(HelperF.DamageIndication):BindToAllNPCs()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
	end)
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)
end

function refreshInventory()
	local playerInventories = {}
	local function isPlayerOwnAsset(AssetId)
		local success, doesPlayerOwnAsset = pcall(MPS.PlayerOwnsAsset, MPS, player, AssetId)
		if not success then
			local errorMessage = doesPlayerOwnAsset
			warn(`Error checking if {player.Name} owns {AssetId}: {errorMessage}`)
			return
		end
		return doesPlayerOwnAsset
	end
	
	local function sync(Items :{[string]: CT.ItemDataType})
		for _, v in pairs(Items) do
			
			local plrData = _G.PlayerData
			if not CF.PlayerData.DoesPlayerHaveItem(plrData, v) then
				
				if v.ProductId == 0 then continue end
				
				if isPlayerOwnAsset(v.ProductId) then
					table.insert(playerInventories, v)
				end
			end
		end
	end

	sync(Constants.GameInventory.Styling.Hair)
	sync(Constants.GameInventory.Styling.Pant)
	sync(Constants.GameInventory.Styling.Jersey)

	if #playerInventories > 0 then
		local mydata = _G.PlayerData
		for _, outfitData in pairs(playerInventories) do
			CF.PlayerData.UpdateInventory(mydata, outfitData, "MarketPlace")
		end
		_G.PlayerDataStore:UpdateData(mydata)
	end
end

--# Roblox's default controls
function PlayerController:ToggleControls(enable:boolean)
	--print("Player Controls ", enable)
	if(enable) then
		Controls:Enable()
	else
		Controls:Disable()
	end
end

function PlayerController:KnitInit()
	task.delay(4, refreshInventory)
end

function PlayerController:KnitStart()
	
	init()
	self:ToggleControls(false)
	
end

return PlayerController