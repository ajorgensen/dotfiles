# PR description examples

These examples are illustrative. Do not copy their rationale, implementation
choices, or verification status unless supported by the current change.

## Weak to strong

### Summary: describe behavior, not a code edit

- Weak: “See JIRA-666,” “Fixed bugs,” or “Added an early return to `someFunc`.”
- Strong: “The toolbar stays visible when scrolling.”

The reviewer can understand the effect without opening the ticket or code.

### Why: explain the consequence

- Weak: “It was broken.”
- Strong: “The dropdown opened outside the viewport, making its options
  inaccessible on smaller screens.”

Explain what the defect prevented, not just that it existed.

### Approach: explain the mechanism and reason

- Weak: “Updated some CSS.”
- Strong: “Choose the dropdown's opening direction from the available viewport
  space rather than always opening below the trigger. This keeps options visible
  when the trigger is near the bottom edge.”

Use this level of detail only when the mechanism helps assess the change.

### Verification: add information CI cannot provide

- Weak: “3 component tests and 7 helper tests passed; lint and TypeScript passed.”
- Strong: “Manually verified the SSO rejection screen in staging: it directs the
  invitee to IT and hides the expired-link prompt and replacement-link button.”
- Omit: “The daemon was not exercised end to end, and no production changes
  were made.” This is a validation disclaimer, not useful manual evidence.

The strong example assumes that manual check actually happened. Omit routine
CI results and validation-gap sections. Omit Verification entirely when there
is no useful completed manual check to describe.

## Bug reproduction

Include steps when they clarify the defect. For example, within Summary:

```markdown
The dropdown opens above its trigger when there is insufficient space below.

To reproduce the original defect:
1. Scroll until the dropdown trigger is near the bottom of the viewport.
2. Open the dropdown.

Actual behavior before this change: Options extend below the viewport.
Expected behavior: The dropdown opens upward so its options remain visible.
```

These are reproduction instructions, not evidence that anyone ran the check.
Record completed manual checks and their results separately in Verification.

For this small fix, the consequence may already be clear from Summary. Omit Why
rather than restating it, unless the repository requires that section.

## Complete description

Given confirmed duplicate-event context and a change that persists and reuses
delivery IDs, with no completed manual verification to report:

Title: `[webhooks] reuse delivery IDs on retries`

```markdown
## Summary
Webhook retries now reuse the original delivery ID.

## Why
A timeout can occur after the receiver accepts a webhook. Reusing the ID lets
receivers recognize retries and avoid processing the same event twice.

## Approach
Persist the delivery ID before the first attempt and reuse it on retries.

```

Verification is omitted because there is no completed manual evidence to report.
Risks and limitations is omitted because this example supplies no relevant
caveats. Do not omit a known product limitation merely to keep the description short.
