-- @ScriptType: ModuleScript
local QuestsModule = {}
local Constants = require(script.Parent.Constants)
local CustomTypes = require(script.Parent.CustomTypes)

QuestsModule.QuestObjectives = Constants.QuestObjectives
QuestsModule.TargetIds = Constants.QuestTargetIds

--[[
Quest: Objective is important in every Quest
]]

function SecToHours(seconds)
	local hours = seconds / 3600
	return math.floor(hours * 100 + 0.5) / 100 
end

QuestsModule.Quests = {
	OneTime = {
		LikeGame = {

		},
		FavGame = {

		},
		InviteFriend = {

		}
	},

	Tutorial = {
		Kill = {
			DefeatWith3EarthBender = {
				Id = "DefeatWith3EarthBender",
				Name = `Battle with {Constants.NPCsType.EarthBender}s`,
				Title = "Foundations of Power",
				Objective = QuestsModule.QuestObjectives.Kill,
				Description = `Defeat the {Constants.NPCsType.EarthBender} 3 Times`,
				PendingMsg = `Please complete your task of defeating 3 {Constants.NPCsType.EarthBender}s before returning.`,
				Targets = {
					[1] = {Id = QuestsModule.TargetIds.EarthBender, Title = `Defeat first {Constants.NPCsType.EarthBender}`},
					[2] = {Id = QuestsModule.TargetIds.EarthBender, Title = `Defeat second {Constants.NPCsType.EarthBender}`},
					[3] = {Id = QuestsModule.TargetIds.EarthBender, Title = `Defeat third {Constants.NPCsType.EarthBender}`},
				},
				Duration = SecToHours(360),  --.1, -- In Hours
				CompleteMsg = "Mastered", -- Will only Use by NPC AI to claim the reward.
				Reward = {
					[1] = {
						Type = Constants.QuestRewardType.Gold,
						Value = 50,
					},
					[2] = {
						Type = Constants.QuestRewardType.XP,
						Value = 50,
					},
				},
			},
		},
	},

	LevelUP = {
		Kill = {
			DefeatWith5EarthBender = {
				Id = "DefeatWith5EarthBender",
				Name = `Battle with {Constants.NPCsType.EarthBender}s`,
				Title = "Stone by Stone, You Will Learn",

				Objective = QuestsModule.QuestObjectives.Kill,
				Description = `Defeat 5 {Constants.NPCsType.EarthBender}s`,
				PendingMsg = `Please complete your task of defeating 5 {Constants.NPCsType.EarthBender}s before returning.`,
				Targets = {
					[1] = {Id = QuestsModule.TargetIds.EarthBender, Title = "Defeat your first "..Constants.NPCsType.EarthBender},
					[2] = {Id = QuestsModule.TargetIds.EarthBender, Title = "Defeat your second "..Constants.NPCsType.EarthBender},
					[3] = {Id = QuestsModule.TargetIds.EarthBender, Title = "Defeat your third "..Constants.NPCsType.EarthBender},
					[4] = {Id = QuestsModule.TargetIds.EarthBender, Title = "Defeat two more "..Constants.NPCsType.EarthBender},
					[5] = {Id = QuestsModule.TargetIds.EarthBender, Title = `Defeat the final {Constants.NPCsType.EarthBender} to complete the quest`},
				},
				Duration = SecToHours(360),
				CompleteMsg = "Well done! Here's some XP and Gold for helping us defend our village! Come back again for more quests", -- Will only Use by NPC AI to claim the reward.
				Reward = {
					[1] = {
						Type = Constants.QuestRewardType.Gold,
						Value = 200,
					},
					[2] = {
						Type = Constants.QuestRewardType.XP,
						Value = 500,
					},
				},
			},
			DefendVillage = {
				Id = "DefendVillage",
				Name = `Battle with {Constants.NPCsType.EarthBender}s`,
				Title = "Repel the Earth-Bending Horde",
				Objective = QuestsModule.QuestObjectives.Kill,
				Description = `Defeat 10 {Constants.NPCsType.EarthBender}s`,
				Targets = { -- Step wise tasks
					[1]	= {Id = QuestsModule.TargetIds.EarthBender, Title = `Defeat 1st {Constants.NPCsType.EarthBender}`},
					[2]	= {Id = QuestsModule.TargetIds.EarthBender, Title = `Defeat 2nd {Constants.NPCsType.EarthBender}`},
					[3]	= {Id = QuestsModule.TargetIds.EarthBender, Title = `Defeat 3rd {Constants.NPCsType.EarthBender}`},
					[4]	= {Id = QuestsModule.TargetIds.EarthBender, Title = `Defeat 4th {Constants.NPCsType.EarthBender}`},
					[5]	= {Id = QuestsModule.TargetIds.EarthBender, Title = `Defeat 5th {Constants.NPCsType.EarthBender}`},
					[6]	= {Id = QuestsModule.TargetIds.EarthBender, Title = `Defeat 6th {Constants.NPCsType.EarthBender}`},
					[7]	= {Id = QuestsModule.TargetIds.EarthBender, Title = `Defeat 7th {Constants.NPCsType.EarthBender}`},
					[8]	= {Id = QuestsModule.TargetIds.EarthBender, Title = `Defeat 8th {Constants.NPCsType.EarthBender}`},
					[9]	= {Id = QuestsModule.TargetIds.EarthBender, Title = `Defeat 9th {Constants.NPCsType.EarthBender}`},
					[10] = {Id = QuestsModule.TargetIds.EarthBender, Title = `Defeat final {Constants.NPCsType.EarthBender}`},
				},
				Duration = SecToHours(600),
				PendingMsg = `The village is still under attack! Defeat 10 {Constants.NPCsType.EarthBender}s to help defend it..`,
				CompleteMsg = "Welcome done! Here's some XP and Gold for helping us defend our village! Come back again for more quests", -- Will only Use by NPC AI to claim the reward.
				Reward = {
					[1] = {
						Type = Constants.QuestRewardType.Gold,
						Value = 200,
					},
					[2] = {
						Type = Constants.QuestRewardType.XP,
						Value = 2500,
					},
				},
			},
		},
		Find = {
			OldBook = {
				Id = "OldBook",
				Name = "Find Old Book",
				Title = "Pages Lost to Time",
				Objective = QuestsModule.QuestObjectives.Find,
				Description = `Find and retrieve the Old Book from the Big House in {Constants.Items.KioshiIsland.Name}`,
				Targets = {
					[1]	= {Id = QuestsModule.TargetIds.OldBook, Title = "Go to Big house and pick old book"},
				}, -- Count
				Duration = SecToHours(240),
				PendingMsg = `You still need to find the Old Book from the Big House on {Constants.Items.KioshiIsland.Name}`,
				CompleteMsg = "You've successfully brought back the Old Book! Good job!", -- Will only Use by NPC AI to claim the reward.
				Reward = {
					[1] = {
						Type = Constants.QuestRewardType.Gold,
						Value = 250,
					},
					[2] = {
						Type = Constants.QuestRewardType.XP,
						Value = 1500,
					},
				},
			},

			MagicBook = {
				Id = "MagicBook",
				Name = "Find Magic Book",
				Title = "Ink Woven with Power", 
				Objective = QuestsModule.QuestObjectives.Find,
				Description = `Find and retrieve the Magic Book from {Constants.Items.KioshiIsland.Name}`,
				Targets = {
					[1]	= {Id = QuestsModule.TargetIds.MagicBook, Title = "Go around and find Magic book."},
				}, -- Count
				Duration = SecToHours(240),
				PendingMsg = `The Magic Book is still out there! Keep searching around {Constants.Items.KioshiIsland.Name}`,
				CompleteMsg = "You've successfully brought back the Magic Book! Good job!", -- Will only Use by NPC AI to claim the reward.
				Reward = {
					[1] = {
						Type = Constants.QuestRewardType.Gold,
						Value = 250,
					},
					[2] = {
						Type = Constants.QuestRewardType.XP,
						Value = 1500,
					},
				},
			},

			Shop = {
				Id = "Shop",
				Name = "Locate the Item Shop",
				Title = "The Merchant’s Hidden Corner",
				Objective = QuestsModule.QuestObjectives.Find,
				Description = `Find the hidden shop on {Constants.Items.KioshiIsland.Name} and report back.`,
				Targets = {
					[1]	= {Id = QuestsModule.TargetIds.Shop, Title = "Locate Shop Area"},
				}, -- Count
				Duration = SecToHours(180),
				PendingMsg = `The hidden shop hasn't been found yet! Keep exploring {Constants.Items.KioshiIsland.Name}`,
				CompleteMsg = "You've found the shop! Great work exploring!", -- Will only Use by NPC AI to claim the reward.
				Reward = {
					[1] = {
						Type = Constants.QuestRewardType.Gems,
						Value = 250,
					},
					[2] = {
						Type = Constants.QuestRewardType.XP,
						Value = 1500,
					},
				},
			}
		},
		Purchase = {
			Glider = {
				Id = "Glider",
				Name = `Purchase {Constants.Items.Glider.Name} from Shop`,
				Title = "Wings of Freedom",
				Objective = QuestsModule.QuestObjectives.Purchase,
				Description = `Buy the {Constants.Items.Glider.Name} from the shop to complete this quest.`,
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.Glider, Title = `Head to the shop and purchase the {Constants.Items.Glider.Name} to complete this quest.`},
				}, -- Count
				Duration = SecToHours(120),
				PendingMsg = `You still need to purchase the {Constants.Items.Glider.Name} from the shop. Don't forget to complete your quest!`,
				CompleteMsg = `Great job! You've successfully purchased the {Constants.Items.Glider.Name}!`,
				Reward = {
					[1] = {
						Type = Constants.QuestRewardType.Gems,
						Value = 250,
					},
					[2] = {
						Type = Constants.QuestRewardType.XP,
						Value = 3000,
					},
				},
			},
		},
		Visit = {
			VisitToFireNation = {
				Id = "VisitToFireNation",
				Name = `Visit to {Constants.Items.LavaIsland.Name}`,
				Title = "Soaring to the Fire Nation", 
				Objective = QuestsModule.QuestObjectives.Visit,
				Description = `Use your {Constants.Items.Glider.Name} to fly to {Constants.Items.LavaIsland.Name}.`,
				Targets = {
					[1] = {Id = QuestsModule.TargetIds.LavaIsland, Title = `Travel to {Constants.Items.LavaIsland.Name}.` },
				},
				Duration = SecToHours(300),
				PendingMsg = `You haven't reached {Constants.Items.LavaIsland.Name} yet. Use your {Constants.Items.Glider.Name} to fly there and complete your journey!`,
				CompleteMsg = `Fantastic! You've successfully reached {Constants.Items.LavaIsland.Name}!`,
				Reward = {
					[1] = {
						Type = Constants.QuestRewardType.Gems,
						Value = 250,
					},
					[2] = {
						Type = Constants.QuestRewardType.XP,
						Value = 2000,
					},
				},
			}
		}
	},

	NPC = {

		Visit = {
			KioshiIsland = {
				Id = "KioshiIsland",
				Name = `{Constants.Items.KioshiIsland.Name}`,
				Title = "The Watcher’s Stand",
				Description = `Glide to the {Constants.Items.KioshiIsland.Name}`,
				Objective = QuestsModule.QuestObjectives.Visit,
				PendingMsg = `The {Constants.Items.KioshiIsland.Name} still await your arrival. Glide there to complete your task.`,
				CompleteMsg = `You've successfully reached {Constants.Items.KioshiIsland.Name}!`,
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.KioshiIsland, Title = `Glide to {Constants.Items.KioshiIsland.Name}` },    
				},
				Duration = SecToHours(120),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 150 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 150 },
				},
			},
			GreenTribeUp = {
				Id = "GreenTribeUp",
				Name = `{Constants.Items.GreenTribeUp.Name}`,
				Title = "Breath of the Wild Grove",
				Description = `Glide to the {Constants.Items.GreenTribeUp.Name}`,
				Objective = QuestsModule.QuestObjectives.Visit,
				PendingMsg = `The {Constants.Items.GreenTribeUp.Name} still await your arrival. Glide there to complete your task..`,
				CompleteMsg = `You've successfully visited {Constants.Items.GreenTribeUp.Name}.`,
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.GreenTribeUp, Title = `Glide to {Constants.Items.GreenTribeUp.Name}` },
				},
				Duration = SecToHours(240),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 100 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 100 },
				},
			},


			SounderAirTemple = {
				Id = "SounderAirTemple",
				Name = `{Constants.Items.SounderAirTemple.Name}`,
				Title = "Winds of Awakening",
				Description = `Glide to the {Constants.Items.SounderAirTemple.Name}`,
				Objective = QuestsModule.QuestObjectives.Visit,
				PendingMsg = `The {Constants.Items.SounderAirTemple.Name} still await your arrival. Glide there to complete your task..`,
				CompleteMsg = `You've successfully visited {Constants.Items.SounderAirTemple.Name}!`,
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.SounderAirTemple, Title = `Glide to {Constants.Items.SounderAirTemple.Name}` },
				},
				Duration = SecToHours(240),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 100 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 150 },
				},
			},

			GreenTribeDown = {
				Id = "GreenTribeDown",
				Name = `{Constants.Items.GreenTribeDown.Name}`,
				Title = "Roots of Balance",
				Description = `Glide to the {Constants.Items.GreenTribeDown.Name}`,
				Objective = QuestsModule.QuestObjectives.Visit,
				PendingMsg = `Let the wind carry you where the forest breathes. Glide to the {Constants.Items.GreenTribeDown.Name}.`,
				CompleteMsg = `You've successfully visited {Constants.Items.GreenTribeDown.Name}!`,
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.GreenTribeDown, Title = `Glide to {Constants.Items.GreenTribeDown.Name}` },
				},
				Duration = SecToHours(300),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 100 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 150 },
				},
			},

			LavaIsland = {
				Id = "LavaIsland",
				Name = `{Constants.Items.LavaIsland.Name}`,
				Title = "Heart of Fire",
				Description = `Glide to the {Constants.Items.LavaIsland.Name}`,
				Objective = QuestsModule.QuestObjectives.Visit,
				PendingMsg = `Let the wind carry you where the forest breathes. Glide to the {Constants.Items.LavaIsland.Name}.`,
				CompleteMsg = `You've successfully visited {Constants.Items.LavaIsland.Name}!`,
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.LavaIsland, Title = `Glide to {Constants.Items.LavaIsland.Name}` },
				},
				Duration = SecToHours(240),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 100 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 150 },
				},
			},

			NorthenWaterTribe = {
				Id = "NorthenWaterTribe",
				Name = `{Constants.Items.NorthenWaterTribe.Name}`,
				Title = "Whispers Beneath the Ice",
				Description = `Glide to the {Constants.Items.NorthenWaterTribe.Name}`,
				Objective = QuestsModule.QuestObjectives.Visit,
				PendingMsg = `Let the wind carry you where the forest breathes. Glide to the {Constants.Items.NorthenWaterTribe.Name}.`,
				CompleteMsg = `You've successfully visited {Constants.Items.NorthenWaterTribe.Name}!`,
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.NorthenWaterTribe, Title = `Glide to {Constants.Items.NorthenWaterTribe.Name}` },
				},
				Duration = SecToHours(240),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 100 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 150 },
				},
			},

			SnowIsland = {
				Id = "SnowIsland",
				Name = `{Constants.Items.SnowIsland.Name}`,
				Title = "Shroud of Ice",
				Description = `Glide to the {Constants.Items.SnowIsland.Name}`,
				Objective = QuestsModule.QuestObjectives.Visit,
				PendingMsg = `The cold winds call you. Glide to {Constants.Items.SnowIsland.Name} to complete your journey.`,
				CompleteMsg = `You've successfully visited {Constants.Items.SnowIsland.Name}!`,
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.SnowIsland, Title = `Glide to {Constants.Items.SnowIsland.Name}` },
				},
				Duration = SecToHours(300),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 100 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 150 },
				},
			},

			WesternTemple = {
				Id = "WesternTemple",
				Name = `{Constants.Items.WesternTemple.Name}`,
				Title = 'Above the Clouds',
				Description = `Glide to the {Constants.Items.WesternTemple.Name}`,
				Objective = QuestsModule.QuestObjectives.Visit,
				PendingMsg = `Let the wind carry you where the forest breathes. Glide to the {Constants.Items.WesternTemple.Name}.`,
				CompleteMsg = `You've successfully visited {Constants.Items.WesternTemple.Name}!`,
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.WesternTemple, Title = `Glide to {Constants.Items.WesternTemple.Name}` },
				},
				Duration = SecToHours(240),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 100 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 150 },
				},
			},
		},

		Kill = {
			WaterBender = {
				Id = "WaterBender",
				Name = `Battle with {Constants.NPCsType.WaterBender}`,
				Title = "Tides of Resistance",
				Description = `Defeat 5 {Constants.NPCsType.WaterBender}`,
				Objective = QuestsModule.QuestObjectives.Kill,
				PendingMsg = `You need to defeat 5 {Constants.NPCsType.WaterBender}`,
				CompleteMsg = `Great job! You've defeated all 5 {Constants.NPCsType.WaterBender}s.`,
				Targets = {
					[1] = { Id = "WaterBender", Title = `Defeat 1st {Constants.NPCsType.WaterBender}` },
					[2] = { Id = "WaterBender", Title = `Defeat 2nd {Constants.NPCsType.WaterBender}` },
					[3] = { Id = "WaterBender", Title = `Defeat 3rd {Constants.NPCsType.WaterBender}` },
					[4] = { Id = "WaterBender", Title = `Defeat 4th {Constants.NPCsType.WaterBender}` },
					[5] = { Id = "WaterBender", Title = `Defeat the final {Constants.NPCsType.WaterBender}` },
				},
				Duration = SecToHours(240),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 100 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 100 },
				},
			},
			FireBender = {
				Id = "FireBender",
				Name = `Battle with {Constants.NPCsType.FireBender}`,
				Title = "Burning Challenge",
				Description = `Defeat 5 {Constants.NPCsType.FireBender}`,
				Objective = QuestsModule.QuestObjectives.Kill,
				PendingMsg = `You need to defeat 5 {Constants.NPCsType.FireBender}`,
				CompleteMsg = `Great job! You've defeated all 5 {Constants.NPCsType.FireBender}s.`,
				Targets = {
					[1] = { Id = "FireBender", Title = `Defeat 1st {Constants.NPCsType.FireBender}` },
					[2] = { Id = "FireBender", Title = `Defeat 2nd {Constants.NPCsType.FireBender}` },
					[3] = { Id = "FireBender", Title = `Defeat 3rd {Constants.NPCsType.FireBender}` },
					[4] = { Id = "FireBender", Title = `Defeat 4th {Constants.NPCsType.FireBender}` },
					[5] = { Id = "FireBender", Title = `Defeat the final {Constants.NPCsType.FireBender}` },
				},
				Duration = SecToHours(300),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 100 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 100 },
				},
			},
			EarthBender = {
				Id = "EarthBender",
				Name = `Battle with {Constants.NPCsType.EarthBender}`,
				Title = "Trial of the Peaks",
				Description = `Defeat 10 {Constants.NPCsType.EarthBender}`,
				Objective = QuestsModule.QuestObjectives.Kill,
				PendingMsg = `You need to defeat 10 {Constants.NPCsType.EarthBender}.`,
				CompleteMsg = `Well done! You've defeated all 10 {Constants.NPCsType.EarthBender}s.`,
				Targets = {
					[1] = { Id = "EarthBender", Title = "Defeat 1st " .. Constants.NPCsType.EarthBender},
					[2] = { Id = "EarthBender", Title = "Defeat 2nd " .. Constants.NPCsType.EarthBender},
					[3] = { Id = "EarthBender", Title = "Defeat 3rd " .. Constants.NPCsType.EarthBender},
					[4] = { Id = "EarthBender", Title = "Defeat 4th " .. Constants.NPCsType.EarthBender},
					[5] = { Id = "EarthBender", Title = "Defeat 5th " .. Constants.NPCsType.EarthBender},
					[6] = { Id = "EarthBender", Title = "Defeat 6th " .. Constants.NPCsType.EarthBender},
					[7] = { Id = "EarthBender", Title = "Defeat 7th " .. Constants.NPCsType.EarthBender},
					[8] = { Id = "EarthBender", Title = "Defeat 8th " .. Constants.NPCsType.EarthBender},
					[9] = { Id = "EarthBender", Title = "Defeat 9th " .. Constants.NPCsType.EarthBender},
					[10] = { Id = "EarthBender", Title = "Defeat the final " .. Constants.NPCsType.EarthBender},
				},
				Duration = SecToHours(300),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 100 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 200 },
				},
			},
			AirBender = {
				Id = "AirBender",
				Name = `Battle with {Constants.NPCsType.AirBender}`,
				Title = "The Wind’s Trial",
				Description = `Defeat 15 {Constants.NPCsType.AirBender}`,
				Objective = QuestsModule.QuestObjectives.Kill,
				PendingMsg = `You need to defeat 15 {Constants.NPCsType.AirBender}.`,
				CompleteMsg = `Great job! You've defeated all 15 {Constants.NPCsType.AirBender}s!`,
				Targets = {
					[1] = { Id = "AirBender", Title = "Defeat 1st " .. Constants.NPCsType.AirBender},
					[2] = { Id = "AirBender", Title = "Defeat 2nd " .. Constants.NPCsType.AirBender},
					[3] = { Id = "AirBender", Title = "Defeat 3rd " .. Constants.NPCsType.AirBender},
					[4] = { Id = "AirBender", Title = "Defeat 4th " .. Constants.NPCsType.AirBender},
					[5] = { Id = "AirBender", Title = "Defeat 5th " .. Constants.NPCsType.AirBender},
					[6] = { Id = "AirBender", Title = "Defeat 6th " .. Constants.NPCsType.AirBender},
					[7] = { Id = "AirBender", Title = "Defeat 7th " .. Constants.NPCsType.AirBender},
					[8] = { Id = "AirBender", Title = "Defeat 8th " .. Constants.NPCsType.AirBender},
					[9] = { Id = "AirBender", Title = "Defeat 9th " .. Constants.NPCsType.AirBender},
					[10] = { Id = "AirBender", Title = "Defeat 10th " .. Constants.NPCsType.AirBender},
					[11] = { Id = "AirBender", Title = "Defeat 11th " .. Constants.NPCsType.AirBender},
					[12] = { Id = "AirBender", Title = "Defeat 12th " .. Constants.NPCsType.AirBender},
					[13] = { Id = "AirBender", Title = "Defeat 13th " .. Constants.NPCsType.AirBender},
					[14] = { Id = "AirBender", Title = "Defeat 14th " .. Constants.NPCsType.AirBender},
					[15] = { Id = "AirBender", Title = "Defeat the final " .. Constants.NPCsType.AirBender},
				},
				Duration = SecToHours(360),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 100 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 150 },
				},
			},
		},

		Find = {
			OldBook = {
				Id = "OldBook",
				Name = "Find the Old Book",
				Title = "Pages Lost to Time",
				Objective = QuestsModule.QuestObjectives.Find,
				Description = `Find and retrieve the Old Book from the Big House in {Constants.Items.KioshiIsland.Name}`,
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.OldBook, Title = "Go to the Big House and pick up the Old Book." },
				},
				Duration = SecToHours(120),
				PendingMsg = `You still need to find the Old Book from the Big House on {Constants.Items.KioshiIsland.Name}.`,
				CompleteMsg = "You've successfully brought back the Old Book! Good job!",
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gold, Value = 50 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 50 },
				},
			},
			MagicBook = {
				Id = "MagicBook",
				Name = "Find the Magic Book",
				Title = "Ink Woven with Power",
				Objective = QuestsModule.QuestObjectives.Find,
				Description = `Find and retrieve the Magic Book from {Constants.Items.KioshiIsland.Name}.`,
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.MagicBook, Title = `Search around {Constants.Items.KioshiIsland.Name} to find the Magic Book.` },
				},
				Duration = SecToHours(240),
				PendingMsg = `The Magic Book is still out there! Keep searching around {Constants.Items.KioshiIsland.Name}.`,
				CompleteMsg = "You've successfully brought back the Magic Book! Good job!",
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gold, Value = 100 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 100 },
				},
			},

		},

		Train = {
			ManaRecovery = {
				Id = "ManaRecovery",
				Name = "Breathe Before the Wave",
				Title = "Breathe Before the Wave", 
				Objective = QuestsModule.QuestObjectives.Train,
				Description = "Learn to manage your energy by exhausting your mana and restoring it through meditation.",
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.ManaDeplete, Title = "Deplete your Mana to 0 (or under 30%) by using Spell." },
					[2] = { Id = QuestsModule.TargetIds.ManaRestored, Title = "Meditate (press N) until Mana is fully restored." },
				},
				Duration = SecToHours(180),
				PendingMsg = "Exhaust your mana through spellcasting, then focus your mind to restore it through meditation. Learn the flow — push and recover.",
				CompleteMsg = "Good. You’ve felt exhaustion — and now you’ve learned recovery. In the heat of battle, it's not always the strongest who win… but those who know when to pause.",
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gold, Value = 200 },
					[2] = { Type = Constants.QuestRewardType.LevelUp, Value = 1 },
					--[2] = { Type = Constants.QuestRewardType.XP, Value = 200 },
				},
			},
			BreathTheSurface = {
				Id = "BreathTheSurface",
				Name = "Beneath the Surface",
				Title = "Beneath the Surface",
				Objective = QuestsModule.QuestObjectives.Find,
				Description = `Dive beneath the waves to uncover a relic lost to the sea. Only the calm and focused can retrieve what lies below.`,
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.SunkenRelic1, Title = "Dive into the sea and retrieve the First Sunken Relic" },
					[2] = { Id = QuestsModule.TargetIds.SunkenRelic2, Title = "Dive into the sea and retrieve the Second Sunken Relic" },
					[3] = { Id = QuestsModule.TargetIds.SunkenRelic3, Title = "Dive into the sea and retrieve the Third Sunken Relic" },
				},
				Duration = SecToHours(120),
				PendingMsg = `Dive into the depths and recover the Sunken Relic. Let the ocean guide your movement — steady, fluid, and fearless.`,
				CompleteMsg = "You’ve done well. Few have the courage to dive into the unknown. Remember this feeling — calm, focused, fluid. That is the essence of waterbending.",
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gold, Value = 200 },
					[2] = { Type = Constants.QuestRewardType.LevelUp, Value = 1 },
				},
			},
		},

		Combined = {
			The_Zephir_Reclamation = {
				Id = "The_Zephir_Reclamation",
				Name = "The Zephir Reclamation",
				Title = "The Zephir Reclamation",
				Objective = QuestsModule.QuestObjectives.Combined,
				Description = `Glide to {Constants.Items.SounderAirTemple.Name} and defeat 10 {Constants.NPCsType.AirBender} NPCs and talk to Sael to reclaim the location.`,
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.SounderAirTemple, Title = `Glide to {Constants.Items.SounderAirTemple.Name}`},
					[2] = { Id = "AirBender", Title = "Defeat first " .. Constants.NPCsType.AirBender},
					[3] = { Id = "AirBender", Title = "Defeat second " .. Constants.NPCsType.AirBender},
					[4] = { Id = "AirBender", Title = "Defeat third " .. Constants.NPCsType.AirBender},
					[5] = { Id = "AirBender", Title = "Defeat 4th " .. Constants.NPCsType.AirBender},
					[6] = { Id = "AirBender", Title = "Defeat 5th " .. Constants.NPCsType.AirBender},
					[7] = { Id = "AirBender", Title = "Defeat 6th " .. Constants.NPCsType.AirBender},
					[8] = { Id = "AirBender", Title = "Defeat 7th " .. Constants.NPCsType.AirBender},
					[9] = { Id = "AirBender", Title = "Defeat 8th " .. Constants.NPCsType.AirBender},
					[10] = { Id = "AirBender", Title = "Defeat 9th " .. Constants.NPCsType.AirBender},
					[11] = { Id = "AirBender", Title = "Defeat final " .. Constants.NPCsType.AirBender},
					[12] = { Id = QuestsModule.TargetIds["Zephir Guide"], Title = "Talk to Sael"},
				},
				Duration = SecToHours(600),
				PendingMsg = `Glide to Zephyr Monastery and defeat {Constants.NPCsType.AirBender} NPCs to reclaim the location.`,
				CompleteMsg = "You've reclaimed the Zephyr Monastery! The Skystriders have been driven out, and the skies are calm once more.",
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gold, Value = 300 },
					[2] = { Type = Constants.QuestRewardType.LevelUp, Value = 1 },
				},
			},
			
			Return_To_Sentinel_Island = {
				Id = "Return_To_Sentinel_Island",
				Name = "Use the teleport system to return to Sentinel Isle.",
				Title = "Through the Veil, Back Home",
				Objective = QuestsModule.QuestObjectives.Combined,
				Description = `Open the world map and select Sentinel Isle to teleport back. Report to the elder upon arrival.`,
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.OpenMap, Title = `Open World Map`},
					[2] = { Id = QuestsModule.TargetIds.KioshiIsland, Title = `Select Sentinel Isle`},
					[3] = { Id = QuestsModule.TargetIds["Journey Master"], Title = `Report to Oryn.`},
				},
				Duration = SecToHours(120),
				PendingMsg = `The elder awaits your return. Use the teleport on the Map.`,
				CompleteMsg = "You have safely returned to Sentinel Isle. The elder welcomes you back with gratitude, and the island feels a little more at peace.",
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gold, Value = 500 },
					[2] = { Type = Constants.QuestRewardType.LevelUp, Value = 1 },
				},
			},

			The_Bloom_of_Power = {
				Id = "The_Bloom_of_Power",
				Name = "The Bloom of Power",
				Title = "The Bloom of Power",
				Objective = QuestsModule.QuestObjectives.Combined,
				Description = `Glide to {Constants.Items.WesternTemple.Name} and retrieve the sacred Flower of Life from the mountain peak.`,
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.WesternTemple, Title = `Glide to the {Constants.Items.WesternTemple.Name}` },
					[2] = { Id = QuestsModule.TargetIds.FlowerOfLife, Title = `Collect the Flower of Life` },
				},
				Duration = SecToHours(600),
				PendingMsg = `Your task awaits at the {Constants.Items.WesternTemple.Name}. Glide there and recover the legendary Flower of Life hidden atop the mountain.`,
				CompleteMsg = "You've successfully retrieved the Flower of Life. Its energy pulses with ancient strength — a true symbol of your growing power.",
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gold, Value = 600 },
					[2] = { Type = Constants.QuestRewardType.LevelUp, Value = 1 },
				},
			},

			TrialByFlame = {
				Id = "TrialByFlame",
				Name = "Trial by Flame",
				Title = "Trial by Flame",
				Objective = QuestsModule.QuestObjectives.Combined,
				Description = "Face the Molten Crag King, guardian of an ancient elemental shrine. Dodge, strike, and survive the trial by fire.",
				Targets = {
					[1] = {
						Id = QuestsModule.TargetIds.LavaIsland,
						Title = `Glide to the {Constants.Items.LavaIsland.Name}`
					},
					[2] = {
						Id = QuestsModule.TargetIds.FireBender_MiniBoss,
						Title = `Defeat the {Constants.NPCsType.FireBender_MiniBoss} near the Blazing Peak Tower.`,
					},
				},
				Duration = SecToHours(900),
				PendingMsg = "The shrine waits — and the Molten Crag King stands in your path. Show you can overcome flame itself.",
				CompleteMsg = "You've conquered the trial. Flame obeys strength, not fear. The path to true mastery continues.",
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gold, Value = 700},
					[2] = { Type = Constants.QuestRewardType.LevelUp, Value = 1 },
				},
			},
		},

	},

	-- no need of duration in daily quest.
	Daily = {
		Visit = {
			KioshiIsland = {
				Id = "KioshiIsland",
				Name = Constants.Items.KioshiIsland.Name,
				Title = "The Watcher’s Stand",
				Description = "Visit " .. Constants.Items.KioshiIsland.Name,
				Objective = QuestsModule.QuestObjectives.Visit,
				PendingMsg = "Please Glide to " .. Constants.Items.KioshiIsland.Name .. ".",
				CompleteMsg = "You've successfully reached " .. Constants.Items.KioshiIsland.Name .. "!",
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.KioshiIsland, Title = "Glide to " .. Constants.Items.KioshiIsland.Name },
				},
				Duration = SecToHours(240),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 50 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 50 },
				},
			},
			GreenTribeUp = {
				Id = "GreenTribeUp",
				Name = Constants.Items.GreenTribeUp.Name,
				Title = "Breath of the Wild Grove",
				Description = "Visit " .. Constants.Items.GreenTribeUp.Name,
				Objective = QuestsModule.QuestObjectives.Visit,
				PendingMsg = "Please Glide to " .. Constants.Items.GreenTribeUp.Name .. ".",
				CompleteMsg = "You've successfully visited " .. Constants.Items.GreenTribeUp.Name .. "!",
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.GreenTribeUp, Title = "Glide to " .. Constants.Items.GreenTribeUp.Name },
				},
				Duration = SecToHours(240),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 50 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 50 },
				},
			},
			SounderAirTemple = {
				Id = "SounderAirTemple",
				Name = Constants.Items.SounderAirTemple.Name,
				Title = "Winds of Awakening",
				Description = "Visit " .. Constants.Items.SounderAirTemple.Name,
				Objective = QuestsModule.QuestObjectives.Visit,
				PendingMsg = "Please Glide to " .. Constants.Items.SounderAirTemple.Name .. ".",
				CompleteMsg = "You've successfully visited " .. Constants.Items.SounderAirTemple.Name .. "!",
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.SounderAirTemple, Title = "Glide to " .. Constants.Items.SounderAirTemple.Name },
				},
				Duration = SecToHours(240),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 50 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 50 },
				},
			},
			GreenTribeDown = {
				Id = "GreenTribeDown",
				Name = Constants.Items.GreenTribeDown.Name,
				Title = "Roots of Balance",
				Description = "Visit " .. Constants.Items.GreenTribeDown.Name,
				Objective = QuestsModule.QuestObjectives.Visit,
				PendingMsg = "Please Glide to " .. Constants.Items.GreenTribeDown.Name .. ".",
				CompleteMsg = "You've successfully visited " .. Constants.Items.GreenTribeDown.Name .. "!",
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.GreenTribeDown, Title = "Glide to " .. Constants.Items.GreenTribeDown.Name },
				},
				Duration = SecToHours(240),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 50 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 50 },
				},
			},
			LavaIsland = {
				Id = "LavaIsland",
				Name = Constants.Items.LavaIsland.Name,
				Title = "Heart of Fire",
				Description = "Visit " .. Constants.Items.LavaIsland.Name,
				Objective = QuestsModule.QuestObjectives.Visit,
				PendingMsg = "Please Glide to " .. Constants.Items.LavaIsland.Name .. ".",
				CompleteMsg = "You've successfully visited " .. Constants.Items.LavaIsland.Name .. "!",
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.LavaIsland, Title = "Glide to " .. Constants.Items.LavaIsland.Name },
				},
				Duration = SecToHours(240),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 50 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 50 },
				},
			},
			NorthenWaterTribe = {
				Id = "NorthenWaterTribe",
				Name = Constants.Items.NorthenWaterTribe.Name,
				Title = "Whispers Beneath the Ice",
				Description = "Visit " .. Constants.Items.NorthenWaterTribe.Name,
				Objective = QuestsModule.QuestObjectives.Visit,
				PendingMsg = "Please Glide to " .. Constants.Items.NorthenWaterTribe.Name .. ".",
				CompleteMsg = "You've successfully visited " .. Constants.Items.NorthenWaterTribe.Name .. "!",
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.NorthenWaterTribe, Title = "Glide to " .. Constants.Items.NorthenWaterTribe.Name },
				},
				Duration = SecToHours(240),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 50 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 50 },
				},
			},
			SnowIsland = {
				Id = "SnowIsland",
				Name = Constants.Items.SnowIsland.Name,
				Title = "Shroud of Ice",
				Description = "Visit " .. Constants.Items.SnowIsland.Name,
				Objective = QuestsModule.QuestObjectives.Visit,
				PendingMsg = "Please Glide to " .. Constants.Items.SnowIsland.Name .. ".",
				CompleteMsg = "You've successfully visited " .. Constants.Items.SnowIsland.Name .. "!",
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.SnowIsland, Title = "Glide to " .. Constants.Items.SnowIsland.Name },
				},
				Duration = SecToHours(240),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 50 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 50 },
				},
			},
			WesternTemple = {
				Id = "WesternTemple",
				Name = Constants.Items.WesternTemple.Name,
				Title = 'Above the Clouds',
				Description = "Visit " .. Constants.Items.WesternTemple.Name,
				Objective = QuestsModule.QuestObjectives.Visit,
				PendingMsg = "Please Glide to " .. Constants.Items.WesternTemple.Name .. ".",
				CompleteMsg = "You've successfully visited " .. Constants.Items.WesternTemple.Name .. "!",
				Targets = {
					[1] = { Id = QuestsModule.TargetIds.WesternTemple, Title = "Glide to " .. Constants.Items.WesternTemple.Name },
				},
				Duration = SecToHours(240),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 50 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 50 },
				},
			},
		},


		Kill = {
			WaterBender = {
				Id = "WaterBender",
				Name = "Battle with " .. Constants.NPCsType.WaterBender,
				Title = "Tides of Resistance",
				Description = "Defeat 5 " .. Constants.NPCsType.WaterBender .. "",
				Objective = QuestsModule.QuestObjectives.Kill,
				PendingMsg = "You need to defeat 5 " .. Constants.NPCsType.WaterBender .. "s.",
				CompleteMsg = "Great job! You've defeated all 5 " .. Constants.NPCsType.WaterBender .. "!",
				Targets = {
					[1] = { Id = "WaterBender", Title = "Defeat 1st " .. Constants.NPCsType.WaterBender},
					[2] = { Id = "WaterBender", Title = "Defeat 2nd " .. Constants.NPCsType.WaterBender},
					[3] = { Id = "WaterBender", Title = "Defeat 3rd " .. Constants.NPCsType.WaterBender},
					[4] = { Id = "WaterBender", Title = "Defeat 4th " .. Constants.NPCsType.WaterBender},
					[5] = { Id = "WaterBender", Title = "Defeat the final " .. Constants.NPCsType.WaterBender},
				},
				Duration = SecToHours(120),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 100 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 100 },
				},
			},
			FireBender = {
				Id = "FireBender",
				Name = "Battle with " .. Constants.NPCsType.FireBender,
				Title = "Burning Challenge",
				Description = "Defeat 5 " .. Constants.NPCsType.FireBender .. " ",
				Objective = QuestsModule.QuestObjectives.Kill,
				PendingMsg = "You need to defeat 5 " .. Constants.NPCsType.FireBender .. "s.",
				CompleteMsg = "Great job! You've defeated all 5 " .. Constants.NPCsType.FireBender .. "!",
				Targets = {
					[1] = { Id = "FireBender", Title = "Defeat 1st " .. Constants.NPCsType.FireBender},
					[2] = { Id = "FireBender", Title = "Defeat 2nd " .. Constants.NPCsType.FireBender},
					[3] = { Id = "FireBender", Title = "Defeat 3rd " .. Constants.NPCsType.FireBender},
					[4] = { Id = "FireBender", Title = "Defeat 4th " .. Constants.NPCsType.FireBender},
					[5] = { Id = "FireBender", Title = "Defeat the final " .. Constants.NPCsType.FireBender},
				},
				Duration = SecToHours(240),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 100 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 100 },
				},
			},
			EarthBender = {
				Id = "EarthBender",
				Name = "Battle with " .. Constants.NPCsType.EarthBender,
				Title = "Trial of the Peaks",
				Description = "Defeat 10 " .. Constants.NPCsType.EarthBender .. "",
				Objective = QuestsModule.QuestObjectives.Kill,
				PendingMsg = "You need to defeat 10 " .. Constants.NPCsType.EarthBender .. "s.",
				CompleteMsg = "Well done! You've defeated all 10 " .. Constants.NPCsType.EarthBender .. "!",
				Targets = {
					[1] = { Id = "EarthBender", Title = "Defeat 1st " .. Constants.NPCsType.EarthBender},
					[2] = { Id = "EarthBender", Title = "Defeat 2nd " .. Constants.NPCsType.EarthBender},
					[3] = { Id = "EarthBender", Title = "Defeat 3rd " .. Constants.NPCsType.EarthBender},
					[4] = { Id = "EarthBender", Title = "Defeat 4th " .. Constants.NPCsType.EarthBender},
					[5] = { Id = "EarthBender", Title = "Defeat 5th " .. Constants.NPCsType.EarthBender},
					[6] = { Id = "EarthBender", Title = "Defeat 6th " .. Constants.NPCsType.EarthBender},
					[7] = { Id = "EarthBender", Title = "Defeat 7th " .. Constants.NPCsType.EarthBender},
					[8] = { Id = "EarthBender", Title = "Defeat 8th " .. Constants.NPCsType.EarthBender},
					[9] = { Id = "EarthBender", Title = "Defeat 9th " .. Constants.NPCsType.EarthBender},
					[10] = { Id = "EarthBender", Title = "Defeat the final " .. Constants.NPCsType.EarthBender},
				},
				Duration = SecToHours(240),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 100 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 100 },
				},
			},
			AirBender = {
				Id = "AirBender",
				Name = "Battle with " .. Constants.NPCsType.AirBender,
				Title = "The Wind’s Trial",
				Description = "Defeat 15 " .. Constants.NPCsType.AirBender .. "",
				Objective = QuestsModule.QuestObjectives.Kill,
				PendingMsg = "You need to defeat 15 " .. Constants.NPCsType.AirBender .. "s.",
				CompleteMsg = "Great job! You've defeated all 15 " .. Constants.NPCsType.AirBender .. "!",
				Targets = {
					[1] = { Id = "AirBender", Title = "Defeat 1st " .. Constants.NPCsType.AirBender},
					[2] = { Id = "AirBender", Title = "Defeat 2nd " .. Constants.NPCsType.AirBender},
					[3] = { Id = "AirBender", Title = "Defeat 3rd " .. Constants.NPCsType.AirBender},
					[4] = { Id = "AirBender", Title = "Defeat 4th " .. Constants.NPCsType.AirBender},
					[5] = { Id = "AirBender", Title = "Defeat 5th " .. Constants.NPCsType.AirBender},
					[6] = { Id = "AirBender", Title = "Defeat 6th " .. Constants.NPCsType.AirBender},
					[7] = { Id = "AirBender", Title = "Defeat 7th " .. Constants.NPCsType.AirBender},
					[8] = { Id = "AirBender", Title = "Defeat 8th " .. Constants.NPCsType.AirBender},
					[9] = { Id = "AirBender", Title = "Defeat 9th " .. Constants.NPCsType.AirBender},
					[10] = { Id = "AirBender", Title = "Defeat 10th " .. Constants.NPCsType.AirBender},
					[11] = { Id = "AirBender", Title = "Defeat 11th " .. Constants.NPCsType.AirBender},
					[12] = { Id = "AirBender", Title = "Defeat 12th " .. Constants.NPCsType.AirBender},
					[13] = { Id = "AirBender", Title = "Defeat 13th " .. Constants.NPCsType.AirBender},
					[14] = { Id = "AirBender", Title = "Defeat 14th " .. Constants.NPCsType.AirBender},
					[15] = { Id = "AirBender", Title = "Defeat the final " .. Constants.NPCsType.AirBender},
				},
				Duration = SecToHours(360),
				Reward = {
					[1] = { Type = Constants.QuestRewardType.Gems, Value = 100 },
					[2] = { Type = Constants.QuestRewardType.XP, Value = 100 },
				},
			},
		},

		Find = {
			OldBook = {
				Id = "OldBook",
				Name = "Find Old Book",
				Title = "Pages Lost to Time",
				Objective = QuestsModule.QuestObjectives.Find,
				Description = `Find and retrieve the Old Book from the Big House in {Constants.Items.KioshiIsland.Name}`,
				Targets = {
					[1]	= {Id = QuestsModule.TargetIds.OldBook, Title = "Go to Big house and pick old book"},
				}, -- Count
				Duration = SecToHours(240),
				PendingMsg = `You still need to find the Old Book from the Big House on {Constants.Items.KioshiIsland.Name}`,
				CompleteMsg = "You've successfully brought back the Old Book! Good job!", -- Will only Use by NPC AI to claim the reward.
				Reward = {
					[1] = {
						Type = Constants.QuestRewardType.Gold,
						Value = 150,
					},
					[2] = {
						Type = Constants.QuestRewardType.XP,
						Value = 100,
					},
				},
			},
		}
	},

}

table.freeze(QuestsModule.Quests)

return QuestsModule