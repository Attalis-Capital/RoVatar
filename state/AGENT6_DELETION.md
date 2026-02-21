# Agent 6: Deletion & Simplification — RoVatar Audit Wave 2

## 1. DELETION_LIST

### DEL-1: Legacy `_S.lua` bending scripts (4 files)

**Files to delete:**
- `ReplicatedStorage/Assets/Models/Combat/Bendings/AirBending/AirKick/RemoteEvent/AirKick_S.lua` (130 lines)
- `ReplicatedStorage/Assets/Models/Combat/Bendings/EarthBending/EarthStomp/RemoteEvent/EarthStomp_S.lua` (155 lines)
- `ReplicatedStorage/Assets/Models/Combat/Bendings/FireBending/FireDropKick/RemoteEvent/FireDropKick_S.lua` (180 lines)
- `ReplicatedStorage/Assets/Models/Combat/Bendings/Fist/Fist/Fist_S.lua` (442 lines)

**Why safe to delete:** All four scripts have `if true then return end` at lines 5/5/5/38 respectively. They are the retired "old Bendings system" superseded by `VFXHandler` dispatch. However, `OnServerEvent:Connect` still fires on every client request (lines 4/4/4/37), executing the function prologue before hitting the early return. This wastes a server thread per fire.

**Risk if not deleted:** Each script's `RemoteEvent` remains connectable from the client. An exploiter who removes the corresponding client-side early-return could send arbitrary payloads to these endpoints. Even though the server returns immediately, the connections waste memory and the `RemoteEvent` objects remain attackable surface area. The old scripts also contain `spawn()`/`wait()` throughout (deprecated APIs) and use the old `CombatStats.EXP` path instead of `Progression.EXP` — if someone re-enables them they cause double-damage alongside VFXHandler.

---

### DEL-2: Duplicate `DialogueGui.lua` in `ReplicatedFirst`

**File to delete:**
- `ReplicatedFirst/DialogueGui.lua` (317 lines)

**Why safe to delete:** Two `DialogueGui` components exist with identical `Tag = "DialogueGui"`. The `StarterPlayer` copy (317 lines) has been updated with `SkipAll()` (line 181), `BaseFrame.Activated` click-anywhere-to-advance (line 153), and `GuiButton` cleanup (line 222). The `ReplicatedFirst` copy lacks all three improvements and has a stale `ui.OptionBtnTemplate` path (`BaseFrame.Templates.Option` at line 147 vs `BaseFrame.Templates.OptionButton` at line 142). Both register on the same `Component` tag, so Knit picks one nondeterministically per session.

**Risk if not deleted:** 50% of sessions may get the broken template path, causing option buttons to fail. The `SkipAll()` skip-tutorial feature only works if the StarterPlayer copy wins. Debugging component conflicts is extremely difficult.

---

### DEL-3: `DevService.ToggleServerLogs` — no admin check

**Code to delete in** `ServerScriptService/Server/Services/DevService.lua`:
```
Lines 28-31:
function DevService.Client:ToggleServerLogs()
    logsOn = not logsOn
    return logsOn
end
```

**Why safe to delete:** This Knit client function has no `ADMIN_IDS` check (unlike `ResetPlayerInfoClick` on line 35). Any player can call it. The `logsOn` variable is not consumed by any other code in the file — it is write-only. It does nothing but expose an unprotected server-side state toggle.

**Risk if not deleted:** Minimal functional risk since it has no downstream effect, but it sets a bad pattern and enlarges the attack surface.

---

### DEL-4: `GetPlrData` remote — any client can read any player's full data

**Code to restrict in** `ReplicatedStorage/Modules/Custom/DataReplicator/DataServer.lua`:
```
Lines 261-299: self.ClientSide:GetPlrData(plr, plrUserId)
```

**Why it should be deleted or restricted:** Any client can call `GetPlrData(targetUserId)` and receive the full data table for any player (including gold, gems, quest state, inventory). The function fetches from DataStore if the target player is not on-server (line 279). This is an information-disclosure vulnerability.

