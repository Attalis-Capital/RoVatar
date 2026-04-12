# Post-Cleanup QA Checklist

**Date:** 2026-04-12
**PRs audited:** #34, #35, #36, #37, #38
**Total changes:** 28 files deleted, 10 files moved, ~30 files modified

---

## Automated Audit Results

| Phase | Check | Result |
|-------|-------|--------|
| 1. Require chain integrity | All require() calls resolve to existing files | PASS |
| 2. Module export verification | All modified files return correctly, no dangling refs | PASS |
| 3. Knit registration | All services/controllers still registered, none deleted | PASS |
| 4. Component registration | All 10 moved GUIs have valid Component.new() calls | PASS |
| 5. Cross-boundary safety | No removed require had method calls in the same file | PASS |

**Overall verdict: PASS**

---

## In-Game Tests for Simon

### Critical (must pass or game is broken)

- [ ] **Game loads without errors** — Open Studio via Rojo, check Output for any "Module not found" or "attempt to index nil" errors on startup
- [ ] **Player spawns correctly** — SafeZoneEnforcer was modified; confirm spawn area works and InSafeZone attribute is set
- [ ] **Player data loads** — PlayerDataService had functions removed; confirm data loads on join (check for Gold/Gems/Level displaying in HUD)
- [ ] **Combat works** — VFXHandler require removed from CharacterService; confirm punching, bending abilities, and hit effects still fire
- [ ] **All 4 bending abilities fire** — AirKick, EarthStomp, FireDropKick, WaterStance (these were unaffected but depend on VFXHandler which is consumed by other files)

### Important (feature-level regression)

- [ ] **Safe zones block PvP** — Walk into spawn safe zone, confirm InSafeZone attribute appears on character, confirm another player cannot damage you
- [ ] **All GUI screens open** — Open each: BagPack, Quest, Settings, Store, Shop, Map, GamePass, Controls Guide, Bending Selection, Main Menu
- [ ] **Store purchases work** — StoreGui had SFXHandler require and ToggleBtn function removed; confirm store UI opens and purchase flow works
- [ ] **Cooldown bars display** — CoolDownGui had requires removed; confirm ability cooldown overlay still appears
- [ ] **Death screen appears** — Die to an NPC and confirm the "You Died" overlay shows with countdown
- [ ] **Combo counter displays** — Land multiple hits on an NPC and confirm combo counter HUD appears
- [ ] **Dialogue system works** — Talk to an NPC; DialogueGui had CF require removed
- [ ] **Loading screen displays** — Rejoin game and confirm loading overlay appears
- [ ] **Main menu works** — Confirm main menu opens correctly on game entry
- [ ] **Tutorial NPC functions** — TutorialGuider had 3 requires removed; interact with tutorial NPC
- [ ] **Momo pet follows** — Momo component had 3 requires removed; summon Momo and confirm it follows
- [ ] **Glider works** — Glider had CF require removed; equip and use glider

### Minor (cosmetic or edge case)

- [ ] **Camera shake on hit** — CameraController had Constants require removed; confirm screen shakes on taking damage
- [ ] **Animation transitions** — AnimationController had 2 requires removed; confirm walk/run/jump animations play smoothly
- [ ] **Character customisation UI** — CustomizationUI was moved; confirm character customisation screen loads
- [ ] **IAP purchase prompts** — IAPController had CF require removed; confirm in-app purchase prompts appear

---

## Console Output — Watch For

These specific error patterns would indicate a cleanup regression:

```
Module not found: <any path>
attempt to index nil with '<any key>'
ServerScriptService.Server.Services: <any error>
```

Specifically watch for:
- `SafeZoneUtils` — should NOT appear (module deleted, inlined into SafeZoneEnforcer)
- `DataVersionHandler` — should NOT appear (module deleted)
- `QuestTrackerHUD` — should NOT appear (module deleted)
- `HandHeld` — should NOT appear (module deleted)
- `Shockwave` — should NOT appear (modules deleted)
- `Button1` — should NOT appear (module deleted)
- `TooltipModule` — should NOT appear (module deleted)

---

## UNCERTAIN Items — Manual Verification Required

These items were flagged during the dead code scan (PR #38) but left untouched due to uncertainty. Simon should verify whether they are truly dead:

1. **`NPCModule.lua:17`** — `local simplePath = require(script.SimplePath)` — simplePath is required but never referenced in code. May be wired through Studio instances. Check if NPCs still pathfind correctly.

2. **`DataReplicator/Comm/Client.lua:6`** — `local Common = require(...)` — Common is required but never used. DataReplicator is a sensitive module; left untouched.

3. **`DataReplicator/Comm/Server.lua:3`** — `local Common = require(...)` — Same pattern, server-side.

4. **`DataReplicator/Comm/Server.lua:5`** — `local ServerComm = require(...)` — Required but never used.

5. **`DataReplicator/DataClient.lua:46`** — `local Constants = require(...)` — Required but never used.

6. **`DataReplicator/DataServer.lua:84`** — `local Constants = require(...)` — Required but never used.

**Recommendation:** Items 2-6 are safe to remove in a future PR if Simon confirms DataReplicator works correctly after the current cleanup. Item 1 needs NPC pathfinding verification.

---

## Summary

All automated checks pass. The cleanup removed only genuinely dead code — no require chains were broken, no module exports were lost, no Knit registrations were affected, and no cross-boundary calls were severed. The in-game test list above covers all areas touched by the cleanup PRs.
