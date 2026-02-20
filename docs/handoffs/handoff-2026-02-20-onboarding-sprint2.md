## Session Handoff — 2026-02-20 — Sprint 2 Onboarding Blockers

### Context
RoVatar (Roblox elemental-combat game, 25% approval rate). Sprint 2 tackled 5 first-session onboarding blockers from GitHub Issue #2 — the highest-ROI items a new player hits in their first 5 minutes.

### Completed this session
- S2.1: Updated `EnergyDepleted_Alert` and `InsufficientStamina` notifications with recovery instructions
- S2.2: Fixed MainMenuGui — Store button now opens Store (was calling GamePassButton), GamePass button uncommented and wired
- S2.3: ControlsGuideGui auto-shows on first spawn (2s delay), persisted via `HasSeenControls` in Settings data model
- S2.4: Locked abilities show "Requires Lvl X" dark overlay using existing Shadow element in BendingSelectionGui
- S2.5: QuestDataService `OnPlayerAdded` now saves immediately after daily quest assignment (gated on change)
- Code review, simplification pass, lesson extraction all completed
- 5 lessons synced to Supabase (3 global, 2 repo-specific)

### Decisions made
- **HasSeenControls uses client-side UpdateData pattern**: Follows existing codebase pattern (BendingSelectionGui, TutorialGuider all do the same). Field is cosmetic-only, no security risk. Added to both type def and defaults to survive data sync.
- **DailyQuest save gated on change**: Returns boolean so `OnPlayerAdded` only writes to DataStore when a new quest was actually assigned, avoiding unnecessary writes.
- **Deferred items**: Tutorial world/teleport rework (#1, #2), PVP at spawn (#4, #5), text size (#8), teleport background (#9) all deferred — require Studio workspace edits or larger architecture changes.

### Learnings
- New persistent data fields must go in BOTH `GetSlotDataModel()` defaults AND `CustomTypes.lua` — Sync/remove strips undeclared fields
- `IsSameDay()` in QuestDataService has a pre-existing bug: compares `os.date("!*t")` numeric fields against strings (always false)
- `Constants.GameInventory.Abilities[id].RequiredLevel` is the canonical level-gate source (Costs.lua -> Constants.Items -> Constants.GameInventory)

### Open questions / blockers
- **PR not yet opened** — branch is pushed, ready for PR creation
- Pre-existing: `IsSameDay()` string comparison bug breaks New Year daily quest rollover (not fixed this sprint — scope creep)
- Pre-existing: BendingSelectionGui ability unlock validation is client-only (no server re-validation)

### Next actions
1. Open PR for `sprint-2-onboarding-blockers` against `main`
2. Start Sprint 3 (Issue #3 — Combat critical bugs and balance)
3. Consider fixing `IsSameDay()` string-vs-number bug as a quick fix before Sprint 3

### Files to review
- `ReplicatedStorage/Modules/Custom/NotificationData.lua` — S2.1 notification text
- `StarterPlayer/.../HomeScreens/MainMenuGui.lua` — S2.2 button wiring
- `StarterPlayer/.../HomeScreens/ControlsGuideGui.lua` — S2.3 first-spawn auto-show
- `StarterPlayer/.../HomeScreens/BendingSelectionGui.lua` — S2.4 locked ability overlay
- `ServerScriptService/.../QuestDataService.lua` — S2.5 quest persistence
- `ReplicatedStorage/Modules/Custom/CustomTypes.lua` — HasSeenControls type
- `ReplicatedStorage/.../Player/PlayerData.lua` — HasSeenControls default

### Resume command
```
/project:start

Sprint 2 (onboarding blockers) is complete on branch `sprint-2-onboarding-blockers` (4 commits). Open a PR against main, then start Sprint 3 (Issue #3 — Combat critical bugs and balance). Check PROGRESS.md and the Gotchas in CLAUDE.md for context. The IsSameDay() string-vs-number bug in QuestDataService is a known pre-existing issue worth fixing early.
```
