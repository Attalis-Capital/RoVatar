-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local QuestsModule = require(script.Parent)
local Constant = require(RS.Modules.Custom.Constants)

return{
	Tutorial = {
		[1] = {
			-- Quest 1: Tutorial
			Title = "Welcome to RoVatar! I'm Guru Pathik, your guide on this grand journey. It's a pleasure to meet you!",
			Options = {
				[1] = {
					Text = "Nice to meet you too!",
					Image = "rbxassetid://17575066019",
					ClickAction = {
						Dialogue = {
							Title = "To grow stronger, you'll need to master combat and survival. I'm sending you for some training. You can find me at the Rock Tribe to begin your tutorial.",
							Options = {
								[1] = {
									Text = "Okay!",
									Image = "rbxassetid://17575066019",
									ClickAction = {
										Teleport = Constant.Places.RoVatar.PlaceId,
									}
								}
							}
						}
					}
				},
			}
		},
		[2] = {
			-- Quest
			Title = "Welcome! Let’s begin with the basics of attacking and defending.",
			Objective = QuestsModule.QuestObjectives.Kill,
			Options = {
				[1] = {
					Text = "Okay!",
					Image = "rbxassetid://17575066019",
					ClickAction = {
						Dialogue = {
							Title = "Your first task is to defeat the enemy three times.",
							Options = {
								[1] = {
									Text = "Okay",
									Image = "rbxassetid://17575066019",
									ClickAction = {
										Assign = QuestsModule.Quests.Tutorial.Kill.DefeatWith3EarthBender,
									}
								}
							},
						},
					},
				},
			}
		},
		[3] = {
			-- Quest: Post-combat teaching - Block, Sprint, Meditation, then progression
			Title = "Great work defeating those enemies! Before you move on, let me teach you some survival skills.",
			Objective = QuestsModule.QuestObjectives.Kill,
			Options = {
				[1] = {
					Text = "I'm ready to learn!",
					Image = "rbxassetid://17575066019",
					ClickAction = {
						Dialogue = {
							Title = "Blocking: Press Q to block enemy attacks. Blocking reduces incoming damage significantly. Time it right for a Perfect Block to stun your attacker!",
							Options = {
								[1] = {
									Text = "Got it!",
									Image = "rbxassetid://17575066019",
									ClickAction = {
										Dialogue = {
											Title = "Sprinting: Hold Left Shift to run faster. Sprinting uses stamina, so keep an eye on your stamina bar. You can't sprint and block at the same time.",
											Options = {
												[1] = {
													Text = "Continue",
													Image = "rbxassetid://17575066019",
													ClickAction = {
														Dialogue = {
															Title = "Meditation: When your stamina runs low, press N to sit and meditate. This will restore your stamina quickly. Find a safe spot before meditating - you can't move or fight while recovering!",
															Options = {
																[1] = {
																	Text = "Continue",
																	Image = "rbxassetid://17575066019",
																	ClickAction = {
																		Dialogue = {
																			Title = "Now about growing stronger - complete quests to earn XP and unlock your skills! XP will Level you up which will make you stronger and able to fight higher level enemies.",
																			Options = {
																				[1] = {
																					Text = "Continue",
																					Image = "rbxassetid://17575066019",
																					ClickAction = {
																						Dialogue = {
																							Title = "Completing Quests will also give you Gold in order to buy objects that allow you to travel around RoVatar!",
																							Options = {
																								[1] = {
																									Text = "Okay",
																									Image = "rbxassetid://17575066019",
																									ClickAction = {
																										Dialogue = {
																											Title = "So let's get you to the Rock Tribe to begin your training in unlocking your first ability! Come find me there.",
																											Options = {
																												[1] = {
																													Text = "Teleport Me",
																													Image = "rbxassetid://17575066019",
																													ClickAction = {
																														Teleport = Constant.Places.RoVatar.PlaceId,
																													}
																												},
																												[2] = {
																													Text = "Let me explore first",
																													Image = "rbxassetid://17575582976",
																													ClickAction = {} -- Exit
																												}
																											},
																										},
																									}
																								}
																							},
																						},
																					}
																				}
																			},
																		},
																	}
																}
															},
														},
													}
												}
											},
										},
									}
								}
							},
						},
					},
				},
			}
		}	
	},

	LevelUP = {
		[1] = {
			-- Quest 1: DefeatWith5EarthBender
			Title = "Welcome to the Rock Tribe! We've been having some troubles here lately with some invaders, can you help us defeat them?",
			Objective = QuestsModule.QuestObjectives.Kill,
			Options = {
				[1] = {
					Text = "Yes",
					Image = "rbxassetid://17575066019",
					ClickAction = {
						Dialogue = {
							Title = "Come find me again after you defeat 5 invaders.",
							Options = {
								[1] = {
									Text = "Ok",
									Image = "rbxassetid://17575066019",
									ClickAction = {
										Assign = QuestsModule.Quests.LevelUP.Kill.DefeatWith5EarthBender,
									}
								}
							}
						}
					}
				},
				[2] = {
					Text = "No",
					Image = "rbxassetid://17575582976",
					ClickAction = {} -- Exit
				}
			},
		},
		[2] = {
			-- Quest 2: OldBook
			Title = `We need help retrieving an old book from the Big House in {Constant.Items.KioshiIsland.Name}.`,
			Objective = QuestsModule.QuestObjectives.Find,
			Options = {
				[1] = {
					Text = "I can do that!",
					Image = "rbxassetid://17575066019",
					ClickAction = {
						Dialogue = {
							Title = "Find the old book and bring it back to me.",
							Options = {
								[1] = {
									Text = "On it!",
									Image = "rbxassetid://17575066019",
									ClickAction = {
										Assign = QuestsModule.Quests.LevelUP.Find.OldBook,
									}
								}
							}
						}
					}
				},
				[2] = {
					Text = "Sorry, I'm busy.",
					Image = "rbxassetid://17575582976",
					ClickAction = {} -- Exit
				}
			}
		},
		[3] = {
			-- Quest 3: Shop (Locate the Shop)
			Title = `We're in desperate need of supplies. Can you find the hidden shop on {Constant.Items.KioshiIsland.Name}?`,
			Objective = QuestsModule.QuestObjectives.Find,
			Options = {
				[1] = {
					Text = "I'll locate the shop!",
					Image = "rbxassetid://17575066019",
					ClickAction = {
						Dialogue = {
							Title = "Find the shop and report back.",
							Options = {
								[1] = {
									Text = "I'm on my way!",
									Image = "rbxassetid://17575066019",
									ClickAction = {
										Assign = QuestsModule.Quests.LevelUP.Find.Shop,
									}
								}
							}
						}
					}
				},
				[2] = {
					Text = "I can't help right now.",
					Image = "rbxassetid://17575582976",
					ClickAction = {} -- Exit
				}
			}
		},
		[4] = {
			-- Quest 4: DefendVillage (Defeat 10 Earth Benders)
			Title = `Our village is under attack! Can you help us by defeating 10 {Constant.NPCsType.EarthBender}?`,
			Objective = QuestsModule.QuestObjectives.Kill,
			Options = {
				[1] = {
					Text = "Yes, I'll defend the village!",
					Image = "rbxassetid://17575066019",
					ClickAction = {
						Dialogue = {
							Title = `Defeat 10 {Constant.NPCsType.EarthBender} to protect the village!`,
							Options = {
								[1] = {
									Text = "Leave it to me!",
									Image = "rbxassetid://17575066019",
									ClickAction = {
										Assign = QuestsModule.Quests.LevelUP.Kill.DefendVillage,
									}
								}
							}
						}
					}
				},
				[2] = {
					Text = "I'm afraid I can't help.",
					Image = "rbxassetid://17575582976",
					ClickAction = {} -- Exit
				}
			}
		},
		[5] = {
			-- Quest 5: MagicBook
			Title = `There's a Magic Book hidden somewhere on {Constant.Items.KioshiIsland.Name}. Can you find it?`,
			Objective = QuestsModule.QuestObjectives.Find,
			Options = {
				[1] = {
					Text = "I'll find the Magic Book!",
					Image = "rbxassetid://17575066019",
					ClickAction = {
						Dialogue = {
							Title = "Search for the Magic Book and return here.",
							Options = {
								[1] = {
									Text = "Consider it done!",
									Image = "rbxassetid://17575066019",
									ClickAction = {
										Assign = QuestsModule.Quests.LevelUP.Find.MagicBook,
									}
								}
							}
						}
					}
				},
				[2] = {
					Text = "Sorry, I can't do that.",
					Image = "rbxassetid://17575582976",
					ClickAction = {} -- Exit
				}
			}
		},
		[6] = {
			-- Quest 6: Glider
			Title = `You've walked through market, shadow and silence. Now, you're ready to rise. The {Constant.Items.Glider.Name} is ready for you.`,
			Objective = QuestsModule.QuestObjectives.Purchase,
			Options = {
				[1] = {
					Text = "Okay...",
					Image = "rbxassetid://17575066019",
					ClickAction = {
						Dialogue = {
							Title = "It’s there for purchase now. You’ve earned the right. Just approach calmly, take what is offered, and give what is fair.",
							Options = {
								[1] = {	
									Text = "Consider it done!",
									Image = "rbxassetid://17575066019",
									ClickAction = {
										Assign = QuestsModule.Quests.LevelUP.Purchase.Glider,
									}
								}
							}
						}
					}
				},
				[2] = {
					Text = "Sorry, I can't do that.",
					Image = "rbxassetid://17575582976",
					ClickAction = {} -- Exit
				}
			},
		},

	},

	------ After Level Five player can get random quests every time... it can be provide randomly acc. to each NPC Type ------
	NPC = {
		Visit = {
			[1] = {
				Title = `Hi there! Interested in visiting {Constant.Items.KioshiIsland.Name}?`,

				Options = {
					[1] = {
						Text = "Yes, let’s explore it.",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Assign = QuestsModule.Quests.NPC.Visit.KioshiIsland,
						}
					},
					[2] = {
						Text = "Not now.",
						Image = "rbxassetid://17575582976",
						ClickAction = {} -- Exit
					}
				}
			},

			[2] = {
				Title = `Hey! Would you like to visit the {Constant.Items.GreenTribeUp.Name}?`,

				Options = {
					[1] = {
						Text = "Yes, let’s explore it.",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Assign = QuestsModule.Quests.NPC.Visit.GreenTribeUp,
						}
					},
					[2] = {
						Text = "Maybe later.",
						Image = "rbxassetid://17575582976",
						ClickAction = {} -- Exit
					}
				}
			},

			[3] = {
				Title = `A calm breeze flows. Want to visit the {Constant.Items.SounderAirTemple.Name}?`,

				Options = {
					[1] = {
						Text = "Absolutely.",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Assign = QuestsModule.Quests.NPC.Visit.SounderAirTemple,
						}
					},
					[2] = {
						Text = "Not right now.",
						Image = "rbxassetid://17575582976",
						ClickAction = {} -- Exit
					}
				}
			},

			[4] = {
				Title = `Journey to the {Constant.Items.GreenTribeDown.Name}? The jungle trails are peaceful this time of day.`,

				Options = {
					[1] = {
						Text = "Absolutely.",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Assign = QuestsModule.Quests.NPC.Visit.GreenTribeDown,
						}
					},
					[2] = {
						Text = "Not right now.",
						Image = "rbxassetid://17575582976",
						ClickAction = {}
					}
				}
			},

			[5] = {
				Title = `There’s a {Constant.Items.LavaIsland.Name} not far from here. Dangerous, but beautiful. Want to visit?`,

				Options = {
					[1] = {
						Text = "Yes, I'd like to go.",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Assign = QuestsModule.Quests.NPC.Visit.LavaIsland,
						}
					},
					[2] = {
						Text = "No, too hot for me.",
						Image = "rbxassetid://17575582976",
						ClickAction = {}
					}
				}
			},

			[6] = {
				Title = `The {Constant.Items.NorthenWaterTribe.Name} welcomes travelers. Interested in making the long journey north?`,

				Options = {
					[1] = {
						Text = "Yes, I'd like to go.",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Assign = QuestsModule.Quests.NPC.Visit.NorthenWaterTribe,
						}
					},
					[2] = {
						Text = "Maybe later.",
						Image = "rbxassetid://17575582976",
						ClickAction = {}
					}
				}
			},

			[7] = {
				Title = `A cold breeze calls from the {Constant.Items.SnowIsland.Name}. It's quiet… and full of mystery. Want to visit?`,

				Options = {
					[1] = {
						Text = "Yes, I’ll brave the cold.",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Assign = QuestsModule.Quests.NPC.Visit.SnowIsland,
						}
					},
					[2] = {
						Text = "Maybe another time.",
						Image = "rbxassetid://17575582976",
						ClickAction = {}
					}
				}
			},

			[8] = {
				Title = `The {Constant.Items.WesternTemple.Name} still holds echoes of the past. Interested in paying a visit?`,

				Options = {
					[1] = {
						Text = "Yes, let’s explore it.",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Assign = QuestsModule.Quests.NPC.Visit.WesternTemple,
						}
					},
					[2] = {
						Text = "No, not now.",
						Image = "rbxassetid://17575582976",
						ClickAction = {}
					}
				}
			},
		},

		Kill = {
			[1] = {
				Title = "Greetings! I have some challenging Kill quests for you. Are you interested?",
				Options = {
					[1] = {
						Text = "Yes, tell me more.",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Dialogue = {
								Title = "Great choice! Please select the quest you would like to undertake.",
								Options = {
									[1] = {
										Text = QuestsModule.Quests.NPC.Kill.FireBender.Name,
										Image = "rbxassetid://17575066019",
										ClickAction = {
											Assign = QuestsModule.Quests.NPC.Kill.FireBender,
										}
									},
									[2] = {
										Text = QuestsModule.Quests.NPC.Kill.WaterBender.Name,
										Image = "rbxassetid://17575066019",
										ClickAction = {
											Assign = QuestsModule.Quests.NPC.Kill.WaterBender,
										}
									}
								}
							}
						}
					},
					[2] = {
						Text = "No, maybe later.",
						Image = "rbxassetid://17575582976",
						ClickAction = {} -- Exit
					}
				}
			}, 
			[2] = {
				Title = "Greetings! I have some challenging Battle quests for you. Are you interested?",
				Options = {
					[1] = {
						Text = "Yes, tell me more.",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Dialogue = {
								Title = "Great choice! Please select the quest you would like to undertake.",
								Options = {
									[1] = {
										Text = QuestsModule.Quests.NPC.Kill.AirBender.Name,
										Image = "rbxassetid://17575066019",
										ClickAction = {
											Assign = QuestsModule.Quests.NPC.Kill.AirBender,
										}
									},
									[2] = {
										Text = QuestsModule.Quests.NPC.Kill.EarthBender.Name,
										Image = "rbxassetid://17575066019",
										ClickAction = {
											Assign = QuestsModule.Quests.NPC.Kill.EarthBender,
										}
									}
								}
							}
						}
					},
					[2] = {
						Text = "No, maybe later.",
						Image = "rbxassetid://17575582976",
						ClickAction = {} -- Exit
					}
				}
			},  
		},

		Find = {
			[1] = {
				Title = "Greetings! I have some challenging quests for you. Are you interested?",
				Options = {
					[1] = {
						Text = "Yes, tell me more.",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Dialogue = {
								Title = "Great choice! Please select the quest you would like to undertake.",
								Options = {
									[1] = {
										Text = QuestsModule.Quests.NPC.Find.OldBook.Name,
										Image = "rbxassetid://17575066019",
										ClickAction = {
											Assign = QuestsModule.Quests.NPC.Find.OldBook,
										}
									},
									[2] = {
										Text = QuestsModule.Quests.NPC.Find.MagicBook.Name,
										Image = "rbxassetid://17575066019",
										ClickAction = {
											Assign = QuestsModule.Quests.NPC.Find.MagicBook,
										}
									},
								}
							}
						}
					},
					[2] = {
						Text = "No, maybe later.",
						Image = "rbxassetid://17575582976",
						ClickAction = {} -- Exit
					}
				}
			},  

		},

		Train = {
			[1] = {
				Title = "You’re eager to fight. I see it in your eyes. But bending is not just about force — it’s about rhythm. Breathe, move, breathe again.",
				Options = {
					[1] = {
						Text = "So… I shouldn’t rush into battle?",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Dialogue = {
								Title = "Exactly. First, learn your limits. Push your body until your energy is gone — then learn how to restore it. There’s a way to quiet your spirit and let it flow back into you.",
								Options = {
									[1] = {
										Text = "How?",
										Image = "rbxassetid://17575066019",
										ClickAction = {
											Dialogue = {
												Title = "Meditation. Find a quiet place, clear your thoughts, and press N to focus your energy. Try it.",

												Options = {
													[1] = {	
														Text = "Okay",
														Image = "rbxassetid://17575066019",
														ClickAction = {
															Assign = QuestsModule.Quests.NPC.Train.ManaRecovery,
														}
													}
												}	
											}
										}
									},
								}
							}
						}
					},
					[2] = {
						Text = "Maybe later.",
						Image = "rbxassetid://17575582976",
						ClickAction = {
							Dialogue = {
								Title = "Take your time. But come back when you're ready to train.",
								Options = {	
									[1] = {
										Text = "Sure.",
										Image = "rbxassetid://17575066019",
										ClickAction = {} -- Exit
									}
								}
							}
						}
					}
				},
			},

			[2] = {
				Title = "The ocean holds more than waves and current. Beneath its surface lie the forgotten memories of our people.",
				Options = {
					[1] = {
						Text = "You mean like artifacts?",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Dialogue = {
								Title = "Exactly. There’s a relic from the old Water Tribe — lost during the Great Crossing. I want you to retrieve it. It’s submerged not far from here.",
								Options = {
									[1] = {
										Text = "Underwater?",
										Image = "rbxassetid://17575066019",
										ClickAction = {
											Dialogue = {
												Title = "Yes. Trust your breath. Dive deep. Feel the ocean — don’t fight it.",
												Options = {
													[1] = {
														Text = "Okay",
														Image = "rbxassetid://17575066019",
														ClickAction = {
															Assign = QuestsModule.Quests.NPC.Train.BreathTheSurface,
														}
													},
												}	
											}
										}
									},
								}
							}
						}
					},
					[2] = {
						Text = "Not ready yet",
						Image = "rbxassetid://17575582976",
						ClickAction = {
							Dialogue = {
								Title = "That’s alright. Clarity comes when the mind is ready to receive it. Come back when you're prepared.",
								Options = {	
									[1] = {
										Text = "Sure.",
										Image = "rbxassetid://17575066019",
										ClickAction = {} -- Exit
									}
								}
							}
						}
					}
				},  

			},
		},

		Combined = {
			---- Quest Assigner name is temporary[Imp for Cross check and refer player to the specific NPC to assign the quest]. 
			[1] = {
				-- Quest 10: The_Zephir_Reclamation
				Title = `The winds stir restlessly over Zephyr Monastery. The {Constant.NPCsType.AirBender} have taken hold — but not for long.`,
				Assigner = "Journey Master",
				Objective = QuestsModule.QuestObjectives.Combined,
				Options = {
					[1] = {
						Text = "I'll do it.",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Dialogue = {
								Title = `Glide to the {Constant.Items.SounderAirTemple.Name}. Drive out ten of their strongest {Constant.NPCsType.AirBender}. Only then will the skies be ours again.`,
								Options = {
									[1] = {

										Text = "I'm ready to move.",
										Image = "rbxassetid://17575066019",
										ClickAction = {
											Assign = QuestsModule.Quests.NPC.Combined.The_Zephir_Reclamation,
										}
									}
								}
							}
						}
					},
					[2] = {
						Text = "Too dangerous. Not now.",
						Image = "rbxassetid://17575582976",
						ClickAction = {} -- Exit
					}
				}
			},

			[2] = {
				-- Quest 11: Return_To_Sentinel_Island
				Title = `You're done here, traveler. The path back is open. Step onto the crystal, open your map, and click on Sentinel Isle. The way home is now yours.`,
				Assigner = "Zephir Guide",
				Objective = QuestsModule.QuestObjectives.Combined,
				Options = {
					[1] = {
						Text = "Got it. I'm heading back",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Dialogue = {
								Title = `Safe travels. The elder will want to hear what you've seen.`,
								Options = {
									[1] = {
										Text = "I'm ready to move.",
										Image = "rbxassetid://17575066019",
										ClickAction = {
											Assign = QuestsModule.Quests.NPC.Combined.Return_To_Sentinel_Island,
										}
									}
								}
							}
						}
					},
					[2] = {
						Text = "Give me a moment.",
						Image = "rbxassetid://17575582976",
						ClickAction = {
							Dialogue = {
								Title = `No rush. The crystal isn’t going anywhere.`,
								Options = {
									[1] = {
										Text = "Okay.",
										Image = "rbxassetid://17575066019",
										ClickAction = {} -- Exit
									}
								}
							}	
						}
					}
				}
			},

			[3] = {
				-- Quest 12: The_Bloom_of_Power
				Title = `Legends speak of a rare blossom hidden at the peak of the {Constant.Items.WesternTemple.Name}. Its power can awaken strength in any bender.`,
				Assigner = "Journey Master",
				Objective = QuestsModule.QuestObjectives.Combined,
				Options = {
					[1] = {
						Text = "I’ll retrieve it.",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Dialogue = {
								Title = `Glide to the {Constant.Items.WesternTemple.Name}. Climb to the summit and recover the Flower of Life — its energy will guide your path.`,
								Options = {
									[1] = {
										Text = "I'll bring it back.",
										Image = "rbxassetid://17575066019",
										ClickAction = {
											Assign = QuestsModule.Quests.NPC.Combined.The_Bloom_of_Power,
										}
									}
								}
							}
						}
					},
					[2] = {
						Text = "Maybe another time.",
						Image = "rbxassetid://17575582976",
						ClickAction = {} -- Exit
					}
				}
			},

			[4] = {
				-- Quest 13: TrialByFlame
				Title = "The flames whisper your name. A trial awaits — one only the strong survive.",
				Assigner = "Journey Master",
				Objective = QuestsModule.QuestObjectives.Combined,
				Options = {
					[1] = {
						Text = "I'm ready.",
						Image = "rbxassetid://17575066019",
						ClickAction = {
							Dialogue = {
								Title = `Glide to {Constant.Items.LavaIsland.Name} and seek the Blazing Peak Tower. There, the {Constant.NPCsType.FireBender_MiniBoss} guards the flame shrine. Defeat him…`,
								Options = {
									[1] = {
										Text = "The fire won’t stop me.",
										Image = "rbxassetid://17575066019",
										ClickAction = {
											Assign = QuestsModule.Quests.NPC.Combined.TrialByFlame,
										}
									}
								}
							}
						}
					},
					[2] = {
						Text = "Not now.",
						Image = "rbxassetid://17575582976",
						ClickAction = {}, -- Exit
					},
				},
			},
		},
	},
}