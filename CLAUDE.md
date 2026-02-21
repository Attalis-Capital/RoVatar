# CLAUDE.md - RoVatar

## Project Overview
RoVatar is a Roblox elemental-combat open-world game built with Luau. Inspired by Avatar: The Last Airbender and Zelda. Players adventure, fight with bending abilities, level up, and explore tribes.

Place ID: 10467665782 | Universe ID: 3812540898

## Architecture
- **Framework**: Knit (Services on server, Controllers on client)
- **Language**: Luau (Roblox Lua)
- **Data layer**: ReplicaService for state replication

## Key Directories
- `ReplicatedStorage/Assets/Models/Combat/Bendings/` - ability scripts per element (_S.lua = server, _L.lua = local)
- `ReplicatedStorage/Modules/Custom/CommonFunctions/Stats/Costs.lua` - centralised damage/stamina costs
- `ReplicatedStorage/Packages/` - Knit + vendor packages (DO NOT EDIT)
- `ServerScriptService/Server/Services/Player/CharacterService.lua` - server character lifecycle, stat validation, health
- `ServerScriptService/Server/Services/Player/DataService.lua` - player data persistence
- `StarterPlayer/StarterPlayerScripts/Game/Controllers/Character/CharacterController.lua` - main client controller
- `StarterPlayer/StarterPlayerScripts/Game/Components/GUIs/` - all UI components

