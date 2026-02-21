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


## Top Session-Ending Bugs (Audit 2026-02-22)

1. **_G.PlayerData nil on startup** — 40+ client files read `_G.PlayerData` without nil guards; any UI interaction before DataReplicator round-trip completes crashes. Guard with a ready-gate or initialise to defaults in `DataController.lua:33`.
2. **Death during tutorial deadlocks dialogue** — `_G.Talking` stays true after death, `DialogueGui.InProcess` stays true. NPC prompt disabled permanently. Hook `Humanoid.Died` to reset state in `TutorialGuider.lua`.
3. **DataStore failures invisible + no retry** — `DataServer.lua:7-8` overrides warn/print as no-ops. Save failures at line 410 and GetAsync failures at line 459 are silent. GetAsync failure silently gives player default data, overwriting real progress on next auto-save.

## Gotchas

- DataServer.lua overrides `warn` and `print` as no-ops at the top — new `warn()` calls won't output unless you bypass this
- VFXHandler.lua runs in both client and server contexts — server-side security code must go in the `else` (IsServer) block only
- Old Bendings `_S.lua` scripts are a parallel combat system to VFXHandler — disabling one without the other leaves duplicate exploit paths
- DataServer `DataReceivedFromClient` accepts raw full-data overwrites — any field not explicitly validated can be spoofed by the client
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
- `LevelUpService.lua:28-31` and `EffectsController.lua:82-85` both watch `CombatStats.Level` which does NOT exist — the real level is `Progression.LEVEL`. Level-up VFX, SFX, ability unlock banners, and broadcast to other players are all permanently dead until fixed.
- `validateClientData` in `DataServer.lua:644-677` only guards 6 fields (Gold, Gems, TotalXP, PlayerLevel, XP, Kills) — `GamePurchases.Passes`, `Abilities`, `Inventory`, and `ElementLevels` can all be spoofed by the client via `UpdateDataRqst`
- VFXHandler (`VFXHandler.lua:52`) validates effect name via `VALID_EFFECTS` whitelist but never checks bending-type ownership — any player can fire any ability regardless of their selected element
- Boomerang and MeteoriteSword server handlers have NO GamePass ownership check — any player can use them via `CastEffect:FireServer("Boomerang", ...)` without purchasing
- 5 of 7 ability handlers in VFXHandler have NO SafeZone PvP check — only Boomerang and MeteoriteSword check `InSafeZone` attribute (and MeteoriteSword awards XP before the check)
- Duplicate `DialogueGui.lua` exists in both `ReplicatedFirst/` and `StarterPlayer/.../Components/GUIs/` with the same Component tag `"DialogueGui"` — the ReplicatedFirst copy lacks SkipAll() and has a stale button template path; delete it
- `QuestController.lua:58` calls `_G.PlayerDataStore:UpdateData(plrData)` with wrong arity (missing player arg) — all client-side quest progress updates silently fail
- `Calculations.lua:53` calls `_G.Warn(...)` which is never assigned — any code path hitting this crashes


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
