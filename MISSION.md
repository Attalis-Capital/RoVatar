# MISSION.md — RoVatar Full End-to-End Review

**Date:** 2026-02-20
**Place ID:** 10467665782 | **Universe ID:** 3812540898
**Game Stats:** 208k visits, 25% approval (121 up / 367 down), 0 concurrent players

Two perspectives inform every finding:
1. **Elite Gamer (12–16yo)** — what feels broken, boring, confusing, or unfair
2. **Senior Roblox Developer** — what's exploitable, unmaintainable, or architecturally unsound

---

## Domain 1: Security & Exploits

The game is **wide open to exploiters**. The architectural root cause is a single design error: the `DataReplicator` system provides bidirectional client-to-server data write capability, and the entire game economy/quest/progression was built on top of it client-side. Any Roblox game must treat the client as fully untrusted.

### CRITICAL

| ID | Finding | File:Line | Impact |
|----|---------|-----------|--------|
| S1 | **Remote Code Execution** — `loadstring(code)()` via unauthenticated Knit signal. Any player can execute arbitrary server-side Lua. Client-side UserId check is trivially bypassed. | `ServerScriptService/Server/Services/DevService.lua:31-33, 62-63` | Full server compromise — DataStore wipe, currency injection, player manipulation, HTTP exfiltration |
| S2 | **Arbitrary data overwrite** — `UpdateDataRqst` RemoteEvent accepts a full player data table from the client. Zero schema validation. 26+ client scripts route through this. | `ReplicatedStorage/Modules/Custom/DataReplicator/DataServer.lua:330, 346-348, 642-655` | Complete economy bypass — set Gold/Gems/Level/Inventory to any value |
| S3 | **Any player's data deletable** — `RemovePlrData` RemoteEvent accepts a target `plrId` from any client and resets that player's DataStore entry to defaults. | `DataServer.lua:335, 355-358, 733-746` | Targeted griefing — permanently wipe any player's progress |
| S4 | **Client-side purchase (Gold)** — ShopGui deducts currency, grants items, pushes crafted data to server. Server never validates balance, price, or ownership. | `StarterPlayer/.../HomeScreens/ShopGui.lua:59-88` | Free items — Appa, Glider obtained without spending Gold |

### HIGH

| ID | Finding | File:Line | Impact |
|----|---------|-----------|--------|
| S5 | **VFXHandler dispatches any ability** — `CastEffect` RemoteEvent calls any VFXHandler module by string name with no bending-type or stamina validation at the dispatch layer. | `ReplicatedStorage/Modules/Custom/VFXHandler.lua:48-50` | Players use abilities they don't own (e.g. FireBender uses EarthStomp) |
| S6 | **VFXHandler ability validation commented out** — EarthStomp and FireDropKick VFXHandler modules have all stamina/level checks commented out. | `VFXHandler/EarthStomp.lua:25-29`, `VFXHandler/FireDropKick.lua:24-28` | Infinite ability spam at any level with zero stamina cost |
| S7 | **Client self-reports quest progress** — `QuestDataService.Client.UpdateQuest` accepts objective+achievement from the client without proof of achievement. | `ServerScriptService/.../QuestDataService.lua:22-23, 186` | Skip quests — report any objective as complete without doing it |
| S8 | **Client-side quest assignment** — QuestGuy assigns quest data and rewards entirely client-side, pushes via `UpdateData`. | `StarterPlayer/.../NPC/QuestGuy.lua:75-98` | Craft arbitrary quests with inflated rewards |
| S9 | **RateLimiter exists but unused** — `RateLimiter.lua` is functional but applied to zero RemoteEvents or Knit signals. | `ReplicatedStorage/Replica/RateLimiter.lua` (unused) | Flood any endpoint — ability spam, DataStore write exhaustion |
| S10 | **Arbitrary path write** — `UpdateSpecDataRqst` accepts a dotted path string and new value from client. No path whitelist. | `DataServer.lua:331, 350-352, 674-706` | Set `CombatStats.Gold`, `GamePurchases.Passes.glider_pass`, etc. to any value |

### MEDIUM

| ID | Finding | File:Line | Impact |
|----|---------|-----------|--------|
| S11 | **ResetPlayerInfoClick no server auth** — Knit client method for data reset lacks server-side admin check (client-side only). | `DevService.lua:44-55` | Second entry point for S3 data wipe |
| S12 | **Client-side IAP credit** — StoreGui applies Gem/Gold credit after purchase callback on client, pushes via `UpdateData`. | `StarterPlayer/.../HomeScreens/StoreGui.lua:76-85` | Spoof purchase signal → free Gems/Gold without Robux spend |
| S13 | **Fist_S.lua shared mutable state** — `M1Debounce`, `Combo`, `hit` at module scope, shared across all players in old system. | `ReplicatedStorage/.../Fist/Fist/Fist_S.lua:22-29` | Combo corruption; hit deduplication bypass in multiplayer |
| S14 | **SafeZone check uses client-writable attribute** — `InSafeZone` is a character Attribute that can be overwritten by client. | `AirKick_S.lua:101-102`, `EarthStomp_S.lua:126-128`, `FireDropKick_S.lua:148-149` | Attack players in safe zones by clearing own attribute |