**Risk if not deleted:** Exploiters can enumerate all online players' inventories, gold, and progression data. Could also be used to scrape DataStore by brute-forcing UserIds.

---

### DEL-5: `DataServer.HearbeatUpdate` — dead code / duplicate auto-save

**Code to delete in** `ReplicatedStorage/Modules/Custom/DataReplicator/DataServer.lua`:
```
Lines 803-820:
function DataServer:HearbeatUpdate(dt)
    self._autoSaveTimer += dt
    if (self._autoSaveTimer == self._config.AutoSave - 1) then
        self.AutoSaveAlert:Fire()
    end
    if(self._autoSaveTimer > self._config.AutoSave) then
        self._autoSaveTimer = 0
    end
end
```

**Why safe to delete:** The Heartbeat save logic has its `Save()` call commented out (lines 816-818). The actual auto-save runs via `DataServer:AutoSave()` (lines 792-801) using `task.delay`. `HearbeatUpdate` connects on every frame (line 205) but does nothing except increment and reset a timer. It never saves.

**Risk if not deleted:** Wastes CPU on every Heartbeat tick. The `== self._config.AutoSave - 1` comparison on a float accumulator almost never triggers (float equality), so `AutoSaveAlert` fires from `AutoSave()` only.

---

### DEL-6: `warn`/`print` no-op overrides in `DataServer.lua`

**Code at** `ReplicatedStorage/Modules/Custom/DataReplicator/DataServer.lua`:
```
Lines 7-8:
local warn = function() end
local print = function() end
```

**Why it should be deleted:** These overrides silence ALL diagnostics including save failures (line 410: `warn("[DataSave] failed")`), security rejections (line 650: `warn("[SECURITY] Rejected")`), and data-not-found warnings. Save failures become completely invisible. This was flagged as a critical issue by Agent 4.

**Risk if not deleted:** DataStore save failures go unnoticed. Player data loss is silent. Security rejections are invisible to any logging system.

---

## 2. SIMPLIFICATION_LIST

### SIMP-1: Fist/MeteoriteSword hardcoded 7.1 base damage
- **What:** `ReplicatedStorage/Modules/Custom/VFXHandler/Fist.lua:42` and `MeteoriteSword.lua:41`
- **Current:** `local baseM1 = 7.1 * (1 + (pStrength * 0.015))` — magic number
- **Target:** Add `FistBaseDamage = 7.1` and `MeteoriteSwordBaseDamage = 7.1` to `Costs.lua`, reference from both files
- **Priority:** HIGH — violates the project rule "Costs.lua for all numeric values"

### SIMP-2: MeteoriteSword XP awarded before SafeZone gate
- **What:** `ReplicatedStorage/Modules/Custom/VFXHandler/MeteoriteSword.lua:148-155`
- **Current:** EXP granted (line 150) then SafeZone check (line 154) returns — XP awarded even on blocked PvP hits
- **Target:** Move SafeZone check before EXP award (same pattern needed in Fist.lua:152-155 and Boomerang.lua:107-116)
- **Priority:** HIGH — free XP farm in safe zones

### SIMP-3: LevelUpService watches `CombatStats.Level` (non-existent)
- **What:** `ServerScriptService/Server/Services/World/LevelUpService.lua:31`
- **Current:** `combatStats:WaitForChild("Level", 10)` — `CombatStats.Level` does not exist; player level is `Progression.LEVEL`
- **Target:** Change to `plr:WaitForChild("Progression", 10)` then `:WaitForChild("LEVEL", 10)`
- **Priority:** HIGH — level-up broadcast to other players is completely dead

### SIMP-4: EffectsController watches `CombatStats.Level` (non-existent)
- **What:** `StarterPlayer/StarterPlayerScripts/Game/Controllers/World/EffectsController.lua:84-85`
- **Current:** `combatStats:WaitForChild("Level", 10)` — same broken path as LevelUpService
- **Target:** Change to `plr:WaitForChild("Progression", 10)` then `:WaitForChild("LEVEL", 10)`
- **Priority:** HIGH — client-side level-up VFX, SFX, and ability-unlock banners never fire

