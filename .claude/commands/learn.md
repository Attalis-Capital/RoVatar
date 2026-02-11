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
- Append to `.claude/cross-repo-candidates.md` (create if missing)
- Format: `- YYYY-MM-DD | category | {one-line rule}`
- Categories: auth, api, testing, git, python, workflow
- Do NOT push these to project-template — they await human review

### Classification test
Ask: "Would this lesson prevent a mistake in a completely different repo?"
- Yes -> Tier 2
- No -> Tier 1
- Unsure -> Tier 1 (conservative)

## After classification
If any changes made:
1. `git add CLAUDE.md .claude/cross-repo-candidates.md`
2. Commit as `learn: extract lessons from recent work`

If Tier 2 candidates were added, end with:
> New cross-repo candidates added. Review with: "review cross-repo candidates" in claude.ai chat.

If nothing new: say "No new lessons" and stop.
