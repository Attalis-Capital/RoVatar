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

- {Add every bug/trap discovered here — every mistake becomes a rule}


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
