---
name: pr
description: Use when asked to write or improve a pull request title or description, prepare a PR from a branch diff, or create or update a GitHub PR. Also applies to merge request descriptions; not to reviewing code or merging PRs.
---

# Pull Requests

Set the reviewer up to understand what changed, why it matters, how it works,
and how to verify it. Keep the description short, concrete, and self-contained.

Based on [Writing A Great Pull Request Description](https://www.hackerone.com/blog/writing-great-pull-request-description)
by Gonzalo Bañuelos, published by HackerOne.

## Gather context

1. Read repository instructions and any applicable PR template. Preserve required
   template sections; use the structure below when no template applies.
2. Establish the request: draft text, create a PR, or update a specific PR.
   Writing a description does not authorize publishing it.
3. Inspect the branch, working tree, commits, and full diff against the intended
   base. For an existing PR, use `gh pr view` to confirm its repository, number,
   base/head branches, title, body, and URL. Do not assume the base is `main`.
   For a stacked PR, compare with its parent branch, not the entire stack.
4. Read relevant code, tests, issue/spec context, and recorded validation results.
   Separate committed branch changes from uncommitted work; do not describe local
   work as part of a published PR unless it is actually in its head branch.
5. Ask a focused question when the base, target, motivation, or scope is unclear.
   Do not invent business goals, issue links, design rationale, or test results.

## Write the title and body

Use a simple title: `[<scope>] <description>`. Name the logical subsystem or
change, not a list of files. Omit the scope if no useful one exists.

Use these headings as a starting point, not a reason to add filler:

- **What?** Explain the net behavior change in a few sentences. Give enough
  context to understand it without opening an issue. Link the issue afterward;
  never substitute “See ticket” or “See title” for the explanation.
- **Why?** Explain the problem and the engineering or business goal. Say why
  the change is needed, rather than repeating what it does.
- **How?** Highlight significant design decisions, dependencies, and tradeoffs
  that help a reviewer assess the approach. Explain reasoning, not a file-by-file
  inventory or a narration of the diff.
- **Testing?** State what was actually checked and the observed results. Include
  commands or reproduction steps when useful. Distinguish checks already run
  from suggested reviewer steps. Identify untested cases, reasons, and risks.
  If no checks ran, say so; test code in the diff is not proof of a passing run.
- **Screenshots** (optional): Show before/after visuals for UI changes when
  available. CLI output or infrastructure plans can also demonstrate the effect.
  Use a `<details>` block for long supporting output. Do not fabricate evidence
  or upload private material without permission.
- **Anything Else?** (optional): Call out relevant risks, deployment/migration
  needs, technical debt, limitations, or follow-ups. Omit speculative redesigns
  and unrelated possibilities that distract from this change.

Use complete sentences, active voice, and plain language. Scale detail to the
change. Remove empty optional sections, repetition, cryptic fragments, and detail
already clear from the diff. If explaining the scope requires a long essay,
suggest splitting the PR; do not split branches or change code on your own.

## Example

Title: `[webhooks] prevent duplicate deliveries after retries`

```markdown
## What?
Retries now reuse the original delivery ID instead of creating a new one.

## Why?
A timeout can occur after the receiver accepts a webhook. A stable ID lets
receivers recognize the retry and avoid processing the same event twice.

## How?
Persist the delivery ID before the first attempt and reuse it on retries.

## Testing?
Not run. Suggested check: simulate a timeout after acceptance and confirm
that the retry carries the original delivery ID.
```

## Publish only when requested

- For a draft-only request, return the title and Markdown body. Do not mutate Git
  or GitHub state. Editing an existing PR preserves unrelated user-written content.
- Before publishing, confirm the target and ensure the description matches the
  remote head. If commits are not pushed, stop and ask; creating a PR is not
  permission to commit, push, force-push, or merge. Do not silently switch targets.
- When posting on the user's behalf, identify the model as required by their
  instructions, using the actual model slug rather than inventing one.
- Write the body to a temporary file and use `gh pr create --base <base> --head
  <head> --title <title> --body-file <file>` or `gh pr edit <number> --title
  <title> --body-file <file>`. Pass explicit targets and quote arguments safely.
- Read the PR back to verify the title/body and report its URL. On failure,
  report the error; do not claim success or retry against another target.
