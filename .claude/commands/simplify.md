---
description: Simplify code after a task — strip unnecessary complexity
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git diff*), Bash(git log*), Bash(ruff*)
---

## Pre-computed context

Files changed in last commit:
```bash
git diff --name-only HEAD~1..HEAD 2>/dev/null || echo "no previous commit"
```

Diff of last commit:
```bash
git diff HEAD~1..HEAD --stat 2>/dev/null || echo "no diff"
```

## Review and simplify

Look at the files changed above. For each file, check for:

1. **Dead code** — unused imports, unreachable branches, commented-out blocks
2. **Over-abstraction** — classes that should be functions, factories that build one thing, wrappers that add nothing
3. **Unnecessary complexity** — nested ternaries, deep callback chains, over-complicated conditionals that could be early returns
4. **Duplication** — copy-pasted blocks that should be extracted
5. **Verbose patterns** — 10 lines that could be 3 without losing clarity

## Rules
- Do NOT change functionality or behaviour
- Do NOT rename public APIs or change signatures
- Do NOT refactor beyond the files in the last commit
- Prefer fewer files, fewer lines, fewer abstractions
- If the code is already clean, say "Nothing to simplify" and stop

## After changes
Run linter to confirm nothing broke:
```bash
ruff check --fix $(git diff --name-only HEAD~1..HEAD) 2>/dev/null || true
```

If changes made, stage and commit as `simplify: reduce complexity in {files}`
