# Shared Agent Guidance

These guides supplement `agents/AGENTS.md`. Agents read them only when the task matches the condition listed there.

## Layout

- `languages/<language>.md`: language-specific guidance. Start with `languages/go.md`.
- `scenarios/<scenario>.md`: guidance for a type of task. Create this directory when adding the first scenario.

## Add a guide

1. Add a Markdown file in the appropriate directory. Use lowercase, hyphen-separated names.
2. State when the guide applies, then add focused instructions. Do not repeat the general rules in `AGENTS.md`.
3. Add a link under **Language and Scenario Guidance** in `agents/AGENTS.md`, with a clear condition for reading it.
4. Run `./agents/sync.sh` from the repository root to install the changes.

The sync script copies this entire directory beside each installed `AGENTS.md` (or `CLAUDE.md`). Relative links therefore have the same layout in the repository and in every supported agent home. Edit the source files here, not the installed copies.

Sync does not delete destination files. When renaming or removing a guide, update its reference and remove stale installed copies explicitly.
