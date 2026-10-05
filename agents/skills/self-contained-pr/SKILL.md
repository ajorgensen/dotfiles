---
name: self-contained-pr
description: Creates self-contained pull requests with useful visuals and increasing levels of detail for reviewers who cannot see the code. Use when the user asks for a PR that can be understood and reviewed without the diff, or invokes self-contained-pr.
---

# Self-contained pull requests

## Purpose

Write a review brief for someone who cannot see the actual code.
The author must inspect the code; the reader must not need it to understand
and assess the purpose, behavior, design, and risks of the change.
This enables design and behavioral review. It does not replace implementation review.

## Quick start

Create a ready-for-review GitHub PR by default, rather than only returning text.
For an existing PR, update its title and body without changing its draft status.
Use draft status only when explicitly requested.
If the user asks only for a description or preview, return text without publishing.
Do not commit or push without explicit permission.
Use `[<scope>] <description>` for the title when a meaningful scope exists.
See [EXAMPLES.md](EXAMPLES.md) for the intended structure and depth.
Read [VISUALS.md](VISUALS.md) when preparing a visual.

## Workflow

### 1. Gather evidence

- Establish the requested change range and target branch. For an existing PR,
  use its actual base and head. Ask if the intended scope cannot be determined.
- Read the task or issue, commits, full diff, relevant surrounding code, and tests.
  Inspect available design notes and CI results when they help explain the change.
- Understand both the old and new behavior. A diff alone may not explain either.
- Separate observed facts, inferred intent or assumptions, and important unknowns.
  Do not invent requirements, rejected alternatives, guarantees, or test results.

### 2. Build the reader's mental model

Answer these questions before writing:

1. What problem exists today, and what are its consequences?
2. What happens differently after this change? Who or what is affected?
3. What stays the same? Which boundaries and guarantees matter?
4. How does the change work, and why does that mechanism produce the new behavior?
5. Why this approach? Which constraints and tradeoffs affect the decision?
6. What could go wrong? Consider relevant failure paths and operational effects.
7. What evidence supports the claims? What still needs reviewer judgment?

Use a concrete before-and-after scenario when it clarifies behavior.
For an internal refactor or documentation change, explain its purpose and scope
without manufacturing a runtime behavior change.

### 3. Write the brief

Organize the body in increasing levels of detail. A reader should be able to
stop after the opening and still understand the change and its main caveat.
Use only the layers that help this change:

1. **Summary:** One to three short sentences about the problem, outcome, and
   scope. Keep major risks and important review questions visible near the top.
2. **Visual overview:** A compact diagram or image when it explains the change
   better than prose. Prefer GitHub-native Mermaid. Omit decorative visuals.
3. **Behavior:** Short before-and-after bullets, affected callers, unchanged
   behavior, and relevant edge cases. Do not narrate every arrow in the diagram.
4. **Details:** Important mechanisms, constraints, tradeoffs, and failure paths.
   Explain why the mechanism produces the behavior, not which files were edited.
   Put design, migration, rollout, and rollback detail under descriptive headings
   lower down. Use optional `<details>` blocks for lengthy supporting material.
5. **Verification:** Connect evidence to behavioral claims. Separate tests found
   from tests actually run. Report supported outcomes and meaningful gaps.

Use short paragraphs, bullets, concrete verbs, and consistent domain terms.
Define unfamiliar terms at first use. Avoid promotional or unsupported claims.
Do not hide material risks, unresolved decisions, or verification failures in
collapsed sections. Mention alternatives only when supported and useful.
Paths and identifiers may locate evidence, but cannot replace an explanation.
Do not dump code, enumerate every file, or force every layer into a small change.
Do not hide important uncertainty or manufacture it for routine changes.

### 4. Run the blind-reader check

Reread the title and body as if the code and earlier conversation were unavailable.
Could the reader explain the problem, predict the new behavior, describe the
mechanism, identify its limits, and challenge a meaningful design decision?

Does the opening stand on its own? Can readers find deeper detail without
reading a wall of text? Does each visual explain something useful and match
the evidence? Keep the summary understandable even if images fail to load.

Add missing context or evidence. Remove details that do not help that assessment.
Check every factual claim, including diagram labels and arrows, against the
evidence. State important unresolved questions instead of guessing.

Create or update the PR with the checked title and body, then return its URL.
For an explicit description-only or preview request, return the proposed title
and body without publishing.