### LOW

| ID | Finding | File:Line | Impact |
|----|---------|-----------|--------|
| S15 | Admin UserIds in client-readable LocalScript | `StarterPlayer/.../DevController.lua:65-71` | Account enumeration for social engineering |
| S16 | Deprecated `spawn()`/`wait()` with unpredictable scheduling | 44+ files use `spawn()`, 61+ use `wait()` | Timing drift under load — exploitable cooldown gaps |

---

## Domain 2: Combat & Balance

### Gamer Perspective
Punching feels wrong — sometimes it costs stamina, sometimes it doesn't. Damage numbers are inconsistent. After level 12 you unlock everything and combat gets stale. Blocking is useless. NPCs just rush you with fast attacks you can't dodge.

### Developer Perspective

**B1: Dual combat systems active simultaneously** — The old `Bendings/` scripts (parented to tool models, fire via per-ability RemoteEvent) and the new `VFXHandler/` system (central `CastEffect` RemoteEvent) both have active server listeners. For Fist specifically, a single M1 click triggers BOTH `Fist_S.lua` and `VFXHandler/Fist.lua`, potentially applying damage twice.
- Old system: `ReplicatedStorage/Assets/Models/Combat/Bendings/` (6 scripts)
- New system: `ReplicatedStorage/Modules/Custom/VFXHandler/` (8 modules)
- Client calls: `CharacterController.lua` exclusively uses VFXHandler (lines 834, 918, 1007, 1106, 1185, 1249, 1351)

**B2: Fist stamina/XP mismatches across systems**

| Metric | Costs.lua | Fist_S.lua (old) | VFXHandler/Fist.lua (new) |
|--------|-----------|------------------|--------------------------|
| Stamina cost | 5 | 6 (hardcoded) | **0** (commented out, line 54) |
| XP reward | 3 | 5 (hardcoded, line 141) | 3 (reads Costs.lua) |
| Damage | Not defined | `7.1 * (1 + str * 0.015)` (line 44) | Same formula (line 40) |

**B3: Hardcoded M1 formula** — `7.1 * (1 + (pStrength * 0.015))` appears in `Fist_S.lua:44` and `VFXHandler/Fist.lua:40`. No `FistDamageRange`, `FistBaseDamage`, or `FistStrengthMultiplier` exists in Costs.lua.

**B4: WaterStance MaxHealth manipulation** — Old system (`Stance_Weld.lua:24-25`) adds +50 MaxHealth on activation with no cap. Repeated activation stacks infinitely. New system has this commented out (`VFXHandler/WaterStance.lua:63-64`) but left a debug print at line 228.

**B5: NPC damage hardcoded** — `NPCModule.lua:34,44` defines `Damage = 7` (NPCAI) and `Damage = 3` (TUTORIALAI). In practice, `Helper.lua:108-120` overrides with level-scaled 3–15, but the hardcoded fallbacks exist outside Costs.lua.

**B6: Old EarthStomp_S and FireDropKick_S are broken** — Both reference `require(Modules.Misc)` (lines 45 and 30 respectively) instead of `Modules.Packages.Misc`. These scripts error on every invocation.

**B7: Boomerang lacks server-side cooldown** — Unlike other abilities that check `plr:GetAttribute("XCD")`, VFXHandler/Boomerang.lua has no server-side cooldown enforcement.

**B8: FastCast installed but unused** — `ReplicatedStorage/Packages/FastCastRedux.lua` is never required by any game code. All projectiles use `BodyVelocity` + `Touched` events.

### Balance Table — All Abilities

| Ability | Damage | Stamina | XP | Cooldown | Level | System | Server Validated |
|---------|--------|---------|-----|----------|-------|--------|-----------------|
| Fist (M1) | 7.1–17.75 (str scaled) | Old: 6 / **New: 0** | Old: 5 / New: 3 | Animation debounce | — | Both (bug) | Yes |
| AirKick | 25–35 | 8 | 4 | 5s | 5 | VFXHandler | Yes |
| FireDropKick | 45–50 | 15 | 7 | 5s | 8 | VFXHandler | Yes |
| EarthStomp | 35–45 | 12 | 5 | 5s | 11 | VFXHandler | Yes |
| WaterStance | 20–30/tick | 10 | 3/tick | 5s | 12 | VFXHandler | Yes (MaxHealth disabled) |
| Boomerang | 30–50 | 5 | 8 | 3s | — (Robux) | VFXHandler | SafeZone only, **no cooldown** |
| MeteoriteSword | 7.1–17.75 (str scaled) | 5 | 6 | Animation debounce | — (Robux) | VFXHandler | Yes |
| NPC (NPCAI) | 3–15 (level scaled) | — | — | 0.4–1.0s | — | NPCModule | — |
| NPC (Tutorial) | 3 | — | — | — | — | NPCModule | — |

