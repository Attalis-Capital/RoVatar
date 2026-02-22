# MISSION.md — Issue #5: UI/UX Polish (P1)

## Classification: Campaign (code-only scope)
**Issue:** https://github.com/Attalis-Capital/RoVatar/issues/5
**Source:** Game Feedback + Adjusted Work documents
**Items:** 19 total — 12 code-only, 7 Studio-dependent (flagged, not in scope)

## Persona
Game designer at Valve. Standard: if Alexander opens every menu tonight, can he buy items, see player names overhead, and never encounter a broken button or confusing label? If any button lies or any purchase fails — the UI fails.

---

## Sub-Sprint 6a — Quick UI Fixes (Size: S-M, ~1 session)
**Branch:** `sprint-6a-ui-quick-fixes`

### S6a.1 — ShopGui purchase bug: `>` to `>=` (Size: S)
**Issue item:** Shop purchase bug — grey button when player has exact gold amount
**File:** `StarterPlayer/StarterPlayerScripts/Game/Components/GUIs/HomeScreens/ShopGui.lua`
**Change:** Line 199: change `saving > itemData.Price` to `saving >= itemData.Price`
**Acceptance:** Player with exactly 2000 Gold sees green Buy button for Glider (Price=2000).

### S6a.2 — Remove GamePass level gates (Size: S)
**Issue item:** Gamepass level requirement — if bought via store page, should work immediately
**File:** `StarterPlayer/StarterPlayerScripts/Game/Components/GUIs/HomeScreens/GamePassGui.lua`
**Change:** Lines 140-149: Remove the `RequiredLevel` check and Shadow overlay. Always allow purchase if not already owned.
**Acceptance:** All GamePasses purchasable regardless of player level. Shadow overlay never shown.

### S6a.3 — Save-name whitespace trim + validation messages (Size: S)
**Issue items:** Game save name character limit + name validation messages
**Files:**
- `StarterPlayer/StarterPlayerScripts/Game/Components/GUIs/LoadGameGui.lua` — trim whitespace in `textBoxFocusLost`
- `ReplicatedStorage/Modules/Custom/CommonFunctions/Utils/Player/PlayerData.lua` — trim in `ValidateSlotName()`
**Changes:**
1. Trim name with `slotName:gsub("^%s+", ""):gsub("%s+$", "")` before validation
2. Verify validation error messages display consistently (check notification path)
**Acceptance:** Leading/trailing spaces stripped. Names like "  ab  " rejected as too short (4 char min after trim).

### S6a.4 — SettingsGui: fix inverted toggle colour (Size: S)
**File:** `StarterPlayer/StarterPlayerScripts/Game/Components/GUIs/HomeScreens/SettingsGui.lua`
**Change:** Line 63: `ToggleBtn` has inverted BackgroundColor3 when `enable` is explicitly passed — `enable and OffColor or OnColor` should be `enable and OnColor or OffColor`
**Acceptance:** Toggle buttons show correct colour: green=ON, red=OFF.

---

## Sub-Sprint 6b — Player Overheads + Welcome Back (Size: M, ~1 session)
**Branch:** `sprint-6b-overheads-welcome`

### S6b.1 — Player overhead BillboardGui: DisplayName + Level (Size: M)
**Issue items:** Player overheads — add DisplayName + Level above each player
**New file:** `ServerScriptService/Server/Services/Player/OverheadService.lua` (Knit service)
**Pattern:** Follow `HitFeedback.lua` BillboardGui creation pattern
**Design:**
- On `Players.PlayerAdded` + `CharacterAdded`: create BillboardGui on character's Head
  - Top line: `player.DisplayName` (white, bold, size ~16)
  - Bottom line: save-slot name from player data (lighter colour, size ~12)
  - Level badge: "Lv. {X}" (from `player.Progression.LEVEL.Value`)
- Update level display on `Progression.LEVEL.Changed`
- Support visibility toggle via `player:GetAttribute("HideOverheads")`
- Clean up on `CharacterRemoving`
**Acceptance:** Every player has DisplayName + save-slot name + level visible above head. Updates on level-up. Reappears on respawn.

### S6b.2 — Toggle overheads in SettingsGui (Size: S)
**Issue item:** Toggle overheads in settings
**File:** `StarterPlayer/StarterPlayerScripts/Game/Components/GUIs/HomeScreens/SettingsGui.lua`
**Changes:**
1. Add `Overhead` toggle to SettingData (default: true)
2. Wire toggle to set local player attribute `HideOverheads`
3. On attribute change, iterate all characters and toggle BillboardGui visibility
4. Persist to `AllProfiles[ActiveProfile].Data.Settings.Overhead`
**Acceptance:** Toggle hides/shows all player name tags client-side. Persists across sessions.

