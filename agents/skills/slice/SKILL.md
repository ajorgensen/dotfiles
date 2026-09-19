---
name: slice
description: "Implement the next unchecked slice in .docs/PLAN.md with the simplest change that works, leave the gates green, and record what was learned. Does not review, refactor, or commit. Use when the user or the loop skill says to take the next slice."
disable-model-invocation: true
---

Make the simple change. One slice, the simplest thing that works, gates green, then stop.

## Before you edit

1. Read `.docs/PROMPT.md`, `.docs/PLAN.md`, and `.docs/MEMORY.md` if present.
2. Take the first unchecked slice in `PLAN.md`. If the user named a slice, take that one.
3. Check the slice against `PROMPT.md`. If you hit an ambiguity or a design decision that the goal, invariants, and answered questions do not settle, do not guess. Add the question with your recommended answer under `## Open questions` in `PROMPT.md`, make no code changes, and return `BLOCKED: <question>`.

## Implement

- Use the `tdd` skill at the seams listed for this slice. Red before green, one test and one minimal implementation at a time.
- Write the least code that makes the slice's "done when" true. No parameters, types, interfaces, or hooks that this slice does not use. If something feels like it will be needed in a later slice, leave it out; the refactor step decides that with real evidence.
- Respect every invariant in `PROMPT.md`.
- Run the typecheck and the touched test files as you go. Run the full gate command from `PLAN.md` once at the end. The slice is not done until the gates are green.

## Record

Edit `.docs/PLAN.md`:

- Check off the slice.
- Under `## Learned`, add one to three lines: facts about the code or the problem that were not known at planning time and that change how the remaining slices should go.
- Adjust the remaining slices from what you learned: split, merge, reorder, or drop. Keep the plan inside the goal in `PROMPT.md`. Work that is outside the goal goes to `.docs/TODO.md` as a follow-up, not into the plan.

Do not review your own work, do not refactor beyond what the slice needs, and do not commit. Those are separate steps with fresh eyes.

## Return

Under ten lines: the slice completed, files touched, the gate command and its result, the `Learned` lines, and any changes to the remaining slices.
