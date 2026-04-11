# Review Guidelines for [repo-name]

## Always check
- [ ] All tests pass (ruff + pytest)
- [ ] No new dependencies without justification
- [ ] API contracts preserved (no breaking changes without version bump)
- [ ] Error handling covers failure modes
- [ ] Secrets never hardcoded

## Architecture invariants
- [Repo-specific patterns that must be preserved]
- [Decisions that were made deliberately and should not be reversed]

## Style
- Australian English
- Follows conventions in CLAUDE.md
- [Repo-specific conventions beyond global CLAUDE.md]

## Known fragile areas
- [Files/functions that break easily and need extra scrutiny]
- [Integration points with external systems]
- [Data contracts that are tightly coupled]

## Skip
- Generated files (node_modules, __pycache__, .next, dist)
- Vendored dependencies
- [Legacy code explicitly frozen]

## Severity thresholds
- BLOCK: test failures, security issues, data loss risk, breaking API changes
- WARN: style violations, missing docs, suboptimal but functional code
- INFO: suggestions, nice-to-haves, refactoring opportunities