---

## Domain 3: Data & Persistence

### Gamer Perspective
"I played for an hour and when the server crashed I lost everything." There's no auto-save. If the game updates while you're playing, your progress might vanish.

### Developer Perspective

**D1: Auto-save disabled** — `DataServer.lua:202` has `--self:AutoSave()` commented out. The Heartbeat save body is also commented out at lines 775-777. Players only save on `PlayerRemoving`. A crash or unexpected shutdown = total session data loss.

**D2: BindToClose saves nothing** — `PlayerDataService.lua:257-263` calls `onPlayerRemoved(plr)` for all players, but `onPlayerRemoved` at line 181-183 has an **empty function body**. On graceful server shutdown (update deploy), this path does nothing. The DataReplicator's own `PlayerRemoving` listener (line 383) does save, but `BindToClose` is a separate broken path.

**D3: MadworkReplica is dead code** — The entire `ReplicatedStorage/Replica/` directory (6 files: ReplicaService, ReplicaController, ReplicaServiceListeners, MadworkMaid, MadworkScriptSignal, RateLimiter) is never required by any active script. The game uses `DataReplicator` instead.

**D4: `_G.PlayerDataStore` global pattern** — Set at `PlayerDataService.lua:27` (server) and `DataController.lua:14` (client). `_G.PlayerData` snapshot set at `DataController.lua:35`, read directly by 30+ client scripts with no nil guard. Race condition: scripts that run before `ListenChange` fires will crash.

**D5: No element XP fields** — `PlayerData.lua:48-50` has only `XP`, `TotalXP`, `PlayerLevel`. No `AirXP`, `FireXP`, etc. ROVA-4 (element progression) requires data model extension and version bump from current `1.32`.

**D6: DataVersionHandler is a debug-only read tool** — `DataVersionHandler.lua` (44 lines) reads all DataStore keys but never writes. Never required by any script. Actual migrations happen in `PlayerData.lua:191-293` via `CheckAndUpdatePlayerData()`. The `remove()` function (line 263-283) is defined but **never called** — stale keys accumulate forever.

**D7: Duplicate ProductId** — Four developer products all share ProductId `1873595644`:

| Product | Line in Constants.lua |
|---------|----------------------|
| GemsPack (50k Gems) | 507 |
| Gems2x multiplier | 536 |
| MegaLuck (3x hatch luck) | 565 |
| MegaLuck2 | 594 |

`IAPService.lua` uses ProductId as the lookup key — only the last-registered handler fires. Three of four products cannot be fulfilled.

**D8: DataServer.lua suppresses all logging** — Lines 7-8: `local warn = function() end` and `local print = function() end`. DataStore failures are completely invisible.

**D9: Duplicate DataModels files** — `CommonFunctions/DataModels.lua` and `CommonFunctions/Utils/DataModels.lua` are byte-for-byte identical.

---

## Domain 4: Player Experience

### Gamer Perspective

**P1: No direction on first join** — You spawn in the Hub with no forced tutorial path. The tutorial NPC uses a ProximityPrompt (walk close + click). `TutorialGuider.lua:275` has `self:StartMoving()` commented out — the NPC just stands there. New players get no automatic guidance.

**P2: No control prompts** — `ControlsGuideGui.lua` exists but has **no entry point in any menu**. No button opens it. No auto-show on first join. Keys 1-4 for abilities, Q for block, N for meditate — all undiscoverable without trial-and-error.

**P3: Store button opens GamePass** — `MainMenuGui.lua:158-161`: `StoreButton()` is commented out on line 159; `GamePassButton()` is called instead on line 160. Clicking "Store" opens the GamePass/Robux screen. The actual Gold shop is unreachable from the sidebar.

**P4: GamePass button disconnected** — `MainMenuGui.lua:163-165`: The `GamePassBtn.Activated` handler is entirely commented out. The button appears but does nothing. Lines 184, 191: show/hide logic also commented out, so it's always hidden.

