# Agent 2 -- Progression Enforcer Full Audit

**Date**: 2026-02-22
**Status**: complete
**Auditor**: swarm-researcher (Agent 2)

---

## Session-Ending Bugs

| # | Severity | Bug | File:Line | Impact |
|---|----------|-----|-----------|--------|
| 1 | **BROKEN** | XP gap between level 5 and 6: level 5 MaxXp=5399, level 6 MinXp=7500. 2100 XP is orphaned -- a player at 5400-7499 XP can never be in a valid level band. `UpdateXpInPlayerData` carries over excess XP, so the player _will_ level up, but the MinXp/MaxXp metadata for display/validation is wrong. | `LevelData.lua:18-19` | Cosmetic/display bug; level-up math itself works via XpRequired chain. |
| 2 | **BROKEN** | `IsSameDay` compares `currentDateTime.yday` (a number from `os.date("!*t")`) to string `"1"` at line 50. In Luau, `os.date("!*t").yday` returns a **number**, so `currentDateTime.yday == "1"` is **always false**. The New Year rollover special case never triggers. | `QuestDataService.lua:50-53` | Daily quest will not roll over across New Year boundary (31 Dec -> 1 Jan treated as "before yesterday"). |
| 3 | **BROKEN** | `IsSameDay` lines 51-52 compare `savedDateTime.month`/`savedDateTime.day`/`savedDateTime.year` to strings like `"12"`, `"31"`, and `tostring(...)`. These are numbers from `os.date("!*t")`, not strings. All comparisons are always false. | `QuestDataService.lua:51-52` | Same as above -- the entire New Year guard is dead code. |
| 4 | **FRAGILE** | Fist, Boomerang, and MeteoriteSword never call `ElementXp.Award()`. Only AirKick, EarthStomp, FireDropKick, and WaterStance do. 3/7 combat abilities grant zero element XP. | `VFXHandler/{Fist,Boomerang,MeteoriteSword}.lua` | Players using starter weapons (Fist/Boomerang/Sword) get no element progression, making element levels almost unreachable at early game. |
| 5 | **FRAGILE** | `LevelUpService.lua` listens for `CombatStats.Level` changes, but the actual player level is stored/updated in `Progression.LEVEL`. `CombatStats.Level` may never exist or change. | `LevelUpService.lua:32` | Broadcast of level-up VFX to other players likely never fires. Self-VFX works via `PlayerDataService.lua:153`. |

---

## Per-System Verdict Table

| System | Verdict | Notes |
|--------|---------|-------|
| 1. XP curve | **FRAGILE** | Curve works for level-up math, but MinXp/MaxXp gap at level 5->6 |
| 2. Ability unlock thresholds | **SOUND** | All 4 bending abilities gated via Costs.lua; levels are reachable |
| 3. Quest reachability | **SOUND** | Level 1-5 players can complete tutorial + level-up quests |
| 4. Element XP coverage | **FRAGILE** | 4/7 abilities covered; Fist, Boomerang, MeteoriteSword missing |
| 5. Daily quest reset | **BROKEN** | IsSameDay New Year branch always false (type mismatch) |
| 6. XP persistence | **SOUND** | Auto-save every 30s; BindToClose saves on shutdown |
| 7. Level-up ceremony | **FRAGILE** | Self-VFX works; broadcast to other players is broken |
| 8. Data model consistency | **SOUND** | PlayerData defaults match CustomTypes definitions |
| 9. LevelUpService | **FRAGILE** | Watches wrong Value object; broadcast never fires |

---

## 1. XP Curve (FRAGILE)

**Source**: `ReplicatedStorage/Modules/Custom/Constants/LevelData.lua`

### XP Thresholds (levels 1-10)

| Level | MinXp | MaxXp | XpRequired | Reward |
|-------|-------|-------|------------|--------|
| 1 | 0 | 299 | 300 | 200 Gold |
| 2 | 300 | 899 | 600 | 300 Gold |
| 3 | 900 | 1899 | 1000 | 400 Gold |
| 4 | 1900 | 3399 | 1500 | 500 Gold |
| 5 | 3400 | 5399 | 2000 | 600 Gold |
| 6 | 7500 | 9999 | 2500 | 700 Gold |
| 7 | 10000 | 12999 | 3000 | 800 Gold |
| 8 | 13000 | 16499 | 3500 | 900 Gold |
| 9 | 16500 | 20499 | 4000 | 1000 Gold |
| 10 | 20500 | 24999 | 4500 | 50 Gems |

