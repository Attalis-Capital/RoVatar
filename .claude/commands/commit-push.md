# /commit-push

Commit and push changed files to GitHub.

## Arguments

$ARGUMENTS

If no arguments provided, commit all changed files in the current working directory.
If arguments provided, treat as the commit message.

## Workflow

1. **Check auth** - Run `gh auth status`. If not authenticated, run `gh auth login` and wait for user

2. **Stage changes** - Run `git status` to show what changed. Stage all modified/new files:
   ```
   git add -A
   ```

3. **Generate commit message** - Use conventional commits format:
   - `feat:` new feature or capability
   - `fix:` bug fix
   - `refactor:` code restructure, no behaviour change
   - `docs:` documentation only
   - `chore:` maintenance, config, dependencies
   - `test:` adding or updating tests
   - Keep subject line under 72 characters
   - If the user provided a message in $ARGUMENTS, use that instead

4. **Commit and push**:
   ```
   git commit -m "{message}"
   git push origin main
   ```

5. **Report** - Print summary: files pushed, commit SHA, commit message

## Rules

- Default branch is `main` unless CLAUDE.md says otherwise
- If push fails due to divergence, run `git pull --rebase origin main` then retry
- If push fails for auth, prompt user to run `gh auth login`
- Never use the GitHub REST API or curl - use native git commands only
- Never hardcode PATs in commands
