-- @ScriptType: ModuleScript
local Constants = {}

local Costs = require(script.Parent.Costs)

------================>>>>>>>>>>>>>>>>>>>>>>....... General ........<<<<<<<<<<<<<<<<<<<<<=================------
Constants.MeditateStates = {
	Meditate = "Meditate",
	Idle = "Idle",
}
table.freeze(Constants.MeditateStates)

Constants.MoveStates = {
	Walk = "Walk",
	Idle = "Idle",
	Running = "Running",
}
table.freeze(Constants.MoveStates)

Constants.ActionStates = {
	Blocking = "Blocking",
	Attacking = "Attacking",
	Defending = "Defending",
}
table.freeze(Constants.ActionStates)

Constants.AttackingStates = {
	Air = "Air",
	Fist = "Fist",
	Fire = "Fire",
	Earth = "Earth",
	Water = "Water",
}
table.freeze(Constants.AttackingStates)

Constants.StateTypes = {
	--Attack = "Attack",
	Move = "Move",
	--Action = "Action",
	Meditate = "Meditate"
}
table.freeze(Constants.StateTypes)

Constants.Places = {
	Tutorial = {
		Name = "Tutorial",
		PlaceId = 123946228115495,
	},
	RoVatar = {
		Name = "RoVatar",
		PlaceId = 10467665782,
	}
}
table.freeze(Constants.Places)

------================>>>>>>>>>>>>>>>>>>>>>>........ General ........<<<<<<<<<<<<<<<<<<<<<=================------

------================>>>>>>>>>>>>>>>>>>>>>>.......... NPCs .........<<<<<<<<<<<<<<<<<<<<<=================------
Constants.NPCsType = {
	AirBender = "Wind strider",
	FireBender = "Solar flare",
	WaterBender = "Wave binder",
	EarthBender = "Mountain Guardian",
	FireBender_MiniBoss = "Molten Crag King",
}
table.freeze(Constants.NPCsType)
------================>>>>>>>>>>>>>>>>>>>>>>.......... NPCs .........<<<<<<<<<<<<<<<<<<<<<=================------

------================>>>>>>>>>>>>>>>>>>>>>>........ Vehicles ........<<<<<<<<<<<<<<<<<<<<<=================------

Constants.VehiclesType = {
	AangGlider = "AangGlider",
	KorraGlider = "KorraGlider",
	Appa = "Appa",
}
table.freeze(Constants.VehiclesType)

------================>>>>>>>>>>>>>>>>>>>>>>........ Vehicle ........<<<<<<<<<<<<<<<<<<<<<=================------


--===========================********************** Objects & Elements ******************============================

Constants.Layers = {
	["Default"] = "Default",
	["Player"] = "Player",
}
table.freeze(Constants.Layers)

Constants.Tags = {
	["Team"] = "Team",
	["NPCAI"] = "NPCAI",
	["QuestGuy"] = "QuestGuy",
	["LevelGuider"] = "LevelGuider",
	["PlayerAvatar"] = "PlayerAvatar",
	["TutorialGuider"] = "TutorialGuider",
}
table.freeze(Constants.Tags)

Constants.UiScreenTags = {
	["MapGui"] = "MapGui",
	["DevGui"] = "DevGui",
	["ShopGui"] = "ShopGui",
	["QuestGui"] = "QuestGui",
	["StoreGui"] = "StoreGui",
	["LoadingGui"] = "LoadingGui",
	["GamePassGui"] = "GamePassGui",
	["BackPackGui"] = "BackPackGui",
	["CoolDownGui"] = "CoolDownGui",
	--["LoadSlotGui"] = "LoadSlotGui",
	["LoadGameGui"] = "LoadGameGui",
	["DialogueGui"] = "DialogueGui",
	["MainMenuGui"] = "MainMenuGui",
	["SettingsGui"] = "SettingsGui",
	["PlayerMenuGui"] = "PlayerMenuGui",
	["MapSelectionGui"] = "MapSelectionGui",
	["NotificationGui"] = "NotificationGui",
	["CustomizationUI"] = "CustomizationUI",
	["ControlsGuideGui"] = "ControlsGuideGui",
	["AvatarSelectionGui"] = "AvatarSelectionGui",
	["BendingSelectionGui"] = "BendingSelectionGui",
}
table.freeze(Constants.UiScreenTags)

Constants.NotificationType = {
	Popup = "Popup",
	Notification = "Notification"
}
table.freeze(Constants.NotificationType)
--===========================********************** Objects & Elements ******************============================

