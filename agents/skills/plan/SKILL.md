---
name: plan
description: "Understand a problem before any code changes. Reads the spec, explores the codebase, and writes .docs/PROMPT.md (goal, invariants, acceptance criteria, open questions) and .docs/PLAN.md (gate commands and thin vertical slices). Use when the user supplies a spec, ticket, or feature idea and wants a plan, or when the loop skill starts without a plan."
---

Understand the problem and write it down. Do not implement anything.

Start by reading `.docs/MEMORY.md` if it exists. Then read the spec the user supplied and explore the code it touches. Use a fresh-context subagent for noisy exploration (large searches, log reads) when one is available, so the raw output stays out of this session.

## Write `.docs/PROMPT.md`

Capture the intent so a fresh-context agent can work from the file alone:

- **Goal**: what must be true when the work is done, in one or two sentences.
- **Invariants**: constraints that every slice must respect (compatibility, performance, security, style rules the user stated). These are the things a reviewer checks against.
- **Acceptance criteria**: observable checks, each one testable.
- **Non-goals**: what this change deliberately does not do. Anything that would tempt over-engineering goes here.
- **Open questions**: every ambiguity or design decision you could not resolve from the spec and the code. State your recommended answer for each.

## Write `.docs/PLAN.md`

```markdown
# PLAN

Gates: `<build cmd> && <typecheck/vet cmd> && <test cmd>`

## Slices

- [ ] 1. <one line: the behaviour this slice adds>
  - Seams: <public interface(s) tests will target>
  - Done when: <observable check>
- [ ] 2. ...

## Learned

(appended by slice runs)
```

Rules for slices:

- Each slice is a vertical slice: one thin path through the change that leaves the gates green on its own.
- Slice 1 is the smallest end-to-end tracer bullet. Later slices widen it.
- Order slices so each one teaches something the next one needs.
- No slice introduces an abstraction for the sake of a later slice. If two slices would share code, the refactor step after the first one decides that, not the plan.
- Prefer three to seven slices. If you need more, the spec is probably several changes; say so.
- The seams listed per slice are the pre-agreed seams the `tdd` skill requires. Choose them at public boundaries.

Discover the gate commands from the repo (Makefile, package scripts, CI config, `MEMORY.md`). If you cannot find them, list that as an open question.

## Finish

Present the plan and the open questions to the user, with your recommendation for each question. Suggest `grill-me` when there are design decisions that deserve a proper interview. Stop and wait for approval. Do not start slice 1.

Return a short summary: goal in one line, slice count, gate command, and the list of open questions.