### SIMP-5: `IsSameDay` New Year branch — type mismatch
- **What:** `ServerScriptService/Server/Services/Player/QuestDataService.lua:50-54`
- **Current:** `currentDateTime.yday == "1"` — `os.date("!*t")` returns numeric fields, comparing number to string always false
- **Target:** `currentDateTime.yday == 1` (and fix `month`/`day`/`year` comparisons similarly on lines 51-53)
- **Priority:** LOW — only affects midnight Dec 31 -> Jan 1 transition; current fallback logic handles it

### SIMP-6: ShopGui off-by-one — can't buy with exact gold
- **What:** `StarterPlayer/StarterPlayerScripts/Game/Components/GUIs/HomeScreens/ShopGui.lua:199`
- **Current:** `if saving > itemData.Price then` — strict greater-than excludes exact-amount purchase
- **Target:** `if saving >= itemData.Price then`
- **Priority:** MEDIUM — also affects BuyButtonClick on line 71 (uses `>=`, so purchase works but button stays grey)

### SIMP-7: SettingsGui VFX and Popup toggles are visual-only
- **What:** `StarterPlayer/StarterPlayerScripts/Game/Components/GUIs/HomeScreens/SettingsGui.lua:101-103 and 139-141`
- **Current:** `PopupToggle()` and `VfxToggle()` only call `ToggleBtn()` to flip the button text/colour. No `SettingData` field is toggled, no system is affected.
- **Target:** Either add `SettingData.Popup` / `SettingData.VFX` fields and wire them to their respective systems, or remove the toggle buttons from the UI to avoid player confusion
- **Priority:** MEDIUM — players think they toggled VFX/popups but nothing changes

### SIMP-8: WaterStance hitbox self-destruct race
- **What:** `ReplicatedStorage/Modules/Custom/VFXHandler/WaterStance.lua:197`
- **Current:** `wait(6)` on line 197 inside the `Touched` callback — after the first hit, the Touched callback waits 6 seconds then destroys `_hitBox`. This runs inside the Touched connection, meaning the hitbox can only register one hit before the `wait(6)` blocks, then destroys it.
- **Target:** Move the cleanup `_hitBox:Destroy()` out of the Touched callback and into the main ability flow with a `task.delay(6, ...)` after the `task.spawn` block
- **Priority:** HIGH — WaterStance only damages one target maximum

### SIMP-9: Boomerang has no server-side validation
- **What:** `ReplicatedStorage/Modules/Custom/VFXHandler/Boomerang.lua:38`
- **Current:** No stamina check, no level check, no GamePass check. All other bending abilities validate these.
- **Target:** Add stamina deduction (`Costs.BoomerangStamina`), add level check if applicable, match the pattern from AirKick/EarthStomp/FireDropKick/WaterStance
- **Priority:** HIGH — unlimited free Boomerang spam, no resource cost

### SIMP-10: Fist/MeteoriteSword missing SafeZone check
- **What:** `ReplicatedStorage/Modules/Custom/VFXHandler/Fist.lua:148-155` and `MeteoriteSword.lua:145-156`
- **Current:** SafeZone check exists in Fist but is placed AFTER XP award. MeteoriteSword has same issue. Both allow PvP damage if attacker is not in safe zone but victim is (only checks `isPlayer` before gating).
- **Target:** Move SafeZone check to BEFORE damage AND XP award, check both attacker and victim regardless of `isPlayer`
- **Priority:** HIGH — PvP damage in safe zones

### SIMP-11: `_onCharacterAdded` shadows `player` parameter
- **What:** `ServerScriptService/Server/Services/Player/CharacterService.lua:435`
- **Current:** Function signature `_onCharacterAdded(character, player, firstTime)` then line 435 does `local player = Players:GetPlayerFromCharacter(character)` which shadows the original parameter. `GetPlayerFromCharacter` can return `nil` if character is being destroyed.
- **Target:** Delete line 435 entirely; use the `player` parameter passed from `onPlayerAdded` (line 456)
- **Priority:** MEDIUM — nil player on race condition causes cascade errors in SetupCharacter

