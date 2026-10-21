---
name: tack-comments
description: Pick up code-review comments left in Neovim via tack.nvim. Reads the .tack/review.json sidecar, implements each open comment against the referenced file/line, and marks comments resolved. Use when the user says "do my hunk comments", "apply the review comments", "check the review sidecar", or after they review a diff in Neovim.
---

# tack.nvim comments

The user reviews diffs in Neovim with **tack.nvim** and leaves inline comments by
visual-selecting lines and writing a note. Those comments are persisted to a
JSON sidecar in the repo. Your job is to read them and act.

## Where the comments live

Default path (relative to the git root): `.tack/review.json`

If it is missing or has an empty `comments` array, there is nothing to do — tell
the user there are no open comments.

## Schema

```json
{
  "version": 1,
  "comments": [
    {
      "id": "c1782623007-1",
      "filePath": "src/app.ts",
      "side": "new",
      "newLine": 372,
      "lineStart": 372,
      "lineEnd": 374,
      "summary": "handle the null case here",
      "rationale": "db.query can return undefined",
      "author": "user",
      "status": "open",
      "createdAt": "2026-06-28T05:03:27Z"
    }
  ]
}
```

Field notes:

- `filePath` — repo-relative path to the file.
- `side` — `"new"` (comment on the post-change code) or `"old"` (on removed code).
- `newLine` / `oldLine` — the anchor line on that side (1-based). Exactly one is present.
- `lineStart` / `lineEnd` — the selected line range on that side. For a single
  line they are equal. Use this range, not just the anchor, to locate the code.
- `summary` — the user's instruction. This is the thing to do.
- `rationale` — optional extra context.
- `status` — `"open"` until handled. Skip anything already `"resolved"`.

## Workflow

1. Read `.tack/review.json` from the git root.
2. For each comment with `status == "open"`, in file order:
   - Open `filePath`, go to `lineStart`..`lineEnd` (use `side`/`newLine` to anchor).
   - Treat `summary` (+ `rationale`) as the instruction. Implement it.
   - If a comment is ambiguous, ask the user rather than guessing.
3. After you finish a comment, mark it resolved (see below).
4. Summarize what you changed, grouped by file.

## Marking comments resolved

Preferred: edit the sidecar in place — set the comment's `status` to `"resolved"`
and add a short `resolution` string describing what you did. This keeps a record
the user can see (and the ✓ marker shows up in Neovim on `:TackReload`). Do not
reorder or drop other comments; only touch the ones you handled.

Example after handling the comment above:

```json
{
  "id": "c1782623007-1",
  "...": "...",
  "status": "resolved",
  "resolution": "added a guard: `if (!rows) return []`"
}
```

The user clears resolved comments themselves with `:TackClear` in Neovim, so do
not delete the sidecar.

## Notes

- `author` is normally `"user"`. tack.nvim only writes human comments here.
- Never invent line numbers — always use the anchors in the file.
- If `filePath` no longer matches current code (the user kept editing), re-locate
  the intent from `summary` and confirm with the user if unsure.
