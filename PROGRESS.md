# PROGRESS.md — RoVatar

## Current Sprint: #3 — Combat Critical Bugs and Balance
**Branch:** `sprint-3-combat-fixes`
**Issue:** https://github.com/Attalis-Capital/RoVatar/issues/3

### Tasks
- [x] S3.1 — Fix damage indicators not binding to respawned NPCs (DamageIndication.lua, PlayerController.lua)
- [x] S3.2 — Reset Strength (mana) alongside Stamina on death (CharacterService.lua)
- [x] S3.3 — Tune stamina regen (0.1→0.2) and sprint cooldown (0→3s) (Costs.lua)
- [x] S3.4 — Increase enemy AI attack cooldowns ~2.5x at low levels (Helper.lua)
- [x] S3.5 — Fix sword holster race condition in task.delay callback (CharacterService.lua)

### Commits
- `d2674e2` feat(combat): sprint 3 — combat critical bugs and balance
- `cf326db` learn: extract lessons from sprint 3 combat fixes

### PR
- https://github.com/Attalis-Capital/RoVatar/pull/22

### Next Action
- Merge PR #22 after in-game testing
- Start Sprint 4 (Issue #4 — Progression and quest overhaul)

## Previous Sprints
### Sprint #2 — First-Session Onboarding Blockers
- Branch: `sprint-2-onboarding-blockers`
- PR: https://github.com/Attalis-Capital/RoVatar/pull/21
- Commits: `c51829d`, `98601e0`, `51d09ef`, `91d10e5`

### Sprint #1 — Tier 1 Security Fixes
- Completed: `36604f5` fix(security): tier 1 critical vulnerability fixes
