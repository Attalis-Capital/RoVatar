# Agent 5: UI & Feel Auditor — Findings

## SESSION-ENDING BUGS

### BUG-1: SettingsGui VFX and Popup toggles are non-functional
`SettingsGui.lua:139-141` — VfxToggle() only toggles button visual, no actual VFX suppression. Same for PopupToggle. Mobile players disabling VFX get zero performance benefit.
**Verdict: BROKEN**

### BUG-2: SettingsGui visible on load (Toggle commented out)
`SettingsGui.lua:204` — `self:Toggle(false)` is commented out. Flash of settings panel on session start.

### BUG-3: ShopGui off-by-one — can't buy with exact gold amount
`ShopGui.lua:199` — `saving > itemData.Price` should be `>=`. Players who grind to exact price can't purchase.

### BUG-4: 25 active print()/warn() calls fire during normal gameplay
BendingSelectionGui (5 prints per level-up), EffectsController (1 per combat event), StoreGui/ShopGui/GamePassGui (on every purchase tap), NotificationGui (every popup), CoolDownGui/MainMenuGui/SettingsGui (session start).

### BUG-5: Double SFX/VFX on ability unlock
`EffectsController.lua:113-114` — Level-up SFX+VFX replays for ability unlock instead of using distinct sounds.

---

## PLAYER CONFUSION POINTS

1. **Two overlapping quest panels** — QuestTrackerHUD (always-visible, Sprint 3) and QuestGui TaskHintDisplay (also right-side) both appear simultaneously. No coordination between them.
2. **"Store" vs "Shop"** — StoreGui (Robux) and ShopGui (Gold) have near-identical labels. Nothing communicates "this costs real money."
3. **Locked abilities show padlock but no action hint** — Level-locked bending button tap does nothing (silent failure). No tooltip explaining what to do.
4. **Ability unlock banner gives no keybind info** — "NEW ABILITY UNLOCKED — Fire Bending" but no indication which key or how to equip.
5. **BendingSelectionGui has no close button** — If no ability is selectable but GUI opens, it's stuck.
6. **Empty quest state** — QuestGui hides hint panel but leaves toggle arrow visible. Arrow reveals empty panel.
7. **Breadcrumb 3s startup delay** — No navigation aid for first 3 seconds of session.

---

## Per-Component Verdict Table

| Component | Status | Key Issue |
|-----------|--------|-----------|
| QuestGui | FRAGILE | Duplicate panel with QuestTrackerHUD; empty state leaves arrow |
| QuestTrackerHUD | FRAGILE | Overlaps QuestGui; uses `#` vs `TableLength` for progress count |
| BreadcrumbController | FRAGILE | Workspace name lookup fragile; 3s delay; no arrival feedback |
| MainMenuGui | FRAGILE | Store/GamePass split unclear; warn() on start |
| BendingSelectionGui | FRAGILE | 5 debug prints; no keybind shown; no close button |
| ShopGui (Gold) | FRAGILE | Off-by-one affordability (`>` not `>=`); warn() on purchase |
| StoreGui (Robux) | FRAGILE | warn() on purchase; dead ToggleBtn stub |
| GamePassGui | SOUND | warn() on purchase only |
| CoolDownGui | SOUND | Redundant with PlayerMenuGui inline cooldown |
| PlayerMenuGui | SOUND | No nil guard on CoolDownText |
| SettingsGui | BROKEN | VFX/Popup toggles non-functional; visible on load |
| NotificationGui | SOUND | print() every popup; scene-graph mutation hack |
| ComboCounter | SOUND | Well implemented |
| HitFeedback | SOUND | Feature-complete; unlock banner lacks keybind info |
| DamageIndication | FRAGILE | BindToAllNPCs doesn't filter player characters |

## Overall Verdict
Combat feedback (ComboCounter, HitFeedback, cooldown bars) is well-implemented. Progression celebration is present but incomplete — celebrates without instructing. Quest layer has structural duplication. Monetisation surfaces confusing. Settings has non-functional toggles. 25 debug print/warn calls in production.
