import {
  convertToLlm,
  getMarkdownTheme,
  type ExtensionAPI,
  type ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { Markdown, truncateToWidth } from "@earendil-works/pi-tui";

const WIDGET = "btw";
const SIDE_QUESTION_PROMPT = `Answer only the user's side question. The preceding conversation is read-only background, not a request to continue the main task. Do not execute tools, change files, or claim to have performed actions. No tools are available. Give a direct, self-contained answer.`;

type Panel = {
  ctx: ExtensionContext;
  controller: AbortController;
  running: boolean;
  show(text: string, status: string): void;
  movePage(direction: number): void;
};

// The docked display is inspired by https://github.com/pifydev/btw.
// Use only Pi's public widget API; no upstream code or dependencies are needed.
function createPanel(ctx: ExtensionContext, question: string, model: string): Panel {
  const controller = new AbortController();
  const body = new Markdown("Waiting for answer…", 0, 0, getMarkdownTheme());
  let status = "asking";
  let page = 0;
  let pageCount = 1;
  let redraw = () => {};

  ctx.ui.setWidget(WIDGET, (tui, theme) => {
    redraw = () => tui.requestRender();
    return {
      render(width: number): string[] {
        const lines = body.render(Math.max(1, width));
        const pageSize = Math.max(1, Math.min(10, Math.floor(tui.terminal.rows / 2) - 3));
        pageCount = Math.max(1, Math.ceil(lines.length / pageSize));
        page = Math.min(page, pageCount - 1);
        const paging = pageCount > 1 ? ` · ${page + 1}/${pageCount} · /btw:prev /btw:next` : "";
        return [
          theme.fg("accent", `─ BTW · ${model} · not saved`),
          theme.fg("muted", `› ${question.replace(/\s+/g, " ")}`),
          ...lines.slice(page * pageSize, (page + 1) * pageSize),
          theme.fg("dim", `${status}${paging} · /btw:clear`),
        ].map((line) => truncateToWidth(line, width));
      },
      invalidate() { body.invalidate(); },
      dispose() { controller.abort(); },
    };
  }, { placement: "aboveEditor" });

  return {
    ctx,
    controller,
    running: true,
    show(text, nextStatus) {
      status = nextStatus;
      body.setText(text);
      redraw();
    },
    movePage(direction) {
      page = Math.max(0, Math.min(pageCount - 1, page + direction));
      redraw();
    },
  };
}

export default function (pi: ExtensionAPI) {
  let current: Panel | undefined;

  function clear(): void {
    const panel = current;
    if (!panel) return;
    current = undefined;
    panel.controller.abort();
    panel.ctx.ui.setWidget(WIDGET, undefined);
  }

  pi.on("session_shutdown", clear);
  pi.on("session_tree", clear);
  pi.registerCommand("btw:clear", {
    description: "Dismiss the side answer and cancel only its pending request",
    handler: async () => clear(),
  });
  for (const [name, direction] of [["btw:next", 1], ["btw:prev", -1]] as const) {
    pi.registerCommand(name, {
      description: `${direction > 0 ? "Next" : "Previous"} page of the side answer`,
      handler: async () => current?.movePage(direction),
    });
  }

  pi.registerCommand("btw", {
    description: "Ask a side question without adding it to the main conversation",
    handler: async (args, ctx) => {
      if (ctx.mode !== "tui") {
        ctx.ui.notify("/btw requires interactive mode.", "error");
        return;
      }
      const question = args.trim();
      if (!question) {
        ctx.ui.notify("Usage: /btw <question>", "info");
        return;
      }
      const model = ctx.model;
      if (!model) {
        ctx.ui.notify("No model selected.", "error");
        return;
      }
      if (current?.running) {
        ctx.ui.notify("A side question is running. Use /btw:clear to cancel it.", "warning");
        return;
      }

      // Providers may mutate their input. Clone the resolved, compaction-aware
      // context, and replace system deltas so no tool declarations leak in.
      const request = structuredClone({
        systemPrompt: `${ctx.getSystemPrompt()}\n\n${SIDE_QUESTION_PROMPT}`,
        messages: [
          ...convertToLlm(ctx.sessionManager.buildSessionProjection().messages)
            .filter((message) => message.role !== "system"),
          { role: "user" as const, content: question, timestamp: Date.now() },
        ],
        tools: [],
      });
      const thinking = pi.getThinkingLevel();
      const panel = createPanel(ctx, question, model.id);
      current = panel;
      const isCurrent = () => current === panel && !panel.controller.signal.aborted;

      // Return immediately so the editor and main agent remain usable.
      void (async () => {
        let text = "";
        try {
          const stream = ctx.modelRegistry.streamSimple(model, request, {
            signal: panel.controller.signal,
            reasoning: thinking === "off" ? undefined : thinking,
            toolChoice: "none",
          });
          for await (const event of stream) {
            if (!isCurrent()) return;
            if (event.type === "text_delta") {
              text += event.delta;
              panel.show(text, "answering");
            } else if (event.type === "thinking_start" && !text) {
              panel.show("Thinking…", "thinking");
            }
          }
          const response = await stream.result();
          if (!isCurrent()) return;
          if (response.stopReason === "error" || response.stopReason === "aborted") {
            panel.show(`${text}${text ? "\n\n" : ""}Request failed: ${response.errorMessage || response.stopReason}`, "failed");
            return;
          }
          if (response.stopReason === "toolUse" || response.stopReason === "deferred") {
            panel.show("The model did not return a direct answer. Side questions cannot run tools or deferred work.", "failed");
            return;
          }
          const answer = response.content.filter((part) => part.type === "text").map((part) => part.text).join("\n");
          panel.show(answer || text || "The model returned no text.", response.stopReason === "length" ? "response limit reached" : "done");
        } catch (error) {
          if (!isCurrent()) return;
          panel.show(`${text}${text ? "\n\n" : ""}Request failed: ${error instanceof Error ? error.message : String(error)}`, "failed");
        } finally {
          panel.running = false;
        }
      })();
    },
  });
}
