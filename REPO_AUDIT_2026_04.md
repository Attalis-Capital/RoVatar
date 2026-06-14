# RoVatar Repo State Audit — June 2026 (refreshed 2026-06-14)

> **History:** First produced 2026-05-12 (PR #40), refreshed 2026-05-15 (PR #41), refreshed 2026-05-16/17 (PR #42), refreshed 2026-06-14 (this PR). This pass records that all GitHub issues were closed on 2026-05-22, confirms no new game-code commits since 2026-04-12, and notes PR #42 is now merged (it was listed as "OPEN" in the May refresh). All code-level findings, deployment gaps, and Studio-dependent items remain unchanged.

---

## Executive Summary

The repo is structurally clean — 12 game sprints, 5 cleanup PRs, and 4 docs PRs (PRs #12–#42) are all merged, all 15 GitHub issues are now closed, and the codebase has been hardened against every critical security issue identified in the February 2026 audit. However, **none of these fixes are live.** Every security patch, gameplay improvement, and structural change since the game was last published (estimated pre-February 2026) exists only in the repository. The single biggest risk is a player exploiting `GetPlrData` (full data exposure for any player) or the `TeleportRequest` redirect attack — over four months of accumulated fixes unshipped as of June 2026. A secondary blocking item is branch `sprint-12-quest-tracker-glider`: the game code is a modest 5-file, 33-line change, but the branch cannot be filed as a PR without rebasing onto main first — `QuestTrackerHUD.lua` was deleted from main during cleanup PR #38 while sprint-12's wiring code still references it. The recommended next action remains an immediate Rojo publish to the live game via the `wimma777` account, followed by rebasing and filing a PR for sprint 12.

---

## Sprint History

| Sprint | Description | PR# | Status |
|--------|-------------|-----|--------|
| S1 (early) | First-Session Survival — SafeZone PvP, tutorial fix | #12 | MERGED |
| S2 | First-Session Onboarding Blockers | #21 | MERGED |
| S2 (combat-feel) | Auto-target, Hit Feedback, Combo Counter, Death Screen | #13 | MERGED |
| S3 (progression) | Progression systems — breadcrumb, HUD, XP/level | #20 | MERGED |
| S3 (combat) | Combat critical bugs and balance | #22 | MERGED |
| S4a | Quest system critical fixes (IsSameDay, deep clone, rate-limit) | #23 (CLOSED) → squash into #32 | MERGED via S10 |
| S4b | Progression foundation — ElementXp, DamageCalc, stamina scaling | #24 | MERGED |
| S5a | Audit critical fixes — _G.PlayerData guard, tutorial deadlock, DataStore retry | #25 | MERGED |
| S5b | Combat security — SafeZone PvP guards, GamePass checks, DialogueGui dedup | #26 | MERGED |
| S5c | Data validation hardening — ElementLevels, Abilities, bending-type ownership | #27 | MERGED |
| S6 | UI/UX polish — shop bug, GamePass gates, overheads, welcome-back, menu restructure | #28 | MERGED |
| S7 | Audio system — shop error sound, glider wind, environment audio controller | #29 | MERGED |
| S8 | Pet system — Momo follow, animations, despawn, kill rewards | #30 | MERGED |
| S9 | NPC/location renaming — IP de-risk | #31 | MERGED |
| S10 | Bug fixes — deprecated APIs, debug no-ops, nil-guards | #32 | MERGED |
| S11 | Modernise remaining deprecated wait() calls | #33 | MERGED |
| Cleanup 1 | Delete 14 disabled legacy Bendings scripts | #34 | MERGED |
| Cleanup 2 | Inline 3 single-use orphan modules | #35 | MERGED |
| Cleanup 3 | Flatten 10 GUI components from depth 7 to depth 6 | #36 | MERGED |
| Cleanup 4 | Inline SafeZoneUtils + remove dead TooltipModule require | #37 | MERGED |
| Cleanup 5 | Dead code scan — 7 modules, 7 functions, 43 requires removed | #38 | MERGED |
| Docs | Migrate CLAUDE.md to AGENTS.md convention | #39 | MERGED |
| Docs | Repo state audit — April/May 2026 (first pass) | #40 | MERGED 2026-05-12 |
| Docs | Repo state audit — May 2026 refresh | #41 | MERGED 2026-05-15 |
| Docs | Repo state audit — May 2026 refresh (2nd) | #42 | MERGED 2026-05-16 |
| Docs | Repo state audit — June 2026 refresh | This PR | OPEN |
| S12 | Quest Tracker HUD wiring + glider constants | **NO PR** | Branch exists, needs rebase before PR can be filed |

**PRs #1, #11, and #23 were closed without merge** (superseded by #12 and the S10 squash respectively). All others are merged.

---

## Open Items

### Security (undeployed fixes)

All security fixes in the repo have **never** been published to the live Roblox game. As of 2026-06-14 this remains unchanged from all prior audits.

| Severity | Issue | Fixed in repo? | Deployed to live? | Notes |
|----------|-------|:--------------:|:-----------------:|-------|
| CRITICAL | `GetPlrData` exposes any player's full data to any client | Yes — DataServer.lua restricted to same-player lookups (sprint 5a + 2026-04-03 fix) | **No** | Highest exploit risk — trivial to abuse |
| CRITICAL | `TeleportRequest` accepts arbitrary PlaceIds (redirect attack) | Yes — whitelist from Constants.Places (2026-04-03 fix) | **No** | |
| CRITICAL | `DataReceivedFromClient` accepts spoofed GamePurchases.Passes (revenue leak) | Yes — validated in validateClientData (sprint 5a) | **No** | Players can self-grant Boomerang/Sword/Glider |
| WARNING | SafeZone PvP — 5/7 abilities allowed damage in safe zones | Yes — all 7 abilities gate on InSafeZone (sprint 5b) | **No** | SafeZoneEnforcer.lua (SafeZoneUtils inlined) not in live game |
| WARNING | GamePass ownership — Boomerang/MeteoriteSword had no server check | Yes — UserOwnsGamePassAsync added (sprint 5b) | **No** | |
| WARNING | Bending-type ownership — any player could fire any element | Yes — Has_*Bending attributes + VFXHandler gate (sprint 5c) | **No** | |
| WARNING | ElementLevels/Abilities could be spoofed by client | Yes — validateClientData extended (sprint 5c) | **No** | |
| WARNING | DevService uses `loadstring()` | Not in repo — only in place file | Unknown | Needs admin-gate verification in Studio |
| WARNING | Duplicate DialogueGui in place file | Repo deleted ReplicatedFirst copy (sprint 5b) | **No** | Resolved once Rojo sync is done |
| INFO | DataStore retry logic missing (silent progress resets) | Yes — exponential-backoff retry added (sprint 5a) | **No** | |
| INFO | DataServer warn/print overrides silencing all errors | Yes — removed (sprint 5a) | **No** | |

### Studio-dependent tasks (consolidated)

| Sprint | Task | Status | Blocking? |
|--------|------|--------|-----------|
| S6 | Loading screen camera on temples + progress bar | Pending | No |
| S6 | Character selection label + missing animations 3–5 | Pending | No |
| S6 | Character customisation UI (skin colour + face) | Pending | No |
| S6 | Store UI editable module + 2× gems GamePass creation | Pending | No |
| S6 | Profile UI restructure (Gold/Gems next to XP bar) | Pending | No |
| S6 | Delay bars centring at top of screen | Pending | No |
| S6 | Glider animation mismatch (orange to blue) | Pending | No |
| S7 | Tag lava-area Parts with "LavaZone" via CollectionService | Pending | **Yes** — EnvironmentAudioController won't trigger without tags |
| S7 | Area music asset IDs for Green Tribe, Southern Air Temple, Western Temple | Pending | No — placeholder entries in SFXs.lua |
| S7 | Appa/Nalu spawn + travel sounds (no asset IDs in issue) | Pending | No |
| S8 | Create Idle/Walk/Jump animations in Moon Animator; set AnimationIds in Momo model | Pending | **Yes** — Momo plays no animations until done |
| S8 | Verify Momo model has Humanoid, PrimaryPart, State (StringValue), Smoke (ParticleEmitter) | Pending | **Yes** — Momo.lua crashes without PrimaryPart |
| S9 | Rename workspace NPC instances: Journey Master→Oryn, Zephir Guide→Sael, Guru Pathik→Kaen | Pending | **Yes** — QuestTargetIds mismatch until done |
| S9 | Update QuestTargetIds, Assigner fields, specialNPCName after Studio rename | Pending | **Yes** — quests won't resolve to renamed NPCs |
| S9 | Rename Appa workspace model to "Nalu" | Pending | No |
| S9 | Rename NPC overhead BillboardGui display names | Pending | No |
| S9 | "Item Guide" → "Ryng" Studio-only NPC rename | Pending | No |
| QA | Run QA_CHECKLIST.md in-game (Simon) — 20 tests across critical/important/minor | Pending | **Yes** — required before next sprint |
| Publish | Rojo sync and publish all accumulated code changes via wimma777 | **BLOCKING** | **Yes — all code fixes are unreachable in live game** |

### Stale PRs and branches

Status as of 2026-06-14:

| Branch | PR# | Commits not in main | Status | Recommendation |
|--------|-----|:------------------:|--------|----------------|
| `sprint-12-quest-tracker-glider` | None | 2 (`3a4e5e3`, `8db9ad1`) | Complete code — PR blocked until rebased | **Rebase onto main first, THEN file PR** — see Contradictions section |
| `fix/pre-existing-broken-requires` | None | 0 (merged via `qa/post-cleanup-audit`) | Fully merged | Delete remote branch |
| `qa/post-cleanup-audit` | None | 0 (merged `f86ce39`) | Fully merged | Delete remote branch |
| `origin/sprint-1/first-session-survival` | #11 (CLOSED) | 0 | Superseded by #12 | Delete remote branch |
| `origin/sprint1-first-session-survival` | #12 (MERGED) | 0 | Merged | Delete remote branch |
| `origin/sprint2-combat-feel` | #13 (MERGED) | 0 | Merged | Delete remote branch |
| `origin/sprint3-progression` | #20 (MERGED) | 0 | Merged | Delete remote branch |
| `origin/sprint-2-onboarding-blockers` | #21 (MERGED) | 0 | Merged | Delete remote branch |
| `origin/sprint-3-combat-fixes` | #22 (MERGED) | 0 | Merged | Delete remote branch |
| `origin/sprint-4a-quest-fixes` | #23 (CLOSED) | 0 | Squash-merged via S10 | Delete remote branch |
| `origin/sprint-4b-progression-foundation` | #24 (MERGED) | 0 | Merged | Delete remote branch |
| `origin/sprint-5b-combat-security` | #26 (MERGED) | 0 | Merged | Delete remote branch |
| `origin/sprint-6a-ui-quick-fixes` | #28 (MERGED) | 0 | Merged | Delete remote branch |
| `origin/sprint-9-npc-rename` | #31 (MERGED) | 0 | Merged | Delete remote branch |
| `origin/sprint-10-bugfixes` | #32 (MERGED) | 0 | Merged | Delete remote branch |
| `origin/docs/agents-md-migration` | #39 (MERGED) | 0 | Merged | Delete remote branch |
| `origin/audit/repo-state-apr-2026` | #40, #41 (MERGED) | 0 | Merged | Delete remote branch |
| `origin/audit/repo-state-may-2026` | #42 (MERGED) | 0 | Merged | Delete remote branch |
| All `cleanup/*` branches | #34–38 (MERGED) | 0 | Merged | Delete remote branches |

### GitHub issues (as of 2026-06-14)

All 15 tracked issues are **CLOSED**. Issues #3, #4, #6, #9, #10, and #14 were open in the May audit and were closed on 2026-05-22.

| Issue# | Title | Closed | Notes |
|--------|-------|--------|-------|
| #2 | P0: First-session onboarding blockers causing D1 churn | 2026-02-20 | |
| #3 | P0: Combat system critical bugs and balance | 2026-05-22 | Partially resolved — gameplay feel items (damage numbers, block rework) remain |
| #4 | P1: Progression system and quest overhaul | 2026-05-22 | Partially resolved — full redesign not done |
| #5 | P1: UI/UX polish and fixes | 2026-02-22 | |
| #6 | P2: Audio system — sounds, music, and atmosphere | 2026-05-22 | Studio tasks still pending (LavaZone tags, music IDs) |
| #7 | P2: Pet Lemur (Momo) system implementation | 2026-02-22 | Studio model verification still pending |
| #8 | P3: NPC and location renaming (IP de-risk) | 2026-02-22 | Studio renames still pending |
| #9 | P3: Feature backlog — combat, narrative, PVP arena | 2026-05-22 | Deferred intentionally; items untouched |
| #10 | EPIC: RoVatar Player Feedback Remediation | 2026-05-22 | Closed as milestone marker — root causes not fully resolved |
| #14 | Quest tracker HUD — always-visible objective display | 2026-05-22 | Sprint-12 code done on branch; PR pending rebase |
| #16 | Sprint 3: XP and gold earn rates review | 2026-02-21 | |
| #17 | Sprint 3: Level-up celebration effect | 2026-02-22 | |
| #18 | Sprint 3: Ability unlock ceremony | 2026-02-22 | |
| #19 | Bug: XP listener accumulates duplicate connections | 2026-02-22 | |

### Known bugs (from AGENTS.md and handoffs)

- `QuestDataService:OnPlayerAdded` mutates `plrData` without saving — data lost on quick disconnect before 30-second auto-save
- `_onCharacterAdded` shadows its `player` parameter with `Players:GetPlayerFromCharacter(character)` on line 419 — re-declaration can return nil
- `SetupCharacter` async race — code after `SetupCharacter()` in `_onCharacterAdded` references the stale original character
- `ToggleWeapon` sword equip has 0.25s `task.delay` race — guard needed with `Char:FindFirstChild("MeteoriteSword")` state check
- `DamageIndication.BindToAllNPCs()` is a one-shot scan at startup — respawned NPCs not covered without a `workspace.DescendantAdded` listener
- `GetPlayerDataModel`/`GetSlotDataModel` access `workspace.ServerTime.Value` at require-time — crashes on client without a `pcall` or `FindFirstChild` guard
- 6 UNCERTAIN dead-code items from QA audit (`NPCModule.simplePath`, DataReplicator Comm requires) — need in-game NPC pathfinding verification by Simon before safe removal
- DevService uses `loadstring()` — needs admin-gate audit directly in the place file

---

## Deployment Gap

### What is in the repo but not in the live game

Every change from sprints 1–12 plus all 5 cleanup PRs is in the repo and **none of it has been published to the live Roblox game**. The last game-code change was commit `f86ce39` on 2026-04-12. The game has not been updated since before February 2026 — over four months of unshipped changes as of June 2026.

**Security infrastructure (CRITICAL — live game is currently exploitable):**
- `GetPlrData` authorisation fix (same-player restriction)
- `TeleportRequest` whitelist (`Constants.Places`)
- `SafeZoneEnforcer.lua` (SafeZoneUtils inlined — all 7 abilities gated)
- `DataReceivedFromClient` GamePasses validation
- ElementLevels/Abilities server validation
- Bending-type ownership check in VFXHandler

**Gameplay systems (never live):**
- `DamageCalc.lua` — element-scaled damage calculations
- `ElementXp.lua` — per-element XP award
- `OverheadService.lua` — player overhead BillboardGuis
- `EnvironmentAudioController.lua` — proximity lava/altitude wind audio
- `QuestTrackerHUD.lua` — always-visible quest HUD (wired in sprint 12, pending PR)
- `LevelUpService.lua` (fixed to watch `Progression.LEVEL`, not dead `CombatStats.Level`)
- `GameAnalyticsService.lua`
- All UI/UX polish from sprints 6–9

**Code quality / stability (never live):**
- DataStore exponential-backoff retry
- `warn`/`print` override removal in DataServer
- All deprecated `wait()`/`spawn()`/`delay()` replacements (sprints 10–11)
- Nil-guards across 6+ files
- All dead code removed by cleanup PRs #34–38

### How to close the gap

1. Run `rojo serve default.project.json` in the repo root
2. Open Roblox Studio logged in as **wimma777** via Team Create (so the map streams correctly)
3. Connect Rojo panel → review sync preview → confirm NO Workspace changes → Accept
4. Commit Drafts panel if anything shows
5. File > Publish to Roblox
6. Close Studio immediately after publish (stops auto-save overwriting the map)
7. Verify via `https://www.roblox.com/games/10467665782`

**WARNING:** Never open with Team Create OFF — the map does not render as local files and an accidental save will push an empty map. See AGENTS.md for the full Team Create warning and recovery steps.

### Rojo integration status

`default.project.json` is present and correctly configured:
- `$ignoreUnknownInstances: true` on all services (prevents Rojo from deleting Studio-managed content)
- `servePlaceIds` locked to Place ID `10467665782`
- Workspace is NOT in the Rojo tree (protects map geometry from terrain wipe)

### World geometry

No explicit mesh or geometry blocker found in any tracking document. The game's world geometry lives entirely as MeshPart instances (67,938 per PLACE_AUDIT.md) referencing Roblox asset IDs owned by the RoVatar Studios group — they exist on Roblox's cloud and cannot be managed via Rojo. Rojo only manages scripts.

---

## Contradictions Found

| Contradiction | Document A | Document B | Resolution |
|---------------|-----------|-----------|------------|
| May 2026 audit listed issues #3, #4, #6, #9, #10, #14 as OPEN | `REPO_AUDIT_2026_04.md` (2026-05-17) | `gh issue list` (2026-06-14) | All six issues were closed 2026-05-22 — after the May audit |
| May 2026 audit Sprint History listed PR #42 as "**OPEN** (this PR)" | Sprint History table, `REPO_AUDIT_2026_04.md` (2026-05-17) | `gh pr list` (2026-06-14) showing MERGED 2026-05-16 | PR #42 was merged before the audit text that describes it as open was committed — the content was written mid-PR and shipped in the same merge |
| Sprint 12 PROGRESS.md says "Current Sprint: #12 — COMPLETE" | `sprint-12-quest-tracker-glider:PROGRESS.md` | `main:PROGRESS.md` (shows Sprint 11 as current) | Sprint 12 work is done on the branch but PROGRESS.md on main has never been updated — branch unmerged |
| Sprint-12 wires `QuestTrackerHUD.Init()` in DataController, but `QuestTrackerHUD.lua` does not exist in main | `sprint-12-quest-tracker-glider:DataController.lua` (`3a4e5e3`) | `main` (cleanup PR #38 deleted QuestTrackerHUD.lua as apparently dead code) | The cleanup sprint removed QuestTrackerHUD.lua because sprint-12's wiring was on an unmerged branch, making it appear unreferenced. Sprint-12 must be rebased onto main — the rebase will restore QuestTrackerHUD.lua as a new file and the diff will be ~5 files, ~33 lines |
| `main:PROGRESS.md` shows Sprint 11 as "Current Sprint" | `main:PROGRESS.md` | Sprint 12 branch PROGRESS.md | Sprint 12 work exists on an unmerged branch; PROGRESS.md on main was never updated to reflect it |
| PR #23 listed as CLOSED in `gh pr list` but PROGRESS.md states its commit was merged | `PROGRESS.md` | GitHub PR state | Changes were squash-committed into main via PR #32 (Sprint 10). PR #23 was closed without merge; its content is in main. No substance contradiction — only PR-state labelling |

---

## Recommendations

Prioritised by impact (updated 2026-06-14):

1. **[P0 — Do today] Rojo publish to live game.** The live game is missing every security fix, gameplay feature, and bug fix from all 12+ sprints spanning over four months. Players are currently exposed to `GetPlrData` data exfiltration and `TeleportRequest` redirect attacks. Publish via `wimma777` account following the Rojo workflow in AGENTS.md.

2. **[P1 — Overdue since 2026-05-12] Rebase and file a PR for sprint 12.** The sprint-12 branch has complete game code (5 files, ~33 lines) but **cannot be filed as a PR without rebasing first.** The branch was created before 18 main commits and `QuestTrackerHUD.lua` was deleted from main during cleanup while sprint-12 still references it. Steps: (1) `git checkout sprint-12-quest-tracker-glider && git rebase origin/main` — restores QuestTrackerHUD.lua as a new file and drops already-merged cleanup changes from the diff; (2) resolve any conflicts in DataController.lua path changes from the flatten-paths PR; (3) `git push --force-with-lease origin sprint-12-quest-tracker-glider && gh pr create`.

3. **[P1 — Do this week] Studio renames for sprint 9 NPC work.** Quest resolution is broken for Oryn, Sael, and Kaen because workspace NPC instance names still use the old IP-risk names. Blocks quest completion for those NPCs until done.

4. **[P1 — Do this week] Verify DevService `loadstring()` is admin-gated.** The only CRITICAL finding from PLACE_AUDIT.md that has not yet been verified. Confirm it cannot be invoked by regular players (open place file in Studio, inspect DevService).

5. **[P2 — Next sprint] Run QA_CHECKLIST.md in Studio.** The 20 post-cleanup tests (5 critical, 10 important, 5 minor) in `QA_CHECKLIST.md` have not been executed. Required before shipping to live players — confirms cleanup PRs #34–38 introduced no regressions.

6. **[P2 — Next sprint] Tag LavaZone Parts in Studio.** EnvironmentAudioController won't trigger lava audio without CollectionService "LavaZone" tags on the relevant Parts.

7. **[P2 — Next sprint] Momo model verification.** Momo.lua requires a `PrimaryPart`, `Humanoid`, `State` StringValue, and `Smoke` ParticleEmitter. Without model verification, summoning Momo will crash.

8. **[P3 — Batch cleanup] Delete stale remote branches.** 20+ merged/closed branches clutter the remote. A batch `git push origin --delete` pass would clean this up safely — all content is in main.

9. **[P3 — Verify before removing] Resolve 6 UNCERTAIN dead-code items from QA_CHECKLIST.md.** Simon needs to verify NPC pathfinding (`NPCModule.simplePath`) and DataReplicator Comm requires in-game before these can be safely removed.

10. **[P3 — Future] Address remaining gameplay gaps.** Combat feel (damage numbers, block rework) and the full progression redesign (multi-quest, move binding) are the root causes of the 25% approval rate. These are the highest-value items once deployment is unblocked.

---

*First produced: 2026-05-12. Refreshed: 2026-05-15, 2026-05-16, 2026-05-17, 2026-06-14. Last game-code change: `f86ce39` (2026-04-12).*
