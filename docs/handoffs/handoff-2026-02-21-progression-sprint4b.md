## Session Handoff — 2026-02-21 — Sprint 4b Progression Foundation

### Context
RoVatar Roblox game. Sprint 4b adds the foundational progression mechanics: per-element XP tracking, damage scaling with player/element level, stamina scaling, and XP rate tuning. Part of issue #4 (Progression and quest overhaul).

### Completed this session
- S4b.1: Added `ElementLevels` data model (Air/Fire/Earth/Water, 20 levels each) to CustomTypes.lua, PlayerData.lua, and Costs.lua
- S4b.2: Created `ElementXp.lua` and `DamageCalc.lua` stateless helpers, wired into all 7 VFXHandler abilities
- S4b.3: Increased XP rates across all abilities, reduced early level thresholds (L1: 500->300)
- S4b.4: Added stamina scaling with player level (MaxStamina + regen rate)
- Fixed `CombatStats.Level` -> `Progression.LEVEL` in all 4 bending abilities
- PR #24 created and merged into main
- Extracted 4 lessons (3 Tier 1 repo, 1 Tier 2 global) synced to Supabase

### Decisions made
- Element-neutral weapons (Fist, Sword, Boomerang) pass `elementLevel=0` to DamageCalc — no element scaling, only player-level scaling
- Element level attributes cached via `plr:SetAttribute()` for synchronous reads in hot combat path
- Legacy Bending LocalScripts left untouched — they're client-side only and VFXHandler is the authoritative server path

### Learnings
- `plr.CombatStats.Level` never existed — correct path is `plr.Progression.LEVEL.Value`
- Modules in ReplicatedStorage that call `_G.PlayerDataStore` will nil-index if required client-side
- Element level attributes must be set on both login AND level-up or DamageCalc reads stale data

### Open questions / blockers
- Legacy Bending `_S.lua` scripts still use `CombatStats.Level` and hardcoded values — should be addressed in a future sprint
- Safe-zone PvP guard missing from element bending abilities (AirKick, EarthStomp, FireDropKick, WaterStance) — Boomerang and MeteoriteSword have it

### Next actions
1. Start sprint 4c or 5 — UI/UX polish (issue #5) or remaining progression tasks from #4
2. Add safe-zone guards to element bending abilities for consistency
3. Consider disabling/removing legacy Bending scripts to close the parallel combat path

### Files to review
- `ReplicatedStorage/Modules/Custom/CommonFunctions/Utils/ElementXp.lua` — element XP award helper
- `ReplicatedStorage/Modules/Custom/CommonFunctions/Utils/DamageCalc.lua` — damage scaling calculator
- `ReplicatedStorage/Modules/Custom/Costs.lua` — new element XP, scaling, and stamina constants
- `ReplicatedStorage/Modules/Custom/CustomTypes.lua` — `ElementLevelData`, `ElementLevelsType` types
- `ServerScriptService/Server/Services/Player/CharacterService.lua` — stamina scaling
- `ServerScriptService/Server/Services/Player/PlayerDataService.lua` — element level attributes on login

### Resume command
```
Continue RoVatar progression work. Sprint 4b (PR #24) is merged — added per-element XP tracking, damage scaling (baseDamage * (1 + 0.02 * playerLevel) * (1 + 0.03 * elementLevel)), stamina scaling, and XP rate tuning. Key new files: ElementXp.lua, DamageCalc.lua. Outstanding items: safe-zone PvP guards missing from element abilities, legacy Bending scripts still use CombatStats.Level. Next: sprint 4c or issue #5 UI/UX polish.
```