--===========================***************************** Tweens ************************============================

Constants.TweenDir = {
	Up = "Up",
	Left = "Left",
	Right = "Right",
	Center = "Center",
	Bottom = "Bottom",
}
table.freeze(Constants.TweenDir)

Constants.EasingStyle = {
	Quad = Enum.EasingStyle.Quad,
	Back = Enum.EasingStyle.Back,
	Sine = Enum.EasingStyle.Sine,
	Quart = Enum.EasingStyle.Quart,
	Cubic = Enum.EasingStyle.Cubic,
	Quint = Enum.EasingStyle.Quint,
	Bounce = Enum.EasingStyle.Bounce,
	Linear = Enum.EasingStyle.Linear,
	Elastic = Enum.EasingStyle.Elastic,
	Circular = Enum.EasingStyle.Circular,
	Exponential = Enum.EasingStyle.Exponential,
}
table.freeze(Constants.EasingStyle)

--===========================***************************** Tweens ************************============================

--===========================****************************** VFX **************************============================

--[[The values must be the same name of childrens of ReplicatedStorage -> Shared -> "VFXHandler"]]
Constants.VFXs = {
	["Fist"] = "Fist",
	["LevelUp"] = "LevelUp",
	["AirKick"] = "AirKick",
	["Boomerang"] = "Boomerang",
	["RewardCoin"] = "RewardCoin",
	["RewardXP"] = "RewardXP",
	["EarthStomp"] = "EarthStomp",
	["Meditation"] = "Meditation",
	["SpawnEffect"] = "SpawnEffect",
	["WaterStance"] = "WaterStance",
	["FireDropKick"] = "FireDropKick",
	["MeteoriteSword"] = "MeteoriteSword",
}
table.freeze(Constants.VFXs)

Constants.CamPresets = {
	["Bump"] =  "Bump",

	-- An intense and rough shake.
	-- Should happen once.
	["Explosion"] =  "Explosion",
	["Dash"] =  "Dash",
	["IceZ"] =  "IceZ",
	["LightningStrike"] =  "LightningStrike",
	["Hit"] =  "Hit",
	["Twerk"] =  "Twerk",

	-- A continuous, rough shake
	-- Sustained.
	["Earthquake"] =  "Earthquake",

	-- A bizarre shake with a very high magnitude and low roughness.
	-- Sustained.
	["BadTrip"] =  "BadTrip",

	-- A subtle, slow shake.
	-- Sustained.
	["HandheldCamera"] =  "HandheldCamera",

	-- A very rough, yet low magnitude shake.
	-- Sustained.
	["Vibration"] =  "Vibration",

	-- A slightly rough, medium magnitude shake.
	-- Sustained.
	["RoughDriving"] =  "RoughDriving",
}
table.freeze(Constants.CamPresets)
--===========================****************************** VFX **************************============================

--===========================************************* Sounds & Music ********************============================

--[[
The constants of all SFX clips. It only refers to the name of SFX clips.
]]

Constants.SoundGroups = {
	UIGroup = "UIGroup", 
	SFXGroup = "SFXGroup",
	MusicGroup = "MusicGroup",
}
table.freeze(Constants.SoundGroups)