**P5: Locked ability UX** — `BendingSelectionGui.lua:126-144`: Locked abilities show greyed-out "Select" button with no "Requires Level X" tooltip. The `Shadow.Lock.Label` exists in the template but `Refresh()` never sets it. Contrast with `ShopGui.lua:182` which does show level requirements — the pattern exists but wasn't carried through.

**P6: Silent quest expiry** — `QuestGui.lua:114-185`: `TimeOver()` silently clears quest data and calls `Refresh()`. No warning notification, no sound. The timer is visible in the quest panel, but no "5 minutes remaining" alert fires.

**P7: BendingSelectionGui has no context** — Element descriptions are one-line flavour text only:
- AirBending: "Swift, evasive, and untouchable" (`Constants.lua:614`)
- FireBending: "Explosive power with fierce aggression" (line 641)
- EarthBending: "Unyielding strength and solid defense" (line 668)
- WaterBending: "Graceful, adaptive, and relentless" (line 695)
No attack descriptions, cooldowns, mechanics, or playstyle info.

**P8: Duplicate quest tracking** — Two overlapping right-side systems both always active:
- `QuestGui.lua:465-475` — TaskHintDisplay slides in from right
- `QuestTrackerHUD.lua:34-44` — Separate ScreenGui at `UDim2.new(1, -275, 0, 120)`
Both listen to `_G.PlayerDataStore:ListenChange`. They occupy the same screen region.

**P9: DialogueGui duplicated** — `ReplicatedFirst/DialogueGui.lua` (canonical, has Welcome + SkipAll) and `StarterPlayer/.../GUIs/DialogueGui.lua` both use `Component.new({Tag = "DialogueGui"})`. Two Component instances registered with the same tag = double dialogue renders or silent state corruption.

**P10: Only 2 gold shop items** — `ShopGui.lua:147-148` hardcodes only `Appa` and `Glider`. The physical shop opens to a near-empty UI. No consumables, cosmetics, or other categories.

**P11: MegaLuck references hatching** — `Constants.lua:552, 581`: "Gives you 3x luck while hatching!" — no hatching system exists. This is a Robux Dev Product with a misleading description. Potential Roblox platform policy violation.

**P12: QuestGuy `Talking` boolean shared across all NPCs** — `QuestGuy.lua:46`: Module-level `local Talking = false` is shared across every NPC instance. If one NPC's dialogue is active, all other NPCs' ProximityPrompts are blocked for all players. `TutorialGuider.lua:38` uses `_G.Talking` instead (global, cross-contamination risk).

---

## Domain 5: Progression & Economy

### Gamer Perspective
You unlock everything by level 12 then there's nothing new for 88 more levels. Quests expire without warning. You can only do one NPC quest at a time. Killing enemies after the first 3 gives nothing special. The shop has two items. After buying the Glider and Appa, Gold is useless. Getting to level 100 would take hundreds of thousands of hits.

### Developer Perspective

**E1: Single-track XP only** — `PlayerData.lua:48-50` stores `XP`, `TotalXP`, `PlayerLevel`. No element-specific XP. All combat XP (3–8 per hit) feeds one level. ROVA-4 requires this as a prerequisite.

**E2: Only 1 NPC quest at a time** — `PlayerData.lua:84-91` defines exactly four quest slots (Level, Daily, NPC, Tutorial). `QuestGuy.lua:80-83` enforces strict single-NPC-quest cap.

**E3: Client-side quest updates create dual path** — Server (`QuestDataService.lua:120-136`) and client (`QuestController.lua:45-66`) both call `CF.Validations.UpdateQuest` independently on the same kill event. Same kill can advance the counter twice, completing quests in half the expected kills.

**E4: Fragile quest chain counters** — `JourneyQuestProgress` and `KataraQuestProgress` (`PlayerData.lua:89-90`) are plain integers with:
- No upper bound check (overshoot = skip future quests permanently)
- `or 1` fallback only guards `nil`, not corrupt values like 0
- No way to reset without data migration

**E5: No persistent quest log** — `PlayerData.lua:704-712`: Completed quests are wiped to `{}`. No `CompletedQuests` array, no achievement log. Line 711 has `--plrQuestData.LevelQuestData.CompletedQuests[QuestData] = QuestData` commented out — planned but never implemented.

**E6: Kill rewards front-loaded** — `PlayerDataService.lua:210-243`:
- Kill #1: +100 Gold
- Kill #2: +50 XP
- Kill #3: +100 Gold
- Kill #4+: nothing

**E7: All abilities unlocked by level 12** — `Costs.lua:21-24`:
- AirKick @ Level 5
- FireDropKick @ Level 8
- EarthStomp @ Level 11
- WaterStance @ Level 12
- Levels 13–100: zero new mechanics. Only Gold/Gem milestone rewards.

