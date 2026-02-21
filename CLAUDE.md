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
- `IsSameDay()` in QuestDataService — fixed in sprint 4a: was comparing `os.date("!*t")` numeric fields against strings, and mixing local/UTC date calls; all `os.date` calls must use `!` prefix consistently
- `GetQuest()` returns a direct reference to cached `today_Quest` — callers must deep-clone via `CF.Tables.CloneTable(GetQuest())` before mutating (shallow `table.clone` leaves nested frozen sub-tables exposed)
- `RefreshDailyQuest` is a client-callable signal — always rate-limit client-triggered data-write signals; cooldown table must be cleaned up on `PlayerRemoving`
- `DailyQuest()` guard must check `IsCompleted and IsClaimed` in addition to `IsSameDay` and missing `Id` — otherwise completed+claimed quests block new assignment for the rest of the day
- `_onCharacterAdded` shadows its `player` parameter with `Players:GetPlayerFromCharacter(character)` on line 419 — the re-declaration can return nil; use the original parameter
- `SetupCharacter` is async (callback inside `_G.PlayerDataStore:GetData`) and replaces `player.Character` — code after `SetupCharacter()` in `_onCharacterAdded` references the stale original character, not the replacement model
- `ToggleWeapon` sword equip uses `task.delay(.25)` to hide the holstered model — if the player unequips within 0.25s the delayed callback races; always guard with a state check (`Char:FindFirstChild("MeteoriteSword")`)
- `DamageIndication.BindToAllNPCs()` is a one-shot scan at startup — respawned/new NPCs need a `workspace.DescendantAdded` listener; filter out player characters with `Players:GetPlayerFromCharacter`


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