Constants.SFXs = {
	--Character
	["Spawn"] = "Spawn",
	["Ragdoll"] = "Ragdoll",
	["Sword_Swing"] = "Sword_Swing",
	["Sheathe"] = "Sheathe",
	["UnSheathe"] = "UnSheathe",
	["Boomerang"] = "Boomerang",

	--Fist
	["Fist_Swing"] = "Fist_Swing",
	["Fist_Parry"] = "Fist_Parry",
	["HeavyPunch1"] = "HeavyPunch1",
	["HeavyPunch2"] = "HeavyPunch2",
	["HeavyPunch3"] = "HeavyPunch3",
	["HeavyPunch4"] = "HeavyPunch4",
	["HeavyPunch5"] = "HeavyPunch5",
	["Punch1"] = "Punch1",
	["Punch2"] = "Punch2",
	["Punch3"] = "Punch3",
	["Punch4"] = "Punch4",
	["Punch5"] = "Punch5",

	--Bendings
	["AirKick_Push"] = "AirKick_Push",

	["EarthStomp_Thrust"] = "EarthStomp_Thrust",

	["FireDropKick_Launch"] = "FireDropKick_Launch",

	["WaterBend_GroundSlam"] = "WaterBend_GroundSlam",
	["WaterBend_Stand"] = "WaterBend_Stand",

	--Vehicles
	["Glider_Wind"] = "Glider_Wind",
	["Appa_Wind"] = "Appa_Wind",

	-- Other
	["Meditation"] = "Meditation",
	["Meditation_Activate"] = "Meditation_Activate",
	["Meditation_Deactivate"] = "Meditation_Deactivate",

	--UI
	["Hover"] = "Hover",
	["Activate"] = "Activate",
	["Buy"] = "Buy",
	["Close"] = "Close",
	["Purchased_Success"] = "Purchased_Success",
	["Purchased_Error"] = "Purchased_Error",
	["LevelUp"] = "LevelUp",
	["Quest_Assign"] = "Quest_Assign",
	["Quest_Notice"] = "Quest_Notice",
	["Quest_Completed"] = "Quest_Completed",
	["IAP_Purchase"] = "IAP_Purchase",
	["Printing"] = "Printing",
	["Reward"] = "Reward",

	-- Environments Sound [Maps]
	["RoVatarLand"] = "RoVatarLand",
	["GreenTribeDown"] = "GreenTribeDown",
	["GreenTribeUp"] = "GreenTribeUp",
	["KioshiIsland"] = "KioshiIsland",
	["LavaIsland"] = "LavaIsland",
	["NorthenWaterTribe"] = "NorthenWaterTribe",
	["SnowIsland"] = "SnowIsland",
	["SounderAirTemple"] = "SounderAirTemple",
	["WesternTemple"] = "WesternTemple",
}

table.freeze(Constants.SFXs)
--===========================********************** Sounds & Music ******************============================


--===========================********************** Animations ******************============================
Constants.AvatarAnimtions = {
	["Meditate"] = "Meditate",
	["Running"] = "Running",

	--Bendings
	["AirKick"] = "AirKick",
	["EarthStomp"] = "EarthStomp",
	["FireDropKick"] = "FireDropKick",
	["WaterStance"] = "WaterStance",

	--Combats
	["BoomerangHold"] = "BoomerangHold",
	["Sheathe"] = "Sheathe",
	["Unsheathe"] = "Unsheathe",
}
table.freeze(Constants.AvatarAnimtions)
--===========================********************** Animations ******************============================

--===========================********************** IAP Data ******************============================
Constants.CurrencyTypes = {
	["Free"] = "Free",
	["Gold"] = "Gold",
	["Gems"] = "Gems",
	["Robux"] = "Robux",
}
table.freeze(Constants.CurrencyTypes)

Constants.ProductCategories = {
	["Gold"] = "Gold",
	["Gems"] = "Gems",
	["Weapon"] = "Weapon",
	["GamePass"] = "GamePass",
}
table.freeze(Constants.ProductCategories)

--===========================********************** IAP Data ******************============================

--===========================********************** GAME ITEMS AND PRODUCTS ******************============================
Constants.LevelAbilities = {
	[Costs.AirKickLvl] = 1,
	[Costs.FireDropKickLvl] = 2,
	[Costs.EarthStompLvl] = 3, 
	[Costs.WaterStanceLvl] = 4,
}

Constants.ItemType = {
	Eye = "Eye",
	Skin = "Skin",
	Mouth = "Mouth",
	Extra = "Extra",
	Eyebrows = "Eyebrows",
	
	Hair = "Hair",
	Pant = "Pant",
	Jersey = "Jersey",
}
table.freeze(Constants.ItemType)

Constants.InventoryType = {
	Pets = "Pets",
	Maps = "Maps",
	Weapons = "Weapons",
	Abilities = "Abilities",
	Transports = "Transports",
	Characters = "Characters",
	Styling = "Styling",
}
table.freeze(Constants.InventoryType)

--[[ Declared as once at single place
# Common/Single table contains all game items with full details. It will be shared as common reference to be used anywhere.
]]