### SIMP-12: `spawn()`/`wait()` deprecated API usage
- **What:** Multiple files still use deprecated `spawn()` and `wait()`:
  - `VFXHandler/Boomerang.lua:66,68,79` — `spawn()`, `wait()`
  - `VFXHandler/WaterStance.lua:121-153` — `spawn()`, `wait()`
  - `VFXHandler/Fist.lua:115,119` — `spawn()`, `wait()`
  - `VFXHandler/MeteoriteSword.lua:112,115` — `spawn()`, `wait()`
- **Current:** `spawn(function() ... end)` and `wait(n)`
- **Target:** Replace with `task.spawn()` and `task.wait(n)` respectively
- **Priority:** LOW — functional but deprecated; Roblox may remove these APIs

### SIMP-13: `ElementXp.Award` has no `RunService:IsServer()` guard
- **What:** `ReplicatedStorage/Modules/Custom/CommonFunctions/Utils/ElementXp.lua:8`
- **Current:** Calls `_G.PlayerDataStore:GetData()` directly — if this module is required client-side, `_G.PlayerDataStore` is nil and the call errors
- **Target:** Add `if not RunService:IsServer() then return end` guard at top of `Award()`
- **Priority:** MEDIUM — currently only called from server-side VFXHandler modules, but any future client require would crash

### SIMP-14: `Calculations.lua` calls `_G.Warn` which is never assigned
- **What:** `ReplicatedStorage/Modules/Custom/CommonFunctions/Utils/Calculations.lua:53`
- **Current:** `_G.Warn("[Need To Calculate Position Again -->>>>]")` — `_G.Warn` is never defined anywhere
- **Target:** Replace with `warn(...)` or remove entirely
- **Priority:** LOW — only hit on edge case where position calculation fails; errors silently

---

## 3. SESSION_BLOCKERS

Issues ordered by "how quickly does this end a player's session?"

### BLOCKER-1: Death during tutorial deadlocks dialogue (SEVERITY: CRITICAL)
**Player experience:** New player dies during the tutorial kill quest. They respawn but the dialogue system is stuck (`_G.Talking = true`). No further dialogue can trigger. The tutorial cannot advance. Player is permanently softlocked.

**Root cause:** `DialogueGui:Finish()` is never called on death. `self.InProcess` stays `true` (StarterPlayer `DialogueGui.lua:168`). All subsequent `ShowDialogue` calls are rejected by the guard on line 162.

**Fix complexity:** Small — hook `Humanoid.Died` to call `DialogueGui:Finish(true)` (force-close) and reset `_G.Talking = false`

---

### BLOCKER-2: Controls taught AFTER combat quest (SEVERITY: HIGH)
**Player experience:** New player is told to "defeat the enemy" but has never been shown how to attack, dodge, or use abilities. They mash random keys, die, and hit BLOCKER-1. Even if they survive, they have no idea what keybinds do.

**Root cause:** Tutorial sequence orders kill-quest before controls tutorial. `ControlsGuideGui` races with dialogue at T+2s (`BreadcrumbController.lua:266` — 3s delay, `CharacterController.lua:1954` — `ToggleControls(false)` at T+1s).

**Fix complexity:** Medium — reorder tutorial steps so controls/keybinds display is shown before kill quest

---

### BLOCKER-3: DataStore save failures are completely silent (SEVERITY: HIGH)
**Player experience:** Player plays for 2 hours. DataStore save fails (throttle, outage, quota). No error is shown. Player leaves. All progress is lost. Player returns next session to find they are reset.

**Root cause:** `DataServer.lua:7-8` overrides `warn`/`print` as no-ops. Save failure on line 409-410 calls `warn("[DataSave] failed")` which goes nowhere. No retry logic exists.

