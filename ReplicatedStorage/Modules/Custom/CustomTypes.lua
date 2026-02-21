-- @ScriptType: ModuleScript
local CustomTypes = {}

----General
export type TimerType = {
	knitTimer : any,
	timerValue : number,
	funcToRun : ()->(),
}

export type NotificationDataType = {
	Icon :string,
	Title : string,
	noBtnText : string,
	yesBtnText : string,
	Description : string,
	AutoHideTime : number,
	Type :string,
}

export type VideoData = {
	videoId : string,
	TimePos : number,
	EndTime : number,
	Looped : boolean,
	Volume : number,
	HideOnComplete :boolean,
	PauseTime :number,
	HideOnPause :boolean,
	HideOnEnd :boolean,
	OnPaused : ()->(),
	OnLoaded : ()->(),
	LoadFailed :()->(),
	OnComplete : ()->(),
}

export type RewardsData = {
	Gold : number,
	Gems : number,
	XP : number,
}

export type tweenDataType = {
	StartPos : UDim2,
	FinalPos : UDim2,
	Time : number,
	OnCompleted : FunctionalTest,
}

export type StatsDataType = {
	Min : number,
	Max : number,
	State : string,
	Factor : number,
	Current : number,
	Stat : NumberValue,
	StateType : string,
}

--- SFX Types
export type EmitterDataType = {
	RollMaxDist: number,
	RollMinDist: number,
	RollOffMode: Enum.RollOffMode,
}

export type SFXDataType = {
	Name: string,
	ID: string,
	TimePosition: number,
	PlaybackSpeed: number,
	Volume: number,
	Loop: boolean,
	RollEmitter: EmitterDataType,
	SoundGroup: string
}

-- Character Animations
export type AnimationDataType = {
	Anim : Animation,
	AnimState : string,
	Priority : any,
	onComplete : () -> (),
	EventsName : table,
	EventCallback : () ->(),
}


---Field GamePlay
export type InputButtonDataType = {
	Image : string,
	Text : string,
	Position : UDim2,
	Size : UDim2,
	Color : Color3
}

export type InputDataType = {
	KeyCodes : table,
	UiData : InputButtonDataType
}


----- IAP
export type ItemDataType = {
	--Item Info 
	Id : string,
	Name : string,
	Description : string,
	Image : string,
	Amount : number, --Amount to be credited of this item . It won't work for key-value pair based items.
	Price : number,
	CurrencyType : string, --Gold, Robux, etc
	InventoryType : string,
	ItemType : string,
	VehicleType : string,
	
	--Other Properties
	Color : Color3,
	BuyXp : IntValue, --XP to earn when an item is purchased
	UseXp :IntValue, --XP to earn on each use of an item
	RequiredLevel : IntValue,
	
	--Purchase logs
	ProductId : any,
	ProductType : string,
	ProductCategory : string, --Gold, Gems, etc
	PurchaseTime : DateTime,
	PurchaseId : string,
	
	--Product Info
	AssetId : number,
	IsForSale :boolean,
	IsLimited : boolean,
	PriceInRobux : number,
	IconImageAssetId : any,
	Creator : {
		CreatorTargetId : number,
		CreatorType : string,
		Id : number,
		Name : string,
	},
}

-------------------------------------> > > > > > > > > Default player Data < < < < < < < < <-------------------------------------


----------------------------------------
------//         Dialogue        \\-----
----------------------------------------
export type DialogueDataType = {
	Narrator :string,
	Message :string,
	
	ForceStart :boolean,
	TypeSpeed :number,
	AllowSkip :boolean,
	AutoHideTimer :number,
	
	Options : table<DialogueButtonType>,
	OnComplete :() -> (),
}


export type DialogueButtonType = {
	Txt :string,
	TxtColor :Color3,
	BgColor :Color3,
	LayoutOrder :IntValue,
	Image :string,
	OnAction :() -> (),
}

----------------------------------------
------//         Dialogue        \\-----
----------------------------------------



