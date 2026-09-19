---
name: loop
description: "Orchestrate a change end to end the way AJ works: understand the problem, make the simple change, review and refactor with what was learned, repeat until done. Composes the plan, slice, code-review, and refactor skills in fresh-context subagents and commits each clean iteration. Use when the user supplies a spec or plan and wants it taken to a state that is ready for human review."
disable-model-invocation: true
---

This session is the orchestrator. It holds the intent, spawns a fresh-context subagent for each step, reads their short returns, and decides what happens next. It does not read diffs, run test suites, or edit code. Every token spent here on work is a token lost from judgement, so keep this context as clean as possible.

State lives in `.docs/`: `PROMPT.md` (intent), `PLAN.md` (slices, gates, learned), `REVIEW.md` (findings ledger), `TODO.md` (follow-ups). Subagents read and write those files. This session reads only the small parts it needs: the open questions, the slice list, and the `OPEN BLOCKING: <n>` line.

## Subagents

Every step runs in a fresh-context subagent. Give it exactly:

- the skill to load and follow
- the `.docs/` files to read first (always `PROMPT.md` and `PLAN.md`)
- the fixed point (a SHA or tag) when the step needs a diff
- one line of task
- "Return in the format the skill specifies. Under ten lines."

Tune the subagent to the step when the tool allows it. As a default: `plan` and `code-review` run with high thinking; `slice` and `refactor` run with medium, raised to high when `PLAN.md`'s `Learned` section or the ledger shows the area is tricky; fix and gate checks run with low. Pick the model the same way; the review axes benefit from the strongest model more than the gate check does.

One writer at a time. Review subagents are read-only. Never run two writers in parallel.

If the agent you are running in has no subagent tool, run each step yourself, but re-read the `.docs/` files at the start of each step and do not carry findings between steps in your head. State goes through the files.

## Stop and ask

Any subagent that returns `BLOCKED: <question>` has written the question to `## Open questions` in `PROMPT.md`. Relay the question and the recommended answer to the user and wait. Do not answer it yourself and do not move to another slice while it is open. This rule applies to every step, not only planning.

## Phases

### 1. Understand

If `.docs/PLAN.md` does not exist or has no unchecked slices for this spec, run the `plan` skill.

Then stop. Present the plan and the open questions to the user and wait for approval. This gate makes sure the problem and its invariants are understood before any code changes. Skip it only when the user said to run unattended, and even then stop if `PROMPT.md` has open questions.

After approval: `git tag -f review-base`.

### 2. Iterate

Repeat for each unchecked slice:

1. Record `iter-base=$(git rev-parse HEAD)`.
2. **Slice.** Run the `slice` skill. On `BLOCKED`, stop and ask.
3. **Review.** Run the `code-review` skill against `iter-base`. Read only the `OPEN BLOCKING: <n>` line.
4. **Fix.** While `n > 0`, at most two rounds: run a fresh subagent with the task "Read `.docs/REVIEW.md`. Fix every unchecked finding under `## Blocking`. Check each one off with a one-line note. Gates green. Do not touch advisory findings." Then run `code-review` again against `iter-base`; it detects the existing ledger and uses verification mode. If `n` does not shrink between rounds, or two rounds end with `n > 0`, stop and escalate: summarize the open findings for the user.
5. **Refactor.** Run the `refactor` skill against `iter-base`. `NO CHANGE` is fine. `REVERTED` is fine; note the reason and move on.
6. **Gates.** Run a small subagent: "Run the gate command in `.docs/PLAN.md`. Return `PASS`, or `FAIL` and the first failing message only." On `FAIL`, one fix round as in step 4, then re-check. On a second `FAIL`, stop and escalate.
7. **Commit.** Commit with the repo's convention (`<scope>: <description>`, body says why). The slice's return gives you the what; `PROMPT.md`'s goal gives you the why. Delete `.docs/REVIEW.md`.

Watch the plan between iterations. If the number of unchecked slices grows on two consecutive iterations, stop and ask: the work is bigger than the spec, or the plan is drifting toward scope creep.

### 3. Finish

When no unchecked slices remain:

1. Run `code-review` against `review-base` for the whole change. Fix `## Blocking` findings as in phase 2 step 4.
2. Run `refactor` against `review-base` for the whole change. Cross-slice duplication and naming show up here, not per slice.
3. Gate check. Commit if there are changes. Delete `.docs/REVIEW.md`.
4. Update `.docs/TODO.md` with follow-ups and `.docs/MEMORY.md` with durable facts from `## Learned` in `PLAN.md`.

The change is ready for human review when the gates are green, the whole-change review ends with `OPEN BLOCKING: 0`, and every slice is checked off.

Stop with a summary for the user: the goal, the commits made, anything advisory left on purpose, and the open follow-ups. Do not open a pull request.

## Escalate, do not loop

Stop and hand the decision to the user when any of these happen:

- a subagent returns `BLOCKED`
- open blocking findings do not shrink between fix rounds
- two fix rounds end with blocking findings open
- gates fail twice in one iteration
- the plan grows on two consecutive iterations

Summarize what is open and what you recommend. Do not keep looping past these limits.
