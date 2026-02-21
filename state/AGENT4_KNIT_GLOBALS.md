# Agent 4: Knit & Globals Auditor — Findings

## SESSION-ENDING BUGS

### CRITICAL-1: _G.PlayerData and _G.QuestsData are nil until first server data arrives
`DataController.lua:33-36` — Never initialised to defaults. 40+ files read them without nil guards. First keypress or NPC interaction before data loads throws "attempt to index nil value."

### CRITICAL-2: GamePurchases.Passes unprotected by validateClientData
`DataServer.lua:644-677` — Only validates Gold, Gems, TotalXP, PlayerLevel, XP, Kills. Client can spoof `Passes["BoomerangId"] = true` via UpdateDataRqst and grant themselves any gamepass for free. Revenue-critical exploit.

### CRITICAL-3: DataStore save failures completely invisible
`DataServer.lua:7` — `warn` overridden as no-op. `DataServer.lua:405-416` — Save pcall catches errors but `warn()` is silenced. No retry logic. Players silently lose progress with zero operational visibility.

### CRITICAL-4: DataStore GetAsync failure silently resets player data
`DataServer.lua:459-480` — If `GetAsync` fails transiently, player gets fresh data model. Next auto-save overwrites their real data. Silent data wipe.

### CRITICAL-5: EffectsController level-up listener watches wrong stat folder
`EffectsController.lua:86` — Watches `CombatStats:WaitForChild("Level")` but level is at `player.Progression.LEVEL`. WaitForChild times out → returns nil → exits silently. **Level-up VFX, ability unlock banners, and SFX from this path are permanently dead.**

### CRITICAL-6: QuestController calls UpdateData with wrong arity
`QuestController.lua:58` — `_G.PlayerDataStore:UpdateData(plrData)` — missing `plr` argument. Server-side assert fires. All client-side quest progress updates silently fail.

### CRITICAL-7: _G.Warn called but never assigned
`Calculations.lua:53` — `_G.Warn(...)` — _G.Warn is never set anywhere. Every code path hitting this crashes with "attempt to call a nil value."

---

## _G Globals Inventory

| Name | Set By | Nil Guard? | Risk |
|------|--------|------------|------|
| `_G.PlayerData` | DataController.lua:35 (callback, never pre-initialised) | NO — 40+ consumers unguarded | CRITICAL |
| `_G.QuestsData` | DataController.lua:36 (same callback) | NO | CRITICAL |
| `_G.PlayerDataStore` (server) | PlayerDataService.lua:27 (module-level) | NO | HIGH |
| `_G.PlayerDataStore` (client) | DataController.lua:14 (module-level) | Some guards, most not | HIGH |
| `_G.SelectedCombat` | CharacterController.lua:159 (= nil) | Inconsistent — guarded at :363, unguarded at :359 | HIGH |
| `_G.ActiveBending` | CharacterController.lua:160 (= "None") | String compare guards | MEDIUM |
| `_G.Flying` | CharacterController.lua:181 (= false) | Boolean guards | LOW |
| `_G.IsHub` | HubHandler.lua:14 / Initialize.lua:14 | Boolean check | LOW |
| `_G.Talking` | TutorialGuider.lua:38 | Local boolean | LOW |
| `_G.Warn` | NEVER ASSIGNED | NO | HIGH |

## RemoteEvent Safety

| Remote | Server Validates? | Risk |
|--------|------------------|------|
| UpdateDataRqst | Partial — only 6 fields protected | **BROKEN** — Passes, Abilities, Inventory spoofable |
| GetPlrData | No auth — any player can fetch any other's full data | MEDIUM — data leak |
| ToggleWeapon | No ownership check | MEDIUM — any client can equip any weapon |
| DevService.ToggleServerLogs | No admin check | MEDIUM |
| Legacy Bending _S.lua remotes | No validation (disabled by `if true return`) | HIGH — parallel exploit path |
| CastSound | No validation of sound name | MEDIUM |

## Per-System Verdicts

| System | Verdict | Key Reason |
|--------|---------|------------|
| _G globals lifecycle | FRAGILE | _G.PlayerData/QuestsData never pre-initialised; 40+ unguarded consumers |
| Knit init ordering | FRAGILE | Module-level assignments before Knit.Start; task.delay workarounds |
| RemoteEvent safety | **BROKEN** | GamePasses unprotected; ToggleWeapon no ownership; DevService no auth |
| EffectsController cleanup | SOUND (XP) / **BROKEN** (Level) | XP fixed; Level listener watches wrong object — permanently dead |
| DataStore resilience | **BROKEN** | No retry; warn silenced; GetAsync failure → silent data wipe |
| Client→server validation | FRAGILE | Whitelist misses Abilities, Inventory, GamePasses, ElementLevels |
| Shared client/server modules | **BROKEN** | ElementXp no IsServer guard; _G.Warn never set |