**BUG**: Level 5 MaxXp (5399) + 1 = 5400, but level 6 MinXp = 7500. There is a **2100 XP gap**. The actual level-up code in `PlayerData.lua:628-649` uses only `XpRequired` (not MinXp/MaxXp), so levelling works correctly in practice. The gap is in the metadata only, but any UI that reads MinXp/MaxXp for progress bars will show incorrect data.

### Cumulative XP to reach level 5
- Level 1->2: 300 XP
- Level 2->3: 600 XP
- Level 3->4: 1000 XP
- Level 4->5: 1500 XP
- **Total: 3400 XP to reach level 5**

### How many kills/quests to reach level 5?

XP sources:
- Kill reward (1st kill): 0 XP (100 Gold instead) -- `PlayerDataService.lua:241`
- Kill reward (2nd kill): 50 XP -- `PlayerDataService.lua:243`
- Kill reward (3rd kill): 0 XP (100 Gold instead) -- `PlayerDataService.lua:247`
- Kill rewards after 3rd: 0 XP (just notification)
- Ability XP per hit: 5-11 XP per hit via Costs.lua (FistXP=5, AirKickXp=7, EarthStompXp=8, FireDropKickXp=10, BoomerangXP=11, MeteoriteSwordXP=9, WaterStanceXp=5)
- **NOTE**: These XP values are defined in Costs.lua but the code path to actually grant them per-hit is unclear; the primary XP source appears to be quests.

Quest XP sources (early game):
- Tutorial quest "DefeatWith3EarthBender": 50 XP -- `QuestsModule.lua:54`
- Level quest "DefeatWith5EarthBender": 500 XP -- `QuestsModule.lua:87`
- Level quest "OldBook" (Find): 1500 XP -- `QuestsModule.lua:143`
- Level quest "DefendVillage": 2500 XP -- `QuestsModule.lua:119`
- Level quest "MagicBook" (Find): 1500 XP -- `QuestsModule.lua:166`
- Level quest "Shop" (Find): 1500 XP -- `QuestsModule.lua:193`
- NPC Train "ManaRecovery": LevelUp reward -- `QuestsModule.lua:553-554`
- NPC Train "BreathTheSurface": LevelUp reward -- `QuestsModule.lua:573`

**Estimate**: Tutorial (50 XP) + DefeatWith5EarthBender (500 XP) + OldBook (1500 XP) + DefendVillage (2500 XP) = 4550 XP. This reaches level 5 (3400 XP needed). Alternatively, the NPC "ManaRecovery" quest gives a direct LevelUp reward, which could accelerate this.

---

## 2. Ability Unlock Thresholds (SOUND)

**Source**: `ReplicatedStorage/Modules/Custom/Costs.lua:21-24` and `Constants.lua:622,650,678,706`

| Ability | Required Level (Costs.lua) | Constants.lua line |
|---------|---------------------------|-------------------|
| AirKick (Storm Whisper) | 5 | `Costs.lua:21` -> `Constants.lua:622` |
| FireDropKick (Inferno Surge) | 8 | `Costs.lua:22` -> `Constants.lua:650` |
| EarthStomp (Earthquake Force) | 11 | `Costs.lua:23` -> `Constants.lua:678` |
| WaterStance (Aqua Flow) | 12 | `Costs.lua:24` -> `Constants.lua:706` |

Other items with level gates:
| Item | Required Level | Line |
|------|---------------|------|
| Glider (Windrider) | 5 | `Constants.lua:738` |
| Appa (Cloudstride) | 10 | `Constants.lua:768` |

All level thresholds are reachable through the XP curve. Level 5 = 3400 cumulative XP, Level 12 = 30000 cumulative XP. The progression is well-paced.

**`Constants.LevelAbilities` mapping** (`Constants.lua:338-343`):
```lua
[5] = 1,   -- AirKick
[8] = 2,   -- FireDropKick
[11] = 3,  -- EarthStomp
[12] = 4,  -- WaterStance
```

---

## 3. Quest Reachability (SOUND)

