---
name: my-pull-request
description: Drafts or opens concise pull requests that explain intent, architectural change, rollout, and meaningful risk. Use when the user asks to create, draft, open, or write a pull request or PR.
allowed-tools: Bash(git *), Bash(gh pr *), Bash(gh stack *)
metadata:
  short-description: Draft concise pull requests
---

## Purpose

Generate a pull request description that helps a human reviewer decide where
to spend attention.

The pull request description is not a summary of the diff.

The reviewer can inspect the code, file list, and individual changes. Do not
repeat information that is easy to get from the diff.

Instead, provide information that is difficult or impossible to infer from
the code.

Prioritize:

- Why the change exists.
- What behavior changes.
- Important assumptions.
- Important design decisions.
- Risks and failure modes.
- Areas that need reviewer judgment.
- Evidence that supports the change.
- Important uncertainty.

Optimize for signal-to-noise ratio.

The goal is to provide the minimum amount of information that materially
improves the review.

## Core Principle

Write for reviewer attention.

Assume that reviewer attention is limited.

Help the reviewer answer:

1. Why does this change exist?
2. What behavior changes?
3. What is important or unusual?
4. Where should I spend my attention?
5. What could go wrong?
6. What evidence supports this change?
7. What remains uncertain?

Do not explain every implementation detail.

Do not summarize every file.

Do not describe code that the reviewer can understand by reading the diff.

## Source of Truth

Before writing the description, inspect all available evidence.

This can include:

- The pull request title.
- The linked issue or task.
- The diff.
- Relevant surrounding code.
- Tests.
- CI results.
- Existing comments.
- Design documents.
- Other available context.

Separate your conclusions into three categories.

### Observed

A fact directly supported by the available evidence.

Example:

> The change adds tests for a PaymentIntent that has multiple InvoicePayments.

### Inferred

A reasonable conclusion based on the available evidence.

Example:

> The implementation appears to assume that InvoicePayments are available
> within the prefetch window.

Do not present inferred information as fact.

### Unknown

Information that is important but not established by the available evidence.

Example:

> It is not clear whether the prefetch window can exclude an InvoicePayment
> that belongs to a balance transaction in the current batch.

Do not hide important uncertainty.

Do not invent intent, requirements, test results, or guarantees.

## Writing Style

Prefer ASD-STE100 Simplified Technical English principles where practical.

### Use simple and direct language

Use short sentences.

Prefer one main idea per sentence.

Prefer active voice.

Use concrete verbs.

Prefer common technical terms.

Use the same term consistently.

Prefer:

> This change adds a lookup from the PaymentIntent to its InvoicePayments.

Avoid:

> This change introduces functionality that facilitates the retrieval of
> associated InvoicePayment entities.

Prefer:

> Review the retry behavior.

Avoid:

> Special attention should be paid to the manner in which retries are handled.

### Avoid vague language

Do not use vague or promotional words unless you define them with evidence.

Avoid:

- robust
- comprehensive
- seamless
- simple
- improved
- optimized
- efficient
- flexible
- clean
- properly
- correctly
- reliable

Prefer:

> Removes one API request for each cache hit.

Over:

> Improves performance.

Prefer:

> The test covers three invoices linked to one PaymentIntent.

Over:

> Adds comprehensive tests.

### Use consistent terminology

Use the names that appear in the code and domain model.

Do not switch between synonyms.

For example, if the system uses `InvoicePayment`, do not alternate between:

- invoice payment
- payment record
- invoice transaction
- payment object

Use `InvoicePayment` consistently.

## Information Priority

Prioritize information in this order:

1. Why the change exists.
2. Where reviewer judgment is most valuable.
3. Non-obvious assumptions and design decisions.
4. Behavioral changes.
5. Risks and blast radius.
6. Concrete verification evidence.
7. Implementation details that are not obvious from the diff.

Do not include lower-priority information when it adds noise.

## Review Focus

The `Review focus` section has high value.

Use it when the change contains a decision, assumption, or risk that requires
human judgment.

State exactly what the reviewer should examine.

Good:

> ## Review focus
>
> Review the cache-miss behavior. A miss can mean that the charge has no
> invoice relationship, or that the relationship was outside the prefetch
> window.

Good:

> ## Review focus
>
> The main design decision is to resolve relationships through InvoicePayments
> instead of querying invoices for every charge. Review whether this boundary
> is correct.

Do not write:

> Please review the code.

Do not create this section when there is no meaningful review focus.

## Design Notes

Use `Design notes` only when the diff does not explain an important decision.

Include:

- Constraints.
- Tradeoffs.
- Rejected alternatives.
- Important assumptions.
- Reasons for architectural boundaries.

Good:

> The sync process does not retain state between runs. The implementation
> cannot depend on keeping all InvoicePayments in memory.

Do not repeat the implementation.

## Risk or Impact

Describe specific risks or affected behavior.

Good:

> Incorrect invoice detection can classify an AR transaction as revenue.

Good:

> This changes behavior only for PaymentIntents associated with more than one
> invoice.

Good:

> Low risk. This change renames an internal type and does not change runtime
> behavior.

Avoid unsupported statements such as:

> Minimal risk.

Explain why the risk is low.

## Verification

Report concrete evidence.

Include relevant information such as:

- Tests that ran.
- Important scenarios covered.
- CI results.
- Manual verification.
- Known gaps.

Good:

> - `go test ./...` passes.
> - The tests cover one PaymentIntent linked to multiple InvoicePayments.
> - Existing single-invoice behavior remains covered.

If verification is incomplete, say so.

Good:

> The tests cover the multi-invoice path. No test was found for a cache miss
> caused by an incomplete prefetch window.

Never claim that testing is comprehensive unless the evidence supports that
claim.

## Uncertainty

Surface important uncertainty.

Do not convert uncertainty into confident prose.

Good:

> ## Open questions
>
> It is not clear whether the prefetch window can exclude an InvoicePayment
> that belongs to a balance transaction in the current batch.

Good:

> The implementation assumes that all relevant invoice relationships can be
> found through InvoicePayments. Confirm this assumption against the API
> behavior.

Do not manufacture uncertainty for simple changes.

## Adaptive Structure

Do not use a fixed template that forces every section to appear.

Include only sections that contain useful information.

The preferred order is:

1. Why
2. What changed
3. Review focus
4. Design notes
5. Risk or impact
6. Verification
7. Open questions

A simple change might contain only:

```markdown
## Why

...

## What changed

...

## Verification

...
