# Agent 3: Tutorial & Onboarding Auditor — Findings

## SESSION-ENDING BUGS

### BUG-1: Duplicate DialogueGui files — structural conflict
`ReplicatedFirst/DialogueGui.lua:19` and `StarterPlayer/.../DialogueGui.lua:19` — Both use same Component tag `"DialogueGui"`. Different button hierarchy assumptions (ReplicatedFirst: `btn.Button.Image`, StarterPlayer: `btn.Image`). If ReplicatedFirst wins the race, SkipAll() and click-anywhere UX are silently absent.
**Verdict: BROKEN**

### BUG-2: Death during tutorial deadlocks dialogue
`TutorialGuider.lua:38` — `_G.Talking` set true on prompt click, only cleared in dialogue finish/prompt-hidden paths. Character death triggers neither cleanup. After respawn: `_G.Talking` stuck true, `DialogueGui.InProcess` stuck true, NPC prompt stuck disabled. Player cannot re-enter dialogue without walking out of range.
**Verdict: BROKEN**

### BUG-3: Controls taught AFTER combat, not before
`Conversation.lua:34` — Tutorial[2] assigns "defeat 3 EarthBenders" kill quest immediately. `Conversation.lua:57` — Tutorial[3] teaches Q (Block), Shift (Sprint), N (Meditate) only AFTER completing the kill quest. Keys 1-6 for abilities are NEVER taught anywhere.
**Verdict: BROKEN**

### BUG-4: ToggleControls(false) at T+1s with no guaranteed restore
`CharacterController.lua:1953-1955` — All keybinds disabled 1 second after KnitStart. If external `ToggleControls(true)` call is missing or delayed, all input stays dead.
**Verdict: FRAGILE**

### BUG-5: AssignQuest nil-crash risk
`TutorialGuider.lua:61` — `_G.QuestsData` accessed with no nil guard. If data not yet replicated when player talks to NPC, line 64 throws.
**Verdict: FRAGILE**

---

## First 90 Seconds Walkthrough

| Time | Event | Verdict |
|------|-------|---------|
| T=0s | Loading screen — no game tips, no control hints | FRAGILE |
| T=5-15s | Load completes — two DialogueGui scripts race to bind | BROKEN |
| T+2s | ControlsGuideGui auto-shows — races with tutorial dialogue | FRAGILE |
| T+1s | ToggleControls(false) — all keybinds disabled | FRAGILE |
| T=5s | Player approaches NPC, sees "Talk" prompt | SOUND |
| T=10s | Click Talk — dialogue opens, commerce UIs hidden | SOUND |
| T=15s | Kill quest assigned — NO combat instructions given | BROKEN |
| T=20-60s | Player must discover combat by key-mashing | BROKEN |
| If death | _G.Talking stuck, dialogue deadlocked | BROKEN |
| T=60-90s | Quest complete — THEN teaches Q/Shift/N | BROKEN |

**Overall first 90 seconds verdict: BROKEN**

---

## Per-System Verdict

| System | Status | Key Issue |
|--------|--------|-----------|
| Loading Screen | FRAGILE | No tips, no orientation. Skip button works. |
| Duplicate DialogueGui | BROKEN | Two scripts, same tag, different button hierarchies |
| Controls Guide | FRAGILE | Races with tutorial; one-shot, no reopen path |
| Tutorial NPC Flow | BROKEN | Combat quest before combat teaching |
| Dialogue Advancement | FRAGILE | No visual "click to continue" indicator |
| SkipAll() | BROKEN | Method exists but orphaned — never wired to any button |
| UI Hiding | FRAGILE | Commerce UIs hidden; ControlsGuide/Notifications not suppressed |
| Death Recovery | BROKEN | _G.Talking stuck, prompt stuck disabled |
| Key Binding Teaching | BROKEN | Keys 1-6 never taught |
| Quest Assignment | FRAGILE | Relies on _G.QuestsData being populated; no nil guard |
| Spawn Location | UNVERIFIED | NPC exists in Tutorial area; spawn proximity unconfirmed |

---

## Key File References
- `ReplicatedFirst/DialogueGui.lua:19` — duplicate Component tag
- `StarterPlayer/.../DialogueGui.lua:181` — orphaned SkipAll() method
- `TutorialGuider.lua:38` — _G.Talking not reset on death
- `TutorialGuider.lua:60` — AssignQuest no nil guard on _G.QuestsData
- `Conversation.lua:34` — Tutorial[2] assigns kill quest immediately
- `Conversation.lua:57-82` — Tutorial[3] teaches controls post-combat
- `CharacterController.lua:1953` — ToggleControls(false) at T+1s
- `ControlsGuideGui.lua:73` — ShowOnFirstSpawn() 2s delay race