**Source**: `ReplicatedStorage/Modules/Custom/QuestsModule.lua`

Quest categories:
- **Tutorial**: Kill 3 EarthBenders (reward: 50 Gold + 50 XP)
- **LevelUP**: Kill, Find, Purchase, Visit quests with escalating rewards (200-3000 XP)
- **NPC**: Visit, Kill, Find, Train, Combined quests (50-700 Gold, LevelUp rewards)
- **Daily**: Visit and Kill quests (50 XP + 50 Gems)

**Level 1-5 player access**: Tutorial quests are available from the start. After tutorial completion, Level-Up and Daily quests become available. NPC quests require talking to specific NPCs. None of the quests have explicit level gates -- they are gated only by the NPC/tutorial flow, not by player level.

**Quest reward analysis**: Several NPC quests award `QuestRewardType.LevelUp` which grants enough XP to fill the current level. This is very generous -- a single Combined quest can level a player up entirely. The `ClaimQuestReward` handler at `PlayerData.lua:782-796` calculates the XP needed and calls `UpdateXpInPlayerData` with that amount.

---

## 4. Element XP Coverage (FRAGILE)

**Source**: `ReplicatedStorage/Modules/Custom/CommonFunctions/Utils/ElementXp.lua` and VFXHandler ability scripts

### Call sites for ElementXp.Award():

| Ability | Calls ElementXp.Award? | Element | XP Amount | File:Line |
|---------|----------------------|---------|-----------|-----------|
| AirKick | YES | Air | 5 (Costs.AirKickElementXp) | `VFXHandler/AirKick.lua:101` |
| EarthStomp | YES | Earth | 6 (Costs.EarthStompElementXp) | `VFXHandler/EarthStomp.lua:120` |
| FireDropKick | YES | Fire | 8 (Costs.FireDropKickElementXp) | `VFXHandler/FireDropKick.lua:146` |
| WaterStance | YES | Water | 4 (Costs.WaterStanceElementXp) | `VFXHandler/WaterStance.lua:175` |
| Fist | **NO** | -- | -- | -- |
| Boomerang | **NO** | -- | -- | -- |
| MeteoriteSword | **NO** | -- | -- | -- |

**Impact**: 3 out of 7 combat abilities grant zero element XP. Since Fist and Boomerang are the starter weapons (available from level 1), new players grinding with these weapons will never advance element levels. Element levels only begin progressing when players unlock bending abilities at level 5+.

**Element level XP curve** (`Costs.lua:69-74`):
```
Level 1->2: 50 XP    Level 6->7: 550 XP     Level 11->12: 1850 XP   Level 16->17: 4400 XP
Level 2->3: 100 XP   Level 7->8: 725 XP     Level 12->13: 2250 XP   Level 17->18: 5100 XP
Level 3->4: 175 XP   Level 8->9: 950 XP     Level 13->14: 2700 XP   Level 18->19: 5900 XP
Level 4->5: 275 XP   Level 9->10: 1200 XP   Level 14->15: 3200 XP   Level 19->20: 6800 XP
Level 5->6: 400 XP   Level 10->11: 1500 XP  Level 15->16: 3750 XP   Max: 20
```

At 5 XP per AirKick hit, reaching element level 2 takes 10 hits. Reaching element level 10 requires 4375 total XP = 875 AirKick hits. This is a long grind.

---

## 5. Daily Quest Reset (BROKEN)

**Source**: `ServerScriptService/Server/Services/Player/QuestDataService.lua:32-67`

### IsSameDay Analysis

The function uses `os.date("!*t", ...)` which returns a table with **numeric** fields (yday, month, day, year are all numbers in Luau).

**Bug at line 50**: `if(currentDateTime.yday == "1") then` -- comparing number to string. **Always false.**

**Bug at lines 51-52**:
```lua
if(savedDateTime.month == "12" and savedDateTime.day == "31"
   and savedDateTime.year == tostring((currentDateTime.year - 1))) then
```
- `savedDateTime.month` is a number, compared to string `"12"` -- always false
- `savedDateTime.day` is a number, compared to string `"31"` -- always false
- `savedDateTime.year` is a number, compared to `tostring(...)` (a string) -- always false

**Consequence**: The New Year rollover case (Dec 31 -> Jan 1) will be treated as "before yesterday" instead of "same day". Players will get their daily quest reset even when they shouldn't, but this only matters on the single New Year boundary day.

