---
name: code-review
description: "Review the changes since a fixed point (commit, branch, tag, or merge-base) along three axes: Standards (does the code follow this repo's documented coding standards?), Spec (does the code match what the originating issue/spec asked for?), and Simplicity (is anything in the diff more general than the spec needs today?). Runs the reviews in parallel sub-agents, reports them side by side, and writes a findings ledger to .docs/REVIEW.md. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to \"review since X\"."
---

Three-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards**: does the code conform to this repo's documented coding standards?
- **Spec**: does the code faithfully implement the originating issue / spec?
- **Simplicity**: is anything in the diff more general than the spec needs today?

The axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings into a ledger.

If `.docs/REVIEW.md` already exists for this fixed point (a review loop, rounds 2+), skip the process below and use **Verification mode** at the bottom of this skill instead.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point (a commit SHA, branch name, tag, `main`, `HEAD~5`, etc.). If they didn't specify one, ask for it.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Also note the list of commits via `git log <fixed-point>..HEAD --oneline`.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here, not inside two parallel sub-agents.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. `.docs/PROMPT.md`, when it exists. Its **Invariants** and **Non-goals** sections are spec too: an invariant breach is a spec finding, and anything that serves a non-goal is scope creep.
2. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, etc.), fetched via the workflow in `docs/agents/issue-tracker.md`.
3. A path the user passed as an argument.
4. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
5. If nothing is found, ask the user where the spec is. If they say there isn't one, the **Spec** sub-agent will skip and report "no spec available".

### 3. Identify the standards sources

Anything in the repo that documents how code should be written, such as `CODING_STANDARDS.md` or `CONTRIBUTING.md`.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below: a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation. Like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Spawn the sub-agents in parallel

**Standards sub-agent prompt** should include:

- The full diff command and commit list.
- The list of standards-source files you found in step 3, **plus the smell baseline from step 3** pasted in full (the sub-agent has no other access to it).
- The brief: "Report, per file/hunk where relevant, (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls: documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** should include:

- The diff command and commit list.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Under 400 words."

**Simplicity sub-agent prompt** should include:

- The diff command and commit list.
- The path or fetched contents of the spec (if found).
- The brief: "For each abstraction the diff introduces — interface, type parameter, config option, hook, layer of indirection, function parameter, feature flag — answer: does the spec require it *today*? The default answer is no. Report every construct where the answer is no, quoting the hunk and naming the simpler form (concrete type, inlined call, deleted parameter). Ignore pre-existing abstractions the diff merely touches. Under 400 words."

The Standards axis' Speculative Generality smell overlaps this axis; that's intentional. Simplicity is the dedicated deep pass, the smell is a safety net.

If the spec is missing, skip the Spec sub-agent, run Simplicity without a spec (judge need by callers in the diff), and note this in the final report.

### 5. Aggregate into the ledger

Present the three reports under `## Standards`, `## Spec`, and `## Simplicity` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings, because the axes are deliberately separate (see _Why separate axes_).

Then write `.docs/REVIEW.md` (create `.docs/` if needed):

```markdown
# Review ledger

Fixed point: <sha>
Round: 1

## Blocking

- [ ] ST-1 (standards): <one line> — <file:line>
- [ ] SP-1 (spec): <one line> — <file:line>
- [ ] SI-1 (simplicity): <one line> — <file:line>

## Advisory

- [ ] ST-2 (standards): <one line> — <file:line>
```

Severity rules:

- **BLOCKING**: documented-standard breaches; spec requirements that are missing, partial, or wrong; scope creep; simplicity findings where the construct was introduced in this diff and has no current caller or need (an interface with one implementation created here, a dead parameter, a hook nothing calls).
- **ADVISORY**: baseline smells and other judgement calls; simplicity findings where a simpler form exists but the construct is at least used.

End with a one-line summary per axis and the machine-readable last line: `OPEN BLOCKING: <n>`. Don't pick a single winner across axes: that's the reranking the separation exists to prevent.

## Why separate axes

A change can pass one axis and fail another:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**
- Code that is correct and conventional but built for requirements nobody has yet → **Standards and Spec pass, Simplicity fail.**

Reporting them separately stops one axis from masking another.

## Verification mode (rounds 2+)

Use this mode when `.docs/REVIEW.md` already exists for the same fixed point. Do **not** run a fresh open-ended review: fresh reviewers surface a different set of issues every round, so open-ended re-review never converges.

Spawn one fresh sub-agent with the ledger and the diff of the hunks changed since the last round (`git diff` against the previous round's HEAD if known, otherwise the full diff plus the ledger). It answers exactly two questions:

1. For each finding checked off since the last round: does the fix actually address it? Un-check anything that does not, with a one-line reason appended.
2. In the changed hunks only: did a fix introduce a new defect? Findings from this question are the only additions allowed to the ledger, and each must name the fix that caused it.

Update the `Round:` counter and end with `OPEN BLOCKING: <n>`. No new open-ended findings, no re-litigating findings already closed.
