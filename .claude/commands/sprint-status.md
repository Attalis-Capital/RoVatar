---
description: Quick status check — sprint progress, tests, blockers
allowed-tools: Read, Glob, Grep, Bash(git log*), Bash(git status*), Bash(pytest --co*)
---

## Pre-computed context

Recent commits:
```bash
git log --oneline -10 2>/dev/null || echo "no commits"
```

Git status:
```bash
git status --short 2>/dev/null || echo "clean"
```

Test count:
```bash
pytest --co -q 2>/dev/null | tail -1 || echo "no tests found"
```

## Report
Read PROGRESS.md. You already have git and test data above — do not re-run those commands.

Report (under 15 lines):
1. Sprint and status
2. Tasks done / remaining
3. Test count (from pre-computed above)
4. Any blockers
5. Next action (one sentence)