**Lines 56-66** (normal day comparison): These use `tonumber(os.date("%Y",...))` and `tonumber(os.date("%j",...))` which correctly produce numbers, so the normal same-day/yesterday/before-yesterday logic works fine.

**Verdict**: The New Year special case is broken, but 364 out of 365 days the function works correctly.

---

## 6. XP Persistence (SOUND)

**Source**: `ReplicatedStorage/Modules/Custom/DataReplicator/DataServer.lua`

### Auto-save interval
- Default: **30 seconds** (`DataServer.lua:30`: `AutoSave = 30`)
- Implementation at `DataServer.lua:792-801`: `task.delay(self._config.AutoSave, ...)` recursively schedules saves
- Fires `AutoSaveAlert` 1 second before saving (line 796-797)

### Save triggers
1. **Auto-save**: Every 30 seconds via `AutoSave()` method
2. **Player leaving**: `OnPlayerLeaving` calls `self:Save(plr)` at line 122
3. **Game shutdown**: `game:BindToClose` in `PlayerDataService.lua:275-280` saves all players
4. **Explicit UpdateData calls**: Server code calls `_G.PlayerDataStore:UpdateData(player, playerData)` which updates in-memory data; actual persistence to Roblox DataStore happens on auto-save or player leave

### XP storage path
- `playerData.AllProfiles[ActiveProfile].XP` -- current XP within level
- `playerData.AllProfiles[ActiveProfile].TotalXP` -- cumulative total XP
- `playerData.AllProfiles[ActiveProfile].PlayerLevel` -- current level

### Gotcha from CLAUDE.md confirmed
`QuestDataService:OnPlayerAdded` mutates `plrData` in memory. Sprint fix added explicit `_G.PlayerDataStore:UpdateData(player, plrData)` at `QuestDataService.lua:183` when daily quest changes, preventing loss on quick disconnect.

---

## 7. Level-Up Ceremony (FRAGILE)

**Source**: `PlayerDataService.lua:143-167` and `LevelUpService.lua`

### What happens on level up:

1. **XP overflow handling** (`PlayerData.lua:633-649`): When XP exceeds `XpRequired`, excess carries to next level, level increments by 1, and `GiveLevelUpReward` is called. Recursively calls itself with 0 XP to handle multi-level jumps.

2. **Level-up reward** (`PlayerData.lua:689-708`): Grants Gold or Gems based on `LevelData` reward table for the new level.

3. **VFX trigger** (`PlayerDataService.lua:148-153`): `ListenSpecChange` on `AllProfiles` detects level change. If `newActiveProfile.PlayerLevel != player.Progression.LEVEL.Value`, fires `VFXHandler:PlayEffect(player, Constants.VFXs.LevelUp)`. This works for the levelling player.

4. **Stamina scaling** (`PlayerDataService.lua:161-165`): Recalculates `MaxStamina` = 100 + 2 * (Level - 1) and updates the `CombatStats.Stamina` Value object.

5. **Progression.LEVEL update** (`PlayerDataService.lua:158`): Sets `player.Progression.LEVEL.Value = Level`.

### LevelUpService broadcast issue

`LevelUpService.lua` (at `ServerScriptService/Server/Services/World/LevelUpService.lua`) listens for `CombatStats.Level` changes at line 32. However:
- The comment says "Listens for CombatStats.Level changes" but no code creates `CombatStats.Level`.
- `PlayerDataService.lua` updates `player.Progression.LEVEL.Value`, not `CombatStats.Level`.
- `CombatStats` folder contains: Stamina, Strength, Health, Energy, Agility, Defense, StatPoints, MaxStamina -- but NOT Level.

**Result**: `levelValue = combatStats:WaitForChild("Level", 10)` returns nil, so no connection is ever made. The broadcast to other players ("Replicate LevelUp") never fires. Other players do NOT see level-up VFX.

---

## 8. Data Model Consistency (SOUND)

### PlayerData.lua defaults vs CustomTypes.lua types