**E8: No loot drops from NPCs** — `NPCModule.Reward` (line 107-113) references `game.ReplicatedStorage.Modules.Packages.QuestSystem` which doesn't exist — dead code that would error at runtime. `NPCAI.lua` never calls it. NPC kills produce nothing beyond quest progress.

**E9: Level 100 requires ~4.88M XP** — `LevelData.lua` defines explicit XP requirements per level. Key milestones:

| Level | XP Required | Cumulative |
|-------|-------------|------------|
| 10 | 4,500 | ~17,000 |
| 20 | 10,000 | ~60,000 |
| 50 | 37,000 | ~500,000 |
| 80 | 95,000 | ~2,100,000 |
| 100 | 140,000 | ~4,877,500 |

At 5.5 avg XP/hit: **~887,000 hits to level 100**. At 8 XP/hit (Boomerang, best): 610,000 hits. No meaningful XP multiplier or bonus beyond quest rewards exists.

**E10: Gold becomes useless** — Glider (2,000) + Appa (10,000) = 12,000 Gold max spend. Level-up rewards reach 36,500 Gold per level at high levels. No other Gold sinks exist. Characters cost Gems, not Gold.

**E11: `__updateDeaths` called on NPC models** — `NPCAI.lua:94` calls `__updateDeaths(Players:GetPlayerFromCharacter(character))` on NPC death. NPCs aren't players, so `GetPlayerFromCharacter` returns nil. Silently fails every NPC death.

---

## Domain 6: Code Health & Infrastructure

### H1: CharacterController.lua — 1957 lines
6.5x the project's 300-line limit. Manages character lifecycle, combat input, bending abilities, animation states, stamina, and movement in one file. Any change risks breaking unrelated systems with zero test coverage.

### H2: 51 files exceed 300 lines
The worst offenders beyond CharacterController:

| File | Lines |
|------|-------|
| `CharacterController.lua` | 1957 |
| `Animate.lua` | 761+ |
| `DataServer.lua` | 537+ |
| `NPCAI.lua` | 431+ |
| `QuestGui.lua` | ~400+ |
| `LoadGameGui.lua` | ~350+ |
| `QuestGuy.lua` | ~350+ |
| Multiple VFXHandler ability scripts | 300+ each |

### H3: Deprecated API usage
- **44 files** use deprecated `spawn()` (should be `task.spawn()`)
- **61 files** use deprecated `wait()` (should be `task.wait()`)
- `AirKick_S.lua:37` has `wait(0.2)` at the **top level** (outside any function), blocking script load

### H4: Zero CI/CD, Rojo, tests, or linter
- No `.github/workflows/` directory
- No `*.project.json` (Rojo)
- No `*.spec.lua` or `*.test.lua` in project code (only vendor packages)
- No `selene.toml` or `.luacheckrc`
- Every push goes live with zero automated verification

### H5: 16 `_G` globals with 357 references
Top offenders: `_G.SelectedCombat` (92 refs), `_G.PlayerData` (74), `_G.PlayerDataStore` (62), `_G.ActiveBending` (45). Violates CLAUDE.md rule against shared module-level mutable state. Makes dependency tracking impossible.

### H6: GameAnalyticsService is empty
`ServerScriptService/Server/Services/World/GameAnalyticsService.lua` is 4 lines — `local module = {} return module`. No analytics, no telemetry, no error reporting.

### H7: Fusion vestigial
Fusion 0.2.0 installed at `Packages/_Index/elttob_fusion@0.2.0/`. Only consumer: `UIClasses/Button1.lua` — which is never required by any file. Dead code.

### H8: 9 identical copies of Animate.lua
All confirmed identical by hash (`beafa76cebc30ad2dcaef659b4bf8d83`) across `Assets/Scripts/`, `NPCAI/Templates/`, and 7 individual NPC folders.

### H9: Duplicate module copies
- `Signal.lua` — 3 separate copies in project code
- `SimplePath.lua` — 2 copies at different paths
- `DataModels.lua` — 2 identical copies in `CommonFunctions/` and `CommonFunctions/Utils/`
- `Value.lua` — 2 copies at `CommonFunctions/Value.lua` and `CommonFunctions/Utils/Value.lua`

### H10: Zero TODO/FIXME markers
Grep for `TODO|FIXME|HACK|XXX` returns 0 results. Technical debt is embedded silently in commented-out code blocks and suppressed warnings.

### H11: DataServer.lua suppresses all logging
Lines 7-8: `local warn = function() end` and `local print = function() end`. DataStore failures are invisible in server output.

---

## Backlog Assessment

