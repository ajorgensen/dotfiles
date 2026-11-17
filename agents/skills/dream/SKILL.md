---
name: dream
description: Use when AJ asks to "dream", consolidate or clean up the brain, promote journal entries to long-term memory, prune or re-verify brain notes, or when a scheduled brain upkeep run starts.
---

Consolidate the brain at `~/.agents/brain/`. Promote what has proved itself, re-check what is already long-term, and delete the rest. The layout, entry formats, and budgets are in the agent instructions, section "Memory".

Scope: $ARGUMENTS (one project note path, or empty for every project and `MEMORY.md`).

## Rules

- Edit only files in `~/.agents/brain/`. Do not edit the repositories that the notes describe.
- Deletion is the default result. Git history keeps what you delete, so do not keep an entry "in case".
- Never change or remove an entry marked `(AJ YYYY-MM-DD)`. If it looks wrong or conflicts with something, add it to `## Open questions for AJ` in `MEMORY.md`.
- Usage is not proof. An entry that is read often and is wrong does the most damage. Promote on evidence, and keep on a passing check.
- Other agents can write while you work. Re-read each file immediately before you edit it.

## 1. Journal entries

For each `projects/**/*.journal.md`, classify every entry. Take the first class that applies.

1. **Wrong or superseded**: a later entry or the current repository contradicts it → delete.
2. **Promote**: one of these is true:
   - The same lesson appears in two or more entries from different days or tasks.
   - Its key identifier (command, path, flag, error text) appears in two or more distinct sessions. Count with `rg -l` over `~/.claude/projects/**/*.jsonl` and `~/.codex/sessions/**/*.jsonl` modified in the last 14 days. Do not read the transcripts in full.
   - The latest report in `scratch/agent-retros/` names it as a repeated problem.
3. **Younger than 14 days** → leave it.
4. **Expired** → delete. Exception: promote it if it can be written as a rule that applies beyond the task that produced it, and its check passes now. A measurement, a finding from one investigation, or a status is never an exception.

To promote an entry:

1. Rewrite it as a timeless rule. Remove dates, branch names, and the story of how it was found.
2. Find a check: a path, a symbol, or a read-only command that shows the rule still holds. Run it. If there is no check, or the check fails, do not promote.
3. Add it in the long-term format with today's date. Put it in the project note, in a topic file, or in `MEMORY.md` if the entry starts with `cross-project:`.
4. If an existing long-term entry covers the same subject, merge into that entry. Do not add a second one.
5. Delete the journal entries that you promoted.

## 2. Long-term entries

For each entry in `MEMORY.md`, the project notes, and the topic files:

1. Run its check. For a path or symbol, confirm that it exists in the repository (find the checkout from the project note path; skip the check if there is no local checkout). For a command, run it only if it is read-only.
2. Check passes → set the `verified` date to today.
3. Check fails → delete the entry, or correct it if the new value is obvious from the repository.
4. No check → add one if you can find it. If you cannot, and the `verified` date is older than 60 days, delete the entry.
5. An entry that is a measurement, a finding, or a status → delete it. It is in Git history.

Entries written before this format have a write date in `verified` and no check. Process them with the same steps.

## 3. Budgets

- `MEMORY.md`: 8 KB. Project note: 24 KB. Measure with `wc -c`.
- If a project note is over budget after step 2, move each area of the repository to a topic file `projects/<host>/<owner>/<repo>/<topic>.md`. Leave one line in the project note for each topic file: the path and when to read it.
- If `MEMORY.md` is over budget, move project-specific entries to their project note, then delete the entries with the oldest `verified` date that have no evidence of recent use.
- A topic file has no budget, but every entry in it must have a passing check.

## 4. Report and commit

Commit in the brain repository with the message `dream: <YYYY-MM-DD>`. Do not push.

Print a short report, as lists:

- Promoted: each entry, with its evidence.
- Deleted from long-term memory: each entry, with the reason (check failed, no check and old, not a rule).
- Journal: counts of entries kept and expired.
- Sizes: bytes before and after for each file that has a budget.
- Open questions for AJ: conflicts, and `(AJ ...)` entries that look wrong.