**ProfileSlotDataType fields** (CustomTypes.lua:450-468):
| Field | In CustomTypes? | In PlayerData defaults? | Match? |
|-------|----------------|------------------------|--------|
| SlotId | YES :451 | YES :38 | OK |
| SlotName | YES :452 | YES :39 | OK |
| CreatedOn | YES :453 | YES :41 | OK |
| XP | YES :455 | YES :48 | OK |
| TotalXP | YES :456 | YES :49 | OK |
| PlayerLevel | YES :457 | YES :50 | OK |
| Gold | YES :459 | YES :52 | OK |
| Gems | YES :460 | YES :53 | OK |
| CharacterId | YES :462 | YES :44 | OK |
| LastVisitedMap | YES :463 | YES :46 | OK |
| LastVisitedCF | YES :464 | YES :45 | OK |
| LastUpdatedOn | YES :465 | YES :41 | OK |
| Data | YES :467 | YES :55+ | OK |

**SlotDataType fields** (CustomTypes.lua:483-491):
| Field | In CustomTypes? | In PlayerData defaults? | Match? |
|-------|----------------|------------------------|--------|
| Settings | YES :484 | YES :56-62 | OK |
| EquippedInventory | YES :485 | YES :64-83 | OK |
| CombatStats | YES :487 | YES :94-103 | OK |
| PlayerStats | YES :488 | YES :105-108 | OK |
| Quests | YES :489 | YES :85-92 | OK |
| ElementLevels | YES :490 | YES :110-116 | OK |

**ElementLevelsType** (CustomTypes.lua:476-481):
| Element | In CustomTypes? | In PlayerData defaults? | Match? |
|---------|----------------|------------------------|--------|
| Air | YES :477 | YES :112 | OK |
| Fire | YES :478 | YES :113 | OK |
| Earth | YES :479 | YES :114 | OK |
| Water | YES :480 | YES :115 | OK |

**AllQuestsType** (CustomTypes.lua:416-424):
| Field | In CustomTypes? | In PlayerData defaults? | Match? |
|-------|----------------|------------------------|--------|
| NPCQuestData | YES :417 | YES :88 | OK |
| DailyQuestData | YES :418 | YES :87 | OK |
| LevelQuestData | YES :419 | YES :86 | OK |
| TutorialQuestData | YES :420 | YES :89 | OK |
| JourneyQuestProgress | YES :422 | YES :90 | OK |
| KataraQuestProgress | YES :423 | YES :91 | OK |

All fields are consistent. The `CheckAndUpdatePlayerData` Sync function (`PlayerData.lua:230-269`) will add missing keys from the template and remove undeclared keys, so any new field must be added to both places.

---

## 9. LevelUpService (FRAGILE)

**Source**: `ServerScriptService/Server/Services/World/LevelUpService.lua`

### What it does
- Listens for `CombatStats.Level` ValueObject changes on each player character
- When level increases, broadcasts `Replicate:FireClient(otherPlayer, "LevelUp", plr, newLevel)` to all OTHER players
- Properly handles character respawns (reconnects listener on `CharacterAdded`)
- Properly cleans up on `PlayerRemoving`

### Why it does not work
- Watches `CombatStats.Level` (line 32) which does not exist
- The actual level is stored on `Progression.LEVEL` ValueObject
- `combatStats:WaitForChild("Level", 10)` times out (returns nil), so the connection is never established
- Net effect: level-up VFX are visible only to the player who levelled up (via `PlayerDataService.lua:153`), not to other players in the server

### Fix recommendation
Change line 28-29 from:
```lua
local combatStats = plr:WaitForChild("CombatStats", 10)
local levelValue = combatStats:WaitForChild("Level", 10)
```
To:
```lua
local progression = plr:WaitForChild("Progression", 10)
local levelValue = progression and progression:WaitForChild("LEVEL", 10)
```

---

## Summary of Recommended Fixes

1. **LevelData.lua:19** -- Fix level 6 MinXp from 7500 to 5400 (= level 5 MaxXp + 1)
2. **QuestDataService.lua:50-53** -- Compare numeric fields to numbers, not strings: `currentDateTime.yday == 1` instead of `== "1"`, etc.
3. **VFXHandler/Fist.lua, Boomerang.lua, MeteoriteSword.lua** -- Add `ElementXp.Award()` calls (decide which element or skip for non-elemental weapons)
4. **LevelUpService.lua:28-32** -- Watch `Progression.LEVEL` instead of `CombatStats.Level`