### #2 — P0: First-Session Onboarding Blockers
- **Current state:** Tutorial exists but requires manual NPC interaction. Loading screen issues, UI clutter during tutorial, missing teaching of Block/Sprint/Meditate. PVP griefing at spawn.
- **Prerequisites:** S1-S4 security fixes first (exploiters would grief new players harder than onboarding issues)
- **Recommendation:** **GO** — after Tier 1 security fixes. High ROI for approval rate.
- **Scope:** ~8 files, medium complexity. TutorialGuider, MainMenuGui, ControlsGuideGui, CharacterController.

### #3 — P0: Combat Critical Bugs and Balance
- **Current state:** Dual combat systems running simultaneously (B1). Fist stamina free in new system. Block nearly useless. Stamina doesn't reset on death.
- **Prerequisites:** Retire old Bendings/ system entirely. Fix VFXHandler validation (S5, S6).
- **Recommendation:** **GO** — merge with security Tier 1 (retiring old system fixes both S5/S6 and B1/B2).
- **Scope:** ~15 files, high complexity. All VFXHandler modules, Fist_S.lua, Costs.lua, CharacterService.

### #4 — P1: Progression System and Quest Overhaul
- **Current state:** Single-track XP only (E1). 1 NPC quest at a time (E2). No element XP fields (D5). Quest rewards client-side (S8). Dual update path (E3).
- **Prerequisites:** S2/S7/S8 security fixes (quest/data integrity). D5 data model extension. D1 auto-save re-enable.
- **Recommendation:** **GO** — this is the highest-impact feature for retention, but needs Foundation tier first.
- **Scope:** ~20 files, high complexity. PlayerData, QuestDataService, QuestController, QuestGuy, Constants, LevelData.

### #5 — P1: UI/UX Polish
- **Current state:** Store button bug (P3), GamePass button dead (P4), locked ability UX (P5), only 2 shop items (P10). Loading screen, character selection, overhead displays all need work.
- **Prerequisites:** None blocking — mostly independent UI fixes.
- **Recommendation:** **GO** — many quick wins here (P3 is a one-line fix).
- **Scope:** ~12 files, medium complexity. MainMenuGui, BendingSelectionGui, ShopGui, LoadGameGui, SettingsGui.

### #6 — P2: Audio System
- **Current state:** Game is essentially silent. No UI sounds, no footsteps, no area music, no combat audio.
- **Prerequisites:** None — audio is independent of all other systems.
- **Recommendation:** **DEFER** to after P0/P1. High atmosphere impact but won't move the approval needle as much as fixing broken fundamentals.
- **Scope:** ~5 new files, medium complexity. Audio controller, area detection, footstep handler.

### #7 — P2: Pet Lemur (Momo)
- **Current state:** GamePass purchasable but pet doesn't appear. `Pets/Momo/State/Handler.lua` exists as a basic follow script. No animations, no spawn/despawn logic.
- **Prerequisites:** None — independent system.
- **Recommendation:** **DEFER** — low player impact vs. fixing core loops. However, players who already paid for the GamePass are being actively defrauded. Consider a quick fix to at least spawn the pet, or refund.
- **Scope:** ~3 files, medium complexity. Handler, animations, GamePass integration.

