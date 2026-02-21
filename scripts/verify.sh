#!/usr/bin/env bash
# RoVatar verification suite — Luau/Roblox project checks
# Run from repo root: bash scripts/verify.sh
set -euo pipefail

FAIL=0
WARN=0

pass()  { echo "  PASS  $1"; }
fail()  { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }
warn_()  { echo "  WARN  $1"; WARN=$((WARN+1)); }

echo "=== RoVatar Verify ==="
echo ""

# --- 1. Protected directories ---
echo "[1/7] Protected directories"
if git diff --name-only HEAD -- ReplicatedStorage/Packages/ ReplicatedStorage/Replica/ 2>/dev/null | grep -q .; then
  fail "Packages/ or Replica/ modified"
else
  pass "Packages/ and Replica/ untouched"
fi

# --- 2. Costs.lua is source of truth ---
echo "[2/7] Costs.lua integrity"
if git diff --name-only HEAD -- ReplicatedStorage/Modules/Custom/Costs.lua 2>/dev/null | grep -q .; then
  warn_ "Costs.lua was modified — verify values are intentional"
else
  pass "Costs.lua untouched"
fi

# --- 3. No hardcoded damage/stamina in ability scripts ---
echo "[3/7] No hardcoded damage/stamina in abilities"
HARDCODED=$(grep -rn 'TakeDamage([0-9]' \
  ReplicatedStorage/Modules/Custom/VFXHandler/ \
  ReplicatedStorage/Assets/Models/Combat/Bendings/ \
  2>/dev/null || true)
if [ -n "$HARDCODED" ]; then
  fail "Hardcoded damage values found:"
  echo "$HARDCODED" | head -5
else
  pass "No hardcoded TakeDamage values in ability scripts"
fi

# --- 4. Max 300 lines per file (changed files only) ---
echo "[4/7] File length (max 300 lines, changed files)"
CHANGED=$(git diff --name-only HEAD 2>/dev/null | grep '\.lua$' || true)
OVER=""
for f in $CHANGED; do
  if [ -f "$f" ]; then
    LINES=$(wc -l < "$f")
    if [ "$LINES" -gt 300 ]; then
      OVER="$OVER\n  $f: $LINES lines"
    fi
  fi
done
if [ -n "$OVER" ]; then
  warn_ "Files over 300 lines (pre-existing OK, new files should be split):$(echo -e "$OVER")"
else
  pass "All changed files under 300 lines"
fi

# --- 5. No secrets or API keys ---
echo "[5/7] No secrets in changed files"
SECRETS=$(git diff HEAD 2>/dev/null | grep -iE '(api[_-]?key|secret[_-]?key|password|token)\s*=\s*["\x27][A-Za-z0-9]' || true)
if [ -n "$SECRETS" ]; then
  fail "Possible secrets in diff:"
  echo "$SECRETS" | head -5
else
  pass "No secrets detected in diff"
fi

# --- 6. Server-side validation patterns ---
echo "[6/7] SafeZone PvP guards"
ABILITIES="AirKick EarthStomp FireDropKick WaterStance Fist Boomerang MeteoriteSword"
MISSING=""
for ability in $ABILITIES; do
  FILE=$(find ReplicatedStorage/Modules/Custom/VFXHandler/ -name "${ability}.lua" 2>/dev/null | head -1)
  if [ -n "$FILE" ]; then
    if ! grep -q "InSafeZone" "$FILE" 2>/dev/null; then
      MISSING="$MISSING $ability"
    fi
  fi
done
if [ -n "$MISSING" ]; then
  fail "Missing SafeZone check in:$MISSING"
else
  pass "All 7 abilities have SafeZone PvP guards"
fi

# --- 7. Lua syntax check (basic) ---
echo "[7/7] Lua syntax (unmatched blocks in changed files)"
SYNTAX_ERR=0
for f in $CHANGED; do
  if [ -f "$f" ]; then
    # Count block openers vs closers as a rough syntax check
    OPENS=$(grep -cE '^\s*(function |if |for |while |repeat )' "$f" 2>/dev/null || echo 0)
    CLOSES=$(grep -cE '^\s*end[)\s,;]*$' "$f" 2>/dev/null || echo 0)
    # Also count inline function/end patterns (rough)
    INLINE_FN=$(grep -cE 'function\s*\(' "$f" 2>/dev/null || echo 0)
    TOTAL_OPENS=$((OPENS + INLINE_FN))
    if [ "$TOTAL_OPENS" -gt 0 ] && [ "$CLOSES" -eq 0 ]; then
      warn_ "$f: $TOTAL_OPENS block openers, 0 ends — may have syntax issues"
      SYNTAX_ERR=$((SYNTAX_ERR+1))
    fi
  fi
done
if [ "$SYNTAX_ERR" -eq 0 ]; then
  pass "No obvious syntax issues in changed files"
fi

# --- Summary ---
echo ""
echo "=== Results: $FAIL failed, $WARN warnings ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
