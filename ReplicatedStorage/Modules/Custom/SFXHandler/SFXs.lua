-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local Constants = require(RS.Modules.Custom.Constants)

local prefix = "rbxassetid://"

export type Emitter = {
	RollMaxDist: number,
	RollMinDist: number,
	RollOffMode: Enum.RollOffMode,
}


export type Type = {
	Name: string,
	ID: string,
	TimePosition: number,
	PlaybackSpeed: number,
	Volume: number,
	Loop: boolean,
	RollEmitter: Emitter,
	Effects : table,
	SoundGroup : string,
}

local Data = {
	--Air
	[Constants.SFXs.AirKick_Push] = {
		Name = Constants.SFXs.AirKick_Push, ID = prefix.."1843130277", Volume = 3, Loop = false, PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	--Earth
	[Constants.SFXs.EarthStomp_Thrust] = {
		Name = Constants.SFXs.EarthStomp_Thrust, ID = prefix.."6465230950", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	--Fire
	[Constants.SFXs.FireDropKick_Launch] = {
		Name = Constants.SFXs.FireDropKick_Launch, ID = prefix.."1843130277", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	--Water
	[Constants.SFXs.WaterBend_GroundSlam] = {
		Name = Constants.SFXs.WaterBend_GroundSlam, ID = prefix.."8588542238", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.WaterBend_Stand] = {
		Name = Constants.SFXs.WaterBend_Stand, ID = prefix.."9120551991", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		Effects = { PitchShiftSoundEffect = {Octave = 1.25, Priority = 0},},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	

	--Fist Fight
	[Constants.SFXs.Fist_Swing] = {
		Name = Constants.SFXs.Fist_Swing, ID = prefix.."4571259077", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Fist_Parry] = {
		Name = Constants.SFXs.Fist_Parry, ID = prefix.."4516507682", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.HeavyPunch1] = {
		Name = Constants.SFXs.HeavyPunch1, ID = prefix.."3763473874", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.HeavyPunch2] = {
		Name = Constants.SFXs.HeavyPunch2, ID = prefix.."3763474082", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.HeavyPunch3] = {
		Name = Constants.SFXs.HeavyPunch3, ID = prefix.."3763474273", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.HeavyPunch4] = {
		Name = Constants.SFXs.HeavyPunch4, ID = prefix.."3763474469", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.HeavyPunch5] = {
		Name = Constants.SFXs.HeavyPunch5, ID = prefix.."4306987778", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Punch1] = {
		Name = Constants.SFXs.Punch1, ID = prefix.."3932504231", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Punch2] = {
		Name = Constants.SFXs.Punch2, ID = prefix.."3932505023", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Punch3] = {
		Name = Constants.SFXs.Punch3, ID = prefix.."3932506183", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Punch4] = {
		Name = Constants.SFXs.Punch4, ID = prefix.."3932506625", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Punch5] = {
		Name = Constants.SFXs.Punch5, ID = prefix.."4306980885", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},

	--* Item
	[Constants.SFXs.Glider_Wind] = {
		Name = Constants.SFXs.Glider_Wind, ID = prefix.."8601687897", Volume = 2.5, Loop = true,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 250, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Appa_Wind] = {
		Name = Constants.SFXs.Appa_Wind, ID = prefix.."8114441138", Volume = 1, Loop = true,  PlaybackSpeed = 1,
		RollEmitter = {RollMaxDist = 250, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	

	--* Weapons
	[Constants.SFXs.Ragdoll] = {
		Name = Constants.SFXs.Ragdoll, ID = prefix.."0", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Spawn] = {
		Name = Constants.SFXs.Spawn, ID = prefix.."12221944", Volume = 2.5, Loop = false,  PlaybackSpeed = 2,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Sword_Swing] = {
		Name = Constants.SFXs.Sword_Swing, ID = prefix.."5649632847", Volume = 0.2, Loop = false,  PlaybackSpeed = 1,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Sheathe] = {
		Name = Constants.SFXs.Sheathe, ID = prefix.."3755634435", Volume = 10, Loop = false,  PlaybackSpeed = 1,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.UnSheathe] = {
		Name = Constants.SFXs.UnSheathe, ID = prefix.."4458741947", Volume = 10, Loop = false,  PlaybackSpeed = 1,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Boomerang] = {
		Name = Constants.SFXs.Boomerang, ID = prefix.."9119226888", Volume = 2, Loop = false,  PlaybackSpeed = 1,
		RollEmitter = {RollMaxDist = 250, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	
	--* Other
	[Constants.SFXs.LevelUp] = {
		Name = Constants.SFXs.LevelUp, ID = prefix.."860861713", Volume = 0.5, Loop = false,  PlaybackSpeed = 1,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Meditation] = {
		Name = Constants.SFXs.Meditation, ID = prefix.."9056932358", Volume = 1, Loop = true,  PlaybackSpeed = .7,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Meditation_Activate] = {
		Name = Constants.SFXs.Meditation_Activate, ID = prefix.."6181008962", Volume = 0.25, Loop = false,  PlaybackSpeed = 1,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Meditation_Deactivate] = {
		Name = Constants.SFXs.Meditation_Deactivate, ID = prefix.."8208593535", Volume = 0.25, Loop = false,  PlaybackSpeed = 1,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	
	--* UI
	[Constants.SFXs.Hover] = {
		Name = Constants.SFXs.Hover, ID = prefix.."7218169592", Volume = 1, Loop = false,  PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Activate] = {
		Name = Constants.SFXs.Activate, ID = prefix.."9080070218", Volume = 1, Loop = false,  PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Buy] = {
		Name = Constants.SFXs.Buy, ID = prefix.."9080070218", Volume = 1, Loop = false,  PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Close] = {
		Name = Constants.SFXs.Close, ID = prefix.."9080070218", Volume = 1, Loop = false,  PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Purchased_Success] = {
		Name = Constants.SFXs.Purchased_Success, ID = prefix.."6599575767", Volume = 1.5, Loop = false,  PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Purchased_Error] = {
		Name = Constants.SFXs.Purchased_Error, ID = prefix.."3779045779", Volume = 1, Loop = false,  PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Quest_Notice] = {
		Name = Constants.SFXs.Quest_Notice, ID = prefix.."2865227271", Volume = 1, Loop = false,  PlaybackSpeed = 1,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Quest_Completed] = {
		Name = Constants.SFXs.Quest_Completed, ID = prefix.."4612383790", Volume = 1, Loop = false,  PlaybackSpeed = 1,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.IAP_Purchase] = {
		Name = Constants.SFXs.IAP_Purchase, ID = prefix.."3295472928", Volume = .5, Loop = false,  PlaybackSpeed = 1,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Printing] = {
		Name = Constants.SFXs.Printing, ID = prefix.."5685209822", Volume = .25, Loop = false,  PlaybackSpeed = .8,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Reward] = {
		Name = Constants.SFXs.Reward, ID = prefix.."3295472928", Volume = .35, Loop = false,  PlaybackSpeed = .8,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Quest_Assign] = {
		Name = Constants.SFXs.Quest_Assign, ID = prefix.."1570675466", Volume = 1, Loop = false,  PlaybackSpeed = .8,
		RollEmitter = {RollMaxDist = 150, RollMinDist = 10, RollOffMode = Enum.RollOffMode.Inverse},
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	
	--**** Environment Proximity
	[Constants.SFXs.Env_Lava] = {
		Name = Constants.SFXs.Env_Lava, ID = prefix.."9095809158",
		Volume = 1, Loop = true, PlaybackSpeed = 1,
		RollEmitter = { RollMaxDist = 80, RollMinDist = 5, RollOffMode = Enum.RollOffMode.InverseTapered },
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},
	[Constants.SFXs.Env_WindHeight] = {
		Name = Constants.SFXs.Env_WindHeight, ID = prefix.."6455667685",
		Volume = 0.5, Loop = true, PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.SFXGroup,
	},

	--**** Environment MapWise
	
	----- DUMMY ASSETS -----
	[Constants.SFXs.RoVatarLand] = {
		Name = Constants.SFXs.RoVatarLand, ID = prefix.."9044560778", Volume = 0.1, Loop = true,  PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.MusicGroup,
	},
	[Constants.SFXs.GreenTribeDown] = {
		Name = Constants.SFXs.GreenTribeDown, ID = prefix.."9044560778", Volume = 0.1, Loop = true,  PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.MusicGroup,
	},
	[Constants.SFXs.GreenTribeUp] = {
		Name = Constants.SFXs.GreenTribeUp, ID = prefix.."9044560778", Volume = 0.1, Loop = true,  PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.MusicGroup,
	},
	[Constants.SFXs.KioshiIsland] = {
		Name = Constants.SFXs.KioshiIsland, ID = prefix.."1847767458", Volume = 0.075, Loop = true,  PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.MusicGroup,
	},
	[Constants.SFXs.SounderAirTemple] = {
		Name = Constants.SFXs.SounderAirTemple, ID = prefix.."1847767458", Volume = .075, Loop = true,  PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.MusicGroup,
	},
	[Constants.SFXs.WesternTemple] = {
		Name = Constants.SFXs.WesternTemple, ID = prefix.."1847767458", Volume = .075, Loop = true,  PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.MusicGroup,
	},
	
	----- ASSETS GIVEN BY CLIENT -----
	[Constants.SFXs.LavaIsland] = {
		Name = Constants.SFXs.LavaIsland, ID = prefix.."1844214992", Volume = 0.5, Loop = true,  PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.MusicGroup,
	},
	[Constants.SFXs.NorthenWaterTribe] = {
		Name = Constants.SFXs.NorthenWaterTribe, ID = prefix.."1838862200", Volume = 0.5, Loop = true,  PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.MusicGroup,
	},
	[Constants.SFXs.SnowIsland] = {
		Name = Constants.SFXs.SnowIsland, ID = prefix.."1838651099", Volume = 0.5, Loop = true,  PlaybackSpeed = 1,
		SoundGroup = Constants.SoundGroups.MusicGroup,
	},
}

return Data