---
description: Stage, commit with sprint format, push, update PROGRESS.md
allowed-tools: Read, Bash(git*), Edit, Write
---

## Pre-computed context

Changed files:
```bash
git status --short 2>/dev/null || echo "nothing to commit"
```

Diff summary:
```bash
git diff --stat 2>/dev/null || echo "no changes"
```

Current branch:
```bash
git branch --show-current 2>/dev/null || echo "unknown"
```

## Execute
You already have the changeset above — do not re-run git status or git diff.

1. Review the pre-computed changes
2. Stage relevant files (skip secrets, generated files, __pycache__, .env)
3. Read PROGRESS.md to infer the current sprint and task number
4. Commit as "S{sprint}.{task}: {description}"
5. `git push`
6. Update PROGRESS.md: mark task done, set next action

If nothing to commit (pre-computed shows clean), say so and stop.
