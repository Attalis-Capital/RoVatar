-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")

local CD = require(RS.Modules.Custom.Constants)
local CT = require(RS.Modules.Custom.CustomTypes)

local PlayerQuestData = require(RS.Modules.Custom.CommonFunctions.Utils.Player.PlayerQuestData)
local Tables = require(RS.Modules.Custom.CommonFunctions.Utils.Tables)
local Transform = require(RS.Modules.Custom.CommonFunctions.Utils.Transform)
local PlayerData

PlayerData = {
	GetDefaultStylings = function()
		local stylings = {
			Hair = {Id = CD.GameInventory.Styling.Hair.Hair_00.Id},
			Pant = {Id = CD.GameInventory.Styling.Pant.Pant_00.Id},
			Jersey = {Id = CD.GameInventory.Styling.Jersey.Jersey_00.Id},

			Eye = {Id = CD.GameInventory.Styling.Eye.Eye_01.Id},
			Skin = {Id = CD.GameInventory.Styling.Skin.Skin_01.Id},
			Extra = {Id = CD.GameInventory.Styling.Extra.Extra_00.Id},
			Mouth = {Id = CD.GameInventory.Styling.Mouth.Mouth_01.Id},
			Eyebrows = {Id = CD.GameInventory.Styling.Eyebrows.Eyebrow_01.Id},
		}
		return stylings
	end,
	
	GetUserThumbnail = function(userId:number, typ:Enum.ThumbnailType?, size:Enum.ThumbnailSize?)
		if tonumber(userId) <= 0 then
			return "rbxasset://textures/ui/GuiImagePlaceholder.png"
		else
			return game.Players:GetUserThumbnailAsync(userId, typ or Enum.ThumbnailType.HeadShot, size or Enum.ThumbnailSize.Size180x180)
		end
	end,
	
	GetSlotDataModel = function()
		local slotData : CT.ProfileSlotDataType = {}
		slotData.SlotId = nil
		slotData.SlotName = ''

		slotData.LastUpdatedOn = workspace.ServerTime.Value --workspace:GetServerTimeNow()
		slotData.CreatedOn = workspace.ServerTime.Value -- workspace:GetServerTimeNow()

		slotData.CharacterId = CD.CharacterTypes.Aang
		slotData.LastVisitedCF = Transform.WrapObject(CFrame.new())
		slotData.LastVisitedMap = CD.GameInventory.Maps.KioshiIsland.Id

		slotData.XP = 0
		slotData.TotalXP = 0
		slotData.PlayerLevel = 1

		slotData.Gold = 0
		slotData.Gems = 0

		slotData.Data = {}
		slotData.Data.Settings = {
			SFX = true,
			Music = true,
			UI = true,
			Shadow = true,
		}

		slotData.Data.EquippedInventory = {}
		slotData.Data.EquippedInventory.Maps = {[CD.GameInventory.Maps.KioshiIsland.Id] = true}
		slotData.Data.EquippedInventory.Abilities = {}
		slotData.Data.EquippedInventory.Transports = {}
		slotData.Data.EquippedInventory.Characters = {}
		slotData.Data.EquippedInventory.Styling = {}
		slotData.Data.EquippedInventory.Pets = {}
		slotData.Data.EquippedInventory.Weapons = {}


		local stylings = PlayerData.GetDefaultStylings()

		slotData.Data.EquippedInventory.Styling.Eye = stylings.Eye
		slotData.Data.EquippedInventory.Styling.Hair = stylings.Hair
		slotData.Data.EquippedInventory.Styling.Pant = stylings.Pant
		slotData.Data.EquippedInventory.Styling.Skin = stylings.Skin
		slotData.Data.EquippedInventory.Styling.Extra = stylings.Extra
		slotData.Data.EquippedInventory.Styling.Mouth = stylings.Mouth
		slotData.Data.EquippedInventory.Styling.Jersey = stylings.Jersey
		slotData.Data.EquippedInventory.Styling.Eyebrows = stylings.Eyebrows

		slotData.Data.Quests = {
			LevelQuestData = {},
			DailyQuestData = {},
			NPCQuestData = {},
			TutorialQuestData = {},
			JourneyQuestProgress = 1,
			KataraQuestProgress = 1,
		}

		slotData.Data.CombatStats = {
			StatPoints = 0,
			Energy = 100 ,
			Health = 100,
			Agility = 100 ,
			Defense = 100 ,
			Stamina = 100,
			Strength = 100,
			MaxStamina = 100,
		}

		slotData.Data.PlayerStats = {
			Kills = 0,
			Deaths = 0,
		}

		return slotData
	end,
	
	GetPlayerDataModel = function()
		local playerData : CT.PlayerDataModel = {}

		playerData.LoginData = {}
		playerData.CoupansData = {}
		playerData.GamePurchases = {}
		playerData.OwnedInventory = {}

		playerData.PersonalProfile = {
			DisplayName = "",
			Description = "",
			AvatarURL = "",
			UserId = 0,
		}


		playerData.LoginData.MyDataStoreVersion = PlayerData.GetActiveDataStoreVersion()

		playerData.LoginData.LastLogin = workspace.ServerTime.Value --workspace:GetServerTimeNow()

		playerData.OwnedInventory.Maps = {}
		playerData.OwnedInventory.Transports = {}
		playerData.OwnedInventory.Abilities = {}
		playerData.OwnedInventory.Characters = {}
		playerData.OwnedInventory.Styling = {}

		playerData.OwnedInventory.Styling.Hair = {}
		playerData.OwnedInventory.Styling.Pant = {}
		playerData.OwnedInventory.Styling.Jersey = {}

		playerData.GamePurchases.Subscriptions =  {}
		playerData.GamePurchases.Passes =  {}

		playerData.ActiveProfile = CD.DefaultSlotId
		playerData.AllProfiles = {}

		local slot :CT.ProfileSlotDataType = PlayerData.GetSlotDataModel()
		slot.SlotId = CD.DefaultSlotId
		playerData.AllProfiles[playerData.ActiveProfile] = slot

		return playerData
	end,

	GetActiveDataStoreVersion = function()
		return CD.DataStoreVersions[#CD.DataStoreVersions]
	end,

	SetupProfile = function(plr: Player, plrData:CT.PlayerDataModel)
		warn("[SetupProfile] called for player:", plr)

		plrData.PersonalProfile.UserId = plr.UserId

		plrData.PersonalProfile.DisplayName = plr.Name

		plrData.PersonalProfile.AvatarURL = game.Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size100x100)
	end,

	CreateNewSlot = function(plrData : CT.PlayerDataModel, slotName:string?)
		warn("[CreateNewSlot] called for player:", plrData)

		local nProfile = Tables:TableLength(plrData.AllProfiles)

		--Creating new Slot
		local slotData :CT.ProfileSlotDataType = PlayerData.GetSlotDataModel()
		slotData.CreatedOn = workspace.ServerTime.Value --workspace:GetServerTimeNow()
		slotData.LastUpdatedOn = workspace.ServerTime.Value --workspace:GetServerTimeNow()
		slotData.SlotId = "Slot_"..os.time()
		slotData.SlotName = slotName or "GameSave"..(nProfile + 1)

		slotData.CharacterId = CD.CharacterTypes.Aang
		slotData.LastVisitedCF = Transform.WrapObject(CFrame.new())
		slotData.LastVisitedMap = CD.GameInventory.Maps.KioshiIsland.Id

		--Set back to player's profile
		plrData.ActiveProfile = slotData.SlotId
		plrData.AllProfiles[slotData.SlotId] = slotData
		warn("[CreateNewProfile] After profile added:", plrData)
	end,
	
	CheckAndUpdatePlayerData = function(playerData:CT.PlayerDataModel)
		local newDataModel = PlayerData.GetPlayerDataModel()

		local currentVersion = PlayerData.GetActiveDataStoreVersion().GameDataStoreVersion
		local plrStoreVersion = (typeof(playerData.LoginData.MyDataStoreVersion) == "number") and playerData.LoginData.MyDataStoreVersion or playerData.LoginData.MyDataStoreVersion.GameDataStoreVersion

		if(plrStoreVersion) then
			if (plrStoreVersion == 1 and currentVersion == 1.1) then
				local DataModels = require(script.Parent.DataModels)
				return DataModels:UpdateData1To1Dot1(playerData, newDataModel, PlayerData.GetSlotDataModel())

			elseif (plrStoreVersion < 1) then
				playerData = newDataModel
				return playerData
			end
		end

		local function CopyTable(t)
			assert(type(t) == "table", "First argument must be a table")
			local tCopy = table.create(#t)
			for k,v in pairs(t) do
				if (type(v) == "table") then
					tCopy[k] = CopyTable(v)
				else
					tCopy[k] = v
				end
			end
			return tCopy
		end

		local function Sync(tbl, templateTbl)
			assert(type(tbl) == "table", "First argument must be a table")
			assert(type(templateTbl) == "table", "Second argument must be a table")

			--if existing key's type changed to `table` then assign same to tbl.
			for k,v in pairs(tbl) do
				local vTemplate = templateTbl[k]

				if (type(v) ~= type(vTemplate)) then
					if (type(vTemplate) == "table") then
						tbl[k] = CopyTable(vTemplate)
					end

					-- Synchronize sub-tables:
				elseif (type(v) == "table") then
					Sync(v, vTemplate)
				end
			end


			-- Add any missing keys:
			for k,vTemplate in pairs(templateTbl) do

				local v = tbl[k]

				if (v == nil) then
					if (type(vTemplate) == "table") then
						tbl[k] = CopyTable(vTemplate)
					else
						tbl[k] = vTemplate
						warn("Added new key in playerData:", k, vTemplate)
					end
				end

				if(typeof(vTemplate) ~= typeof(v)) then
					--print("Type not same. Key:",k)
					tbl[k] = vTemplate
				end
			end

		end

		local function remove(mainTbl, tmpTbl)
			for k, v in pairs(mainTbl) do
				local keyFound = false
				for kk, vv in pairs(tmpTbl) do
					if(kk == k) then
						keyFound = true
					end
				end

				--Remove the key if NOT found
				if(keyFound == false) then
					--print("Key not found in new tmp table.")
					--print("[Key]",k)
					mainTbl[k] = nil
				else
					if(typeof(v) == "table" and typeof(tmpTbl[k] == "table")) then
						remove(v, tmpTbl[k])
					end
				end
			end
		end

		Sync(playerData, newDataModel)
		--Special sync for slot profiles (because there are generate at runtime)
		for key, val in pairs(playerData.AllProfiles) do
			print("Syncing dynamic profile slot of profile", key, val)
			Sync(val, newDataModel.AllProfiles[newDataModel.ActiveProfile])
		end

		return playerData
	end,
	
	ValidateSlotName = function(data:{[string] : CT.ProfileSlotDataType}, slotName:string, id)
		--print("[Debug New Slot] Validate Slot Name ", data, slotName)

		if(slotName == "") then
			return false, "Cannot be empty"
		end

		local minLength = 4
		local maxLength = game.ReplicatedStorage.GameElements.Configs.MaxSlotNameLength.Value

		local length = slotName:len() 
		if(length < minLength) then
			return false, `Name too short (min {minLength} letters)`
		end

		if(length > maxLength) then
			return false, `Name too long (max {maxLength} letters)`
		end

		for key, slot in pairs(data) do
			--print("[Debug New Slot] Slots ", slot, slot.SlotName, slotName, slot.SlotName == slotName)
			if(slot.SlotName == slotName) and slot.SlotId ~= id then
				warn("SlotName already used")
				return false , "Slot Name already used"
			end

			local prohebitedNames = {"GameSlot", ""}
			if(table.find(prohebitedNames, slotName)) then
				warn("Prohibited name cannot be used")
				return false
			end

			local reservedNames = {"GameSlot", }
			if(table.find(reservedNames, slotName)) then
				warn("ReservedNames name cannot be used")
				return false
			end
		end

		return true
	end,


	---------- Get Calls 
	GetLevelData = function(level)
		for i, levelData in pairs(CD.GameLevelsData) do
			if(level >= levelData.MinLevel and level <= levelData.MaxLevel) then
				return levelData
			end
		end
		return nil
	end,

	RandomizeNPCAppearance = function(_npc :Model)
		local function getRandomizeTexture(_type)
			local items = CD.GameInventory.Styling[_type]

			local item = Tables.RandomValue(items)
			return item.Image
		end

		local function remove(_parent, _type)
			for _, child in ipairs(_parent:GetChildren()) do
				if child:IsA("Decal") then
					local hasAttributes = next(child:GetAttributes()) ~= nil
					if (_type and child:GetAttribute("Type") == _type) or (not _type and not hasAttributes) then
						child:Destroy()
					end
				end
			end
		end

		local function applyTexture(_parent, _type)
			local Decal = Instance.new("Decal", _parent)
			Decal.Texture = getRandomizeTexture(_type)
			Decal:SetAttribute("Type", _type)
		end

		local head = _npc:WaitForChild("Head")
		local leftHand = _npc.LeftHand
		local rightHand = _npc.RightHand

		local function applyColor()
			local skinColors = {
				"255, 224, 189",  -- Fair skin (Peach)
				"255, 219, 172",  -- Light skin (Warm Ivory)
				"250, 210, 161",  -- Fair with warm undertone
				"245, 205, 156",  -- Beige
				"240, 194, 136",  -- Light tan
				"225, 184, 132",  -- Golden tan
				"216, 175, 127",  -- Medium tan
				"202, 157, 106",  -- Caramel
				"190, 140, 95",   -- Warm honey
				"179, 125, 81",   -- Deep tan
				"166, 111, 74",   -- Light brown
				"153, 97, 64",    -- Medium brown
				"140, 85, 56",    -- Deep brown
				"128, 72, 49",    -- Chocolate brown
				"116, 63, 42",    -- Dark caramel
				"105, 55, 36",    -- Deep cocoa
				"94, 48, 30",     -- Warm espresso
				"83, 42, 26",     -- Dark espresso
				"73, 37, 23",     -- Ebony
				"63, 32, 20"      -- Deep ebony
			}

			local RNG = Random.new()
			local index = math.floor(RNG:NextNumber(1, #skinColors))
			local randomSkinColor = skinColors[index]
			local colorCont = string.split(randomSkinColor, ", ")
			local color = Color3.fromRGB(table.unpack(colorCont))

			head.Color = color
			leftHand.Color = color
			rightHand.Color = color

			if not leftHand:FindFirstChildOfClass("SurfaceAppearance") then
				Instance.new('SurfaceAppearance', leftHand)
			end

			if not rightHand:FindFirstChildOfClass("SurfaceAppearance") then
				Instance.new('SurfaceAppearance', rightHand)
			end
		end

		remove(head)

		applyTexture(head, CD.ItemType.Eye)
		applyTexture(head, CD.ItemType.Eyebrows)
		applyTexture(head, CD.ItemType.Mouth)

		applyColor()
	end,

	--.DataPaths should be table. --> The number of paths and value
	UpdateActiveProfile = function(playerData: CT.PlayerDataModel, DataPaths: table)
		--print("playerDataACTIVe", playerData.ActiveProfile)
		local IsUpdated = false

		for FullPath, Value in pairs(DataPaths) do
			--print("playerDataACTIVe Fulll Path", FullPath)
			local SPath = FullPath:split(".")

			local ReF = playerData.AllProfiles[playerData.ActiveProfile]
			--local ReF2 = playerData.ActiveProfile

			for i, Key in ipairs(SPath) do
				if i == #SPath then
					ReF[Key] = Value
					--ReF2[Key] = Value
				else
					if ReF[Key] == nil then
						ReF[Key] = {}
					end
					--if ReF2[Key] == nil then
					--	ReF2[Key] = {}
					--end

					ReF = ReF[Key]
					--ReF2 = ReF2[Key]
				end

			end

			IsUpdated = true
		end

		if IsUpdated then
			playerData.AllProfiles[playerData.ActiveProfile].LastUpdatedOn = workspace.ServerTime.Value --workspace:GetServerTimeNow()
		end
	end,

	DoesPlayerHaveAbility = function(playerData: CT.PlayerDataModel, abilityId)
		return PlayerQuestData.GetPlayerActiveProfile(playerData).Data.EquippedInventory.Abilities[abilityId]
	end,

	EquipItem = function(_profileData :CT.ProfileSlotDataType, _itemData :CT.ItemDataType, _equip :boolean)
		if _profileData.Data.EquippedInventory[_itemData.InventoryType] then
			if _itemData.InventoryType == CD.InventoryType.Styling then
				if _equip then
					_profileData.Data.EquippedInventory[_itemData.InventoryType][_itemData.ItemType] = {Id = _itemData.Id}
				else
					if PlayerData.DoesPlayerEquipItem(_profileData, _itemData) then
						_profileData.Data.EquippedInventory[_itemData.InventoryType][_itemData.ItemType] = {Id = PlayerData.GetDefaultStylings()[_itemData.ItemType].Id}
					end
				end
			else
				if _equip then
					_profileData.Data.EquippedInventory[_itemData.InventoryType] = {Id = _itemData.Id}
				else
					if PlayerData.DoesPlayerEquipItem(_profileData, _itemData) then
						_profileData.Data.EquippedInventory[_itemData.InventoryType] = {}
					end
				end
			end
		end
	end,

	DoesPlayerEquipItem = function(_profileData: CT.ProfileSlotDataType, _itemData: CT.ItemDataType)
		local equippedInventory = _profileData.Data.EquippedInventory[_itemData.InventoryType]

		if not equippedInventory then
			return false
		end

		if _itemData.InventoryType == CD.InventoryType.Styling then
			local item = equippedInventory[_itemData.ItemType]
			return item and item.Id == _itemData.Id, item and item.Id or false
		end

		return equippedInventory.Id == _itemData.Id
	end,

	DoesPlayerHaveItem = function(_playerData: CT.PlayerDataModel, _itemData : CT.ItemDataType)
		if _playerData.OwnedInventory[_itemData.InventoryType] then
			if _playerData.OwnedInventory[_itemData.InventoryType][_itemData.ItemType] then
				return _playerData.OwnedInventory[_itemData.InventoryType][_itemData.ItemType][_itemData.Id]
			else
				return nil
			end
		end
	end,

	UpdateItem = function(storeObject, itemToAdd, add: any)
		if(storeObject[itemToAdd.Id]) then
			warn("Item already exists in the player's Data table:", itemToAdd)
			if(not add) then
				storeObject[itemToAdd.Id] = nil
			end
			return
		end
		if(add) then
			storeObject[itemToAdd.Id] = add
			--print("Item added to player's Data:", itemToAdd.Name)
		else
			storeObject[itemToAdd.Id] = nil
		end
	end,

	UpdateInventory = function(playerData: CT.PlayerDataModel, ItemData : CT.ItemDataType, Add)
		if(ItemData.ProductType) then
			if(ItemData.ProductType == Enum.InfoType.GamePass) then
				PlayerData.UpdatePassesData(playerData, ItemData.Id, Add)
			elseif(ItemData.ProductType == Enum.InfoType.Subscription) then
				PlayerData.UpdateSubscription(playerData, ItemData.Id, Add)
			end
		end

		--Update general/common inventory
		if playerData.OwnedInventory[ItemData.InventoryType] then
			if ItemData.InventoryType == CD.InventoryType.Styling then
				PlayerData.UpdateItem(playerData.OwnedInventory[ItemData.InventoryType][ItemData.ItemType], ItemData, Add)
			else
				PlayerData.UpdateItem(playerData.OwnedInventory[ItemData.InventoryType], ItemData, Add)
			end
		end

		--Update active profile inventory
		local activeProfile :CT.ProfileSlotDataType = PlayerQuestData.GetPlayerActiveProfile(playerData)
		if(activeProfile.Data.EquippedInventory[ItemData.InventoryType]) then
			if ItemData.InventoryType == CD.InventoryType.Styling then
				PlayerData.UpdateItem(activeProfile.Data.EquippedInventory[ItemData.InventoryType][ItemData.ItemType], ItemData, Add)
			elseif(ItemData.ProductType ~= Enum.InfoType.GamePass) then
				PlayerData.UpdateItem(activeProfile.Data.EquippedInventory[ItemData.InventoryType], ItemData, Add)
			end

			--restore updated data into playerData
			playerData.AllProfiles[playerData.ActiveProfile] = activeProfile
		end
	end,

	UpdateProfileInventory = function(playerData: CT.PlayerDataModel, ItemData : CT.ItemDataType, Add)
		--Update active profile inventory
		local activeProfile :CT.ProfileSlotDataType = PlayerQuestData.GetPlayerActiveProfile(playerData)
		if(activeProfile.Data.EquippedInventory[ItemData.InventoryType]) then
			if ItemData.InventoryType == CD.InventoryType.Styling then
				PlayerData.UpdateItem(activeProfile.Data.EquippedInventory[ItemData.InventoryType][ItemData.ItemType], ItemData, Add)
			else
				PlayerData.UpdateItem(activeProfile.Data.EquippedInventory[ItemData.InventoryType], ItemData, Add)
			end

			--restore updated data into playerData
			playerData.AllProfiles[playerData.ActiveProfile] = activeProfile
		end
	end,
	
	UpdateGoldInPlayerData = function(playerData:CT.PlayerDataModel, goldToUpdate:number)
		--print("[Updating Gold ] : ",playerData, goldToUpdate)
		local activeProfile :CT.ProfileSlotDataType = PlayerQuestData.GetPlayerActiveProfile(playerData)

		activeProfile.Gold += goldToUpdate
		activeProfile.Gold = math.max(0, activeProfile.Gold)

		playerData.AllProfiles[playerData.ActiveProfile] = activeProfile
	end,
	
	UpateGemsInPlayerData = function(playerData:CT.PlayerDataModel, gemsToUpdate:number)
		--print("[Updating Gems ] : ",playerData, gemsToUpdate)
		local activeProfile :CT.ProfileSlotDataType = PlayerQuestData.GetPlayerActiveProfile(playerData)

		activeProfile.Gems += gemsToUpdate
		activeProfile.Gems = math.max(0, activeProfile.Gems)

		playerData.AllProfiles[playerData.ActiveProfile] = activeProfile
	end,

	UpdatePlayerLevelData = function(playerData:CT.PlayerDataModel, levelToAdd:IntValue)

		playerData.AllProfiles[playerData.ActiveProfile].PlayerLevel += levelToAdd

		--PlayerData.UpdateXpInPlayerData(playerData, 0)
	end,

	UpdateXpInPlayerData = function(playerData:CT.PlayerDataModel, xpToAdd:IntValue)
		local activeProfile :CT.ProfileSlotDataType = PlayerQuestData.GetPlayerActiveProfile(playerData)
		warn("Player XP to increase by:",xpToAdd," Now:", activeProfile.XP)
		local plrLevel = activeProfile.PlayerLevel

		-- Increase player-Profile wise level
		do
			local lvlData :CT.GameLevelData = CD.GameLevelsData[plrLevel]

			--print("leveldata:", lvlData)
			if lvlData and lvlData ~= {} then
				local targetXp = lvlData.XpRequired

				activeProfile.XP += xpToAdd
				activeProfile.TotalXP += xpToAdd

				if(activeProfile.XP >= targetXp) then
					local extraXp = activeProfile.XP - targetXp

					activeProfile.XP = extraXp

					--restore data in playerData
					activeProfile.LastUpdatedOn = workspace.ServerTime.Value
					playerData.AllProfiles[playerData.ActiveProfile] = activeProfile

					local nxtLvlData = CD.GameLevelsData[plrLevel + 1]
					if(nxtLvlData) then
						PlayerData.UpdatePlayerLevelData(playerData, 1)
						PlayerData.GiveLevelUpReward(playerData)
					end

					PlayerData.UpdateXpInPlayerData(playerData, 0) --Refreshing xp and lvl data to check and update.
				end
			end
		end


		return playerData
	end,
	
	UpdateSubscription = function(playerData: CT.PlayerDataModel, SubscriptionId, add)
		--if playerData.GamePurchases.Subscriptions[SubscriptionId] then
		playerData.GamePurchases.Subscriptions[SubscriptionId] = add
		--end
	end,

	UpdatePassesData = function(playerData: CT.PlayerDataModel, PassId, add)
		--if playerData.GamePurchases.Passes[PassId] then
		playerData.GamePurchases.Passes[PassId] = add
		--end
	end,

	GiveLevelUpReward = function(playerData:CT.PlayerDataModel, plrLevel)
		local activeProfile :CT.ProfileSlotDataType = PlayerQuestData.GetPlayerActiveProfile(playerData)
		if not plrLevel then
			plrLevel = activeProfile.PlayerLevel
		end

		--VFXHandler:PlayEffect(nil, CD.VFXs.LevelUp, plrLevel)

		local RewardData :CT.GameLevelData = CD.GameLevelsData[plrLevel]

		if RewardData then
			if RewardData.Reward.Type == CD.LevelUpRewardType.Gold then
				PlayerData.UpdateGoldInPlayerData(playerData, RewardData.Reward.Amount)
			elseif RewardData.Reward.Type == CD.LevelUpRewardType.Gems then
				PlayerData.UpateGemsInPlayerData(playerData, RewardData.Reward.Amount)
			elseif RewardData.Reward.Type == CD.LevelUpRewardType.XP then
				PlayerData.UpdateXpInPlayerData(playerData, RewardData.Reward.Amount)
			end
		end
	end,
	
	
	ClaimQuestReward = function(QData, plrData:CT.PlayerDataModel)
		local plrQuestData :CT.AllQuestsType = PlayerQuestData.GetPlrActiveQuests(plrData)

		---- Update Quest Data
		local QuestData :CT.QuestDataType = {}

		if QData.Type == CD.QuestType.DailyQuest then
			if plrQuestData.DailyQuestData.Id == QData.Id then
				plrQuestData.DailyQuestData.IsClaimed = true

				QuestData = plrQuestData.DailyQuestData

			else
				--Karna: Notification ("Something wrong!")
				warn("[Error] [Quest] Quest can't claim, Id Mismatched!")
				return false
			end
		elseif QData.Type == CD.QuestType.NPCQuest then
			plrQuestData.NPCQuestData.IsClaimed = true

			QuestData = plrQuestData.NPCQuestData

			plrQuestData.NPCQuestData = {}
		elseif QData.Type == CD.QuestType.LevelQuest then
			if plrQuestData.LevelQuestData.Objective == QData.Objective then
				plrQuestData.LevelQuestData.IsClaimed = true

				QuestData = plrQuestData.LevelQuestData

				--plrQuestData.LevelQuestData.CompletedQuests[QuestData] = QuestData
				plrQuestData.LevelQuestData = {}
			else
				--Karna: Notification ("Something wrong!")
				warn("[Error] [Quest] Quest can't claim, Id Mismatched!")
				return false
			end
		end

		--Update completion count for sequence-wise quests
		if QData.Objective == CD.QuestObjectives.Combined then
			if(not plrQuestData.JourneyQuestProgress) then --Give default value if not present
				plrQuestData.JourneyQuestProgress = 1 
			end
			plrQuestData.JourneyQuestProgress += 1	
		elseif(QData.Objective == CD.QuestObjectives.Train) then
			if(not plrQuestData.KataraQuestProgress) then --Give default value if not present
				plrQuestData.KataraQuestProgress = 1 
			end
			plrQuestData.KataraQuestProgress += 1

			--Special check for BreathTheSurface (Objective : Find, Train roola)	
		elseif(QData.Id == "BreathTheSurface") then
			if(not plrQuestData.KataraQuestProgress) then --Give default value if not present
				plrQuestData.KataraQuestProgress = 1 
			end
			plrQuestData.KataraQuestProgress += 1

		end

		---- Claiming Rewards 
		local Rewards = QuestData.Reward

		for _, rewardData :CT.QuestsRewardDataType in pairs(Rewards) do
			if rewardData.Type == CD.QuestRewardType.XP then
				-- Karna: Level Upgrade Check 
				PlayerData.UpdateXpInPlayerData(plrData, rewardData.Value)
			elseif rewardData.Type == CD.QuestRewardType.Gold then
				PlayerData.UpdateGoldInPlayerData(plrData, rewardData.Value)
			elseif rewardData.Type == CD.QuestRewardType.Gems then
				PlayerData.UpateGemsInPlayerData(plrData, rewardData.Value)
			else
				if rewardData.Type == CD.QuestRewardType.LevelUp then
					local activeProfile :CT.ProfileSlotDataType = PlayerQuestData.GetPlayerActiveProfile(plrData)
					local plrLevel = activeProfile.PlayerLevel

					-- Increase player-Profile wise level
					do
						local lvlData :CT.GameLevelData = CD.GameLevelsData[plrLevel]

						--print("leveldata:", lvlData)
						if lvlData and lvlData ~= {} then
							local targetXp = lvlData.XpRequired

							PlayerData.UpdateXpInPlayerData(plrData, targetXp)
						end
					end
				end
			end
		end

		return true
	end,
}

return PlayerData
