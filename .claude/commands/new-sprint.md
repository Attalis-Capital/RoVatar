---
description: Propose the next sub-sprint — read state, plan tasks, wait for approval
allowed-tools: Read, Glob, Grep, Bash(git log*), Bash(git status*), Bash(git branch*)
---

Read PROGRESS.md, CLAUDE.md, and MISSION.md (if exists).

1. Identify current sub-sprint and carry forward incomplete tasks
2. Check GitHub issues for the next sprint in order (see CLAUDE.md Sprint order)
3. Select next 3-5 tasks
4. For each task:
   - Task ID: S{n}.{t}
   - One-line description
   - Files to create/modify
   - Acceptance criteria (testable)
   - Size: S/M/L
5. Propose branch name: `sprint-{N}{letter}-{description}`

Do NOT create or modify any files. Wait for "go" before executing.
