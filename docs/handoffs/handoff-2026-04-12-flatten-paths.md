## Session Handoff — 2026-04-12 — Flatten Deep Folder Nesting

### Context
RoVatar repo — reducing maximum folder depth by moving deeply nested modules to shallower locations. Simon McGlenn flagged deep nesting as a navigation problem.

### Completed this session
- Built full dependency graph: 156 files at depth >= 5, categorised by moveability
- Moved 9 Knit Component GUIs from `GUIs/HomeScreens/` to `GUIs/` (depth 7 → 6)
- Moved `CustomizationUI.lua` from `GUIs/LoadGameGui/` to `GUIs/` (depth 7 → 6)
- Created PR #36 for Simon's review
- Also completed inline-batch2 (PR pending merge): SafeZoneUtils inlined, TooltipModule dead require removed

### Decisions made
- **Only moved zero-caller files:** HomeScreens GUIs are Knit Components (tag-discovered), so zero require() updates needed
- **Skipped CommonFunctions/Utils/ refactor:** Name collisions (DataModels.lua, Value.lua at both levels), relative require chains, and HIGH-risk modules (PlayerData 17 callers, DamageCalc 8 callers) made it not worth the risk
- **Skipped Roblox-positional files:** StarterGui, Assets/Models depth 7-9 files are tied to instance hierarchy

### Learnings
- Knit Components can be moved freely within StarterPlayerScripts — discovered by tag, not require
- CommonFunctions re-exports sub-modules via `CF.*` — dependency analysis must trace indirect access

### Open questions / blockers
- PR #36 needs Simon's review before merge
- Inline-batch2 branch also pending merge
- All code changes still need Rojo publish via wimma777 to reach live game

### Next actions
1. Merge PR #36 after Simon's review
2. Merge inline-batch2 branch
3. Rojo publish accumulated changes to live game
4. Consider resolving CommonFunctions name collisions in a future session if deeper flattening is wanted

### Files to review
- `StarterPlayer/StarterPlayerScripts/Game/Components/GUIs/*.lua` — all 10 moved GUI components

### Resume command
RoVatar cleanup status: PR #36 (flatten-paths, 10 GUI moves) and inline-batch2 (2 module inlines) both pending merge. Next priorities: get Simon's review, merge both PRs, Rojo publish to live game. If deeper flattening wanted, start with resolving CommonFunctions/DataModels.lua and CommonFunctions/Value.lua name collisions.