## Rules
- Use modern Luau: `task.spawn`/`task.delay` not `spawn`/`delay`, type annotations where helpful
- All damage/stat changes MUST be validated server-side (PR #1 established this pattern)
- Use Costs.lua for all damage/stamina values - no hardcoded numbers in ability scripts
- No shared module-level mutable state - use per-player state via Value objects or player attributes
- DO NOT modify ReplicatedStorage/Packages/ or ReplicatedStorage/Replica/
- Conventional commits: fix:, feat:, refactor:

## Issue Tracker
Master epic: https://github.com/Attalis-Capital/RoVatar/issues/10

Sprint order:
1. #2 P0 - First-session onboarding blockers
2. #3 P0 - Combat critical bugs and balance
3. #4 P1 - Progression and quest overhaul
4. #5 P1 - UI/UX polish
5. #6 P2 - Audio system
6. #7 P2 - Pet system
7. #8 P3 - NPC/location renaming (IP de-risk)
8. #9 P3 - Feature backlog

## Verification
After changes, check:
- No module-level shared mutable state
- Server validates all client requests
- Costs.lua used for all numeric values
- No edits to Packages/ or Replica/


## Top Session-Ending Bugs (Audit 2026-02-22) — ALL FIXED in Sprint 5a (PR #25)

1. ~~**_G.PlayerData nil on startup**~~ — Fixed: pcall ready-gate in DataController.lua initialises defaults before ListenChange fires
2. ~~**Death during tutorial deadlocks dialogue**~~ — Fixed: OnCharacterAdded resets `_G.Talking` + all bare `Talking` refs fixed to `_G.Talking`
3. ~~**DataStore failures invisible + no retry**~~ — Fixed: warn/print overrides removed, 3-retry with exponential backoff added, GetAsync failure returns nil instead of silently creating defaults

## Gotchas

- ~~DataServer.lua overrides `warn` and `print` as no-ops at the top~~ — FIXED in sprint 5a: overrides removed, diagnostics now visible
- VFXHandler.lua runs in both client and server contexts — server-side security code must go in the `else` (IsServer) block only
- Old Bendings `_S.lua` scripts are a parallel combat system to VFXHandler — disabling one without the other leaves duplicate exploit paths
- DataServer `DataReceivedFromClient` accepts raw full-data overwrites — most fields now validated (Gold, Gems, TotalXP, GamePasses, ElementLevels, Abilities, OwnedInventory, per-profile PlayerLevel/XP/Kills)
- WaterStance has two-phase dispatch (`typ == "Weld"` = activation, `else` = deactivation) — stamina/level gates belong only in the Weld branch
- `RemovePlrData` was exposed as a client RemoteEvent — always audit RemoteEvent creation for destructive operations before shipping
- New persistent data fields must be added to BOTH `GetSlotDataModel()` defaults (PlayerData.lua) AND the type definition (CustomTypes.lua) — `CheckAndUpdatePlayerData` Sync/remove strips undeclared fields on migration
- `QuestDataService:OnPlayerAdded` mutates `plrData` in memory without saving — any data changes in OnPlayerAdded must explicitly call `UpdateData` or they're lost on quick disconnect (before 30s auto-save)
- `Constants.GameInventory.Abilities[id].RequiredLevel` is the canonical level-gate source — values flow from Costs.lua → Constants.Items → Constants.GameInventory; never hardcode level thresholds
- `IsSameDay()` in QuestDataService compares `os.date("!*t")` numeric fields against strings (`yday == "1"`) — always false in Luau; daily quest New Year rollover is broken (pre-existing)
- `_onCharacterAdded` shadows its `player` parameter with `Players:GetPlayerFromCharacter(character)` on line 419 — the re-declaration can return nil; use the original parameter
- `SetupCharacter` is async (callback inside `_G.PlayerDataStore:GetData`) and replaces `player.Character` — code after `SetupCharacter()` in `_onCharacterAdded` references the stale original character, not the replacement model
- `ToggleWeapon` sword equip uses `task.delay(.25)` to hide the holstered model — if the player unequips within 0.25s the delayed callback races; always guard with a state check (`Char:FindFirstChild("MeteoriteSword")`)
- `DamageIndication.BindToAllNPCs()` is a one-shot scan at startup — respawned/new NPCs need a `workspace.DescendantAdded` listener; filter out player characters with `Players:GetPlayerFromCharacter`
- VFXHandler bending abilities originally used `plr.CombatStats.Level` which never existed — the correct player level accessor is `plr.Progression.LEVEL.Value` (fixed in sprint 4b)
- Modules in `ReplicatedStorage` that call `_G.PlayerDataStore` (e.g. `ElementXp.Award`) will nil-index if required client-side — guard with `RunService:IsServer()` or keep server-only logic in ServerScriptService
- Element level attributes (`ElementLevel_Air`, etc.) must be set in BOTH `PlayerDataService.onPlayerAdded` (login) AND `ElementXp.Award` (on level-up) — if either path is missed, `DamageCalc.GetElementLevel` returns stale data via `plr:GetAttribute()`
- ~~`LevelUpService.lua` and `EffectsController.lua` watched `CombatStats.Level` which does NOT exist~~ — FIXED in sprint 5a: both now watch `Progression.LEVEL`
- ~~`validateClientData` in DataServer.lua now guards 7 fields + GamePurchases.Passes (sprint 5a) — but `Abilities`, `Inventory`, and `ElementLevels` can still be spoofed by the client via `UpdateDataRqst`~~ — FIXED in sprint 5c: ElementLevels (Level/TotalXP increase rejected) and Abilities (new keys require level gate) now validated
- ~~VFXHandler (`VFXHandler.lua:52`) validates effect name via `VALID_EFFECTS` whitelist but never checks bending-type ownership — any player can fire any ability regardless of their selected element~~ — FIXED in sprint 5c: `Has_*Bending` player attributes set at login + data change, checked in VFXHandler server dispatch
- ~~Boomerang and MeteoriteSword server handlers have NO GamePass ownership check~~ — FIXED in sprint 5b: `UserOwnsGamePassAsync` check added in VFXHandler server dispatch
- ~~5 of 7 ability handlers in VFXHandler have NO SafeZone PvP check~~ — FIXED in sprint 5b: all 7 abilities now check `InSafeZone` before XP/damage/knockback
- ~~Duplicate `DialogueGui.lua` exists in both `ReplicatedFirst/` and `StarterPlayer/.../Components/GUIs/`~~ — FIXED in sprint 5b: ReplicatedFirst copy deleted
- ~~`QuestController.lua:58` — quest progress updates silently fail~~ — FIXED in sprint 5c: DataClient.lua had warn/print no-ops (same as DataServer sprint 5a); arity was actually correct for client-side API
- ~~`Calculations.lua:53` calls `_G.Warn(...)` which is never assigned — any code path hitting this crashes~~ — FIXED: replaced with `warn(...)` (standard Luau)
- In Roblox Luau, bare `Talking` and `_G.Talking` are different variables — `_G` is the shared cross-script table, bare globals are script-scoped only. Always use the `_G.` prefix for cross-script state
- `GetPlayerDataModel()` and `GetSlotDataModel()` access `workspace.ServerTime.Value` — calling on client at require-time crashes if ServerTime doesn't exist yet. Always pcall or guard with `FindFirstChild`
- `OnPlayerLeaving` cleanup must be unconditional — never gate `_plrsInfo` cleanup on `Save()` success or player state leaks permanently on DataStore outages
- ~~`EffectsController.lua` XP listener still watches `CombatStats.EXP` (not Progression)~~ — FIXED: now watches `Progression.EXP` (matches the Level listener pattern)
- SafeZone PvP checks must go before ALL victim effects (ragdoll, knockback, CFrame, VFX) not just before `TakeDamage` — otherwise players still get flung/stunned in safe zones
- VFXHandler ability modules live as children of the VFXHandler ModuleScript (`ReplicatedStorage/Modules/Custom/VFXHandler/`), not the old Bendings `_S.lua` scripts which are disabled with `if true then return end`
- `Hits[target]` debounce set before a SafeZone early-return is never cleared by the delayed nil-setter — low impact for short-lived hitboxes but a structural leak pattern to watch
- `UserOwnsGamePassAsync` can throw on network errors — always pcall and default to deny; log the error for diagnostics
- When adding early-return guards (SafeZone, auth) to existing hit handlers, check for duplicate state assignments downstream — e.g. `Hits[char] = true` may appear both at the dedup gate and after damage
- `Has_*Bending` player attributes must be set in BOTH `PlayerDataService.onPlayerAdded` (login) AND `ListenSpecChange("AllProfiles")` callback (on data change) — mirrors the `ElementLevel_*` dual-write pattern
- `validateClientData` Abilities check must allow level-gated unlocks via `curProfile.PlayerLevel >= ABILITY_LEVELS[abilityId]` — pure rejection breaks BendingSelectionGui unlock flow


## Sprint workflow

Mandatory sequence — always follow this order:

### Session start
1. `/project:start` — load local + shared memory, report state
2. Enter Plan mode (Shift+Tab twice)
3. `/project:new-sprint` — propose sprint, wait for approval
4. Iterate on the plan until solid
5. Exit Plan mode (Shift+Tab) to normal mode

### Per task (repeat for each task in sprint)
6. Build the task
7. `/project:verify` — confirm it works
8. `/project:simplify` — strip unnecessary complexity
9. `/project:commit-push` — stage, commit, push, update PROGRESS.md

### Mid-session (as needed)
- `/project:sprint-status` — quick progress check

### Session end
10. `/project:learn` — extract lessons (Tier 1 repo, Tier 2 universal)
11. `/project:handoff` — save state for next session
