## Session Handoff — 2026-02-20 — Combat Sprint 3

### Context
RoVatar Roblox game. Sprint 3 addressed combat-feel bugs from Issue #3 that cause player churn — damage indicators breaking on respawned NPCs, stats not resetting on death, stamina regen too slow, enemy AI too aggressive, and weapon holster visibility bugs.

### Completed this session
- All 5 tasks (S3.1–S3.5) implemented, code-reviewed, and pushed
- PR #22 created: https://github.com/Attalis-Capital/RoVatar/pull/22
- 4 repo-specific gotchas added to CLAUDE.md
- 6 lessons synced to Supabase (all embedded)

### Decisions made
- **Weapon holster fix scoped to race condition only**: The `task.delay(.25)` callback in sword equip now guards against the combat clone being destroyed before it fires. Full respawn weapon reset was removed after code review showed `SetupCharacter` is async and replaces `player.Character`, making the original character reference stale.
- **Enemy AI cooldowns ~2.5x at low levels, ~1.5x at high**: Keeps new player experience forgiving while high-level combat stays challenging (0.6s floor).
- **Deferred 4 items from Issue #3**: Block rework, enemy level scaling, stuck-in-state bug, invisible collisions — all need deeper investigation or Studio-only changes.

### Learnings
- `_onCharacterAdded` shadows its `player` parameter — the `GetPlayerFromCharacter` re-declaration can return nil
- `SetupCharacter` is async and replaces `player.Character` — post-call code references stale character
- `ToggleWeapon` sword equip `task.delay(.25)` creates a race window for holster visibility
- `workspace.DescendantAdded` fires for player characters too — filter with `GetPlayerFromCharacter`

### Open questions / blockers
- PR #22 needs review and merge
- `CharacterService.lua` is 567 lines (exceeds 300-line rule) — pre-existing, needs refactoring sprint
- `ToggleWeapon` lacks gamepass ownership validation (pre-existing exploit path)
- Stamina regen server fallback (`Data.Factor or .05`) is stale vs updated Costs.lua value (`.2`)

### Next actions
1. Merge PR #22 after in-game testing
2. Start Sprint 4 (Issue #4 — Progression and quest overhaul)
3. Consider a refactoring task to split CharacterService.lua

### Files to review
- `ReplicatedStorage/Modules/Custom/Costs.lua` — stamina regen and sprint cooldown tuning
- `ServerScriptService/Server/Components/NPCAI/Helper.lua` — enemy attack cooldown curve
- `ServerScriptService/Server/Services/Player/CharacterService.lua` — stat reset on death, sword holster guard
- `StarterPlayer/StarterPlayerScripts/Game/Helpers/DamageIndication.lua` — new BindToNewNPCs() method
- `StarterPlayer/StarterPlayerScripts/Game/Controllers/Player/PlayerController.lua` — BindToNewNPCs call

### Resume command
```
Resume Sprint 3 combat fixes for RoVatar. Branch: sprint-3-combat-fixes. PR #22 is open at https://github.com/Attalis-Capital/RoVatar/pull/22. All 5 tasks complete (S3.1-S3.5). Next: merge PR #22 after testing, then start Sprint 4 (Issue #4 — Progression and quest overhaul). Check PROGRESS.md and docs/handoffs/handoff-2026-02-20-combat-sprint3.md for full state.
```
