# /review-workflow

End-to-end workflow sanity checker. Audits any workflow, pipeline, or process from three lenses: technical correctness, expert cognitive fidelity, and user experience.

## Arguments

$ARGUMENTS

If no arguments: review the workflow built in the current sprint (read PROGRESS.md to identify it).
If argument is a file path: review the workflow described in that file.
If argument is a description: review that workflow directly.

## When to run

- After completing a sprint's build tasks, before `/commit-push`
- When a workflow has grown incrementally and needs a coherent end-to-end check
- When you're unsure if the thing you've built actually makes sense as a whole
- Before handoff to another developer or to production

## Workflow

### 1. Reconstruct

Identify the workflow under review:
- If in a sprint: read PROGRESS.md, identify completed tasks, reconstruct the workflow from code and config files
- If a file is specified: read it
- If described inline: use the description

Produce a **numbered step list** of the workflow. Print it and confirm with the user before proceeding.

### 2. Lens 1 — Technical correctness

Walk each step and check:
- Does data flow correctly from the prior step? Are inputs available when needed?
- What happens if this step fails? Is there error handling, a fallback, or a silent break?
- Race conditions, ordering dependencies, state mutations that could corrupt?
- Implicit assumptions (eg "this API always returns in <2s", "user has already authenticated")?
- Unnecessary duplication, redundant steps, dead paths?
- External dependencies (APIs, services, human approvals) identified and bounded?

Output a markdown table:

| Step | Issue | Severity | Detail |
|------|-------|----------|--------|

Severity: Critical / Warning / Info

### 3. Lens 2 — Expert cognitive fidelity

Step back from mechanics. Imagine a domain expert doing this task manually. Check:
- Would an expert do these steps in this order?
- Are there steps the system forces that an expert would skip or combine?
- Does the workflow miss a step an expert would consider essential?
- Does it assume linear execution when an expert would iterate or branch?
- Would an expert trust the output, or feel compelled to manually verify?

Output as narrative paragraphs, not a table. Cognitive issues are nuanced.

### 4. Lens 3 — User experience

Assume a real user — possibly time-poor, distracted, not an expert. Check:
- Where will the user get confused about what to do next?
- Where does effort exceed perceived value?
- Context-switching points?
- Adequate feedback at each step?
- Where might the user abandon, and what's lost?
- Error messages actionable or opaque?

Output a markdown table:

| Friction point | Step | Impact | Suggested fix |
|---------------|------|--------|---------------|

Impact: High / Medium / Low

### 5. Prioritised fix list

Combine all three lenses into one list, ordered:
1. Critical blockers — breaks the workflow or causes data loss
2. Trust eroders — makes experts or users doubt the system
3. Friction reducers — makes the workflow faster or more pleasant
4. Design debt — fine now, problems at scale

For each: issue (one sentence), which lens, suggested fix, effort (Quick / Medium / Significant).

### 6. Verdict

One of:
- **Ship as-is** — no critical issues
- **Ship with caveats** — works but has known gaps (list them)
- **Rework required** — critical issues, list minimum viable fixes
- **Rethink** — fundamental approach has problems, suggest alternative

## Context adaptations

- Code pipeline: emphasise error handling, idempotency, observability
- Human process: emphasise cognitive load, handoff clarity, accountability
- Hybrid (human + system): emphasise the seams — that's where failures live

## Rules

- Find at least one real improvement — every workflow has one
- Do not invent phantom issues to appear thorough
- Do not rewrite the workflow unprompted — suggest fixes, let the user decide scope
- Start with "does the overall approach make sense?" before step-level issues
- If the workflow is genuinely sound, say so briefly and move on
