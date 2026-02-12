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
# Try gh CLI first (most reliable on local machines), fall back to git credential helper
GITHUB_TOKEN=$(gh auth token 2>/dev/null || printf 'protocol=https\nhost=github.com\n' | git credential fill 2>/dev/null | grep '^password=' | cut -d= -f2 || echo '')
if [ -n "$GITHUB_TOKEN" ]; then
  PYTHON_CMD=$(command -v python3 2>/dev/null || command -v python 2>/dev/null || echo '')
  if [ -n "$PYTHON_CMD" ]; then
    curl -sf -H "Authorization: token $GITHUB_TOKEN" \
      "https://api.github.com/repos/Attalis-Capital/project-template/contents/LEARNED.md?ref=main" | \
      $PYTHON_CMD -c "import sys,json,base64; d=json.load(sys.stdin); print(base64.b64decode(d['content']).decode())" 2>/dev/null || echo "Could not fetch LEARNED.md -- continuing without shared rules"
  else
    echo "No Python available -- skipping shared rules"
  fi
else
  echo "No GitHub auth available -- skipping shared rules"
fi
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