----------------------------------------
------//         Quests        \\-------
----------------------------------------
export type QuestsRewardDataType = {
	Type : string,
	Value : string,
}

export type ClickActionsType = {
	Assign: string, -- Task Id
	Dialogue : ConversationsDataType,
}

export type OptionsDataType = {
	Text : string,
	Image : string,
	ClickAction : ClickActionsType,
}

export type ConversationsDataType = {
	Title :string,
	Objective :string,
	Options :{[string] : OptionsDataType}
}

-- Quest Data Types
export type QuestDataType = {
	Id :string,
	Targets :{},
	Type :string, -- >Runtime< (NPCQuest or DailyQuest)
	Name :string,
	Duration :number,
	Achieved : number, -- Karna: convert to table acc.
	Objective :string,
	StartTime :boolean,
	IsClaimed :boolean,
	PendingMsg :string,
	CompleteMsg :string,
	Description :string,
	IsCompleted :boolean,
	Reward :{[string] :QuestsRewardDataType},
}

export type LevelQuestDataType = {
	ActiveQuest : QuestDataType,
	CompletedQuests :{[string] :QuestDataType}
}

export type NPCQuestDataType = {
	ActiveQuest :QuestDataType,
	CompletedQuests :{[string] :QuestDataType}
}

export type DailyQuestDataType = {
	ActiveQuest : QuestDataType,
	CompletedQuests :{[string] :QuestDataType}
}

export type TutorialQuestData = {
	ActiveQuest : QuestDataType,
	CompletedQuests :{[string] :QuestDataType}
}

export type PlayerQuestDataModel = {
	LoginData :LoginDataType,
	Profiles : {[string] : {
		NPCQuestData : QuestDataType, --NPCs
		DailyQuestData: QuestDataType, --Server
		LevelQuestData : QuestDataType, --Guru pathik 1-5 lvl
		TutorialQuestData : QuestDataType, ----Guru pathik tutorial (teleport 3 kills return)
	},},
	
}
----------------------------------------
------\\         Quests        //-------
----------------------------------------



----------------------------------------
------//       DailyReward     \\-------
----------------------------------------
export type RewardDetailsType = {
	Type: string,
	Value :number,
}
----------------------------------------
------\\      DailyReward      //-------
----------------------------------------


----------------------------------------
------//       LoginData       \\-------
export type LoginDataType = {
	LastLogin : number,
	MyDataStoreVersion : {GameDataStoreVersion : number,},
}
------\\       LoginData       //-------
----------------------------------------


----------------------------------------
------//     GamePurchases     \\-------
export type GamePurchasesDataType = {
	Subscriptions : table,
	Passes : table,	
}
------\\     GamePurchases     //-------
----------------------------------------



export type AbilitiesType = {
	AirKick : DateTime,
	EarthStomp : DateTime,
	WaterStance : DateTime,
	FireDropKick : DateTime,
}

----------------------------------------------------
--// InventoryType \\--
----------------------------------------
export type MapDataType = {
	Id :string,
	Name :string,
	Image :string,
}

export type ItemInfoType = {
	Name :string,
	Id :string,
	AssetId :string,
}

export type StylingDataTypes = {
	Hair :{[string] :string},
	Pant :{[string] :string},
	Jersey :{[string] :string},
	
	-- only for profile slots
	Eye :{[string] :string},
	Skin :{[string] :string},
	Extra :{[string] :string},
	Mouth :{[string] :string},
	Eyebrows :{[string] :string},
}

export type InventoryType = {
	Weapons : {}, -- Profile(Boomrang, Sword)
	Abilities : AbilitiesType, --Profile(All 4 bendings)
	Maps : {[string] : ItemDataType}, --Profile
	
	Styling : StylingDataTypes, -- Profile[Equipped Inventory] + Owned(All purchased customization)
	Transports : {[string] : ItemDataType}, -- Profile[Aang Glider, Appa] + Owned(Blue Glider --(All purchased customization))
	
	Pets : {[string] : ItemDataType}, --Owned
	
	Characters : {[string] : ItemDataType}, --Not In Use :Table of different characters (typeof- CharDataType)
}

