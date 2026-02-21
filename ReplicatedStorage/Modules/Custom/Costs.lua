-- @ScriptType: ModuleScript
return {
	--> Transports
	VehicleCoolDown = 2, --5

	--Sprint CoolDown
	SprintCoolDown = 3, --1
	StaminaRegenerationRate = .2, -- *dt ..1
	StaminaDecrementRate = .075, -- *dt

	--Block CoolDown
	BlockCoolDown = 0, --2

	-- boomerang cooldown
	BoomerangCoolDown = 3,	 --5

	--Abilities CoolDown
	Abilities = 5, --3
	
	--Usage Min Level [[JOHN: you can adjust Required Level From here]]
	AirKickLvl = 5,
	FireDropKickLvl = 8,--5,
	EarthStompLvl = 11,--5,
	WaterStanceLvl = 12,--5,

	--Usage Stamina Costs
	FistStamina = 5,--25,
	AirKickStamina = 8,--25,
	EarthStompStamina = 12,--25,
	FireDropKickStamina = 15,--25,
	WaterStanceStamina = 10,--25,
	BoomerangStamina = 5,--25,
	MeteoriteSwordStamina = 5, 

	--Usage gain Xp
	AirKickXp = 7,
	EarthStompXp = 8,
	FireDropKickXp = 10,
	WaterStanceXp = 5, -- every second on damage
	FistXP = 5,
	MeteoriteSwordXP = 9,
	BoomerangXP = 11,

	--Usage Strength/Mana Costs
	AirKickStrength = 12,
	EarthStompStrength = 15,
	FireDropKickStrength = 15,
	WaterStanceStrength = 20,

	BoomerangStrength = 0,

	--Hit Damages
	AirKickDamageRange = Vector2.new(25, 35),
	EarthStompDamageRange = Vector2.new(35, 45),
	FireDropKickDamageRange = Vector2.new(45, 50),
	WaterStanceDamageRange = Vector2.new(20, 30), -- Continous damage on every .5 sec.

	--
	BoomerangDamageRange = Vector2.new(30, 50),
	MeteoriteSwordDamageRange = Vector2.new(15, 25),

	-- Element XP awarded per ability hit
	AirKickElementXp = 5,
	EarthStompElementXp = 6,
	FireDropKickElementXp = 8,
	WaterStanceElementXp = 4,

	-- Element level XP curve (XP required to advance FROM each level)
	ElementLevelData = {
		[1]=50, [2]=100, [3]=175, [4]=275, [5]=400,
		[6]=550, [7]=725, [8]=950, [9]=1200, [10]=1500,
		[11]=1850, [12]=2250, [13]=2700, [14]=3200, [15]=3750,
		[16]=4400, [17]=5100, [18]=5900, [19]=6800, [20]=8000,
	},
	MaxElementLevel = 20,

	-- Damage scaling constants
	PlayerLevelDamageScale = 0.02,  -- +2% per player level
	ElementLevelDamageScale = 0.03, -- +3% per element level

	-- Stamina scaling constants
	BaseMaxStamina = 100,
	MaxStaminaPerLevel = 2,          -- +2 per player level above 1
	BaseStaminaRegen = 0.05,
	StaminaRegenPerLevel = 0.0005,   -- +0.0005 per player level above 1
}