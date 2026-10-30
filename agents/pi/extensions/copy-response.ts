import { copyToClipboard, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";

export type CopyChoice = {
  label: string;
  text: string;
};

export function getCopyChoices(text: string): CopyChoice[] {
  const choices: CopyChoice[] = [{ label: "Whole response", text }];
  const lines = text.replace(/\r\n/g, "\n").split("\n");

  for (let i = 0; i < lines.length; i++) {
    const quote = /^ {0,3}>[ \t]?/;
    if (quote.test(lines[i])) {
      let end = i;
      while (end < lines.length && quote.test(lines[end])) end++;
      const content = lines.slice(i, end).map((line) => line.replace(quote, "")).join("\n");
      const preview = content.split("\n").find((line) => line.trim())?.trim() ?? "(empty)";
      choices.push({ label: `Quote ${choices.length}: ${preview.slice(0, 70)}`, text: content });
      i = end - 1;
      continue;
    }

    const opening = /^( {0,3})(`{3,}|~{3,})(.*)$/.exec(lines[i]);
    if (!opening) continue;
    const [, indent, fence, info] = opening;
    if (fence[0] === "`" && info.includes("`")) continue;

    const closing = new RegExp(`^ {0,3}${fence[0]}{${fence.length},}[ \\t]*$`);
    let end = i + 1;
    while (end < lines.length && !closing.test(lines[end])) end++;

    // CommonMark removes up to the opening fence's indentation from each line.
    const content = lines.slice(i + 1, end)
      .map((line) => line.replace(new RegExp(`^ {0,${indent.length}}`), ""))
      .join("\n");
    const language = info.trim().split(/\s+/)[0];
    const preview = content.split("\n").find((line) => line.trim())?.trim() ?? "(empty)";
    const label = `Code block ${choices.length}${language ? ` (${language})` : ""}: ${preview.slice(0, 70)}`;
    choices.push({ label, text: content });
    i = end;
  }

  return choices;
}

export async function copyResponse(text: string, ctx: ExtensionContext): Promise<void> {
  const choices = getCopyChoices(text);
  const label = choices.length === 1
    ? choices[0].label
    : await ctx.ui.select("Copy what?", choices.map((choice) => choice.label));
  const choice = choices.find((candidate) => candidate.label === label);
  if (!choice) return;

  try {
    await copyToClipboard(choice.text);
    ctx.ui.notify(`Copied ${choice === choices[0] ? "response" : "block"}.`, "info");
  } catch (error) {
    ctx.ui.notify(`Copy failed: ${error instanceof Error ? error.message : String(error)}`, "error");
  }
}

export default function (pi: ExtensionAPI) {
  async function copyLastResponse(ctx: ExtensionContext): Promise<void> {
    if (ctx.mode !== "tui") {
      ctx.ui.notify("/copy-response requires interactive mode.", "error");
      return;
    }
    const branch = ctx.sessionManager.getBranch();
    for (let i = branch.length - 1; i >= 0; i--) {
      const entry = branch[i];
      if (entry.type !== "message" || entry.message.role !== "assistant") continue;
      const text = entry.message.content
        .filter((part) => part.type === "text")
        .map((part) => part.text)
        .join("\n");
      if (!text) continue;
      await copyResponse(text, ctx);
      return;
    }
    ctx.ui.notify("No assistant response to copy.", "warning");
  }

  pi.registerShortcut("ctrl+x", {
    description: "Copy the last response, code block, or quoted passage",
    handler: copyLastResponse,
  });
  pi.registerCommand("copy-response", {
    description: "Copy the last response, code block, or quoted passage",
    handler: async (_args, ctx) => copyLastResponse(ctx),
  });
}
