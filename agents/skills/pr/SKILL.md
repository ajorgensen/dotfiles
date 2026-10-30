---
name: pr
description: Use when asked to draft, write, or improve a pull request title or description, prepare PR text from a branch diff, or write a merge request description.
---

# Pull request descriptions

Give reviewers the context they cannot get from the diff: what changes, why it
matters, important decisions, risks, and evidence that it works.

Draft text only. Do not publish PRs, edit files, run tests, commit, or push.
Use read-only Git and GitHub inspection when needed.

## Gather context

1. Read repository instructions and any applicable PR template. Preserve required
   sections; use the template below when the repository has none.
2. Establish the intended change and base. For a branch, inspect commits and the
   full diff against that base. Do not assume the base is `main`. For a stacked
   PR, compare with its parent branch, not the entire stack.
3. For an existing PR, confirm its repository, number, base/head branches, title,
   and body with read-only `gh` commands. Describe its actual remote head, not
   unrelated local changes. Distinguish committed and uncommitted work when
   drafting from a working tree.
4. Read relevant code, tests, issue/spec context, and recorded verification
   results. When revising supplied text, use the provided context and inspect
   the repository only if needed.
5. Ask a focused question if the target, scope, or motivation is unclear. Do not
   invent rationale, alternatives considered, issue links, or test results.

## Draft the title and body

Use a short, active title: `[<scope>] <description>`. Name the logical subsystem
or behavior, not a list of files. Omit the scope if none is useful.

Write for someone who has not followed the ticket. Lead with the behavior change,
then explain the problem before implementation details. Use this structure:

```markdown
## Summary
<!-- What changes for users or the system? State the primary change first.
     Name affected areas if the change spans multiple components. -->

## Risks and limitations
<!-- Optional: flag blockers, breaking changes, known limitations, or
     deployment/migration requirements. Delete this section if unnecessary. -->

## Why
<!-- What problem does this solve? Include enough context to stand alone.
     Link the issue for supporting detail, not as a substitute for explanation. -->

## Approach
<!-- Explain decisions the diff cannot: why this approach, important
     alternatives or tradeoffs, and departures from existing patterns.
     Omit details that are obvious from the code. -->

## Verification
<!-- Optional: describe completed manual checks and observed behavior, with
     relevant steps/environment. Omit routine CI results and validation-gap
     disclaimers. Delete this section if there is no useful manual evidence. -->
```

Replace prompts with facts and remove comments. Combine or omit sections when
allowed by the repository template and they add no distinct context. Do not
repeat the summary merely to fill “Why” or “Approach.” Avoid “N/A” and
file-by-file narration.

For bugs, include reproduction steps plus actual and expected behavior when they
help explain the defect. Put them in an existing section, not a mandatory new one.
Distinguish reproduction instructions from checks actually performed.

Scale detail to the change, not a word quota. Use short paragraphs and bullets
for distinct changes or checks.
Explain significant dependency choices and migration sequencing/reversibility
when relevant. Put consequential caveats near the top, not in a closing footnote.

Do not include test counts, automated test results, or routine lint, formatting,
typecheck, and build summaries. CI already reports these; do not duplicate them.
Verification is for completed manual checks, not an execution log.
Do not add a “Validation gap” section or equivalent disclaimers such as “not
exercised end to end,” “tests not run,” or “no production changes were made.”
Omit incidental tooling failures and unrelated warnings. Keep concrete product
limitations and deployment requirements in the relevant explanation, not a
validation disclaimer. Report only manual checks actually performed.
Include screenshots only when supplied or available; never fabricate evidence.

## Examples

Read [EXAMPLES.md](EXAMPLES.md) for weak-to-strong contrasts, bug reproduction
steps, and a complete description. Examples illustrate structure, not facts to
reuse; include only details supported by the current change.

Return the proposed title and Markdown body in chat. Publishing is a separate action.

Sources: [Willow's guidance](https://willowvoice.com/blog/how-to-write-good-pull-request-description)
and [Oleg Petrov's Juro Tech guide](https://medium.com/juro-tech/writing-effective-pull-request-descriptions-a-developers-guide-56847bbd3870).
