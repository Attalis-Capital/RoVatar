# Sprint 1 - Studio Setup Tasks

These tasks require Roblox Studio and cannot be done via code alone.
Complete these after merging the sprint-1 branch.

## REQUIRED for SafeZone to work

### 1. Create SafeZone Part at spawn
- In workspace, create a **Part** covering the entire spawn/hub area
- Name it `SafeZone`
- Properties:
  - Anchored = true
  - CanCollide = false
  - Transparency = 1
  - Size = large enough to cover spawn + immediate surroundings
- Tag it `SafeZone` via CollectionService (or the Tag Editor plugin)
- SpawnProtectionService will detect it automatically

## REQUIRED for enemy spawn fix

### 2. Move enemy spawn points away from starter area
- In workspace, find enemy NPCs near the spawn/hub area
- Move their spawn positions or patrol paths at least 100 studs from spawn
- Alternatively, add a `SafeZone` check to NPCAI.lua so enemies don't aggro
  players inside the safe zone (future sprint can handle this in code)

## RECOMMENDED for tutorial text

### 3. Increase dialogue text size
- In StarterGui > DialogueGui > BaseFrame > Container > DialogueFrame > Speech
- Increase TextSize from current value to at least 18-20
- Consider enabling TextScaled = true with a MaxTextSize constraint
- Also check Narrator label text size

## RECOMMENDED for loading screen

### 4. Loading screen camera
- Currently shows a static background image
- Replace with a ViewportFrame showing the game world, or
- Add a simple camera flyover script in LoadingGui.lua (Sprint 4 task)

## TESTING CHECKLIST

After merging and completing studio tasks:

- [ ] New player spawns with blue ForceField for ~8 seconds
- [ ] Another player cannot damage you while ForceField is active
- [ ] Another player cannot damage you while standing in SafeZone part
- [ ] You CAN still attack NPCs while in SafeZone (PvE allowed)
- [ ] Tutorial NPC dialogue does NOT close when you walk slightly
- [ ] Tutorial dialogue buttons still work correctly
- [ ] ForceField disappears after 8 seconds
- [ ] After leaving SafeZone, PvP works normally