export type CharDataType = {
	Id :string,
	Name : string,
	SkinColor : any,
	Accessories : {},
	Hair : any,
	Face : any,
	Shirt : any,
	Pant : any,
}

--\\ InventoryType //--
----------------------------------------------------



----------------------------------------
--// DataType \\--
----------------------------------------
export type PlayerStats = {
	Kills : IntValue,
	Deaths : IntValue,
}

export type CombatStats = {
	Health : IntValue,
	Stamina : IntValue,
	Strength : IntValue,
	
	Energy : IntValue, 
	Agility : IntValue, 
	Defense : IntValue, 
	StatPoints : IntValue,
	MaxStamina : IntValue,
}

export type SettingsDataType = {
	Shadow :boolean,
	SFX :boolean,
	Music :boolean,
	UI :boolean,
	HasSeenControls :boolean?,
}


export type GameLevelData = {
	MinXp: IntValue,
	MaxXp: IntValue,
	XpRequired : IntValue,
	Reward : {
		Type: string,
		Amount: any,
	},
	LevelCategory: string,
}


export type PersonalType = {
	DisplayName: string,
	AvatarURL: string,
	Description: string,
	UserId :number,
}

--Deprecated Now (26June25)
export type OfficialType = {
	UserID : number,
	PlayerLevel : number,
	XP : number,
	TotalXP : number,
	
	Gold : number,
	Gems : number,
	IsFirstTime: boolean,
}

export type AllQuestsType = {
	NPCQuestData : QuestDataType, --NPCs
	DailyQuestData: QuestDataType, --Server
	LevelQuestData : QuestDataType, --Guru pathik 1-5 lvl
	TutorialQuestData : QuestDataType, --Guru pathik tutorial (teleport 3 kills return)
	
	JourneyQuestProgress : number, --Stores current completed count of quests (for sequence-wise quest)
	KataraQuestProgress : number,
}
--\\ DataType //--
----------------------------------------


----------------------------------------------------
----Game contains different Save/Load game preset option. 
----Need more details how items will be distributed between common data and specific to load preset.
export type PlayerDataModel = {
	--*********COMMON DATA*********--
	PersonalProfile : PersonalType,
	LoginData : LoginDataType,
	GamePurchases : GamePurchasesDataType,
	CoupansData : table,
	
	OwnedInventory :InventoryType, --All common purchases (slot independent) 
	--Daily Rewards if includes
	--*********COMMON DATA*********--
	
	
	--********* INDEPENDENT - SPECIFIC SLOT DATA *********--
	ActiveProfile : string, -- SlotId -> AllProfiles
	AllProfiles : {[string] : ProfileSlotDataType}, --table that contains Key = "SlotId" & value = "ProfileSlotDataType" objects.
	--********* INDEPENDENT - SPECIFIC SLOT DATA *********--
}

export type ProfileSlotDataType = {
	SlotId : string,
	SlotName : string,
	CreatedOn :DateTime,
	
	XP :number,
	TotalXP :number,
	PlayerLevel :number,
	
	Gold :number,
	Gems :number,
	
	CharacterId : string,
	LastVisitedMap : string,
	LastVisitedCF :CFrame,
	LastUpdatedOn : DateTime,
	
	Data : SlotDataType,
}

export type ElementLevelData = {
	Level : number,
	XP : number,
	TotalXP : number,
}

export type ElementLevelsType = {
	Air : ElementLevelData,
	Fire : ElementLevelData,
	Earth : ElementLevelData,
	Water : ElementLevelData,
}

export type SlotDataType = {
	Settings : SettingsDataType,
	EquippedInventory : InventoryType,

	CombatStats : CombatStats,
	PlayerStats : PlayerStats,
	Quests : AllQuestsType,
	ElementLevels : ElementLevelsType,
}



return CustomTypes