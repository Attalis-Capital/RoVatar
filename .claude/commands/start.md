---
description: Session start protocol — run this at the beginning of every session
allowed-tools: Read, Glob, Grep, Bash(git log*), Bash(git status*), Bash(git branch*), Bash(curl*)
---

## Pre-computed context

Git status:
```bash
git status --short 2>/dev/null || echo "not a git repo"
```

Current branch:
```bash
git branch --show-current 2>/dev/null || echo "unknown"
```

Last 5 commits:
```bash
git log --oneline -5 2>/dev/null || echo "no commits"
```

## Step 1: Local context
Read CLAUDE.md and PROGRESS.md. You already have git state above — do not re-run those commands.

## Step 2: Shared memory
Fetch the cross-repo learned rules from project-template:

```bash
curl -s -H "Authorization: token $(grep -s 'github_pat' .env 2>/dev/null || echo '')" \
  "https://api.github.com/repos/Attalis-Capital/project-template/contents/LEARNED.md?ref=main" | \
  python3 -c "import sys,json,base64; d=json.load(sys.stdin); print(base64.b64decode(d['content']).decode()) if 'content' in d else print('LEARNED.md not found -- skipping')"
```

If the fetch fails (no network, no token), skip silently and continue. Do NOT block session start.

Read the fetched rules. Note any that are relevant to this repo's domain. Do NOT copy them into CLAUDE.md — just hold them in context for this session.

## Step 3: Report
Report concisely:
1. Current sprint and status
2. Tasks done vs remaining
3. Git status (from pre-computed above)
4. Last 3 commits (from pre-computed above)
5. The ONE next action from PROGRESS.md
6. If any shared rules are especially relevant to the next task, mention them

Remind: "Enter Plan mode (Shift+Tab twice) before starting work."

Do NOT write any code or modify any files. Wait for instruction.
