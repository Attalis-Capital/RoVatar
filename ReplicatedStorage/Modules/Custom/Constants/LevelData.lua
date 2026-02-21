-- @ScriptType: ModuleScript
return function(LevelUpRewardType)
	return {
		[1] = {MinXp = 0, MaxXp = 299, XpRequired = 300,
			Reward = {Type = LevelUpRewardType.Gold, Amount = 200}
		},
		[2] = {MinXp = 300, MaxXp = 899, XpRequired = 600,
			Reward = {Type = LevelUpRewardType.Gold, Amount = 300}
		},
		[3] = {MinXp = 900, MaxXp = 1899, XpRequired = 1000,
			Reward = {Type = LevelUpRewardType.Gold, Amount = 400}
		},
		[4] = {MinXp = 1900, MaxXp = 3399, XpRequired = 1500,
			Reward = {Type = LevelUpRewardType.Gold, Amount = 500}
		},
		[5] = {MinXp = 3400, MaxXp = 5399, XpRequired = 2000,
			Reward = {Type = LevelUpRewardType.Gold, Amount = 600}
		},
		[6] = {MinXp = 7500, MaxXp = 9999, XpRequired = 2500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 700}
		},
		[7] = {MinXp = 10000, MaxXp = 12999, XpRequired = 3000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 800}
		},
		[8] = {MinXp = 13000, MaxXp = 16499, XpRequired = 3500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 900}
		},
		[9] = {MinXp = 16500, MaxXp = 20499, XpRequired = 4000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 1000}
		},
		[10] = {MinXp = 20500, MaxXp = 24999, XpRequired = 4500, 
			Reward = {Type = LevelUpRewardType.Gems, Amount = 50}
		},
		[11] = {MinXp = 25000, MaxXp = 29999, XpRequired = 5000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 1200}
		},
		[12] = {MinXp = 30000, MaxXp = 35999, XpRequired = 6000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 1400}
		},
		[13] = {MinXp = 36000, MaxXp = 42499, XpRequired = 6500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 1600}
		},
		[14] = {MinXp = 42500, MaxXp = 49499, XpRequired = 7000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 1800}
		},
		[15] = {MinXp = 49500, MaxXp = 56999, XpRequired = 7500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 2000}
		},
		[16] = {MinXp = 57000, MaxXp = 64999, XpRequired = 8000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 2200}
		},
		[17] = {MinXp = 65000, MaxXp = 73499, XpRequired = 8500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 2400}
		},
		[18] = {MinXp = 73500, MaxXp = 82499, XpRequired = 9000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 2600}
		},
		[19] = {MinXp = 82500, MaxXp = 91999, XpRequired = 9500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 2800}
		},
		[20] = {MinXp = 92000, MaxXp = 101999, XpRequired = 10000, 
			Reward = {Type = LevelUpRewardType.Gems, Amount = 100}
		},
		[21] = {MinXp = 102000, MaxXp = 112499, XpRequired = 10500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 3000}
		},
		[22] = {MinXp = 112500, MaxXp = 123499, XpRequired = 11000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 3200}
		},
		[23] = {MinXp = 123500, MaxXp = 134999, XpRequired = 11500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 3400}
		},
		[24] = {MinXp = 135000, MaxXp = 147499, XpRequired = 12500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 3600}
		},
		[25] = {MinXp = 147500, MaxXp = 159999, XpRequired = 12500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 3800}
		},
		[26] = {MinXp = 160000, MaxXp = 172499, XpRequired = 13000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 4000}
		},
		[27] = {MinXp = 172500, MaxXp = 185999, XpRequired = 13500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 4200}
		},
		[28] = {MinXp = 186000, MaxXp = 199499, XpRequired = 14000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 4400}
		},
		[29] = {MinXp = 199500, MaxXp = 212999, XpRequired = 14500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 4600}
		},
		[30] = {MinXp = 213000, MaxXp = 227499, XpRequired = 15000, 
			Reward = {Type = LevelUpRewardType.Gems, Amount = 200}
		},
		[31] = {MinXp = 227500, MaxXp = 242499, XpRequired = 15500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 5000}
		},
		[32] = {MinXp = 242500, MaxXp = 257999, XpRequired = 16000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 5500}
		},
		[33] = {MinXp = 258000, MaxXp = 274499, XpRequired = 16500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 6000}
		},
		[34] = {MinXp = 274500, MaxXp = 291999, XpRequired = 17500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 6500}
		},
		[35] = {MinXp = 292000, MaxXp = 310499, XpRequired = 18500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 7000}
		},
		[36] = {MinXp = 310500, MaxXp = 330499, XpRequired = 20000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 7500}
		},
		[37] = {MinXp = 330500, MaxXp = 351499, XpRequired = 20000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 8000}
		},
		[38] = {MinXp = 351500, MaxXp = 373999, XpRequired = 20000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 8500}
		},
		[39] = {MinXp = 374000, MaxXp = 397999, XpRequired = 24000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 9000}
		},
		[40] = {MinXp = 398000, MaxXp = 422499, XpRequired = 25000, 
			Reward = {Type = LevelUpRewardType.Gems, Amount = 300}
		},


		[41] = {MinXp = 422500, MaxXp = 448499, XpRequired = 26000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 10000}
		},
		[42] = {MinXp = 448500, MaxXp = 475999, XpRequired = 27500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 10500}
		},
		[43] = {MinXp = 476000, MaxXp = 503999, XpRequired = 28000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 11000}
		},
		[44] = {MinXp = 504000, MaxXp = 533499, XpRequired = 29500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 11500}
		},
		[45] = {MinXp = 533500, MaxXp = 563999, XpRequired = 30500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 12000}
		},
		[46] = {MinXp = 564000, MaxXp = 595999, XpRequired = 32000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 12500}
		},
		[47] = {MinXp = 596000, MaxXp = 628999, XpRequired = 33000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 13000}
		},
		[48] = {MinXp = 629000, MaxXp = 663499, XpRequired = 34500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 13500}
		},
		[49] = {MinXp = 663500, MaxXp = 698999, XpRequired = 35500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 14000}
		},
		[50] = {MinXp = 699000, MaxXp = 735999, XpRequired = 37000, 
			Reward = {Type = LevelUpRewardType.Gems, Amount = 400}
		},

		[51] = {MinXp = 736000, MaxXp = 773999, XpRequired = 38000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 14500}
		},
		[52] = {MinXp = 774000, MaxXp = 813499, XpRequired = 39500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 15000}
		},
		[53] = {MinXp = 813500, MaxXp = 854999, XpRequired = 41500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 15500}
		},
		[54] = {MinXp = 855000, MaxXp = 897999, XpRequired = 43000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 16000}
		},
		[55] = {MinXp = 898000, MaxXp = 941999, XpRequired = 44000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 16500}
		},
		[56] = {MinXp = 942000, MaxXp = 987499, XpRequired = 45500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 17000}
		},
		[57] = {MinXp = 987500, MaxXp = 1034499, XpRequired = 47500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 17500}
		},
		[58] = {MinXp = 1034500, MaxXp = 1086499, XpRequired = 49000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 18000}
		},
		[59] = {MinXp = 1086500, MaxXp = 1139999, XpRequired = 51500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 18500}
		},
		[60] = {MinXp = 1140000, MaxXp = 1196999, XpRequired = 57000, 
			Reward = {Type = LevelUpRewardType.Gems, Amount = 500}
		},
		[61] = {MinXp = 1197000, MaxXp = 1254499, XpRequired = 57500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 19000}
		},
		[62] = {MinXp = 1254500, MaxXp = 1313499, XpRequired = 59000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 19500}
		},
		[63] = {MinXp = 1313500, MaxXp = 1374999, XpRequired = 61500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 20000}
		},
		[64] = {MinXp = 1375000, MaxXp = 1437999, XpRequired = 63000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 20500}
		},
		[65] = {MinXp = 1438000, MaxXp = 1503499, XpRequired = 65500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 21000}
		},
		[66] = {MinXp = 1503500, MaxXp = 1570499, XpRequired = 67000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 21500}
		},
		[67] = {MinXp = 1570500, MaxXp = 1638999, XpRequired = 68500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 22000}
		},
		[68] = {MinXp = 1639000, MaxXp = 1709999, XpRequired = 71000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 22500}
		},
		[69] = {MinXp = 1710000, MaxXp = 1782499, XpRequired = 72500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 23000}
		},
		[70] = {MinXp = 1782500, MaxXp = 1858499, XpRequired = 76000, 
			Reward = {Type = LevelUpRewardType.Gems, Amount = 600}
		},
		[71] = {MinXp = 1858500, MaxXp = 1934999, XpRequired = 76500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 23500}
		},
		[72] = {MinXp = 1935000, MaxXp = 2012999, XpRequired = 78000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 24000}
		},
		[73] = {MinXp = 2013000, MaxXp = 2093499, XpRequired = 80500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 24500}
		},
		[74] = {MinXp = 2093500, MaxXp = 2175499, XpRequired = 82000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 25000}
		},
		[75] = {MinXp = 2175500, MaxXp = 2259999, XpRequired = 84500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 25500}
		},
		[76] = {MinXp = 2260000, MaxXp = 2345999, XpRequired = 86000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 26000}
		},
		[77] = {MinXp = 2346000, MaxXp = 2433499, XpRequired = 87500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 26500}
		},
		[78] = {MinXp = 2433500, MaxXp = 2523499, XpRequired = 90000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 27000}
		},
		[79] = {MinXp = 2523500, MaxXp = 2614999, XpRequired = 91500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 27500}
		},
		[80] = {MinXp = 2615000, MaxXp = 2709999, XpRequired = 95000, 
			Reward = {Type = LevelUpRewardType.Gems, Amount = 750}
		},
		[81] = {MinXp = 2710000, MaxXp = 2805499, XpRequired = 95500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 28000}
		},
		[82] = {MinXp = 2805500, MaxXp = 2902499, XpRequired = 97000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 28500}
		},
		[83] = {MinXp = 2902500, MaxXp = 3001999, XpRequired = 99500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 29000}
		},
		[84] = {MinXp = 3002000, MaxXp = 3102999, XpRequired = 101000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 29500}
		},
		[85] = {MinXp = 3103000, MaxXp = 3206499, XpRequired = 103500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 30000}
		},
		[86] = {MinXp = 3206500, MaxXp = 3311499, XpRequired = 105000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 30500}
		},
		[87] = {MinXp = 3311500, MaxXp = 3418999, XpRequired = 107500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 31000}
		},
		[88] = {MinXp = 3419000, MaxXp = 3527999, XpRequired = 110000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 31500}
		},
		[89] = {MinXp = 3528000, MaxXp = 3639499, XpRequired = 111500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 32000}
		},
		[90] = {MinXp = 3639500, MaxXp = 3753499, XpRequired = 114000, 
			Reward = {Type = LevelUpRewardType.Gems, Amount = 1000}
		},
		[91] = {MinXp = 3753500, MaxXp = 3867999, XpRequired = 115000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 32500}
		},
		[92] = {MinXp = 3868000, MaxXp = 3984999, XpRequired = 117000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 33000}
		},
		[93] = {MinXp = 3985000, MaxXp = 4104499, XpRequired = 119500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 33500}
		},
		[94] = {MinXp = 4104500, MaxXp = 4225499, XpRequired = 122000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 34000}
		},
		[95] = {MinXp = 4225500, MaxXp = 4348999, XpRequired = 124500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 34500}
		},
		[96] = {MinXp = 4349000, MaxXp = 4473999, XpRequired = 127000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 35000}
		},
		[97] = {MinXp = 4474000, MaxXp = 4601499, XpRequired = 130500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 35500}
		},
		[98] = {MinXp = 4601500, MaxXp = 4730499, XpRequired = 134000, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 36000}
		},
		[99] = {MinXp = 4730500, MaxXp = 4861999, XpRequired = 137500, 
			Reward = {Type = LevelUpRewardType.Gold, Amount = 36500}
		},
		[100] = {MinXp = 4862000, MaxXp = 5000000, XpRequired = 140000, 
			Reward = {Type = LevelUpRewardType.Gems, Amount = 1500}
		},
	}
end