**Fix complexity:** Small — remove warn/print overrides (lines 7-8), add retry with exponential backoff in `Save()`, and fire a client notification on persistent failure

---

### BLOCKER-4: GetAsync failure silently resets player data to defaults (SEVERITY: HIGH)
**Player experience:** Player joins during a brief DataStore outage. `GetAsync` throws (pcall catches it). The code falls through to `s and not result` branch (`DataServer.lua:470-480`) which treats the player as first-time and gives them default data. Their real data is overwritten on next auto-save.

**Root cause:** `DataServer:GetData()` line 459-461 — `pcall` failure (`s = false`) falls through with `data = nil`. If `self._defaultData` exists and `handlePlayers` is true, the next `AutoSave` writes defaults over the player's real data.

**Fix complexity:** Medium — on `pcall` failure (`s = false`), do NOT create a new player entry. Kick the player with an explanatory message or retry the fetch.

---

### BLOCKER-5: Level-up VFX/SFX/unlock banners never fire (SEVERITY: MEDIUM)
**Player experience:** Player levels up from 4 to 5 (unlocking Air Bending). Nothing happens visually. No celebration, no banner, no sound. They don't know they unlocked a new ability. They continue punching things, unaware Air Bending is available.

**Root cause:** `EffectsController.lua:84-85` watches `CombatStats.Level` which does not exist. The real level is `Progression.LEVEL`. The listener never connects.

**Fix complexity:** 1-line — change `WaitForChild` path from `CombatStats.Level` to `Progression.LEVEL`

---

### BLOCKER-6: Boomerang has zero server validation (SEVERITY: MEDIUM)
**Player experience:** Not directly session-ending, but any player who discovers they can spam Boomerang infinitely with no stamina cost, no cooldown enforcement beyond VFXHandler's basic CD, and no level requirement will break the game balance for all other players on the server.

**Root cause:** `VFXHandler/Boomerang.lua:38` — function body starts immediately with no stamina deduction, no level check, no GamePass check. Compare with `AirKick.lua:25-27` which has all three.

**Fix complexity:** Small — add 3 lines matching AirKick pattern: stamina check, level check, stamina deduction

---

### BLOCKER-7: WaterStance only damages one target (SEVERITY: MEDIUM)
**Player experience:** Player activates WaterStance (their highest-level ability). It hits one enemy, then the hitbox self-destructs after 6 seconds. In a group fight, only one NPC takes damage despite the visual effect suggesting AoE.

**Root cause:** `VFXHandler/WaterStance.lua:197` — `wait(6)` inside the `Touched` callback blocks the thread, then `_hitBox:Destroy()` on line 199 removes the hitbox. The `Touched` connection can only process one hit before the blocking wait, then the hitbox is gone.

**Fix complexity:** Small — move `_hitBox:Destroy()` to a `task.delay(6)` outside the Touched callback

---

### BLOCKER-8: ShopGui prevents purchase with exact gold amount (SEVERITY: LOW)
**Player experience:** Player grinds to exactly 500 gold to buy the Glider (cost: 500). The buy button is greyed out. They think the shop is bugged. They need 501 gold.

**Root cause:** `ShopGui.lua:199` uses `saving > itemData.Price` (strict greater-than) for the button enable check. The actual purchase function `BuyButtonClick` on line 71 correctly uses `>=`.

**Fix complexity:** 1-line — change `>` to `>=` on line 199

---

### BLOCKER-9: Quest progress updates silently fail (SEVERITY: LOW)
**Player experience:** Player completes quest objectives but the tracker doesn't update. Quests appear stuck. Restarting the game may or may not fix it depending on auto-save timing.

**Root cause:** `QuestController.lua:58` calls `_G.PlayerDataStore:UpdateData(plrData)` with one argument. The server-side `UpdateData` expects `(plr, data)` — two arguments. The quest update is silently dropped. (Agent 4 finding — wrong arity.)

**Fix complexity:** 1-line — change to `_G.PlayerDataStore:UpdateData(plrData)` with the correct calling convention, or if this is the client-side store, verify the client API signature
