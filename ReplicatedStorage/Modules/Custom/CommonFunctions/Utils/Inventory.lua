-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")

local CD = require(RS.Modules.Custom.Constants)
local CT = require(RS.Modules.Custom.CustomTypes)

local Inventory

Inventory = {
	ApplyInventory = function(_character :Model, _itemData:CT.ItemDataType, _apply:boolean?)
		local function clear(__parent, __type)
			for _, child in pairs(__parent:GetChildren()) do
				local typee = child:GetAttribute("Type")
				if typee and typee == __type then
					child:Destroy()
				end
			end
		end

		local humanoid = _character:WaitForChild("Humanoid", 15)
		if not humanoid then
			return
		end

		local HumanoidDescription = humanoid:GetAppliedDescription()
		if not HumanoidDescription then
			return
		end

		if(_itemData.ItemType == CD.ItemType.Eye) 
			or(_itemData.ItemType == CD.ItemType.Mouth) 
			or(_itemData.ItemType == CD.ItemType.Eyebrows)
			or(_itemData.ItemType == CD.ItemType.Extra) then

			clear(_character.Head, _itemData.ItemType)

			if _apply then
				local decal = Instance.new("Decal", _character.Head)
				decal:SetAttribute("Type", _itemData.ItemType)
				decal.Texture = _itemData.Image
			end
		elseif(_itemData.ItemType == CD.ItemType.Skin) then

			local color = Color3.fromRGB(255, 224, 189)
			if _apply then
				if typeof(_itemData.Color) == "Color3" then
					color = _itemData.Color
				else
					local colorCont = string.split(_itemData.Color, ", ")
					color = Color3.fromRGB(table.unpack(colorCont))
				end
			end

			HumanoidDescription.HeadColor = color
			HumanoidDescription.LeftArmColor = color	
			--HumanoidDescription.LeftLegColor = color	
			HumanoidDescription.RightArmColor = color	
			--HumanoidDescription.RightLegColor = color	
			--HumanoidDescription.TorsoColor = color

			humanoid:ApplyDescription(HumanoidDescription)

		elseif(_itemData.ItemType == CD.ItemType.Hair) then
			-- Hair

			HumanoidDescription.HairAccessory = _itemData.ProductId
			local s, r = pcall(function()
				return humanoid:ApplyDescription(HumanoidDescription)
			end)
			--print("ApplyDescription :", s, r)

		elseif _itemData.ItemType == CD.ItemType.Jersey or _itemData.ItemType == CD.ItemType.Pant then
			local defaultIds = {
				[CD.ItemType.Jersey] = 1,--7123903816,
				[CD.ItemType.Pant] = 1,--12176104895
			}

			local id = _apply and _itemData.ProductId or defaultIds[_itemData.ItemType]

			clear(_character, _itemData.ItemType)
			local humanoid = _character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				local desc = humanoid:GetAppliedDescription()
				--print("Jersey Add ", desc, _itemData, _itemData.ItemType)
				if _itemData.ItemType == CD.ItemType.Jersey then
					if desc.Shirt ~= id then
						desc.Shirt = id
					end
				elseif _itemData.ItemType == CD.ItemType.Pant then
					if desc.Pants ~= id then
						desc.Pants = id
					end
				end
				humanoid:ApplyDescription(desc)
			end
		end
	end,
	ApplyFullInventory = function(_character, _profileSlotData :CT.ProfileSlotDataType)
		local hairData = CD.GameInventory.Styling.Hair[_profileSlotData.Data.EquippedInventory.Styling.Hair.Id]

		local EyeData = CD.GameInventory.Styling.Eye[_profileSlotData.Data.EquippedInventory.Styling.Eye.Id]
		local PantData = CD.GameInventory.Styling.Pant[_profileSlotData.Data.EquippedInventory.Styling.Pant.Id]
		local SkinData = CD.GameInventory.Styling.Skin[_profileSlotData.Data.EquippedInventory.Styling.Skin.Id]
		local MouthData = CD.GameInventory.Styling.Mouth[_profileSlotData.Data.EquippedInventory.Styling.Mouth.Id]
		local ExtraData = CD.GameInventory.Styling.Extra[_profileSlotData.Data.EquippedInventory.Styling.Extra.Id]
		local JerseyData = CD.GameInventory.Styling.Jersey[_profileSlotData.Data.EquippedInventory.Styling.Jersey.Id]
		local EyebrowsData = CD.GameInventory.Styling.Eyebrows[_profileSlotData.Data.EquippedInventory.Styling.Eyebrows.Id]

		print("[[Inventory]] _character is :", _character)
		task.delay(.1 ,function()
			Inventory.ApplyInventory(_character, hairData, true)
			Inventory.ApplyInventory(_character, PantData, true)
			Inventory.ApplyInventory(_character, SkinData, true)
			Inventory.ApplyInventory(_character, JerseyData, true)

			Inventory.ApplyInventory(_character, EyeData, true)
			Inventory.ApplyInventory(_character, MouthData, true)
			Inventory.ApplyInventory(_character, ExtraData, true)
			Inventory.ApplyInventory(_character, EyebrowsData, true)
		end)
	end,
}

return Inventory