### #8 — P3: NPC/Location Renaming (IP De-risk)
- **Current state:** All names directly reference Avatar: The Last Airbender IP. Renaming table exists in external doc.
- **Prerequisites:** Stable quest system first (#4) — quest scripts reference NPC names.
- **Recommendation:** **DEFER** — legal risk but no gameplay impact. Do after quest system is stable.
- **Scope:** ~15 files, low complexity but wide surface area. Constants, quest modules, UI text, tutorial.

### #9 — P3: Feature Backlog (Combat/Narrative/PVP)
- **Current state:** Wishlisted features. None started. PVP arena, element-specific abilities, boss fights, expanded customisation.
- **Prerequisites:** Stable combat (#3), progression (#4), and security (Tier 1).
- **Recommendation:** **DEFER** — don't build features on a broken foundation.
- **Scope:** Very large, multi-sprint.

### New Issues Found During Review

| Issue | Priority | Description |
|-------|----------|-------------|
| #19 (existing) | Low | XP listener accumulates on respawn — `EffectsController.lua` |
| NEW | **P0** | D1: Auto-save commented out — data loss on crash |
| NEW | **P0** | D2: BindToClose empty — data loss on graceful shutdown |
| NEW | **P0** | D7: Duplicate ProductIds — 3 of 4 IAP products unfulfillable |
| NEW | **P0** | S1: Remote Code Execution — server compromise |
| NEW | **P1** | P11: MegaLuck describes nonexistent hatching — Robux policy violation |
| NEW | **P1** | E11: `__updateDeaths` on NPC models — silent failure every kill |

---

## Prioritised Action Plan

### Tier 1: STOP THE BLEEDING (do before ANY feature work)

These are exploits and data-loss bugs that make the game unsafe to operate.

| # | Action | Files | Effort |
|---|--------|-------|--------|
| 1.1 | **Delete `ExecuteCode` signal and `CodeExecuteRequest`** from DevService.lua. Remove `loadstring` entirely. | DevService.lua | 10 min |
| 1.2 | **Remove `UpdateDataRqst`, `UpdateSpecDataRqst`, `RemovePlrData`** from DataServer.lua's client-facing RemoteEvents. All data mutations must originate server-side. | DataServer.lua | 2–4 hrs |
| 1.3 | **Create server-side intent signals** to replace client data writes: `RequestPurchaseItem(itemId)`, `RequestAssignQuest(npcId)`, `RequestClaimQuest()`, `RequestUpdateSettings(key, value)`. Each validates server-side before writing. | New: PurchaseService, QuestClaimService; modify: ShopGui, StoreGui, QuestGuy, BendingSelectionGui, SettingsGui, LoadGameGui + 20 more | 3–5 days |
| 1.4 | **Uncomment auto-save** at DataServer.lua:202 (`self:AutoSave()`). One-line fix, prevents total data loss on crash. | DataServer.lua:202 | 5 min |
| 1.5 | **Fix BindToClose** — add `_G.PlayerDataStore:Save(player)` to `onPlayerRemoved()` at PlayerDataService.lua:181. | PlayerDataService.lua:181-183 | 10 min |
| 1.6 | **Fix duplicate ProductIds** — create 3 new dev products in Roblox Dashboard, update Constants.lua lines 536, 565, 594 with unique IDs. | Constants.lua | 30 min |
| 1.7 | **Retire old Bendings/ server scripts** — disable all `_S.lua` scripts under `Assets/Models/Combat/Bendings/` (or delete their `OnServerEvent` connections). This fixes S5/S6 and B1 simultaneously. | 6 scripts in Bendings/ | 1 hr |
| 1.8 | **Uncomment VFXHandler ability validation** — restore stamina/level checks in `VFXHandler/EarthStomp.lua:25-29` and `VFXHandler/FireDropKick.lua:24-28`. | 2 files | 15 min |
| 1.9 | **Re-enable Fist stamina deduction** — uncomment `VFXHandler/Fist.lua:54`. | 1 line | 5 min |
| 1.10 | **Apply RateLimiter** to `CastEffect`, `UpdateQuest`, and all remaining RemoteEvents. | VFXHandler.lua, QuestDataService.lua, DataServer.lua | 2 hrs |

### Tier 2: FOUNDATION (architecture fixes that unblock features)

| # | Action | Files | Effort |
|---|--------|-------|--------|
| 2.1 | **Move all quest progress updates server-side** — remove `CF.Validations.UpdateQuest` from QuestController.lua. All quest progress via QuestDataService only. | QuestController.lua, QuestDataService.lua | 2 hrs |
| 2.2 | **Move quest claim server-side** — add `QuestDataService.Client.ClaimQuest` that validates server-side before awarding rewards. Remove client-side claim in QuestGuy.lua:59-73. | QuestGuy.lua, QuestDataService.lua | 3 hrs |
| 2.3 | **Add element XP fields** to PlayerData schema — `AirXP`, `FireXP`, `WaterXP`, `EarthXP` (and `AirLevel` etc.). Bump DataStore version. Sync() auto-fills for existing players. | PlayerData.lua, Constants.lua | 2 hrs |
| 2.4 | **Replace `_G` globals** with Knit Controller methods — `DataController:GetPlayerData()` instead of `_G.PlayerData`. Affects 30+ files but is mechanical. | DataController.lua + 30 consumers | 1 day |
| 2.5 | **Split CharacterController.lua** into `CombatController`, `MovementController`, `BendingController`, `AnimationStateController`. Each under 300 lines. | CharacterController.lua → 4 new files | 1 day |
| 2.6 | **Delete dead code** — `ReplicatedStorage/Replica/` (6 files), `UIClasses/Button1.lua`, `DataVersionHandler.lua`, `NPCModule.Reward` dead function, 8 duplicate `Animate.lua` copies. | Multiple | 1 hr |
| 2.7 | **Restore DataServer logging** — remove `warn = function() end` overrides at DataServer.lua:7-8. Replace with structured toggle. | DataServer.lua:7-8 | 15 min |
| 2.8 | **Replace deprecated spawn/wait** — mechanical find-and-replace across 61+ files. `spawn(` → `task.spawn(`, `wait(` → `task.wait(`. | 61 files | 2 hrs |

### Tier 3: GAMEPLAY (features that drive retention)

| # | Action | Files | Effort |
|---|--------|-------|--------|
| 3.1 | **Fix Store button bug** — uncomment `StoreButton()` at MainMenuGui.lua:159, remove `GamePassButton()` at line 160, restore GamePassBtn handler. | MainMenuGui.lua:158-165 | 10 min |
| 3.2 | **Add level requirement tooltip** to locked abilities in BendingSelectionGui — mirror ShopGui.lua:182 pattern. | BendingSelectionGui.lua:126-144 | 30 min |
| 3.3 | **Fix MegaLuck descriptions** — update Constants.lua:552, 581 to accurately describe the product. | Constants.lua | 5 min |
| 3.4 | **Add quest expiry warning** — fire notification at 5 min remaining in QuestGui.lua's `countDownFunction`. | QuestGui.lua | 30 min |
| 3.5 | **Consolidate quest tracking** — pick one of QuestTrackerHUD or TaskHintDisplay, remove the other. | QuestGui.lua, QuestTrackerHUD.lua | 1 hr |
| 3.6 | **Fix QuestGuy Talking** — move to `self.Talking` per-instance instead of module-level. | QuestGuy.lua:46 | 15 min |
| 3.7 | **Remove duplicate DialogueGui** — delete StarterPlayerScripts copy, keep ReplicatedFirst. | StarterPlayer/.../GUIs/DialogueGui.lua | 5 min |
| 3.8 | **Add ControlsGuideGui entry point** — add "Controls" button to MainMenuGui sidebar + auto-show on first join. | MainMenuGui.lua, ControlsGuideGui.lua | 1 hr |
| 3.9 | **Add NPC Gold drops** — 10–50 Gold per NPC type to create continuous earn loop. | NPCAI.lua, PlayerDataService.lua | 2 hrs |
| 3.10 | **Expand shop** — add Gold sinks (cosmetics, stat boosts, transport tiers) so accumulated Gold has purpose. | ShopGui.lua, Constants.lua | 1 day |
| 3.11 | **Add ability unlock milestones** beyond level 12 — passive stat upgrades or new abilities at levels 15, 20, 25, 30. | Costs.lua, Constants.lua, VFXHandler modules | 2 days |

### Tier 4: POLISH (tech debt and infrastructure)

| # | Action | Files | Effort |
|---|--------|-------|--------|
| 4.1 | **Add Rojo project file** — `default.project.json` for file-based syncing. | New file | 1 hr |
| 4.2 | **Add Selene linter** — `selene.toml` with Luau type-checking pass. | New file + CI | 2 hrs |
| 4.3 | **Add GitHub Actions CI** — lint + type check on every push. | `.github/workflows/ci.yml` | 2 hrs |
| 4.4 | **Implement GameAnalyticsService** — funnel tracking, error reporting, session data. | GameAnalyticsService.lua | 1 day |
| 4.5 | **Remove FastCast** if `Touched` events are acceptable. Otherwise implement it for AirKick/Boomerang projectiles. | Packages/, VFXHandler/ | 1 day |
| 4.6 | **Consolidate duplicate modules** — Signal.lua (3 copies), SimplePath.lua (2), DataModels.lua (2), Value.lua (2), Animate.lua (9). | Multiple | 2 hrs |
| 4.7 | **Add pcall to DataVersionHandler.lua:30** — unprotected `GetAsync` will crash on DataStore throttle. | DataVersionHandler.lua:30 | 5 min |
| 4.8 | **Wrap SafeZone checks** — replace attribute reads with server-side position checks using `SafeZoneUtils.IsPositionInSafeZone()`. | AirKick_S.lua, EarthStomp_S.lua, FireDropKick_S.lua | 1 hr |
| 4.9 | **Fix `__updateDeaths` on NPCs** — guard with nil check or remove the call from NPCAI.lua:94. | NPCAI.lua:94 | 5 min |
| 4.10 | **Add TODO markers** to known debt locations with standardised format. | All files with commented-out code | 1 hr |

---

## Summary

The game has **4 CRITICAL security vulnerabilities** that allow any player to execute arbitrary server code, steal unlimited currency, delete any player's data, and bypass all purchases. These must be fixed before any feature work.

The data layer has **auto-save disabled**, meaning any server crash erases all player progress for that session. Three of four IAP products are unfulfillable due to shared ProductIds.

Combat has **dual active systems** causing inconsistent damage, stamina, and XP. All abilities unlock by level 12, leaving 88 levels with no new mechanics. Progression to level 100 requires ~887,000 combat hits with no meaningful XP acceleration.

The recommended path: **Tier 1 (1–2 weeks) → Tier 2 (1 week) → Tier 3 (2 weeks) → Tier 4 (ongoing)**. Tier 1 makes the game safe to operate. Tier 2 unblocks feature work. Tier 3 gives players a reason to stay. Tier 4 builds long-term maintainability.
