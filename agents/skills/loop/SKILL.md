---
name: loop
description: "Take a change from intent to human review: understand, implement, validate, review, and fix with ceremony proportional to the task. Use when the user supplies a spec or plan and wants it implemented end to end."
disable-model-invocation: true
---

# Loop

Deliver the simplest correct change. This session owns intent, implementation decisions, and acceptance. It may read code and diffs, edit files, and run gates. Delegation is a tool, not a required phase.

## Choose the smallest useful workflow

- **Small, clear change:** work directly. Inspect the relevant files, state the approach briefly, implement, run the focused gate, and inspect the diff for correctness and simplicity. No planning agent, review panel, separate refactor agent, or gate agent. Do not invoke the heavier companion skills merely to satisfy phase names.
- **Multi-step or uncertain change:** keep a short plan and deliver thin vertical slices. Delegate only work that benefits from specialization, independent review, or genuinely useful parallelism.
- Choose based on uncertainty and affected contracts, not just file count. A one-line security change can need independent review; a mechanical multi-file edit may not.
- Follow any mandatory project review or validation requirements. They do not justify unrelated extra phases.

Example: enabling grouped CI statuses needs the existing task keys, the vendor's naming/selection semantics, a narrow YAML edit, and lint. It does not need a branch-protection audit, four long planning documents, or repeated reviews unless those are part of the request.

## Understand just enough

Read applicable instructions and existing `.docs/` state. Inspect the caller and affected contracts. Research only uncertainties that can change the implementation or its acceptance.

- Reuse findings already recorded; do not repeat searches or validation without a concrete reason.
- A clear request to implement is approval to act. Do not require a separate plan-approval turn for an obvious, bounded change.
- For meaningful design choices, present a short recommendation and ask the targeted question before implementing. A request for planning only remains planning only.
- Separate the requested change from external rollout or administration. Mention relevant risks, but do not turn follow-ups into blockers unless they prevent safe implementation.
- When the user revises a requirement, update that decision and continue. Do not restart discovery or spawn a replacement planner for a local adjustment.

For resumable work, `.docs/PROMPT.md` holds intent and unresolved decisions; `.docs/PLAN.md` holds slices, gates, and useful learned facts. Keep entries short and update them in place. Create other notes only when they contain distinct useful state; do not duplicate the plan across four files or validate document headings with ad hoc scripts. Follow applicable repository memory requirements.

Record a fixed base SHA and the initial dirty state. Do not overwrite tags or assume pre-existing changes belong to this task. Without intermediate commits, a HEAD SHA does not isolate individual slices: record slice boundaries explicitly and review only task-owned changes.

## Implement, validate, review

For each slice:

1. Implement the smallest end-to-end change. Use the `slice` skill when its fuller process is useful, not for a trivial edit.
2. Run the focused gate. Keep its command, result, and the revision or working-tree state it covers.
3. Inspect the diff for correctness, scope, and simplicity. Use an independent reviewer for meaningful risk or breadth; use `code-review` when its multi-axis review earns the overhead. Reviewers are read-only except for explicitly assigned review notes.
4. Fix blocking findings and verify them. Simplify as part of this pass; use a separate `refactor` step only when there is a concrete opportunity worth investigating.
5. Re-run only gates affected by subsequent edits. Do not launch another agent just to repeat a gate that already passed on the unchanged final state.

At most two fix rounds per blocking issue. Stop sooner if the finding count does not shrink or the same gate fails again after a fix. Summarize the blocker and recommended next action rather than cycling through fresh agents.

## Delegation, when it earns its cost

Use fresh context by default and one writer per worktree. State exclusive file ownership before parallel work. Never delegate ordinary shell checks solely to keep this session's context clean.

Give each child a bounded brief: objective; cwd and relevant files; edit boundary; existing evidence and decisions; acceptance criteria and focused gate; stop conditions; expected short return. Load a companion skill only when it fits the assignment. Children should read relevant state, not every document unconditionally.

- Bundle implementation and its validation in one worker assignment.
- Give reviewers distinct questions; do not commission overlapping discovery.
- Match model and thinking to uncertainty. High thinking is not the default for mechanical planning or lint checks.
- Require a return under ten lines: result, changed files, validation, blockers, and artifact path if needed. Do not request extra reports that duplicate `.docs/` or tool receipts.
- For async work, yield and use native completion notifications. Do not poll or wait merely because a child is active.
- If a child is expanding scope or repeating completed research, steer it to the concrete deliverable rather than launching another child.

## Finish

For a single slice, its final diff review and passing gates are the finish gate. Do not repeat them as a whole-change review, refactor, and gate sequence. For multiple slices, inspect integration and cross-slice behavior; run additional review or gates only for gaps not already covered.

Update useful state and follow-ups once. Remove only this task's completed review ledger. Report what changed, validation, and remaining risks or decisions. Leave changes uncommitted unless the user explicitly authorized commits; never push or open a PR without permission.

## Stop and ask

Stop for an unresolved decision that affects safe implementation, a child returning `BLOCKED:`, non-shrinking blocking findings, repeated gate failure, or a plan that keeps growing. Record resumable blockers when useful, relay the question and recommendation, and wait. Do not manufacture blockers from optional follow-ups or already settled decisions.
