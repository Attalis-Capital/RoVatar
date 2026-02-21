# PROGRESS.md — RoVatar

## Full Audit — 2026-02-22
**Type:** First-principles audit (7 agents, 2 waves)
**Report:** `ROVATAR_AUDIT_REPORT.md`
**Detail:** `state/AGENT{1-6}_*.md`

### Headline Verdict
Alexander cannot have 30 continuous minutes of fun — session crashes or softlocks within 5 minutes.

### Key Findings
- 3 session-ending bugs: _G.PlayerData nil crash, tutorial death deadlock, silent DataStore wipes
- 2 BROKEN abilities: Boomerang (zero server validation), MeteoriteSword (no GamePass check)
- 5/7 abilities allow PvP damage in SafeZones
- GamePurchases.Passes spoofable by client (revenue leak)
- Level-up VFX/SFX/unlock banners permanently dead (watches wrong stat)
- Tutorial teaches controls AFTER combat quest
- 25 debug print/warn calls in production UI code

### Files Modified
- `CLAUDE.md` — added top 3 session-ending bugs + 9 new gotchas
- `ROVATAR_AUDIT_REPORT.md` — final 900-word audit report
- `state/SWARM_STATE.md` — swarm coordination
- `state/AGENT{1-6}_*.md` — per-agent detailed findings

### Next Action
- Sprint 5: Fix top 10 audit items (see ROVATAR_AUDIT_REPORT.md § Recommended Sprint Priority)

---

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
