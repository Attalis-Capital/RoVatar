# RoVatar Repo State Audit — April 2026

## Executive Summary

The repo is in good structural shape — 11 game sprints plus 5 cleanup PRs (PRs #21–#39) are all merged, code quality is high, and the codebase has been hardened against the Feb 2026 audit's critical security vulnerabilities. However, **none of these fixes are live**. Every security patch, gameplay improvement, and structural change since the game was last published (estimated Feb 2026 or earlier) exists only in the repo. The single biggest risk is a player exploiting `GetPlrData` (any-player data exposure) or the `TeleportRequest` redirect attack while the fix sits undeployed. The recommended next action is an immediate Rojo publish to the live game via the `wimma777` account. A secondary branch (`sprint-12-quest-tracker-glider`) with completed quest-tracker work also has no PR and cannot merge until one is filed.

---

## Sprint History

| Sprint | Description | PR# | Status |
|--------|-------------|-----|--------|
| S1 (early) | First-Session Survival — SafeZone PvP, tutorial fix | #12 | MERGED |
| S2 | First-Session Onboarding Blockers | #21 | MERGED |
| S2 (combat-feel) | Auto-target, Hit Feedback, Combo Counter, Death Screen | #13 | MERGED |
| S3 (progression) | Progression systems (Sprint 3 — breadcrumb, HUD, XP/level) | #20 | MERGED |
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
| S12 | Quest Tracker HUD wiring + glider constants | **NO PR** | Branch exists, not merged |

**PRs #11 and #23 were closed without merge** (superseded by #12 and the S10 squash respectively). All others merged.

---

## Open Items

### Security (undeployed fixes)

All security fixes in the repo have NEVER been published to the live Roblox game. As of AGENTS.md line 150 (updated 2026-04-04), this remains true.

| Severity | Issue | Fixed in repo? | Deployed to live? | Notes |
|----------|-------|:--------------:|:-----------------:|-------|
| CRITICAL | `GetPlrData` exposes any player's full data to any client | Yes — DataServer.lua restricted to same-player lookups (sprint 5a + 2026-04-03 fix) | **No** | Highest exploit risk — trivial to abuse |
| CRITICAL | `TeleportRequest` accepts arbitrary PlaceIds (redirect attack) | Yes — whitelist from Constants.Places (2026-04-03 fix) | **No** | |
| CRITICAL | `DataReceivedFromClient` accepts spoofed GamePurchases.Passes (revenue leak) | Yes — validated in validateClientData (sprint 5a) | **No** | Players can self-grant Boomerang/Sword/Glider |
| WARNING | SafeZone PvP — 5/7 abilities allowed damage in safe zones | Yes — all 7 abilities gate on InSafeZone (sprint 5b) | **No** | SafeZoneEnforcer.lua (with inlined SafeZoneUtils) not in live game |
| WARNING | GamePass ownership — Boomerang/MeteoriteSword had no server check | Yes — UserOwnsGamePassAsync added (sprint 5b) | **No** | |
| WARNING | Bending-type ownership — any player could fire any element | Yes — Has_*Bending attributes + VFXHandler gate (sprint 5c) | **No** | |
| WARNING | ElementLevels/Abilities could be spoofed by client | Yes — validateClientData extended (sprint 5c) | **No** | |
| WARNING | DevService uses `loadstring()` | Not in repo — only in place file | Unknown | Needs admin-gate verification |
| WARNING | Duplicate DialogueGui in place file | Repo deleted ReplicatedFirst copy (sprint 5b) | **No** | Will be resolved once Rojo sync is done |
| INFO | DataStore retry logic missing (silent progress resets) | Yes — exponential-backoff retry added (sprint 5a) | **No** | |
| INFO | DataServer warn/print overrides silencing all errors | Yes — removed (sprint 5a) | **No** | |

### Studio-dependent tasks (consolidated)

| Sprint | Task | Status | Blocking? |
|--------|------|--------|-----------|
| S6 | Loading screen camera on temples + progress bar | Pending | No |
| S6 | Character selection label + missing animations 3-5 | Pending | No |
| S6 | Character customisation UI (skin colour + face) | Pending | No |
| S6 | Store UI editable module + 2x gems GamePass creation | Pending | No |
| S6 | Profile UI restructure (Gold/Gems next to XP bar) | Pending | No |
| S6 | Delay bars centring at top of screen | Pending | No |
| S6 | Glider animation mismatch (orange to blue) | Pending | No |
| S7 | Tag lava-area Parts with "LavaZone" via CollectionService | Pending | Yes — EnvironmentAudioController won't trigger without tags |
| S7 | Area music asset IDs for Green Tribe, Southern Air Temple, Western Temple | Pending | No — placeholder entries in SFXs.lua |
| S7 | Appa/Nalu spawn + travel sounds (no asset IDs in issue) | Pending | No |
| S8 | Create Idle/Walk/Jump animations in Moon Animator; set AnimationIds in Momo model | Pending | Yes — Momo plays no animations until done |
| S8 | Verify Momo model has Humanoid, PrimaryPart, State (StringValue), Smoke (ParticleEmitter) | Pending | Yes — Momo.lua crashes without PrimaryPart |
| S9 | Rename workspace NPC instances: Journey Master→Oryn, Zephir Guide→Sael, Guru Pathik→Kaen | Pending | Yes — QuestTargetIds mismatch until done |
| S9 | Update QuestTargetIds, Assigner fields, specialNPCName after Studio rename | Pending | Yes — quests won't resolve to renamed NPCs |
| S9 | Rename Appa workspace model to "Nalu" | Pending | No |
| S9 | Rename NPC overhead BillboardGui display names | Pending | No |
| S9 | "Item Guide" → "Ryng" Studio-only NPC rename | Pending | No |
| Publish | Rojo sync and publish all accumulated code changes via wimma777 | **BLOCKING** | **Yes — all code fixes are unreachable in live game** |

### Stale PRs and branches (to close or clean up)

| Branch | PR# | Commits not in main | Status | Recommendation |
|--------|-----|:------------------:|--------|----------------|
| `sprint-12-quest-tracker-glider` | None | 2 (`3a4e5e3`, `8db9ad1`) | Complete — no PR filed | File PR immediately; work is done |
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
| All `cleanup/*` branches | #34–38 (MERGED) | 0 | Merged | Delete remote branches |

### Open issues (to close or action)

| Issue# | Title | State | Actually resolved? | Recommendation |
|--------|-------|-------|:-----------------:|----------------|
| #3 | P0: Combat system critical bugs and balance | OPEN | Partially — server security fixed (S5a-5c), GamePass checks added. Original gameplay feel items (damage numbers, block rework, stamina-on-death reset) NOT addressed | Keep open; remaining combat feel items still pending |
| #4 | P1: Progression system and quest overhaul | OPEN | Partially — element XP system and level gating done (S4b), quest fixes done (S4a). Full redesign (multi-quest, move binding, progression redesign) NOT done | Keep open; major redesign items still pending |
| #6 | P2: Audio system | OPEN | Partially — shop error sound, glider wind, environment audio controller done (S7). LavaZone Studio tags, area music IDs, Appa sounds still pending | Keep open; Studio + asset items pending |
| #9 | P3: Feature backlog — combat, narrative, PVP arena | OPEN | No — all items are future features, untouched | Keep open; deferred intentionally |
| #10 | EPIC: RoVatar Player Feedback Remediation | OPEN | Partially — many sub-items addressed via sprints 2-12, but the 25% approval rate root causes (combat feel, progression redesign, narrative) not fully fixed | Keep open until game metrics improve |
| #14 | Quest tracker HUD | OPEN | Yes (code-only) — QuestTrackerHUD wired in sprint 12 (branch `sprint-12-quest-tracker-glider`) | Close once sprint 12 PR is merged |

### Known bugs (from AGENTS.md and handoffs)

- `QuestDataService:OnPlayerAdded` mutates `plrData` without saving — data lost on quick disconnect
- `_onCharacterAdded` shadows its `player` parameter — re-declaration can return nil
- `SetupCharacter` async race — code after `SetupCharacter()` references stale original character
- `ToggleWeapon` sword equip has 0.25s `task.delay` race — guard needed with state check
- `DamageIndication.BindToAllNPCs()` is a one-shot scan — respawned NPCs not covered
- `GetPlayerDataModel`/`GetSlotDataModel` access `workspace.ServerTime.Value` at require-time — crashes on client without pcall guard
- 6 UNCERTAIN dead code items from QA audit (NPCModule.simplePath, DataReplicator Comm requires) — need in-game NPC pathfinding verification
- DevService uses `loadstring()` — needs admin-gate audit in place file

---

## Deployment Gap

### What is in the repo but not in the live game

Every change from sprints 1–12 plus all 5 cleanup PRs is in the repo and **none of it has been published to the live Roblox game**. Specifically:

**Security infrastructure (CRITICAL — live game is exploitable):**
- `GetPlrData` authorisation fix
- `TeleportRequest` whitelist
- `SafeZoneEnforcer.lua` (with inlined SafeZoneUtils)
- `DataReceivedFromClient` GamePasses validation
- ElementLevels/Abilities server validation
- Bending-type ownership check in VFXHandler

**Gameplay systems (never live):**
- `DamageCalc.lua` — element-scaled damage calculations
- `ElementXp.lua` — per-element XP award
- `OverheadService.lua` — player overhead BillboardGuis
- `EnvironmentAudioController.lua` — proximity lava/altitude wind audio
- `QuestTrackerHUD.lua` — always-visible quest HUD (wired in sprint 12)
- `LevelUpService.lua` (fixed to watch Progression.LEVEL, not dead CombatStats.Level)
- `GameAnalyticsService.lua`
- All UI/UX polish from sprints 6-9

**Code quality / stability:**
- DataStore exponential-backoff retry
- warn/print override removal in DataServer
- All deprecated `wait()`/`spawn()`/`delay()` replacements (sprints 10-11)
- Nil-guards across 6+ files

### How to close the gap

1. Run `rojo serve default.project.json` in the repo root
2. Open Roblox Studio logged in as **wimma777** via Team Create (so the map streams correctly)
3. Connect Rojo panel → review sync preview → confirm NO Workspace changes → Accept
4. Commit Drafts panel if anything shows
5. File > Publish to Roblox
6. Close Studio immediately after publish (stops auto-save overwriting the map)
7. Verify via `https://www.roblox.com/games/10467665782`

**WARNING:** Never open with Team Create OFF — the map does not render as local files and an accidental save will push an empty map. See AGENTS.md for full Team Create warning and recovery steps.

### Rojo integration status

`default.project.json` is present and correctly configured:
- `$ignoreUnknownInstances: true` on all services (prevents Rojo from deleting Studio-managed content)
- `servePlaceIds` locked to Place ID `10467665782`
- Workspace is NOT in the Rojo tree (protects the map from terrain wipe)

### Skimowou/mesh blocker status

No explicit "Skimowou" or mesh blocker found in tracking documents. The game's world geometry lives entirely as MeshPart instances (67,938 MeshParts per PLACE_AUDIT.md) referencing Roblox asset IDs. These are owned by the RoVatar Studios group and exist on Roblox's cloud — they cannot be exported or managed via Rojo. There is no indication of a specific mesh import blocker in any handoff document.

---

## Contradictions Found

| Contradiction | Document A | Document B | Resolution |
|---------------|-----------|-----------|------------|
| Sprint 12 PROGRESS.md says "Current Sprint: #12 — COMPLETE" | `sprint-12-quest-tracker-glider:PROGRESS.md` | `main:PROGRESS.md` (shows Sprint 11 as current) | Sprint 12 work is done on the branch but PROGRESS.md on main has not been updated — branch not merged |
| PLACE_AUDIT.md lists QuestTrackerHUD as "IN REPO ONLY — Not yet deployed" | `PLACE_AUDIT.md` (Apr 3) | Sprint 12 notes (Feb 22, branch) claim it was wired | PLACE_AUDIT.md reflects state at audit time; Sprint 12 subsequently wired the module — still undeployed |
| PROGRESS.md (main) shows Sprint 11 as "Current Sprint" | `main:PROGRESS.md` | Sprint 12 branch PROGRESS.md | Sprint 12 branch work predates some cleanup PRs in git ordering; PROGRESS.md on main was not updated when sprint 12 work landed |
| PR #23 listed as CLOSED (not merged) in `gh pr list` output but PROGRESS.md says "dea0acc feat(quests): sprint 4a" merged | PROGRESS.md | GitHub PR state | Changes were squash-committed into main via PR #32 (Sprint 10). PR #23 was closed without merging but its content is in main. No contradiction in substance — only in PR state labelling. |

---

## Recommendations

Prioritised by impact:

1. **[P0 — Do today] Rojo publish to live game.** The live game is missing every security fix, gameplay feature, and bug fix from all 11+ sprints. Players are currently exposed to the `GetPlrData` data-exfiltration exploit and the `TeleportRequest` redirect attack. Publish via `wimma777` account following the Rojo workflow in AGENTS.md. This one action closes the entire deployment gap.

2. **[P1 — Do this week] File a PR for sprint 12.** Branch `sprint-12-quest-tracker-glider` has two complete commits but no PR. Quest Tracker HUD is wired and ready. Run `gh pr create` from that branch to merge it before starting any new sprint.

3. **[P1 — Do this week] Verify DevService `loadstring()` is admin-gated.** This is the only CRITICAL finding from PLACE_AUDIT.md that has not been verified. Confirm it cannot be invoked by regular players.

4. **[P1 — Do this week] Studio renames for sprint 9 NPC work.** Quest resolution is broken for Oryn, Sael, and Kaen because workspace NPC instance names still use the old IP-risk names. This blocks quest completion for those NPCs.

5. **[P2 — Next sprint] Tag LavaZone Parts in Studio.** EnvironmentAudioController won't trigger lava audio without CollectionService "LavaZone" tags on the relevant Parts.

6. **[P2 — Next sprint] Momo model verification.** Momo.lua requires a `PrimaryPart`, `Humanoid`, `State` StringValue, and `Smoke` ParticleEmitter. Without model verification, summoning Momo will crash.

7. **[P2 — Next sprint] Delete stale remote branches.** 15+ merged branches are cluttering the remote. A batch `git push origin --delete` pass would clean this up.

8. **[P3 — Ongoing] Close issue #14** once sprint 12 merges. Issue #14 (Quest Tracker HUD) is resolved in code.

9. **[P3 — Ongoing] Resolve 6 UNCERTAIN dead-code items from QA_CHECKLIST.md.** Simon needs to verify NPC pathfinding (NPCModule.simplePath) and DataReplicator Comm requires in-game before these can be safely removed.

10. **[P3 — Future] Address remaining open issues #3, #4.** Combat feel (damage numbers, block rework) and the full progression redesign (multi-quest, move binding) are the root causes of the 25% approval rate. These are the highest-value work items once deployment is unblocked.
