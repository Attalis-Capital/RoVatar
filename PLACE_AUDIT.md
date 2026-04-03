# RoVatar Place File Audit — 2026-04-03

## File Summary

| Property | Value |
|----------|-------|
| File | `Rovatar.rbxl` |
| Size | 5,027,004 bytes (4.8 MB) |
| Format | Binary RBXL (zstd compressed) |
| Version | 0 |
| Class types | 158 |
| Total instances | 114,964 |
| Terrain | **NOT PRESENT** (no TERR chunk) |

### Chunk breakdown

| Chunk | Count |
|-------|-------|
| INST | 158 |
| PROP | 2,996 |
| PRNT | 1 |
| SSTR | 1 |
| END | 1 |
| **Total** | **3,157** |

## Service Inventory

All expected Roblox services present:

| Service | Mapped in Rojo? |
|---------|:---:|
| Workspace | Yes |
| ServerScriptService | Yes |
| ReplicatedStorage | Yes |
| ReplicatedFirst | Yes |
| StarterGui | Yes |
| StarterPlayer | Yes |
| StarterPack | No (empty, OK) |
| ServerStorage | No (unused) |
| Lighting | No (Studio-managed) |
| SoundService | No (Studio-managed) |
| Players | N/A (runtime) |
| Chat | N/A (runtime) |

50 services total in place file (most are Roblox system services not requiring Rojo mapping).

## Script Inventory

| Type | Place File | Repo |
|------|-----------|------|
| Script | 25 | ~15 |
| LocalScript | 17 | ~10 |
| ModuleScript | 270 | ~155 |
| **Total** | **312** | **~180** |

The difference is accounted for by:
- Vendor packages (Knit, Fusion, FastCast, Replica, Zone+, R15Ragdoll) embedded in place file
- Duplicate Animate scripts per NPC (8x in workspace NPCs)
- Studio-managed scripts (UITextSizeConstraint, UIPadding — auto-generated)

## Script Comparison: Place File vs Repo

### BOTH (in place file AND repo) — Core Game Scripts

| Script | Type | Status |
|--------|------|--------|
| CharacterController | ModuleScript | BOTH |
| CharacterService | ModuleScript | BOTH |
| PlayerDataService | ModuleScript | BOTH |
| DataServer | ModuleScript | BOTH |
| DataClient | ModuleScript | BOTH |
| VFXHandler | ModuleScript | BOTH |
| QuestDataService | ModuleScript | BOTH |
| QuestController | ModuleScript | BOTH |
| Constants | ModuleScript | BOTH |
| CommonFunctions | ModuleScript | BOTH |
| Costs | ModuleScript | BOTH |
| CustomTypes | ModuleScript | BOTH |
| MultiplaceHandlerService | ModuleScript | BOTH |
| IAPService | ModuleScript | BOTH |
| GameService | ModuleScript | BOTH |
| DevService | ModuleScript | BOTH |
| DialogueGui | ModuleScript | BOTH |
| BagPackGui | ModuleScript | BOTH |
| LoadGameGui | ModuleScript | BOTH |
| QuestGui | ModuleScript | BOTH |
| MainMenuGui | ModuleScript | BOTH |
| SettingsGui | ModuleScript | BOTH |
| ShopGui | ModuleScript | BOTH |
| GamePassGui | ModuleScript | BOTH |
| MapGui | ModuleScript | BOTH |
| NotificationGui | ModuleScript | BOTH |
| Glider | ModuleScript | BOTH |
| Appa | ModuleScript | BOTH |
| Momo | ModuleScript | BOTH |
| CameraController | ModuleScript | BOTH |
| InputController | ModuleScript | BOTH |
| EffectsController | ModuleScript | BOTH |
| AnimationController | ModuleScript | BOTH |
| LevelGuider | ModuleScript | BOTH |
| TutorialGuider | ModuleScript | BOTH |
| QuestGuy | ModuleScript | BOTH |
| UpdateMap | ModuleScript | BOTH |
| SFXHandler | ModuleScript | BOTH |
| CustomizationUI | ModuleScript | BOTH |
| NPCAI | ModuleScript | BOTH |
| Initialize (server) | Script | BOTH |
| Initialize (client) | LocalScript | BOTH |
| HubHandler | Script | BOTH |
| Animate (template) | Script | BOTH |
| All 7 bending ability scripts | Mixed | BOTH |

### IN REPO ONLY — Not yet deployed

| Script | Repo Path | Notes |
|--------|-----------|-------|
| SafeZoneUtils | `ReplicatedStorage/Modules/Custom/SafeZoneUtils.lua` | Added sprint 5b |
| SafeZoneEnforcer | `ServerScriptService/.../SafeZoneEnforcer.lua` | Added sprint 5b |
| DamageCalc | `ReplicatedStorage/.../Utils/DamageCalc.lua` | Added sprint 4b |
| ElementXp | `ReplicatedStorage/.../Utils/ElementXp.lua` | Added sprint 4b |
| OverheadService | `ServerScriptService/.../OverheadService.lua` | Added sprint 6b |
| GameAnalyticsService | `ServerScriptService/.../GameAnalyticsService.lua` | Added post-audit |
| LevelUpService | `ServerScriptService/.../LevelUpService.lua` | Fixed sprint 5a |
| EnvironmentAudioController | `StarterPlayer/.../EnvironmentAudioController.lua` | Added sprint 7 |
| BreadcrumbController | `StarterPlayer/.../BreadcrumbController.lua` | Added post-audit |
| QuestTrackerHUD | `ReplicatedStorage/.../QuestTrackerHUD.lua` | Added post-audit |
| DeathScreen | `ReplicatedStorage/.../DeathScreen.lua` | Added post-audit |
| HitFeedback | `ReplicatedStorage/.../HitFeedback.lua` | Added post-audit |
| ComboCounter | `ReplicatedStorage/.../ComboCounter.lua` | Added post-audit |
| AutoTarget | `ReplicatedStorage/.../AutoTarget.lua` | Added post-audit |
| RateLimiter | `ReplicatedStorage/.../Signal.lua` (custom) | Added post-audit |

