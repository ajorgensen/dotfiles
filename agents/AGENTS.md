# Personal Conventions

- Use ASD-STE100 Simplified Technical English as a writing guide, not as a strict conformance requirement.
- Apply it most strongly to explanations, instructions, summaries, and documentation: use clear, direct, consistent language and short sentences where practical.
- Prefer technical accuracy and natural phrasing when they conflict with ASD-STE100. Preserve exact identifiers, commands, API terms, error messages, quotations, and established project terminology.
- Make the change easy, then make the easy change
- Pull request titles where applicable should be of the form "[<scope>] <description>". Prefer a scope that describes the logical change or subsystem. If there is no clear scope, or the change is broad, the scope can be omitted
- Branch names should be `aj/<type>/<short description>`
- Do not commit or push code without explicit sign off and permission
- Do not force push unless I give you permission to

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
- Launch subagents with fresh context by default. Use forked parent-session context only when the user explicitly requests it.

# Preferred Code Style

Prefer flat, guard-clause-driven, fail-fast procedural code ("line of sight" style: the happy path hugs the left margin).

- Check invariants and preconditions first and fail fast, so the rest of the function can assume a valid state. Do not bury validity checks inside nested branches.
- Keep the happy path at minimal indentation. Prefer early returns over `else` ladders and accumulating nesting.
- Handle errors as values and return them immediately at each step; do not collect them or build try/catch pyramids.
- Structure construction as validate-then-construct: run all guards first, then build the result once at the end. Avoid partially constructing a value and patching it up along the way.
- Prefer a simple flat function over polymorphism or extra abstraction when the branch count is small and readable.

# Deleting Code

Deleted code is debugged code. Do not be afraid to delete code when it makes the codebase more maintainable, understandable, or correct — removal is often the highest-value change you can make.

- Treat deletion as a first-class outcome of a task, not a risk to avoid. If the best fix is removing code, remove it; do not leave it in place just to be safe.
- When a change makes code unreachable or obsolete, delete it in the same change: dead branches, unused functions and parameters, stale feature flags, orphaned tests, config for things that no longer exist.
- Delete, don't disable. Do not comment code out, rename it to `_old`/`_unused`, or guard it behind a permanently-false condition. Version control is the archive; the working tree should only contain live code.
- Prefer deleting a bad abstraction over extending it. If an indirection layer, helper, or option exists "just in case" and has no real callers or second use, inline or remove it.
- Before deleting, do the cheap verification: search for references (`rg`), check tests, and confirm the code isn't reached via reflection, dynamic dispatch, serialization, or external callers (public APIs, scripts, CI). State what you checked.
- Deletion still follows the normal rules: keep it incremental, run the smallest relevant validation, and call out removals explicitly in your summary so they're easy to review.
- If you find dead or redundant code adjacent to your task but removing it would balloon the diff, note it as a follow-up instead of silently leaving it forever.

# Code Comments

Comments are for the next reader of the code, not for the person reviewing your change. Do not write comments that justify your implementation choices to me — "this is low-volume so plain reads are fine", "a single Save commits atomically", "this is simpler than X". That reasoning belongs in the conversation, the commit body, or the PR description, where it has an audience and a shelf life.

- Before writing a comment, ask: does this state a constraint or non-obvious fact the code cannot express, or is it defending a decision? Defenses go in the commit/PR; delete them from the code.
- Signs a comment is a justification, not documentation: it compares to an approach not taken, argues about performance or volume without a measurement, explains why the code is "safe" or "fine", or would only make sense to someone who watched the change happen.
- Narrating procedural steps ("read the current state", "build the mutations", "commit everything") is acceptable only sparingly in long procedural functions; keep them to a few words, and never let a step label grow into a rationale.
- Good comments capture: invariants, ordering requirements, protocol/format quirks, why an obvious-looking alternative is actually wrong, and links to external context. If none of those apply, write no comment.

# Preserve User Changes

If something you previously wrote looks changed, reverted, or deleted, leave it alone — the user did that on purpose.

- At the start of every turn, re-read affected files and inspect the current diff before editing.
- Treat changes made since your last turn as user-owned and intentional.
- Never restore code that is absent from the current working tree merely because you wrote it earlier.
- When a user modification breaks a test, update the test or dependent code to match the user's new behavior. If intent is ambiguous, ask before changing it.
- Do not use `git restore`, `git checkout`, `git reset`, or stash-based recovery on user-modified files without explicit permission.

# Memory

Persistent notes live in `.docs/` at the repository root. Create the directory and files when they don't exist — an empty repo is not a reason to skip this.

The files:

- `MEMORY.md`: Stable project knowledge. Architecture notes, repo-specific workflows, important commands, known constraints, naming conventions, recurring gotchas, and decisions that future work should preserve.
- `PROMPT.md`: The current engagement context. The user's goal, constraints, acceptance criteria, open questions, and any important wording or intent that should not be lost across longer tasks.
- `PLAN.md`: The working implementation plan. Approach, milestones, files likely to change, validation strategy, tradeoffs, and decisions made while executing.
- `TODO.md`: The actionable task list. Concrete next steps, task status, blockers, follow-ups, and handoff items so work can resume cleanly.

Reading — do this by default, not opportunistically:

- At the start of a coding task, before exploring the repo yourself, check for `.docs/` and read `MEMORY.md` and `TODO.md` if present.
- When resuming or continuing multi-step work, also read `PLAN.md` and `PROMPT.md`.

Writing — these events are triggers, act on them when they happen:

- You discovered something by trial and error (a build/test/run command, a gotcha, a non-obvious constraint or convention) → add it to `MEMORY.md`.
- You made or revised a multi-step plan → keep `PLAN.md` current as you execute.
- The user stated goals or constraints that must survive a long task → capture them in `PROMPT.md`.
- You are ending a turn with unfinished steps, blockers, or follow-ups → update `TODO.md`.
- At the end of any multi-step task, spend one step on upkeep: record new durable facts and delete notes that no longer reflect reality.

Keep entries short — a few accurate lines beat a verbose log. When in doubt about whether something is worth recording, record it; stale-note cleanup is cheaper than rediscovery.

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

