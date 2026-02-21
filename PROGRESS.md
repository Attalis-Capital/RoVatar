# PROGRESS.md — RoVatar

## Current Sprint: #4b — Progression Foundation
**Branch:** `sprint-4b-progression-foundation`
**Issue:** https://github.com/Attalis-Capital/RoVatar/issues/4

### Tasks
- [x] S4b.1 — Add ElementLevels to data model (CustomTypes.lua, PlayerData.lua, Costs.lua)
- [x] S4b.2 — Create ElementXp + DamageCalc helpers, wire into all 7 VFXHandler abilities
- [x] S4b.3 — XP rate tuning — increase rates, reduce early level thresholds (issue #16)
- [x] S4b.4 — Stamina scaling with player level (CharacterService.lua, Combats.lua, PlayerDataService.lua)

### Commits
- `9e4ea18` feat(progression): sprint 4b — progression foundation
- `4513d7c` learn: extract lessons from sprint 4b progression foundation

### PR
- https://github.com/Attalis-Capital/RoVatar/pull/24 (merged)

### Next Action
- Start next sprint (issue #5 UI/UX polish, or remaining #4 progression tasks)
- Add safe-zone PvP guards to element bending abilities
- Consider disabling legacy Bending scripts

## Previous Sprints
### Sprint #4a — Quest Fixes
- Branch: `sprint-4a-quest-fixes`
- Fixes to QuestDataService (IsSameDay, GetQuest cloning, RefreshDailyQuest rate-limit)

### Sprint #3 — Combat Critical Bugs and Balance
- Branch: `sprint-3-combat-fixes`
- PR: https://github.com/Attalis-Capital/RoVatar/pull/22
- Commits: `d2674e2`, `cf326db`

### Sprint #2 — First-Session Onboarding Blockers
- Branch: `sprint-2-onboarding-blockers`
- PR: https://github.com/Attalis-Capital/RoVatar/pull/21
- Commits: `c51829d`, `98601e0`, `51d09ef`, `91d10e5`

### Sprint #1 — Tier 1 Security Fixes
- Completed: `36604f5` fix(security): tier 1 critical vulnerability fixes
