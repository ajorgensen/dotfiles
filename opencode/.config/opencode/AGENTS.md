# Personal Conventions

- Pull request titles where applicable should be of the form "[<scope>] <description>". If there is no clear scope or the change is broad then the scope can be omitted
- Branch names should be `aj/<type>/<short description>`

# Memory

You have access to a `.docs` directory you can use to persist context that may help later turns or future agents. Prefer short, durable notes over verbose logs, and only record information that is likely to stay useful beyond the current reply. Here are some of the documents you may find there:

- `MEMORY.md`: Stable project knowledge. Capture architecture notes, repo-specific workflows, important commands, known constraints, naming conventions, recurring gotchas, and decisions that future work should preserve.
- `PROMPT.md`: The current engagement context. Capture the user's goal, constraints, acceptance criteria, open questions, and any important wording or intent that should not be lost across longer tasks.
- `PLAN.md`: The working implementation plan. Capture the approach, milestones, files likely to change, validation strategy, tradeoffs, and decisions made while executing.
- `TODO.md`: The actionable task list. Capture concrete next steps, task status, blockers, follow-ups, and handoff items so work can resume cleanly.

Use these files to reduce repeated discovery, but keep them current: update or remove stale notes when they no longer reflect reality.

## Git Commits
- Always use conventional commit style (e.g., `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`)
- The subject line should be short (~50 chars) and state what changed
- The commit body should explain **why** — what problem this solves, what motivated the change, or what decision led to this approach. Do not simply restate the diff.
- For trivial changes (typos, formatting), a single-line subject is acceptable. For anything non-trivial, include a body.
- Bad example: `fix: update handler` (no context). Good example: `fix: prevent duplicate webhook deliveries` with a body explaining the root cause.

## Test Driven Development
When adding new functionality or fixing bugs, prefer a TDD workflow where applicable:

1. **Write a failing test first** — define the expected behavior before writing any implementation code.
2. **Run the test and confirm it fails** — this validates that the test actually exercises the code path you intend to change.
3. **Write the minimum code to make it pass** — resist the urge to over-engineer; just make the test green.
4. **Refactor** — clean up the implementation with confidence, knowing the test will catch regressions.

This cycle (red → green → refactor) keeps changes small and focused, produces a test suite that documents intent, and surfaces design issues early.

## Stacked PRs
- Treat stacked PRs as first-class: always check the current branch, base branch, and commit ancestry before creating or updating a PR.
- When a PR is stacked on another PR, assume that parent merges can change what GitHub shows in the child diff.
- If a parent PR was squash-merged and GitHub retargets a child PR to `main`, expect duplicate diff/review noise from parent changes.
- In that case, restack the child branch so it contains only child commits on top of the new base branch (typically `main`), then force-push with lease.
- Preferred command pattern for restacking a child after parent merge:
  - `git fetch origin`
  - `git rebase --onto origin/main <old-parent-tip> <child-branch>` (or equivalent while checked out on child)
  - `git push --force-with-lease`
- If parent tip is hard to identify, create a fresh branch from `main` and cherry-pick only the child commits.
- When asked to review PR comments on stacked PRs, verify whether comments are on inherited parent changes vs true child changes before applying fixes.
