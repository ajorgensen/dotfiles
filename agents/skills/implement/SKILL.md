---
name: implement
description: "Implement a change in a red-green-refactor loop, using TDD where tests add value, then review the diff and fix findings until the change is ready for human review. Use when the user asks to implement a feature, fix, or spec test-first with a review loop."
disable-model-invocation: true
---

# Implement

Build the change in small verified steps, review it critically, and loop until it is ready for a human reviewer. Work directly in this session. Do not commit, push, or open a PR without explicit permission.

## 1. Set up

- Read `.docs/` state and applicable language guidance per project instructions.
- Restate the goal as a short list of acceptance criteria. If an unclear requirement or design decision changes the implementation, ask a targeted question before writing code.
- Record the base: `git rev-parse HEAD` and `git status --short`. Pre-existing changes are not yours; review only task-owned changes.
- Find the gate: the project's typecheck, lint, and test commands. Run it first so you know what was already red.
- List the behaviors to build, smallest end-to-end slice first. For each, choose how to verify it (see step 2).

## 2. Decide what to test

Use TDD when a test pins down behavior that someone depends on:

- Logic with clear inputs and outputs: parsing, validation, transformation, calculation, state transitions.
- Bug fixes: first write a test that reproduces the bug.
- Public contracts: API responses, CLI output, error handling, and edge cases that callers rely on.

Do not write tests that cannot fail for a useful reason:

- Configuration, dotfiles, wiring, and glue with no logic.
- Layout and styling, docs, and generated code.
- Mechanical renames and moves that existing tests already cover.
- Deleted features ("regression tests" that assert something is gone).
- Code that needs heavy mocking, so the test only mirrors the implementation.
- Exploratory spikes and throwaway scripts.

When you skip a test, choose another check: typecheck, lint, a dry run, running the command, or inspecting output. State the choice in one line.

Test through public seams. Assert behavior and external contracts, not internals. Expected values come from an independent source (the spec, a known-good literal, a worked example), never recomputed the way the code does. See [tests.md](../tdd/tests.md) and [mocking.md](../tdd/mocking.md). If the right seam is not obvious, propose it to the user before writing tests at it.

## 3. Red, green, refactor

For each behavior, one at a time:

1. **Red:** write one failing test. Run it and confirm it fails for the expected reason, not a typo or setup error.
2. **Green:** write the least code that passes. Add no parameters, hooks, or abstractions that the current test does not need. Run the test file and the typecheck.
3. **Refactor:** with tests green, improve names, remove duplication, flatten nesting, and simplify. Do not change behavior. Run the tests again.

For untested work, keep the same rhythm: make the smallest change, verify it with the chosen check, then simplify.

Keep slices vertical: one test, one implementation, repeat. Do not write all the tests first.

## 4. Review

When all acceptance criteria appear met, run the full gate. Then review the whole task-owned diff against the base as a skeptical reviewer:

- **Spec:** every acceptance criterion is met; nothing outside the request was added.
- **Correctness:** edge cases, error paths, cleanup, and concurrency or security where relevant.
- **Simplicity:** no abstraction, option, or parameter without a current caller; flat guard-clause code; no dead code.
- **Standards:** repo conventions and applicable language guidance.
- **Tests:** they test behavior at public seams; no mirror assertions or slop tests.
- **Hygiene:** no debug output, stray TODOs, commented-out code, or stale comments and docs.

Classify each finding as **blocking** (wrong, missing, out of scope, or against a documented standard) or **advisory** (a judgement call). For broad or high-risk changes, use the `code-review` skill for an independent review instead of a self-review.

## 5. Fix and loop

- Fix every blocking finding. If a finding is a behavior bug, start with a failing test (step 3).
- Take advisory findings only when they are cheap and local.
- Run the gate again, then re-review only the changed hunks and the fixed findings. Do not start a fresh open-ended review each round; it does not converge.
- Repeat until the exit criteria are true.

## Exit criteria: ready for review

- Every acceptance criterion is met and verified by a test or a stated check.
- The full gate passes on the final working tree.
- The last review round found no blocking findings.
- The diff contains only task-owned changes, and comments and docs match the code.

## Stop and ask

Stop and report instead of looping when:

- A blocking finding survives two fix rounds, or the finding count does not shrink between rounds.
- The same gate fails again after a fix.
- A design decision is unresolved, or the scope keeps growing.

Give the blocker, what you tried, and your recommendation.

## Report

Under fifteen lines: what changed, tests added, what was not tested and why, the gate command and result, open advisory findings, and remaining risks. Leave changes uncommitted and update `.docs/` state per project instructions.
