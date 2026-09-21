I'm AJ. You're my agent. We will be working together to solve problems.

I focus on building complex things as simple as possible. I love to find ways to reduce complexity when solving problems.

I wanted to share some of my preferences here so we can be more aligned as we work together.

## Coding Preferences - General
- Make the change easy, then make the easy change
- Keep things simple. Channel YAGNI energy unless told otherwise.
- Typesafety is useful, take advantage of it
- Don't be scared to propose bold ideas if they are meaningfully beneficial to our work
- Be careful with destructive actions that are not explicitly requested by the user
- Tests are good! Endless smoke tests, "regression tests" for featur deletions, etc, much less good. Tests should be focused, not slop.
- Use ASD-STE100 Simplified Technical English as a guide, not a strict requirement, especially for explanations, instructions, summaries, and documentation. Use clear, direct language and short sentences where practical. Prioritize technical accuracy and natural phrasing; preserve exact identifiers, commands, API terms, error messages, quotations, and established project terminology.
- Keep comments up to date! When making changes, it's important to keep things in sync.
- Preserve existing style and patterns unless changing them is part of the task.
- For searches, prefer rg/find over slower shell pipelines.
- If requirements are unclear, ask a targeted question or state the assumption.
- For multi-step work, keep changes incremental and verifiable.
- Launch subagents with fresh context by default. Use forked parent-session context only when the user explicitly requests it.
- Prefer flat, guard-clause-driven code. Validate invariants and preconditions and handle errors early; keep the happy path at minimal indentation.
- Where idiomatic, handle errors as values and return them immediately at each step. Avoid deeply nested error handling.
- Structure construction as validate-then-construct: run all guards first, then build the result once at the end. Avoid partially constructing a value and patching it up along the way.
- Prefer a simple flat function over polymorphism or extra abstraction when the branch count is small and readable.

## Design and Implementation Approach
- Work outside in. Start with the caller’s use case or outermost interface, then work toward the core.
- Write the code you wish you could call. Use that caller code to shape the API, then implement what it needs.
- Define the types and data structures for each layer before adding behavior. If the behavior is difficult to express, revisit the data model before adding complexity.
- Keep this incremental. Build only the types and interfaces needed for the current use case, not a complete architecture up front.

## Language and Scenario Guidance

Read the relevant guides before working on a matching task. Load only the guides that apply.

Paths below are relative to the directory containing this instruction file (`AGENTS.md`, or `CLAUDE.md` for Claude), not the project's working directory. Shared installations keep `guidance/` in `~/.codex/`, `~/.claude/`, `~/.config/opencode/`, or `~/.pi/agent/`, respectively.

- Go: when writing, changing, or reviewing Go code, read [guidance/languages/go.md](guidance/languages/go.md).

To add a language or scenario guide, follow [guidance/README.md](guidance/README.md).

## Markdown Formatting
- Use summary lists instead of wide tables with paragraph-length cells. Prose-heavy comparisons are easier to read as bullets or short sections.
- Keep tables for compact numerical data and short, structured comparisons.

## Tests: no mirror assertions
- Avoid assertions that merely duplicate implementation details. Assert behavior and external contracts: what the function returns, how the response is parsed, and what side effects occur.
- Literal expectations are useful when they independently express a contract. For an HTTP client, test response handling and request details required by the external API. Explain non-obvious wire-format requirements in a comment.

## Questions are read-only
- Requests for advice, explanation, or assessment are read-only. Answer without editing files, even if the suggested change is trivial; offer the change and get permission first.
- Requests to act, such as "Can you fix this bug?", authorize changes even when phrased as questions. Use the user's intent, not the sentence structure; ask if it is unclear.

## Match ceremony to the task
- Do not spawn sub-agents or multi-agent panel for work a single agent finishes in one pass. Delegation is for the breadth or adversarial review, not for ordinary tasks.
- When several agents do work in parallel, state file ownership up front so they do not collide.

## Pull Requests
- Pull request titles where applicable should be of the form "[<scope>] <description>". Prefer a scope that describes the logical change or subsystem. If there is no clear scope, or the change is broad, the scope can be omitted
- Titles should be simple and easy to understand. 
- Branch names should be prefixed with 'aj/'
- Do not commit or push code without explicit sign off and permission
- Do not force push unless I give you permission to
- When replying on my behalf, make it clear that it is a model responding with `[MODEL SLUG]: <comment>`

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

## Preserve User Changes

If something you previously wrote looks changed, reverted, or deleted, leave it alone — the user did that on purpose.

- Treat changes made since your last turn as user-owned and intentional.
- Never restore code that is absent from the current working tree merely because you wrote it earlier.
- When a user modification breaks a test, update the test or dependent code to match the user's new behavior. If intent is ambiguous, ask before changing it.
- Do not use `git restore`, `git checkout`, `git reset`, or stash-based recovery on user-modified files without explicit permission.

## Memory

Persistent notes live in `.docs/` at the repository root. Create notes only when there is useful state to preserve. Do not create or update them for read-only questions.

The files:

- `MEMORY.md`: Stable project knowledge. Architecture notes, repo-specific workflows, important commands, known constraints, naming conventions, recurring gotchas, and decisions that future work should preserve.
- `PROMPT.md`: The current engagement context. The user's goal, constraints, acceptance criteria, open questions, and any important wording or intent that should not be lost across longer tasks.
- `PLAN.md`: The working implementation plan. Approach, milestones, files likely to change, validation strategy, tradeoffs, and decisions made while executing. For loop-driven work (the `loop` skill) it holds the gate command, the slice list, and a `Learned` section.
- `TODO.md`: The actionable task list. Concrete next steps, task status, blockers, follow-ups, and handoff items so work can resume cleanly.
- `REVIEW.md`: The findings ledger for the current review loop. Written by the code-review skill, worked down by workers, verified in later rounds. Delete it when the loop for a change is done.

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

