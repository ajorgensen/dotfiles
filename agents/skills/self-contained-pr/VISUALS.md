# Visuals for pull request descriptions

## Choose a visual that answers a question

Use a visual when it reduces the effort needed to understand the change.
Do not add one merely because the skill supports diagrams.
Usually one overview near the top is enough. Add a deeper diagram lower down
only when it answers a different, important question.

- **Before-and-after flowchart:** What changes in the path, ownership, or outcome?
- **Sequence diagram:** How do callers, services, and storage interact? Useful
  for retries, concurrency, and changes to request order.
- **State diagram:** Which transitions become possible or impossible?
- **Component or data-flow diagram:** Where does data go, and which boundary changes?
- **Screenshot or annotated image:** What visible UI behavior changes?
- **SVG or another image format:** Use when spatial layout or custom annotation
  communicates something that Mermaid cannot express clearly.

Skip the visual if a sentence or a few bullets explain the change better.

## Prefer a format the reviewer can see

Use fenced `mermaid` blocks for GitHub PRs. They render in the body without
an image upload. Prefer common syntax and avoid renderer-specific features.

Do not paste raw SVG markup into a GitHub PR body. For SVGs, screenshots, or
other images, use a Markdown image with meaningful alt text and a stable URL
that reviewers can access. Check that the destination renders that format;
use PNG when SVG is not supported. Local paths and temporary files are not
viewable PR assets.

Do not commit assets or upload them to external services without permission.
Do not send private code or architecture to a third-party diagram renderer.
If an image cannot be embedded reliably, use Mermaid or a text explanation.

## Make the diagram do useful work

- Show the changed path or boundary, not the entire system architecture.
- Keep the overview small. Move secondary branches and implementation detail down.
- Use short domain labels, not unexplained function or file names.
- Distinguish before and after, or changed and unchanged behavior, with labels.
  Do not rely on color alone. Keep contrast readable in light and dark themes.
- Explain what arrows mean when their meaning is not obvious.
- Include failure paths when they are central to the change being reviewed.
- Add a short caption for scope and assumptions. The visual must not imply a
  broader guarantee than the code or evidence supports.
- Replace prose with the visual where possible. Do not duplicate it with a long
  paragraph that walks through each node.

Treat every node, arrow, and label as a factual claim. Depict the implemented
behavior, not an idealized design. Label inferred or proposed behavior explicitly.

## Keep the reading path shallow

Put the high-level summary first and the overview visual immediately after it.
Keep major caveats and review decisions visible, even if their explanation is
lower down. Readers should not need to expand a section to discover a blocker.

Use descriptive lower headings such as `Concurrency behavior` or `Migration`.
For lengthy optional detail, GitHub supports this structure:

```html
<details>
<summary>Concurrency behavior and failure handling</summary>

Supporting Markdown goes here, with blank lines around it.

</details>
```

Keep the summary useful when the visual cannot render. Add captions or alt text,
not a second full narrative. Check syntax and rendered legibility when tooling
is available. Do not claim a rendering check that was not performed.