Constants.Items = {
	--> Game Passes
	["Momo"] = {
		--Item Info 
		Id = "Momo",
		Name = "Nimbus",
		Description = "Special Pet that Follows Around",
		Image = "",
		Price = 100,
		CurrencyType = Constants.CurrencyTypes.Robux,
		InventoryType = Constants.InventoryType.Pets,

		--Other Properties
		BuyXp = 500,
		RequiredLevel = 0,
		Color = Color3.fromRGB(40, 169, 0),

		--Purchase logs
		ProductId = 112888751,
		ProductType = Enum.InfoType.GamePass, --Product, Pass, etc
		ProductCategory = Constants.ProductCategories.GamePass, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["Boomerang"] = {
		--Item Info 
		Id = "Boomerang",
		Name = "Sky Cutter",
		Description = "Special Tool that acts like a Boomerang and does damage",
		Image = "",
		Price = 500,
		CurrencyType = Constants.CurrencyTypes.Robux,
		InventoryType = Constants.InventoryType.Weapons,

		--Other Properties
		BuyXp = 1000,
		Color = Color3.fromRGB(255, 61, 50),
		RequiredLevel = 0,

		--Purchase logs
		ProductId = 111701633,
		ProductType = Enum.InfoType.GamePass, --Product, Pass, etc
		ProductCategory = Constants.ProductCategories.GamePass, --Gold, Gems, etc
		
		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["BlueGlider"] = {
		--Item Info 
		Id = "BlueGlider",
		Name = "Skybound Glider",
		Description = `Special Tool that grants faster gliding than original \"FREE\" Windrider`,
		Image = "rbxassetid://11109285385",
		Price = 1000,
		CurrencyType = Constants.CurrencyTypes.Robux,
		InventoryType = Constants.InventoryType.Transports,
		VehicleType = Constants.VehiclesType.KorraGlider,

		--Other Properties
		BuyXp = 1500,
		Color = Color3.fromRGB(60, 112, 255),
		RequiredLevel = 0,

		--Purchase logs
		ProductId = 75648015,
		ProductType = Enum.InfoType.GamePass, --Product, Pass, etc
		ProductCategory = Constants.ProductCategories.GamePass, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["MeteoriteSword"] = {
		--Item Info 
		Id = "MeteoriteSword",
		Name = "Celestial Blade",
		Description = "Special Tool that is a sword with special attacks",
		Image = "",
		Price = 1500,
		CurrencyType = Constants.CurrencyTypes.Robux,
		InventoryType = Constants.InventoryType.Weapons,

		--Other Properties
		BuyXp = 2000,
		Color = Color3.fromRGB(255, 255, 255),
		RequiredLevel = 0,

		--Purchase logs
		ProductId = 113435663,
		ProductType = Enum.InfoType.GamePass, --Product, Pass, etc
		ProductCategory = Constants.ProductCategories.GamePass, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},

	--> Dev Products
	["GemsPack"] = {
		--Item Info 
		Id = "GemsPack",
		Name = "Gems Pack",
		Description = "Special Pack of 50k Gems loot",
		Image = 17575036283,
		Amount = 50000,
		Price = 500,
		CurrencyType = Constants.CurrencyTypes.Robux,
		InventoryType = nil,

		--Other Properties
		BuyXp = 100,
		RequiredLevel = 0,
		Color = nil,

		--Purchase logs
		ProductId = 1873595644,
		ProductType = Enum.InfoType.Product, --Product, Pass, etc
		ProductCategory = Constants.ProductCategories.Gems, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["Gems2x"] = {
		--Item Info 
		Id = "Gems2x",
		Name = "2x Gems",
		Description = "Gives You x2 Gems in Game when playing",
		Image = 17574937865,
		Amount = 2,
		Price = 200,
		CurrencyType = Constants.CurrencyTypes.Robux,
		InventoryType = nil,

		--Other Properties
		BuyXp = 50,
		RequiredLevel = 0,
		Color = nil,

		--Purchase logs
		ProductId = 1873595644, -- TODO(SECURITY): Replace with unique ProductId from Roblox Dashboard
		ProductType = Enum.InfoType.Product, --Product, Pass, etc
		ProductCategory = Constants.ProductCategories.Gems, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["MegaLuck"] = {
		--Item Info
		Id = "MegaLuck",
		Name = "Mega Luck!",
		Description = "~ Gives you 3x luck while hatching!",
		Image = 17575091854,
		Amount = 3,
		Price = 500,
		CurrencyType = Constants.CurrencyTypes.Robux,
		InventoryType = nil,

		--Other Properties
		BuyXp = 100,
		RequiredLevel = 0,
		Color = nil,

		--Purchase logs
		ProductId = 1873595644, -- TODO(SECURITY): Replace with unique ProductId from Roblox Dashboard
		ProductType = Enum.InfoType.Product, --Product, Pass, etc
		ProductCategory = Constants.ProductCategories.Gold, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["MegaLuck2"] = {
		--Item Info
		Id = "MegaLuck2",
		Name = "Mega Luck!",
		Description = "~ Gives you 3x luck while hatching!",
		Image = 17575121818,
		Amount = 3,
		Price = 500,
		CurrencyType = Constants.CurrencyTypes.Robux,
		InventoryType = nil,

		--Other Properties
		BuyXp = 100,
		RequiredLevel = 0,
		Color = nil,

		--Purchase logs
		ProductId = 1873595644, -- TODO(SECURITY): Replace with unique ProductId from Roblox Dashboard
		ProductType = Enum.InfoType.Product, --Product, Pass, etc
		ProductCategory = Constants.ProductCategories.Gold, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},


	--> Abilities
	["AirBending"] = {
		--Item Info 
		Id = "AirBending",
		Name = "Storm Whisper",
		Description = "Swift, evasive, and untouchable",
		Image = "rbxassetid://18203035442",
		Price = 0,
		CurrencyType = Constants.CurrencyTypes.Free,
		InventoryType = Constants.InventoryType.Abilities,

		--Other Properties
		BuyXp = 0,
		Color = nil,
		RequiredLevel = Costs.AirKickLvl,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["FireBending"] = {
		--Item Info 
		Id = "FireBending",
		Name = "Inferno Surge",
		Description = "Explosive power with fierce aggression",
		Image = "rbxassetid://18203041786",
		Price = 0,
		CurrencyType = Constants.CurrencyTypes.Free,
		InventoryType = Constants.InventoryType.Abilities,

		--Other Properties
		BuyXp = 100,
		Color = nil,
		RequiredLevel = Costs.FireDropKickLvl,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["EarthBending"] = {
		--Item Info 
		Id = "EarthBending",
		Name = "Earthquake Force",
		Description = "Unyielding strength and solid defense",
		Image = "rbxassetid://18203044569",
		Price = 0,
		CurrencyType = Constants.CurrencyTypes.Free,
		InventoryType = Constants.InventoryType.Abilities,

		--Other Properties
		BuyXp = 100,
		Color = nil,
		RequiredLevel = Costs.EarthStompLvl,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["WaterBending"] = {
		--Item Info 
		Id = "WaterBending",
		Name = "Aqua Flow",
		Description = "Graceful, adaptive, and relentless",
		Image = "rbxassetid://18203049187",
		Price = 0,
		CurrencyType = Constants.CurrencyTypes.Free,
		InventoryType = Constants.InventoryType.Abilities,

		--Other Properties
		BuyXp = 100,
		Color = nil,
		RequiredLevel = Costs.WaterStanceLvl,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},


	--> Transport
	["Glider"] = {
		--Item Info 
		Id = "Glider",
		Name = "Windrider",
		Description = "Windrider that you can fly with, not fast, but still travel",
		Image = "rbxassetid://18298943565",
		Price = 2000,
		CurrencyType = Constants.CurrencyTypes.Gold,
		InventoryType = Constants.InventoryType.Transports,
		VehicleType = Constants.VehiclesType.AangGlider,

		--Other Properties
		BuyXp = 0,
		Color = nil,
		RequiredLevel = 5,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	--BlueGlider in GamePasses
	["Appa"] = {
		--Item Info 
		Id = "Appa",
		Name = "Cloudstride",
		Description = `Glider that you can fly with, not fast, but still travel`,
		Image = "rbxassetid://18298865227",
		Price = 10000,
		CurrencyType = Constants.CurrencyTypes.Gold,
		InventoryType = Constants.InventoryType.Transports,
		VehicleType = Constants.VehiclesType.Appa,

		--Other Properties
		BuyXp = 200,
		Color = nil,
		RequiredLevel = 10,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},


	--> Maps
	["RoVatarLand"] = {
		--Item Info 
		Id = "RoVatarLand",
		Name = "RoVatar Land",
		Description = "Base Map",
		Image = "",
		Price = 0,
		CurrencyType = Constants.CurrencyTypes.Free,
		InventoryType = Constants.InventoryType.Maps,
		VehicleType = nil,

		--Other Properties
		Color = nil,
		RequiredLevel = 0,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = false,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["GreenTribeDown"] = {
		--Item Info 
		Id = "GreenTribeDown",
		Name = "Emerald Basin",
		Description = "The Green Tribe Down",
		Image = "",
		Price = 0,
		CurrencyType = Constants.CurrencyTypes.Free,
		InventoryType = Constants.InventoryType.Maps,
		VehicleType = nil,

		--Other Properties
		BuyXp = 1000,
		Color = nil,
		RequiredLevel = 0,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = false,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["GreenTribeUp"]= {
		--Item Info 
		Id = "GreenTribeUp",
		Name = "Verdant Heights",
		Description = "The Green Tribe Up",
		Image = "",
		Price = 0,
		CurrencyType = Constants.CurrencyTypes.Free,
		InventoryType = Constants.InventoryType.Maps,
		VehicleType = nil,

		--Other Properties
		BuyXp = 1000,
		Color = nil,
		RequiredLevel = 0,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = false,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["KioshiIsland"] = {
		--Item Info 
		Id = "KioshiIsland",
		Name = "Sentinel Isle",
		Description = "The Kioshi Island",
		Image = "",
		Price = 0,
		CurrencyType = Constants.CurrencyTypes.Free,
		InventoryType = Constants.InventoryType.Maps,
		VehicleType = nil,

		--Other Properties
		BuyXp = 0,
		Color = nil,
		RequiredLevel = 0,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = false,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["LavaIsland"] = {
		--Item Info 
		Id = "LavaIsland",
		Name = "Molten Crag",
		Description = "The Lava Island",
		Image = "",
		Price = 0,
		CurrencyType = Constants.CurrencyTypes.Free,
		InventoryType = Constants.InventoryType.Maps,
		VehicleType = nil,

		--Other Properties
		BuyXp = 1000,
		Color = nil,
		RequiredLevel = 0,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = false,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["NorthenWaterTribe"] = {
		--Item Info 
		Id = "NorthenWaterTribe",
		Name = "Frozen Haven",
		Description = "The Northen Water Tribe",
		Image = "",
		Price = 0,
		CurrencyType = Constants.CurrencyTypes.Free,
		InventoryType = Constants.InventoryType.Maps,
		VehicleType = nil,

		--Other Properties
		BuyXp = 1000,
		Color = nil,
		RequiredLevel = 0,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = false,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["SnowIsland"] = {
		--Item Info 
		Id = "SnowIsland",
		Name = "Glacial Expanse",
		Description = "The Snow Island",
		Image = "",
		Price = 0,
		CurrencyType = Constants.CurrencyTypes.Free,
		InventoryType = Constants.InventoryType.Maps,
		VehicleType = nil,

		--Other Properties
		BuyXp = 1000,
		Color = nil,
		RequiredLevel = 0,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = false,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["SounderAirTemple"] = {
		--Item Info 
		Id = "SounderAirTemple",
		Name = "Zephyr Monastery",
		Description = "The SounderAirTemple",
		Image = "",
		Price = 0,
		CurrencyType = Constants.CurrencyTypes.Free,
		InventoryType = Constants.InventoryType.Maps,
		VehicleType = nil,

		--Other Properties
		BuyXp = 1000,
		Color = nil,
		RequiredLevel = 0,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = false,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["WesternTemple"] = {
		--Item Info 
		Id = "WesternTemple",
		Name = "Horizon Spire",
		Description = "The Western Temple",
		Image = "",
		Price = 0,
		CurrencyType = Constants.CurrencyTypes.Free,
		InventoryType = Constants.InventoryType.Maps,
		VehicleType = nil,

		--Other Properties
		BuyXp = 1000,
		Color = nil,
		RequiredLevel = 0,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = false,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},


	--> Characters
	["Aang"] = {
		--Item Info 
		Id = "Aang",
		Name = "Storm Walker",
		Description = "The main character Aang",
		Image = "",
		Price = 0,
		CurrencyType = Constants.CurrencyTypes.Free,
		InventoryType = Constants.InventoryType.Characters,
		VehicleType = nil,

		--Other Properties
		BuyXp = 0,
		Color = nil,
		RequiredLevel = 0,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = false,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["Katara"] = {
		--Item Info 
		Id = "Katara",
		Name = "Tideweaver",
		Description = "The female character Katara",
		Image = "",
		Price = 1000,
		CurrencyType = Constants.CurrencyTypes.Gems,
		InventoryType = Constants.InventoryType.Characters,
		VehicleType = nil,

		--Other Properties
		BuyXp = 200,
		Color = nil,
		RequiredLevel = 5,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["Sokka"] = {
		--Item Info 
		Id = "Sokka",
		Name = "Moonfang",
		Description = "The male character Sokka",
		Image = "",
		Price = 3000,
		CurrencyType = Constants.CurrencyTypes.Gems,
		InventoryType = Constants.InventoryType.Characters,
		VehicleType = nil,

		--Other Properties
		BuyXp = 500,
		Color = nil,
		RequiredLevel = 10,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["Toph"] = {
		--Item Info 
		Id = "Toph",
		Name = "Stoneheart",
		Description = "The enemy character Toph",
		Image = "",
		Price = 500.,
		CurrencyType = Constants.CurrencyTypes.Gems,
		InventoryType = Constants.InventoryType.Characters,
		VehicleType = nil,

		--Other Properties
		BuyXp = 1000,
		Color = nil,
		RequiredLevel = 20,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	["Zuko"] = {
		--Item Info 
		Id = "Zuko",
		Name = "Emberborn",
		Description = "A friend in opposite-team",
		Image = "",
		Price = 10000,
		CurrencyType = Constants.CurrencyTypes.Gems,
		InventoryType = Constants.InventoryType.Characters,
		VehicleType = nil,

		--Other Properties
		BuyXp = 1500,
		Color = nil,
		RequiredLevel = 50,

		--Purchase logs
		ProductId = 0,
		ProductType = nil, --Product, Pass, etc
		ProductCategory = nil, --Gold, Gems, etc

		--Product Info
		AssetId = nil,
		IsForSale = true,
		IsLimited = false,
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Creator = nil,
	},
	
}
table.freeze(Constants.Items)

Constants.Weapons = {
	Fist = "Fist",
	Air = Constants.Items.AirBending.Id,
	Fire = Constants.Items.FireBending.Id,
	Water = Constants.Items.WaterBending.Id,
	Earth = Constants.Items.EarthBending.Id,
	Boomerang = Constants.Items.Boomerang.Id,
	MeteoriteSword = Constants.Items.MeteoriteSword.Id,
}
table.freeze(Constants.Weapons)

Constants.GameInventory = {
	Pets = {
		Momo = Constants.Items.Momo,
	},
	Maps = {
		RoVatarLand = Constants.Items.RoVatarLand,
		GreenTribeDown = Constants.Items.GreenTribeDown,
		GreenTribeUp = Constants.Items.GreenTribeUp,
		KioshiIsland = Constants.Items.KioshiIsland,
		LavaIsland = Constants.Items.LavaIsland,
		NorthenWaterTribe = Constants.Items.NorthenWaterTribe,
		SnowIsland = Constants.Items.SnowIsland,
		SounderAirTemple = Constants.Items.SounderAirTemple,
		WesternTemple = Constants.Items.WesternTemple,
	},
	Abilities = {
		AirBending = Constants.Items.AirBending,
		FireBending = Constants.Items.FireBending,
		EarthBending = Constants.Items.EarthBending,
		WaterBending = Constants.Items.WaterBending,
	},
	Weapons = Constants.Weapons,
	Transports = {
		Glider = Constants.Items.Glider,
		BlueGlider = Constants.Items.BlueGlider,
		Appa = Constants.Items.Appa,
	},
	Characters = {
		Aang = Constants.Items.Aang,
		Katara = Constants.Items.Katara,
		Sokka = Constants.Items.Sokka,
		Toph = Constants.Items.Toph,
		Zuko = Constants.Items.Zuko,
	},
	Styling = {
		Eye = require(script.Eye)(Constants),
		Skin = require(script.Skin)(Constants),
		Mouth = require(script.Mouth)(Constants),
		Extra = require(script.Extra)(Constants),
		Eyebrows = require(script.Eyebrows)(Constants),
		
		Hair = require(script.Hair)(Constants),
		Pant = require(script.Pant)(Constants),
		Jersey = require(script.Jersey)(Constants),
	}
}
table.freeze(Constants.GameInventory)

Constants.IAPItems = {
	--GamePasses
	Momo = Constants.Items.Momo,
	Boomerang = Constants.Items.Boomerang,
	BlueGlider = Constants.Items.BlueGlider,
	MeteoriteSword = Constants.Items.MeteoriteSword,

	--Dev Products
	GemsPack = Constants.Items.GemsPack,
	Gems2x = Constants.Items.Gems2x,
	MegaLuck = Constants.Items.MegaLuck,
	MegaLuck2 = Constants.Items.MegaLuck2,

}
table.freeze(Constants.IAPItems)

--===========================********************** GAME ITEMS AND PRODUCTS ******************============================



--===========================********************** Inventory Data ******************==========================

--===========================********************** Data Stores ETC ******************============================
Constants.DataStoreVersions = {
	{
		GameDataStoreVersion = 1,
	},
	{
		GameDataStoreVersion = 1.1,
	},
	{
		GameDataStoreVersion = 1.2, -- Added JourneyQuestProgress
	},
	{
		GameDataStoreVersion = 1.3, -- Added KataraQuestProgress
	},
	{
		GameDataStoreVersion = 1.31, -- nothing
	},
	{
		GameDataStoreVersion = 1.32, -- Updated CheckAndUpdatePlayerData logic (for runtime profile slots update)
	},
}
table.freeze(Constants.DataStoreVersions)

Constants.DataStores = {
	["PlayerData"] = {Name = "_playerData6_", KeySuffix = "_Data", Config = {AutoSave = 60},
		CurrVersion = Constants.DataStoreVersions[#Constants.DataStoreVersions]},
	["QuestsStore"] = {Name = "_QuestStore6_", KeySuffix = "_Quests", Config = {AutoSave = 60},
		CurrVersion = Constants.DataStoreVersions[#Constants.DataStoreVersions]},
}
table.freeze(Constants.DataStores)

Constants.LevelUpRewardType = {
	["Gold"] = "Gold",
	["Gems"] = "Gems",
	["XP"] = "XP",
}
table.freeze(Constants.LevelUpRewardType)

Constants.GameLevelsData = require(script.LevelData)(Constants.LevelUpRewardType)
table.freeze(Constants.GameLevelsData)

Constants.DefaultSlotId = "Default_Slot"

--===========================********************** Data Stores ETC ******************============================

---------------------------- >>>>>>>>>>>>> ......... Quests Data ......... <<<<<<<<<<<< --------------------------
Constants.QuestDataStoreVersions = {
	{
		GameDataStoreVersion = 0.1,
	},
}
table.freeze(Constants.QuestDataStoreVersions)

Constants.QuestRewardType = {
	Gold = "Gold",
	Gems = "Gems",
	LevelUp = "LevelUp",
	XP = "XP",
}
table.freeze(Constants.QuestRewardType)

Constants.QuestObjectives = {
	Kill = "Kill",
	Find = "Find",
	Visit = "Visit",
	Purchase = "Purchase",
	Train = "Train",
	Combined = "Combined",
}
table.freeze(Constants.QuestObjectives)

Constants.QuestTargetIds = {
	--- KILL
	WaterBender = "WaterBender",
	EarthBender = "EarthBender",
	FireBender = "FireBender",
	AirBender = "AirBender",
	
	-- Upgraded version of Fire Bender
	FireBender_MiniBoss = "FireBender_MiniBoss",

	--- PURCHASE
	Glider = "Glider",
	Appa = "Appa",

	--- FIND
	OldBook = "OldBook",
	MagicBook = "MagicBook",
	Shop = "Shop",
	FlowerOfLife = "FlowerOfLife",
	
	--Train
	SunkenRelic1 = "SunkenRelic1",
	SunkenRelic2 = "SunkenRelic2",
	SunkenRelic3 = "SunkenRelic3",
	ManaDeplete = "ManaDeplete",
	ManaRestored = "ManaRestored",

	--- VISIT MAPS
	KioshiIsland = Constants.GameInventory.Maps.KioshiIsland.Id, 
	LavaIsland = Constants.GameInventory.Maps.LavaIsland.Id, 
	SnowIsland = Constants.GameInventory.Maps.SnowIsland.Id, 
	SounderAirTemple = Constants.GameInventory.Maps.SounderAirTemple.Id, 
	GreenTribeUp = Constants.GameInventory.Maps.GreenTribeUp.Id, 
	WesternTemple = Constants.GameInventory.Maps.WesternTemple.Id, 
	GreenTribeDown = Constants.GameInventory.Maps.GreenTribeDown.Id, 
	NorthenWaterTribe = Constants.GameInventory.Maps.NorthenWaterTribe.Id, 
	
	-- Talk NPC
	["Zephir Guide"] = "Zephir Guide",
	["Journey Master"] = "Journey Master",
	
	-- UI Open 
	OpenMap = "OpenMap"
}
table.freeze(Constants.QuestTargetIds)

-----
Constants.QuestType = {
	OneTime = "OneTime", -- Will Assigned By Server [Like, Fav, Invite etc.]
	NPCQuest = "NPCQuest",
	DailyQuest = "DailyQuest",
	LevelQuest = "LevelQuest",
	TutorialQuest = "TutorialQuest",
}
table.freeze(Constants.QuestType)
---------------------------- >>>>>>>>>>>>> ......... Quests Data ......... <<<<<<<<<<<< --------------------------

--===========================********************** 3D Elements ******************============================--
Constants.CharacterTypes = {
	["Roblox"] = "Roblox", --Means real player's own character.
	["Default"] = "Default",
	["Aang"] = "Aang",
	["Katara"] = "Katara",
	["Zuko"] = "Zuko",
	["Toph"] = "Toph",
	["Sokka"] = "Sokka",
}
table.freeze(Constants.CharacterTypes)
--==========================********************** 3D Elements ******************===========================


return Constants
