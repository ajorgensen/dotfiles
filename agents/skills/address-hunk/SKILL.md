---
name: address-hunk
description: Addresses the user's review comments in a live Hunk session, tests the affected code, and leaves changes uncommitted for review. Use when the user asks to check or address their Hunk comments, act on Hunk feedback, or invokes address-hunk.
---

# Address Hunk Comments

Treat the user's Hunk comments like inline AI directives: make bounded changes,
answer questions, and ask about ambiguity. Keep replies in Hunk, not in source
code comments.

## Load Hunk's instructions first

1. Run `hunk skill path` and read the returned `SKILL.md` in full. This is
   Hunk's bundled `hunk-review` skill; load it from the installed CLI rather than
   copying it or hardcoding a version-specific path.
2. Follow that skill for current command syntax and session behavior. Use
   `hunk session --help` or command-specific help if needed. If the CLI or
   bundled skill is unavailable, report the blocker; do not guess commands or
   install software without permission.
3. Do not launch interactive commands such as `hunk diff` through the agent's
   shell. The user runs the TUI; the agent uses `hunk session *`.

## Find the review and read the comments

1. Run `hunk session list --json`. Select the session for the current checkout
   and verify its repository and review source with `hunk session get`.
   If several sessions match, ask which one to use, then use its exact ID for
   subsequent commands. Never silently select another checkout.
2. If no session exists, ask the user to open Hunk in their terminal (for
   example, `hunk diff` for working-tree changes), add their comments, and tell
   you when they are ready. Stop until the session is available.
3. Read the review structure, user comments, and existing replies:

   ```bash
   hunk session review <session-id> --include-notes --json
   hunk session comment list <session-id> --type user --json
   hunk session comment list <session-id> --type all --json
   ```

   The default comment list shows live agent comments, not the user's comments.
   Use `--type user` explicitly. Preserve returned note IDs for replies.
4. Read each comment's full thread and surrounding code. Use patch text only
   when needed. Check the diff side and current file contents before editing;
   review line numbers may no longer match the working tree. Do not repeat work
   already addressed unless the user requests a revision.
5. If there are no user comments, say so and ask the user to add them in Hunk.
   Do not invent review work or treat agent-authored notes as user directives.

## Address the feedback

- Make the smallest change that satisfies each directive. Follow existing
  style and preserve unrelated user changes. Do not refactor unrelated code or
  expand the scope with unsolicited abstractions or edge-case handling.
- Questions request answers, not edits. Reply without changing code.
- If a directive is ambiguous, ask a specific question in its thread and leave
  that item pending. If you disagree, explain why instead of silently making a
  different change. Flag unspecified edge cases rather than expanding scope.
- Reply to the original note using its returned ID, for example:

  ```bash
  hunk session comment add <session-id> --reply-to <note-id> --summary '<reply>'
  ```

  Safely quote reply text. Prefix replies with `[MODEL SLUG]:` using your actual
  model slug. State what changed, answer the question, or explain the blocker.
  Read existing replies first to avoid duplicate responses on repeated passes.
- Preserve user comments and review history. Do not remove or clear comments
  to mark work complete. Do not replace the review source or reload a different
  comparison without the user's agreement.

## Validate and hand back

1. Run relevant tests or builds for the affected code. Report failures and any
   checks you could not run; do not claim an item is validated when it is not.
2. Re-read user comments and threads to catch feedback added during the pass.
   Report remaining items explicitly.
3. Summarize comment-to-resolution results, validation, and questions or
   objections awaiting the user. State that changes remain uncommitted.
4. Prompt the user: "Please review the updated changes and my replies in Hunk.
   Add any follow-up comments there and tell me when they are ready."
5. Continue the same workflow for revisions. Do not commit or push unless the
   user explicitly approves the changes and requests that action.