### S6b.3 — Welcome-back message for returning players (Size: S)
**Issue item:** "Hello [User]! Welcome back to [Location]" (not during first tutorial)
**File:** `StarterPlayer/StarterPlayerScripts/Game/Components/GUIs/DialogueGui.lua`
**Change:** In `Welcome()` (~line 281): detect returning player via profile data (Level > 1 or quests completed). Show "Welcome back to" instead of "Welcome to" for returning players.
**Acceptance:** Players with progress see "Welcome back". New players (Level 1, no quests) see "Welcome to". Tutorial flow unaffected.

---

## Sub-Sprint 6c — Menu Restructure (Size: M, ~1 session)
**Branch:** `sprint-6c-menu-restructure`

### S6c.1 — Button consolidation: merge Store into Gamepasses (Size: M)
**Issue item:** Merge Store into Gamepasses button. 4 left buttons: Settings, Quests, Map, Gamepasses. Add Shop button to top area.
**File:** `StarterPlayer/StarterPlayerScripts/Game/Components/GUIs/HomeScreens/MainMenuGui.lua`
**Changes:**
1. Remove separate "Store" button from left sidebar
2. Reorder remaining buttons: Settings, Quests, Map, Gamepasses
3. Make GamePassGui include StoreGui Robux items (tabs or sections)
4. Add "Shop" button to top HUD area that opens ShopGui
5. Update `includeList` to reflect new button set
**Acceptance:** Left sidebar has exactly 4 buttons. GamePasses screen shows both passes and Robux items. Shop accessible from top area. No orphaned screens.

### S6c.2 — Investigate unknown top-right UI button (Size: S)
**Issue item:** Unknown UI button (top right) — identify and fix or remove
**Action:** Search all GUI components for top-right positioned elements. Identify function. If dead stub, hide it. If functional, label it.
**Acceptance:** No unidentified buttons visible in top-right during gameplay.

### S6c.3 — Collapsible panel: tween + feedback (Size: S)
**Issue item:** Add arrow to hide/show left button group
**File:** `StarterPlayer/StarterPlayerScripts/Game/Components/GUIs/HomeScreens/MainMenuGui.lua`
**Changes:**
1. Add hover/click tween to ToggleBtn (currently missing)
2. Smooth rotation tween on arrow icon (replace instant Rotation flip)
3. Keep existing staggered button show/hide behaviour
**Acceptance:** Arrow has visual press feedback. Rotation animates smoothly (~0.2s tween).

---

## Studio-Dependent Items (OUT OF SCOPE — manual follow-up)

| # | Item | Why Studio |
|---|------|-----------|
| 1 | Loading screen camera on temples + progress bar | Camera targets need scene setup; progress bar UI element must exist in ScreenGui |
| 2 | Character selection label + missing anims 3-5 | Animation assets need upload in Studio |
| 3 | Character customization (skin colour + face) | New UI panels needed in ScreenGui hierarchy |
| 6 | Store UI editable module + 2x gems gamepass | New GamePass creation in Roblox dashboard |
| 13 | Profile UI restructure (Gold/Gems next to XP) | UI element repositioning in place file |
| 14 | Delay bars centre at top | Frame position change in place file |
| 18 | Glider animation mismatch (orange to blue) | Animation asset transfer in Studio |

---

## Constraints
- No edits to `ReplicatedStorage/Packages/` or `ReplicatedStorage/Replica/`
- All prices/thresholds from `Constants.lua` — no hardcoded values
- Server validates all client requests
- Max 300 lines per new file
- Australian English in user-facing strings
- Run `scripts/verify.sh` before every commit

## Stop Conditions
- All 12 code-only items implemented and verified
- `scripts/verify.sh` passes clean
- No new shared mutable module-level state introduced
- No regressions in existing UI components

## Verification
- ShopGui: player with exact gold sees green Buy button and can purchase
- GamePassGui: no level shadow overlay on any pass
- Save name: whitespace-only names rejected, trimmed names validated correctly
- Overheads: visible on all players, update on level-up, toggle works in settings
- Welcome: returning players see "Welcome back", new players see "Welcome to"
- Menu: 4 left buttons, Shop accessible from top HUD, no orphaned screens
- Collapsible: arrow animates smoothly, press feedback present

## Execution Order
1. **Sub-sprint 6a** (quick fixes) — highest bang-per-line, unblocks playtesting
2. **Sub-sprint 6b** (overheads + welcome) — new player-visible system
3. **Sub-sprint 6c** (menu restructure) — largest UI change, benefits from 6a/6b stability
