---
name: address-review
description: Address all inline REVIEW comments in the working tree, test the affected code, and leave the changes uncommitted for review. Use when the user asks to address review markers or invokes this skill.
---

# Address Review Comments

Address all inline review comments in the working tree.

1. Run `git grep -n -w 'REVIEW:'` to find all review comments. The whole-word match avoids identifiers that merely end in `REVIEW`, such as `PRICE_PREVIEW` and `TRIAGE_GROUP_REVIEW`. If there are none, say so and stop.
2. For each comment, in file order:
   - Read the surrounding code for context.
   - Make the requested change. If you disagree, make no change, leave the marker in place, and explain the disagreement in the final summary.
   - When the comment directly asks a question, leave the original marker unchanged and add a new comment immediately below it with the same indentation and comment syntax: `AGENT: <answer>`.
   - When ambiguity prevents you from making the requested change, leave the original marker unchanged and add a new comment immediately below it with the same indentation and comment syntax: `AGENT: <specific clarification needed>`.
   - Do not add an `AGENT:` comment for status updates, general reasoning, disagreements, or other unsolicited commentary. Add one only to answer a question the user asked or to request clarification required to proceed.
   - Otherwise, delete the entire marker comment line after addressing it.
3. Do not refactor unrelated code unless a comment asks for it.
4. Run the relevant tests or build for the touched packages.
5. Do not commit as part of the initial pass, even when the user explicitly invokes this workflow. Leave the changes uncommitted so the user can inspect them with `:Review HEAD`, or use `:Review` to inspect the complete branch and working tree.
6. If the user requests revisions, continue updating and testing the uncommitted changes. Only commit after the user explicitly confirms the changes are ready and asks you to commit them. Make one commit summarizing the final resolutions rather than committing each review iteration.
7. Verify `git grep -n -w 'REVIEW:'` returns only markers you intentionally left because they are questions, require clarification, or document a disagreement. Report a comment-to-resolution summary and state that the changes remain uncommitted.
