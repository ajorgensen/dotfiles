# Personal Conventions

- Make the change easy, then make the easy change
- Pull request titles where applicable should be of the form "[<scope>] <description>". Prefer a scope that describes the logical change or subsystem. If there is no clear scope, or the change is broad, the scope can be omitted
- Branch names should be `aj/<type>/<short description>`

# Global Coding Rules

- Read relevant files before editing.
- Prefer precise edits over broad rewrites unless requested.
- Preserve existing style and patterns unless changing them is part of the task.
- After code changes, run the smallest relevant validation available.
- Summarize what changed and list touched files.
- Do not install dependencies or run destructive shell commands (e.g. `rm -rf` outside the repo, dropping data) unless asked. Deleting code or files *within the repo* as part of the task is normal, expected work — see "Deleting Code".
- For searches, prefer rg/find over slower shell pipelines.
- If requirements are unclear, ask a targeted question or state the assumption.
- For multi-step work, keep changes incremental and verifiable.
- Use subagents for recon, planning, and review when that will improve quality or reduce context load.

# Deleting Code

Deleted code is debugged code. Do not be afraid to delete code when it makes the codebase more maintainable, understandable, or correct — removal is often the highest-value change you can make.

- Treat deletion as a first-class outcome of a task, not a risk to avoid. If the best fix is removing code, remove it; do not leave it in place just to be safe.
- When a change makes code unreachable or obsolete, delete it in the same change: dead branches, unused functions and parameters, stale feature flags, orphaned tests, config for things that no longer exist.
- Delete, don't disable. Do not comment code out, rename it to `_old`/`_unused`, or guard it behind a permanently-false condition. Version control is the archive; the working tree should only contain live code.
- Prefer deleting a bad abstraction over extending it. If an indirection layer, helper, or option exists "just in case" and has no real callers or second use, inline or remove it.
- Before deleting, do the cheap verification: search for references (`rg`), check tests, and confirm the code isn't reached via reflection, dynamic dispatch, serialization, or external callers (public APIs, scripts, CI). State what you checked.
- Deletion still follows the normal rules: keep it incremental, run the smallest relevant validation, and call out removals explicitly in your summary so they're easy to review.
- If you find dead or redundant code adjacent to your task but removing it would balloon the diff, note it as a follow-up instead of silently leaving it forever.

# Memory

You have access to a `.docs` directory you can use to persist context that may help later turns or future agents. Prefer short, durable notes over verbose logs, and only record information that is likely to stay useful beyond the current reply. Here are some of the documents you may find there:

- `MEMORY.md`: Stable project knowledge. Capture architecture notes, repo-specific workflows, important commands, known constraints, naming conventions, recurring gotchas, and decisions that future work should preserve.
- `PROMPT.md`: The current engagement context. Capture the user's goal, constraints, acceptance criteria, open questions, and any important wording or intent that should not be lost across longer tasks.
- `PLAN.md`: The working implementation plan. Capture the approach, milestones, files likely to change, validation strategy, tradeoffs, and decisions made while executing.
- `TODO.md`: The actionable task list. Capture concrete next steps, task status, blockers, follow-ups, and handoff items so work can resume cleanly.

Use these files to reduce repeated discovery, but keep them current: update or remove stale notes when they no longer reflect reality.

# Skills

Global skills are installed in the sibling `skills/` directory next to this instruction file. When a task matches a skill, read that skill's `SKILL.md` before acting.

## Git Commits

- Use scoped commit subjects: `<scope>: <description>`.

```text
<scope>: <description>

[optional body]

[optional trailer(s)]
```

- The scope should name the logical change, subsystem, area, module, tool, or package touched by the change.
- If a commit touches multiple areas, prefer the scope that best describes the logical change, not just the list of touched files. For example, use `theme: switch ghostty and nvim to dracula` when the shared purpose is theming.
- If there is no clear shared logical scope, use the best shared parent scope, list scopes separated by commas, or use a broad scope such as `treewide`.
- Reverts, merges, and other special commits may use their natural Git-generated format when that is clearer.
- The subject line should be short (~50 chars) and state what changed
- The commit body should explain **why** — what problem this solves, what motivated the change, or what decision led to this approach. Do not simply restate the diff.
- Use trailers for metadata such as issue IDs when helpful.
- For trivial changes (typos, formatting), a single-line subject is acceptable. For anything non-trivial, include a body.
- Bad example: `handler: update handler` (no context). Good example: `webhooks: prevent duplicate deliveries` with a body explaining the root cause.

