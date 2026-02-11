---
description: Run the full verification suite — lint, format, tests
allowed-tools: Bash(ruff*), Bash(pytest*), Bash(bash scripts/verify.sh*), Bash(npm*)
---

## Pre-computed context

Project type detection:
```bash
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then echo "python"; elif [ -f "package.json" ]; then echo "node"; else echo "unknown"; fi
```

Source files changed since last commit:
```bash
git diff --name-only HEAD 2>/dev/null || echo "no changes"
```

## Run verification

If a `scripts/verify.sh` exists, run it and report results.

Otherwise, run sequentially based on project type. Stop on first failure:

### Python
1. `ruff check src/ tests/ 2>/dev/null || ruff check . --exclude node_modules`
2. `ruff format --check src/ tests/ 2>/dev/null || ruff format --check . --exclude node_modules`
3. `pytest -q 2>/dev/null || echo "no tests configured"`

### Node
1. `npm run lint 2>/dev/null || echo "no lint script"`
2. `npm test 2>/dev/null || echo "no test script"`

## Report
Summary: all passed, or what failed with output. Keep under 10 lines unless there are failures.
