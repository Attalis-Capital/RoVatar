## Session Handoff — 2026-02-20 — Security Tier 1

### Context
RoVatar Roblox game. MISSION.md identified 4 CRITICAL and 6 HIGH security vulnerabilities. This session implemented all Tier 1 fixes (items 1.1-1.10) except item 1.3 (full intent signal migration, deferred to next sprint).

### Completed this session
- Removed RCE vector (loadstring/ExecuteCode) from DevService.lua + added admin whitelist
- Removed 2 dangerous client RemoteEvents (RemovePlrData, UpdateSpecDataRqst) from DataServer.lua
- Added server-side validation to DataReceivedFromClient rejecting increases to Gold, Gems, TotalXP, PlayerLevel, XP, Kills
- Enabled auto-save (30s interval) and fixed BindToClose to persist data on player leave/shutdown
- Disabled 6 legacy Bendings server scripts with early returns
- Restored stamina/level validation in all VFXHandler ability modules (EarthStomp, FireDropKick, AirKick, WaterStance, Fist)
- Added ability whitelist, per-ability cooldowns, and Fist rate limiting to VFXHandler dispatch
- Added 1-second rate limit on DataServer client writes
- Flagged 3 duplicate ProductIds with TODO(SECURITY) comments
- Extracted 9 lessons (6 repo-specific, 3 universal) to Gotchas and Supabase

### Decisions made
- **Item 1.3 deferred**: 22 UpdateData callsites across 16 files need intent signal migration — too large for this sprint. Validation in DataReceivedFromClient provides interim defence.
- **Early return pattern for Bendings**: Used `if true then return end` instead of deleting files to preserve git history and allow easy revert.
- **WaterStance stamina gate**: Added to Weld (activation) branch only — the else branch is deactivation and shouldn't cost stamina.

### Learnings
- DataServer.lua overrides `warn`/`print` as no-ops — new warn() calls won't output
- VFXHandler runs in both client and server contexts — security code must be in the IsServer else block
- Old Bendings _S.lua scripts are a parallel combat system to VFXHandler — both must be addressed together
- DataReceivedFromClient accepts raw full-data overwrites — any unvalidated field is spoofable

### Open questions / blockers
- 3 duplicate ProductIds (Gems2x, MegaLuck, MegaLuck2) share ProductId 1873595644 — owner must create new dev products in Roblox Dashboard
- Fist.lua has hardcoded base damage `7.1` and scaling `0.015` — should be moved to Costs.lua
- Fist stamina deduction lacks a pre-check guard (stamina could go slightly negative under rapid spam, mitigated by 0.3s rate limiter)

### Next actions
1. **Item 1.3**: Migrate 22 UpdateData callsites to server-side intent signals (dedicated sprint)
2. **Fist.lua cleanup**: Move hardcoded damage values to Costs.lua, add stamina pre-check guard
3. **Continue to Sprint #2 (Issue #2)**: First-session onboarding blockers

### Files modified
- `ServerScriptService/Server/Services/DevService.lua` — RCE removal + admin check
- `ReplicatedStorage/Modules/Custom/DataReplicator/DataServer.lua` — endpoint removal, validation, rate limiting, auto-save
- `ServerScriptService/Server/Services/Player/PlayerDataService.lua` — BindToClose fix
- `ReplicatedStorage/Modules/Custom/VFXHandler.lua` — cooldown + whitelist dispatch
- `ReplicatedStorage/Modules/Custom/VFXHandler/{AirKick,EarthStomp,FireDropKick,Fist,WaterStance}.lua` — validation restored
- 6 files under `ReplicatedStorage/Assets/Models/Combat/Bendings/` — disabled with early return
- `ReplicatedStorage/Modules/Custom/Constants.lua` — TODO(SECURITY) markers
- `CLAUDE.md` — 6 new Gotchas entries

### Resume command
```
Review MISSION.md and CLAUDE.md. The Tier 1 security sprint is complete (commit 36604f5). The main remaining security work is Item 1.3: migrating 22 UpdateData callsites across 16 files from raw client data overwrites to server-side intent signals. DataReceivedFromClient now has interim validation blocking currency/XP/level/kills spoofing. After that, proceed to Sprint #2 (GitHub Issue #2 — first-session onboarding blockers). Also: move Fist.lua hardcoded damage (7.1, 0.015) to Costs.lua and add stamina pre-check guard.
```
