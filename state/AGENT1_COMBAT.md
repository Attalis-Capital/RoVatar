# Agent 1: Combat Loop Archaeologist — Findings

## SESSION-ENDING BUGS & EXPLOITS

### EXPLOIT-1: VFXHandler has no bending-type ownership check
`VFXHandler.lua:52-53` — dispatches any ability string. A FireBender can fire `CastEffect:FireServer("EarthStomp", ...)` and the server executes it. No cross-check against player's bending type.

### EXPLOIT-2: Boomerang — no server validation at all
`Boomerang.lua` — NO stamina check, NO level check, NO GamePass ownership check. Only gate is 3s cooldown. Any player can use Boomerang by firing the RemoteEvent directly.

### EXPLOIT-3: MeteoriteSword — no GamePass check, XP before SafeZone gate
`MeteoriteSword.lua:150 vs 154` — XP awarded BEFORE SafeZone return. No GamePass ownership verified server-side. No ability cooldown (only 0.3s Fist rate-limit).

### EXPLOIT-4: 5 of 7 abilities have NO SafeZone PvP check
AirKick, EarthStomp, FireDropKick, WaterStance, Fist — all deal damage inside safe zones. Only Boomerang and MeteoriteSword check (MeteoriteSword awards XP before the check).

### BUG-1: WaterStance hitbox self-destructs via race condition
`WaterStance.lua:197-200` — `wait(6); _hitBox:Destroy()` fires inside every Touched callback. Multiple touches create multiple destroy coroutines. Ability can silently stop dealing damage mid-stance.

### BUG-2: Fist/MeteoriteSword stamina goes negative
`Fist.lua:57`, `MeteoriteSword.lua:57` — stamina deducted unconditionally with no floor guard. If client check is bypassed, stamina goes negative.

### BUG-3: AirKick uses `wait(0.2)` blocking server thread
`AirKick.lua:37` — top-level `wait(0.2)` blocks the VFXHandler server event coroutine for 200ms on every AirKick.

---

## Per-Ability Verdict Table

| Ability | Server Validation | SafeZone | DamageCalc | Element XP | Verdict |
|---------|------------------|----------|------------|------------|---------|
| AirKick | Stamina+Level. No ownership. | ABSENT | Yes (player+element) | Yes (5 XP) | **FRAGILE** |
| EarthStomp | Stamina+Level+Distance(200). No ownership. | ABSENT | Yes (player+element) | Yes (6 XP) | **FRAGILE** |
| FireDropKick | Stamina+Level. No ownership. No range check. | ABSENT | Yes (player+element) | Yes (8 XP) | **FRAGILE** |
| WaterStance | Weld: Stamina+Level. RE: stamina check commented out. | ABSENT | Yes (player+element) | Yes (4 XP/hit) | **FRAGILE** |
| Fist | 0.3s rate-limit. Stamina deducted no floor. | ABSENT | Yes (player only, el=0) | None | **FRAGILE** |
| Boomerang | 3s cooldown ONLY. No stamina/level/GamePass check. | Present (attr-based) | Yes (player only, el=0) | None | **BROKEN** |
| MeteoriteSword | Stamina no floor. No GamePass/cooldown. | Present but XP before gate | Yes (player only, el=0). Hardcoded 7.1 base ignores Costs.lua. | None | **BROKEN** |

## Key Structural Issues

1. **Legacy dual combat system** — Old _S.lua scripts disabled via `if true then return end` but OnServerEvent connections still active (memory + latent risk)
2. **Hardcoded damage values** — Fist (7.1) and MeteoriteSword (7.1) base damage not from Costs.lua
3. **No hit FX for bending abilities** — Only Fist, Boomerang, MeteoriteSword call `Replicate:FireAllClients("Combat", "HitFX", ...)`. Bending abilities have no client-side hit feedback.
4. **Deprecated `spawn()`/`wait()` calls** throughout ability modules: WaterStance.lua:121, EarthStomp.lua:77,88, FireDropKick.lua:47,59,84,109, AirKick.lua:53,67, Boomerang.lua:66
5. **Client-only level checks** — Level gates commented out on client (CharacterController.lua:866,953,1048); server re-enforces them in VFXHandler modules but this is fragile documentation-wise
6. **Auto-target range not server-validated** — `GetTargetPosition()` range check (200 units) is client-only; server accepts any position
