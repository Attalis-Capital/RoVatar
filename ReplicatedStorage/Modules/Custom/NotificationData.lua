-- @ScriptType: ModuleScript
local NotificationData = {}

local CD = require(script.Parent.Constants)

NotificationData.LockedAbility_Alert = {
	Title = "Locked ability",
	Description = "This ability requires purchase from the Marketplace.",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.EnergyDepleted_Alert = {
	Title = "Energy depleted!",
	Description = 'Your energy has run out. Press "N" to meditate and recover it.',
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.InsufficientMana = {
	Title = "Not Enough Mana",
	Description = `You need more mana to Perform. Press "N" to recover.`,
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.InsufficientStamina = {
	Title = "Not Enough Stamina",
	Description = "You need more stamina to perform. Stamina recovers over time.",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.AppaSpawnBlocked = {
	Title = "Spawn Blocked",
	Description = `Cannot summon {CD.Items.Appa.Name} here — the area is obstructed.`,
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.DeleteProfile_Confirmation = {
	Title = "Confirm Character Deletion?",
	Description = "Are you sure you want to delete this character? This action cannot be undone.",
	Type = CD.NotificationType.Popup,
	yesBtnText = "Delete",
	noBtnText = "Cancel",
}

NotificationData.Level5 = {
	Title = "Level 5",
	Description = "Level 5 reached. Your training begins to show.",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.Level10 = {
	Title = "Level 10",
	Description = "Level 10 unlocked. You’re becoming stronger.",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.Level15 = {
	Title = "Level 15",
	Description = "Level 15! You’ve come far, but the path is long.",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.Level20 = {
	Title = "Level 20",
	Description = "Level 20 achieved. Your presence is felt.",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.Level25 = {
	Title = "Level 25",
	Description = "Level 25! A true warrior in the making.",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.Level30 = {
	Title = "Level 30",
	Description = "Level 30 unlocked. Few walk this path with such power.",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.FirstDeath = {
	Title = "First death",
	Description = "You have fallen for the first time. Learn from defeat.",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.Kills1 = {
	Title = "First Kill",
	Description = "First enemy defeated! The journey begins.",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.Kills25 = {
	Title = "25 Kills",
	Description = "25 kills achieved! You’re becoming a true warrior.",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.Kills50 = {
	Title = "50 Kills",
	Description = "Half a hundred defeated! Few can match your skill.",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.Kills100 = {
	Title = "100 Kills",
	Description = "100 kills! You are a legend in the making.",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.NewIsland = {
	Title = "New island",
	Description = "You’ve discovered a new island. Adventure awaits!",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.FirstAbilityUse = { -- Not Done
	Title = "First use of abilities",
	Description = "You’ve used magic for the first time. Your journey as a bender begins.",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.FirstGliderUse = { -- Not Done
	Title = `First use of {CD.Items.Glider.Name}`,
	Description = `You’ve taken flight with your {CD.Items.Glider.Name}. The skies are yours to explore!`,
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.AbilityUnlocked = {
	Title = "New ability unlocked",
	Description = "New magic unlocked. Harness your power and master it!",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.GliderUnlocked = {
	Title = `{CD.Items.Glider.Name} unlocked`,
	Description = `{CD.Items.Glider.Name} unlocked. Soar freely across the world!`,
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

NotificationData.AllAbilitiesUnlocked = {
	Title = "Unlocking all abilities",
	Description = "All abilities unlocked. You’ve mastered every element of your power!",
	AutoHideTime = 4,
	Type = CD.NotificationType.Notification,
}

return NotificationData
