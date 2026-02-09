-- @ScriptType: ModuleScript
return {
	--> Transports
	VehicleCoolDown = 2, --5

	--Sprint CoolDown
	SprintCoolDown = 0, --1
	StaminaRegenerationRate = .1, -- *dt ..1
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
	AirKickXp = 4,
	EarthStompXp = 5,
	FireDropKickXp = 7,
	WaterStanceXp = 3, -- every second on damage
	FistXP = 3,
	MeteoriteSwordXP = 6,
	BoomerangXP = 8,

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

	--> Spawn Protection (Sprint 1)
	SpawnProtectionDuration = 8, -- seconds of ForceField after spawning
}
