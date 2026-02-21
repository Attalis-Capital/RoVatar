# RoVatar Audit Report — 2026-02-22

## Verdict

No. Alexander's session will crash or softlock within the first 5 minutes due to `_G.PlayerData` nil-indexing on startup, tutorial death deadlock, and invisible DataStore failures that silently reset progress.

## The Three Session-Ending Bugs

**1. _G.PlayerData is nil on startup — instant crash across 40+ consumers**
The player sees: UI elements (SettingsGui, ShopGui, DialogueGui) attempt to read `_G.PlayerData` before the DataReplicator round-trip completes. Any interaction triggers a nil-index crash. Root cause: `SettingsGui.lua:158` calls `CF.PlayerQuestData.GetPlayerActiveProfile(_G.PlayerData)` inside `_refresh()` at T+2s, before data arrives. Every client GUI that touches `_G.PlayerData` is vulnerable. Fix: ~30 lines — add a ready-gate that yields consumers until `_G.PlayerData` is populated.

**2. Death during tutorial deadlocks the dialogue system**
The player sees: they die to the kill-quest NPC, respawn, and can never interact with any NPC again. Root cause: `TutorialGuider.lua:38` sets `_G.Talking = false` at module load, but line 217 sets `Talking = true` on prompt click. Character death triggers neither the `PromptHidden` cleanup (line 233) nor `DialogueGui:Finish()`. After respawn, `Talking` stays `true` and all ProximityPrompts are gated out. Fix: ~5 lines — hook `Humanoid.Died` to reset `_G.Talking` and force-close dialogue.

**3. DataStore GetAsync failure silently resets player data**
The player sees: nothing — their progress is quietly wiped. Root cause: `DataServer.lua:459-480` wraps `GetAsync` in pcall, but on failure (`s == false`), the code falls through to `elseif(s and not result)` which is false, leaving `data = nil`. No retry is attempted. The `warn` on line 7-8 is overridden as a no-op, so failures are invisible. Fix: ~20 lines — add exponential-backoff retry and remove the warn/print overrides.

## Combat: What Works, What Doesn't

| Ability | Status | Issue |
|---------|--------|-------|
| Fist | FRAGILE | Stamina can go negative (`MeteoriteSword.lua:57`); no SafeZone PvP check |
| AirKick | FRAGILE | Missing SafeZone gate; `wait(0.2)` blocks server thread |
| EarthStomp | FRAGILE | Missing SafeZone gate |
| FireDropKick | FRAGILE | Missing SafeZone gate |
| WaterStance | FRAGILE | Touched callback race — hitbox self-destructs after first hit, only damages one target |
| **Boomerang** | **BROKEN** | No server validation at all — no stamina cost, no level check, no GamePass check (`Boomerang.lua:38-137`). XP awarded at line 109 before SafeZone gate at line 116. |
| **MeteoriteSword** | **BROKEN** | No GamePass ownership check. Uses Fist damage formula (`line 41: baseM1 = 7.1`) instead of a sword-specific value. XP awarded at line 149 before SafeZone check at line 154. |

VFXHandler server block (`VFXHandler.lua:52-72`) validates effect names but never checks bending-type ownership — a FireBender can fire `EarthStomp` via RemoteEvent.

## Progression: The Invisible Level-Up

`LevelUpService.lua:28-31` watches `plr:WaitForChild("CombatStats").Level` — a ValueObject that does not exist. The actual level lives at `plr.Progression.LEVEL.Value` (set in `PlayerDataService.lua:120`). Consequence: `LevelUpService` never broadcasts level-ups to other players. `EffectsController.lua:82-85` has the identical dead listener for `CombatStats.Level` on the client — XP popups and level-up celebrations never fire for the local player either. Element XP is only awarded by 4 of 7 abilities; Fist, Boomerang, and MeteoriteSword contribute zero element XP.

## Tutorial: First 90 Seconds Are Hostile

The tutorial assigns a kill quest (via `Conversation.Tutorial[2]`) before teaching the player how to attack, block, or sprint. Controls are taught passively via `ControlsGuideGui` at T+2s, but ability keybinds (1-6) are never taught anywhere. The `SkipAll()` method exists in `DialogueGui.lua:181` (StarterPlayer copy) but is orphaned — no UI button is wired to call it. Two copies of `DialogueGui` exist: `ReplicatedFirst/DialogueGui.lua:19` and `StarterPlayer/.../DialogueGui.lua:19`, both using `Tag = "DialogueGui"`. Knit's Component system binds both, causing undefined behaviour.

## Security: Revenue Leaks

GamePass ownership is checked server-side via `IAPService:RefreshPurchaseDataUpdates` (`IAPService.lua:199-213`) and stored in `playerData.GamePurchases.Passes`. However, `DataServer:DataReceivedFromClient` (`DataServer.lua:680-696`) accepts full data overwrites from the client. The `validateClientData` function (line 644-677) only guards `Gold`, `Gems`, `TotalXP`, `PlayerLevel`, `XP`, and `Kills` — `GamePurchases.Passes` is not validated. A client can set any pass to `true` and receive Boomerang/MeteoriteSword/BlueGlider for free. `GetPlrData` (`DataServer.lua:261`) exposes any player's full data to any client via RemoteFunction — no authorisation check.

## Data Layer: Silent Failures

`DataServer.lua:7-8` overrides `warn` and `print` as no-ops. Every `warn()` in this 827-line file — including save failures at line 410 and fetch errors — produces no output. The `Save` function (line 397-442) calls `SetAsync` in a pcall but has no retry logic; transient Roblox DataStore throttling silently drops saves. The `HearbeatUpdate` function (line 803-820) has its save logic commented out (lines 816-818), so only `AutoSave` at 30s intervals persists data. A player who disconnects within 30s of a change loses progress unless `BindToClose` fires (which has a 30s Roblox timeout).

## Recommended Sprint Priority

1. Guard `_G.PlayerData` with a ready-gate — fixes 40+ nil-index crash paths across all client GUIs
2. Fix `_G.Talking` death deadlock in `TutorialGuider.lua` — hook `Humanoid.Died` to reset state
3. Validate `GamePurchases.Passes` in `DataServer:DataReceivedFromClient` — block revenue spoofing
4. Add DataStore retry with exponential backoff in `DataServer:GetData` and `DataServer:Save`
5. Remove `warn`/`print` overrides in `DataServer.lua:7-8` — restore error visibility
6. Fix `LevelUpService.lua` and `EffectsController.lua` to watch `Progression.LEVEL` not `CombatStats.Level`
7. Add server-side validation to Boomerang (stamina, level, GamePass) and MeteoriteSword (GamePass)
8. Add bending-type ownership check in `VFXHandler.lua:52` server handler
9. Delete duplicate `ReplicatedFirst/DialogueGui.lua` — keep only the StarterPlayer version
10. Restrict `GetPlrData` (`DataServer.lua:261`) to same-player lookups only

## Systems That Work

XP curve and levelling arithmetic are sound — `UpdateXpInPlayerData` correctly accumulates XP and increments `PlayerLevel`. Ability unlock thresholds (levels 5/8/11/12) are reachable through the tutorial plus three quests. Quest assignment, tracking, and completion logic is functional. Data model consistency between `GetSlotDataModel` defaults and `CustomTypes` is maintained. `ComboCounter` and `HitFeedback` combat-feel systems work correctly. The 30s auto-save and `BindToClose` persistence paths function when DataStore calls succeed. SafeZone detection via character attributes is wired correctly where it exists.
