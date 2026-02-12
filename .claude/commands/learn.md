---
description: Extract lessons from recent work — repo-specific and universal
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git log*), Bash(git diff*), Bash(git add*), Bash(git commit*), Bash(git push*)
---

## Pre-computed context

Recent commits:
```bash
git log --oneline -20 2>/dev/null || echo "no commits"
```

Recent diff summary (last 5 commits):
```bash
git diff --stat HEAD~5..HEAD 2>/dev/null || echo "no diff available"
```

## Extract lessons
You already have commit history above — do not re-run git log.

Read the current Gotchas section of CLAUDE.md.

For each new lesson from the pre-computed commits, classify into exactly one tier:

### Tier 1: Repo-specific
Lessons that only matter in this repo (specific APIs, file structures, domain logic).
- Check it is not already in Gotchas
- Append to the Gotchas section in CLAUDE.md
- Format: `- {one-line rule}`

### Tier 2: Universal candidate
Lessons that would help in ANY Attalis-Capital repo (auth patterns, workflow conventions, Python/git gotchas, testing patterns).
- Format: `- YYYY-MM-DD | category | {one-line rule}`
- Categories: auth, api, testing, git, python, workflow

These get pushed directly to project-template/LEARNED.md so all repos see them on next `/start`.

### Classification test
Ask: "Would this lesson prevent a mistake in a completely different repo?"
- Yes -> Tier 2
- No -> Tier 1
- Unsure -> Tier 1 (conservative)

## After classification

### Commit Tier 1 changes
If any Tier 1 lessons added:
1. `git add CLAUDE.md`
2. Commit: `learn: extract lessons from sprint`

### Push Tier 2 to project-template
If any Tier 2 lessons identified:
1. Fetch the current LEARNED.md from project-template:
```bash
GITHUB_TOKEN=$(gh auth token 2>/dev/null || printf 'protocol=https\nhost=github.com\n' | git credential fill 2>/dev/null | grep '^password=' | cut -d= -f2 || echo '')
```

2. Read the current content via GitHub API:
```bash
PYTHON_CMD=$(command -v python3 2>/dev/null || command -v python 2>/dev/null)
curl -sf -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/Attalis-Capital/project-template/contents/LEARNED.md?ref=main" > "${TEMP:-/tmp}/learned_response.json"
```

3. Extract the current SHA and content:
```bash
LEARNED_SHA=$($PYTHON_CMD -c "import json; d=json.load(open('${TEMP:-/tmp}/learned_response.json')); print(d['sha'])")
CURRENT_CONTENT=$($PYTHON_CMD -c "import json,base64; d=json.load(open('${TEMP:-/tmp}/learned_response.json')); print(base64.b64decode(d['content']).decode())")
```

4. Append the new Tier 2 rules to the content

5. Push the updated file via GitHub API:
```bash
NEW_CONTENT_B64=$(echo "$UPDATED_CONTENT" | $PYTHON_CMD -c "import sys,base64; print(base64.b64encode(sys.stdin.buffer.read()).decode())")
curl -sf -X PUT -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"message\":\"learn: add cross-repo rules from $(basename $(pwd))\",\"content\":\"$NEW_CONTENT_B64\",\"sha\":\"$LEARNED_SHA\"}" \
  "https://api.github.com/repos/Attalis-Capital/project-template/contents/LEARNED.md"
```

6. If the push succeeds, report: "Tier 2 rules pushed to project-template/LEARNED.md"
7. If the push fails (no auth, conflict), fall back to writing to `.claude/cross-repo-candidates.md` and report: "Could not push to project-template -- saved locally in .claude/cross-repo-candidates.md for manual review"

### Dedup check
Before appending Tier 2 rules, check the existing LEARNED.md content for duplicates. Compare the lesson text (ignoring date). Skip any rule that already exists.

### Curate check
If LEARNED.md exceeds 50 entries after adding new rules, warn: "LEARNED.md has {N} entries -- consider curating to keep under 50."

If nothing new: say "No new lessons" and stop.
