# /repo-fetch

Clone or pull a GitHub repository into the local working directory.

## Arguments

$ARGUMENTS

Expected format: `owner/repo` or just `repo` (defaults to Attalis-Capital org).
Optional: append a path to fetch only a subdirectory via sparse checkout.
Optional: append `--shallow` for depth-1 clone (faster, no history).

## Known repos

| Short name | Full path |
|---|---|
| ic-memo | Attalis-Capital/Ic-memo |
| skills | Attalis-Capital/skills |
| golf-app | Attalis-Capital/Golf-app |
| kinder | Attalis-Capital/kinder-australia |
| vision | Attalis-Capital/vision-intelligence |
| memory | shinny77/claude-memory |
| lbo | Attalis-Capital/lbo-model-builder |
| cfo | shinny77/cfo-recruiter-agent |
| jarvis | Attalis-Capital/jarvis-web-app |
| brain | Attalis-Capital/Attalis-brain |
| design | Attalis-Capital/design-system |
| nbio | Attalis-Capital/nbio-app |

If the user provides a short name, resolve it from this table.

## Workflow

1. **Check auth** - Run `gh auth status`. If not authenticated, run `gh auth login` and wait for user

2. **Check if repo already cloned locally** - If the directory exists and has a `.git` folder, pull instead of clone:
   ```
   cd {repo-dir} && git pull origin main
   ```

3. **Clone** - If not already local:
   ```
   git clone https://github.com/{owner}/{repo}.git
   ```
   If `--shallow` flag: `git clone --depth 1 https://github.com/{owner}/{repo}.git`

4. **Subdirectory fetch** - If a specific path was requested, use sparse checkout:
   ```
   git clone --filter=blob:none --sparse https://github.com/{owner}/{repo}.git
   cd {repo}
   git sparse-checkout set {path}
   ```

5. **Report** - Print summary: directory location, file count, branch, latest commit

## Rules

- Never use the GitHub REST API or curl - use native git commands only
- Never hardcode PATs in commands
- If clone fails for auth, prompt user to run `gh auth login`
- For repos with >500 files, mention `--shallow` option if not already used
- Read CLAUDE.md after clone to load project context
