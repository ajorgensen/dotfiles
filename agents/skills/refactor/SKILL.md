---
name: refactor
description: "Behaviour-preserving refactor of the current change: act on advisory review findings and make the next slice easy. Gates must be green before and after; no new abstractions without a caller in the diff. Use when the user asks to refactor a change, or when the loop skill runs its refactor step after a review."
disable-model-invocation: true
---

Refactor with the knowledge the last slice produced. Two questions drive it, in this order:

1. **What did review flag?** Read the `## Advisory` findings in `.docs/REVIEW.md`. Take the ones that improve clarity or structure for a cost that is local to the change.
2. **What does the next slice need?** Read the next unchecked slice and the `## Learned` section in `.docs/PLAN.md`. If the next slice would be awkward against the current shape of the code, reshape the code now so that slice becomes the easy change. This is the "make the change easy" step.

Scope is the code touched since the fixed point the user or the loop gives you (default: `git diff review-base...HEAD`). Reach outside it only when question 2 requires it, and say so in the return.

## Hard constraints

- Run the gate command from `.docs/PLAN.md` before you start. If it is not green, stop and return `GATES RED` with the first failure. Refactoring on red is not refactoring.
- Preserve behaviour. Do not change public APIs unless the user asked. Update tests only where a rename or a move requires it; a test that changes its assertion is a behaviour change, not a refactor.
- No new abstractions without a caller in the diff: no interface, type parameter, config option, hook, or layer of indirection that fewer than two places in the current change use.
- Do not act on `## Blocking` findings. Those are fixes, not refactors, and they belong to the fix step.
- Run the gates again at the end. If they are red and you cannot make them green with a local correction, revert the whole pass (`git checkout -- .` on the files you touched) and return `REVERTED` with the reason.

Net line count may grow. Guard clauses, line-of-sight code, and small named types often add lines and are still simpler. Report the delta and justify it in one line when it is positive.

## Record

Check off each advisory finding you addressed in `.docs/REVIEW.md` with a one-line note. Add to `## Learned` in `.docs/PLAN.md` if the refactor revealed something the remaining slices should know.

`NO CHANGE` is a valid result. If neither question produces work worth doing, change nothing and return that.

## Return

Under ten lines: what moved and why (per question 1 or 2), findings checked off, net line delta with justification, gate result. Or `NO CHANGE`, `GATES RED`, or `REVERTED` with the reason.
