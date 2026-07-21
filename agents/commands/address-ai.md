---
name: address-ai
description: Address all inline AI markers in the working tree — review fixes, questions, and implementation directives (including skeleton-first implementation stubs) — test the affected code, and leave the changes uncommitted for review. Use when the user asks to address AI markers, review comments, fill in stubs, or invokes this skill.
---

# Address AI Markers

Address all inline `AI` markers in the working tree. There are exactly two marker
words in this codebase: `AI` (written by the user, a directive to the agent) and
`AGENT` (written by the agent, a response to the user). Each takes an optional
parenthesized type. Never invent other marker words.

## Marker grammar

### User markers (directives you must address)

| Marker | Meaning |
|---|---|
| `AI: <directive>` | Infer the kind from content: a bounded edit, a question, or new code to write. |
| `AI(review): <directive>` | A bounded change to existing code ("rename this", "handle nil here", "extract into a helper"). |
| `AI(impl): <spec>` | An implementation stub: write the body/code this comment specifies, at this location, within the existing signature. Stub bodies typically contain `panic("AI")`. |
| `AI(ask): <question>` | A question to answer in place. Make no code change. |

The type is a hint, not a contract — a bare `AI:` asking a question is still a
question. When the type and content conflict, follow the content.

### Agent markers (the only comments you may add)

| Marker | When to add it |
|---|---|
| `AGENT: <answer>` | Answering a question the user asked. |
| `AGENT(ask): <clarification needed>` | Ambiguity prevents you from making the requested change. Leave the original `AI` marker in place above it. |
| `AGENT(edge): <description>` | You identified an edge case the directive does not cover. Flag it, do not handle it in code, and continue. |
| `AGENT(note): <objection>` | You disagree with a directive, signature, or design decision. Make no change; state the disagreement here and in the final summary. |

Place agent markers immediately below the line they respond to, matching its
indentation and the file's comment syntax. Do not add `AGENT` comments for
status updates, general reasoning, or unsolicited commentary — only for the four
purposes above.

## Procedure

1. Run `rg -n '\bAI(\(\w+\))?:'` to find all markers. Use `rg` rather than
   `git grep` so markers in untracked files are found too.
2. For each marker, in file order:
   - Read the surrounding code for context.
   - Make the requested change. If you disagree, make no change, leave the
     `AI` marker in place, and add an `AGENT(note):` below it.
   - For questions (`AI(ask):` or a bare `AI:` that asks something), leave the
     original marker unchanged and add `AGENT: <answer>` below it.
   - If ambiguity prevents you from proceeding, leave the original marker
     unchanged and add `AGENT(ask): <specific clarification needed>` below it.
   - Otherwise, delete the entire marker comment line after addressing it. For
     `AI(impl)` stubs, also remove the `panic("AI")` placeholder.
3. For implementation directives (`AI(impl):` and bare `AI:` requesting new
   code), produce the minimum diff that satisfies the directive:
   - Implement only what the marker asks for. Do not modify signatures. Do not
     add configuration, abstraction layers, or new top-level declarations
     (types, interfaces, helpers) beyond what the directive names or clearly
     requires. If you believe a signature is wrong, leave an `AGENT(note):`
     instead of changing it.
   - Before writing new code, search the repo for existing code that does
     something similar and imitate its style, naming, and error-handling
     conventions. If the marker names an exemplar, follow it exactly.
   - If you identify an edge case the directive does not cover, do not handle
     it in code. Add `AGENT(edge): <description>` at the relevant line and
     continue. These are triage notes for the user, not work items.
4. Do not refactor unrelated code unless a marker asks for it.
5. Run the relevant tests or build for the touched packages. `AI(impl)` stubs
   left unfilled must still compile — their `panic("AI")` bodies fail loudly at
   runtime, which is intended.
6. Do not commit as part of the initial pass, even when the user explicitly
   invokes this workflow. Leave the changes uncommitted so the user can inspect
   them with `:Review HEAD`, or use `:Review` to inspect the complete branch
   and working tree.
7. If the user requests revisions, continue updating and testing the
   uncommitted changes. Only commit after the user explicitly confirms the
   changes are ready and asks you to commit them. Make one commit summarizing
   the final resolutions rather than committing each review iteration.
8. Verify `rg -n '\bAI(\(\w+\))?:'` returns only markers you intentionally left
   because they have an `AGENT(ask):` or `AGENT(note):` beneath them. Then run
   `rg -n '\bAGENT(\(\w+\))?:'` and report:
   - a marker-to-resolution summary,
   - all `AGENT(edge):` markers you added,
   - all `AGENT(ask):` and `AGENT(note):` items awaiting the user,
   - a statement that the changes remain uncommitted, and
   - confirmation that the diff introduces no new top-level declarations beyond
     what the directives named (or an explanation for each one it does).