**These scripts exist in the repo but have NEVER been published to the live game.** This includes critical security infrastructure (SafeZoneUtils, SafeZoneEnforcer, DamageCalc) and all fixes from sprints 4b–11.

### IN PLACE FILE ONLY — Not managed by Rojo

| Script | Type | Concern |
|--------|------|---------|
| DialogueGui (duplicate) | ModuleScript | Two copies with same name — one is the ReplicatedFirst version that should have been deleted (sprint 5b) |
| Fist_ORIGINAL | ModuleScript | Dead code — original Fist before refactor |
| RocksModule | ModuleScript | Map/terrain module not in repo |
| DamageModule | ModuleScript | Legacy damage module not in repo |
| SwimController | ModuleScript | Client swim controller not in repo |
| TooltipModule | ModuleScript | UI tooltip module not in repo |
| Zone/ZoneController/ZonePlusReference | ModuleScript | Zone+ library not in repo |
| Janitor | ModuleScript | Cleanup utility not in repo |
| Trove/trove | ModuleScript | Cleanup utility not in repo |
| Tracker | ModuleScript | Analytics tracker not in repo |
| LightningBolt/Explosion/Sparks | ModuleScript | VFX libraries not in repo |
| CollectiveWorldModel | ModuleScript | Physics module not in repo |
| Detection | ModuleScript | Hit detection module not in repo |
| Mouse2 | ModuleScript | Input module not in repo |
| StoreGui | ModuleScript | In repo but may have diverged |

## Security Findings

### CRITICAL

| # | Finding | Location |
|---|---------|----------|
| C1 | **`loadstring()` call in DevService** | ModuleScript "DevService" — `loadstring` enables arbitrary code execution. Verify this is dev-only and gated behind admin checks. |

### WARNING

| # | Finding | Location |
|---|---------|----------|
| W1 | Duplicate DialogueGui still in place file | Two ModuleScripts named "DialogueGui" — repo deleted the ReplicatedFirst copy in sprint 5b but the place file hasn't been re-published |
| W2 | Place file is missing ALL security fixes from sprints 5a-11 | SafeZoneUtils, SafeZoneEnforcer, DamageCalc, ElementXp, OverheadService, GetPlrData auth check, Teleport whitelist — none deployed |
| W3 | 8x duplicate Animate scripts in workspace NPCs | Each NPC has its own copy — Studio-managed but diverges from template |
| W4 | ReplicaService OnServerEvent handlers | Lines ~553, ~555 — vendor code, low risk but flagged |

### INFO

| # | Finding | Notes |
|---|---------|-------|
| I1 | HTTP URLs in scripts are all roblox.com asset URLs or documentation links | No external data exfiltration URLs found |
| I2 | `_G` global writes in 17 scripts | Expected pattern — game uses `_G` for cross-script state (PlayerData, Talking, etc.) |
| I3 | HttpService references are for GenerateGUID only | No outbound HTTP calls to external servers |
| I4 | No terrain data in place file | World geometry is all MeshParts/Parts (67,938 + 6,050) |
| I5 | 114,964 total instances — moderate size | 67,938 are MeshParts (models/maps) |

## Terrain Analysis

**No terrain data.** The TERR binary chunk is absent from the place file. The game world is built entirely from MeshPart (67,938) and Part (6,050) instances. This means:
- No heightmap terrain
- No terrain materials (grass, sand, rock, etc.)
- World is entirely model-based

## Recommended Actions

1. **CRITICAL: Publish repo to Roblox immediately** — The live game is missing ALL security fixes from sprints 5a–11 (Feb 2026). This includes:
   - GetPlrData authorisation (player data exposed)
   - Teleport whitelist (redirect attack)
   - SafeZone PvP enforcement
   - GamePass ownership validation
   - DataStore retry logic
   - Bending-type ownership checks

2. **Delete Fist_ORIGINAL** from place file — dead code, 10,935 chars of unused logic

3. **Add unmanaged scripts to repo** — RocksModule, DamageModule, SwimController, TooltipModule, Zone+, Janitor, Trove, LightningBolt, Detection, Mouse2, Tracker need to be extracted from the place file and added to the repo for Rojo management

4. **Verify DevService loadstring** — Confirm it's gated behind admin/dev-only checks and not accessible to regular players

5. **Consider adding place file to Git LFS** — At 5MB it's fine now, but place files grow; LFS prevents repo bloat

---

*Generated by place file binary parser — 2026-04-03*
