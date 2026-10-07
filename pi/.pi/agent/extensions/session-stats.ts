import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

type Usage = {
  input?: number;
  output?: number;
  cacheRead?: number;
  cacheWrite?: number;
  totalTokens?: number;
  cost?: { total?: number };
};

type TokenTotals = {
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
  total: number;
  cost: number;
};

const STATUS_KEY = "session-stats";

function number(value: unknown): number {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}

function formatInteger(value: number): string {
  return Math.round(value).toLocaleString();
}

function formatRate(value: number | undefined): string {
  return value === undefined ? "n/a" : `${value.toFixed(1)} tok/s`;
}

function formatPercent(value: number | undefined): string {
  return value === undefined ? "n/a" : `${value.toFixed(1)}%`;
}

function getContextWindow(ctx: ExtensionContext): number | undefined {
  const usage = ctx.getContextUsage();
  if (usage?.contextWindow) return usage.contextWindow;

  const model = ctx.model as { contextWindow?: unknown; context_window?: unknown } | undefined;
  const contextWindow = number(model?.contextWindow) || number(model?.context_window);
  return contextWindow > 0 ? contextWindow : undefined;
}

function getUsageTotals(ctx: ExtensionContext): TokenTotals {
  const totals: TokenTotals = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0, cost: 0 };

  for (const entry of ctx.sessionManager.getBranch()) {
    if (entry.type !== "message") continue;

    const message = entry.message as { role?: string; usage?: Usage };
    if (message.role !== "assistant" || !message.usage) continue;

    totals.input += number(message.usage.input);
    totals.output += number(message.usage.output);
    totals.cacheRead += number(message.usage.cacheRead);
    totals.cacheWrite += number(message.usage.cacheWrite);
    totals.total += number(message.usage.totalTokens);
    totals.cost += number(message.usage.cost?.total);
  }

  if (totals.total === 0) {
    totals.total = totals.input + totals.output + totals.cacheRead + totals.cacheWrite;
  }

  return totals;
}

export default function (pi: ExtensionAPI) {
  let currentAssistantStartedAt: number | undefined;
  let measuredOutputTokens = 0;
  let measuredAssistantMs = 0;

  function averageTokensPerSecond(): number | undefined {
    if (measuredAssistantMs <= 0 || measuredOutputTokens <= 0) return undefined;
    return measuredOutputTokens / (measuredAssistantMs / 1000);
  }

  function buildLines(ctx: ExtensionContext): string[] {
    const totals = getUsageTotals(ctx);
    const contextUsage = ctx.getContextUsage();
    const contextTokens = number(contextUsage?.tokens);
    const contextWindow = getContextWindow(ctx);
    const contextPercent = typeof contextUsage?.percent === "number"
      ? contextUsage.percent
      : contextWindow && contextTokens > 0
        ? (contextTokens / contextWindow) * 100
        : undefined;

    return [
      `Avg output speed: ${formatRate(averageTokensPerSecond())}`,
      `Context: ${formatInteger(contextTokens)} / ${contextWindow ? formatInteger(contextWindow) : "unknown"} tokens (${formatPercent(contextPercent)})`,
      `Session input: ${formatInteger(totals.input)} tokens`,
      `Session output: ${formatInteger(totals.output)} tokens`,
      `Cache read/write: ${formatInteger(totals.cacheRead)} / ${formatInteger(totals.cacheWrite)} tokens`,
      `Session cost: $${totals.cost.toFixed(3)}`,
      `Assistant tokens measured for speed: ${formatInteger(measuredOutputTokens)}`,
    ];
  }

  function updateUi(ctx: ExtensionContext) {
    if (!ctx.hasUI) return;

    ctx.ui.setStatus(
      STATUS_KEY,
      ctx.ui.theme.fg("dim", `output speed ${formatRate(averageTokensPerSecond())}`),
    );
  }

  pi.on("session_start", async (_event, ctx) => {
    updateUi(ctx);
  });

  pi.on("model_select", async (_event, ctx) => {
    updateUi(ctx);
  });

  pi.on("message_start", async (event) => {
    if (event.message.role === "assistant") {
      currentAssistantStartedAt = Date.now();
    }
  });

  pi.on("message_end", async (event, ctx) => {
    if (event.message.role === "assistant") {
      const outputTokens = number(event.message.usage?.output);
      if (currentAssistantStartedAt && outputTokens > 0) {
        measuredOutputTokens += outputTokens;
        measuredAssistantMs += Math.max(1, Date.now() - currentAssistantStartedAt);
      }
      currentAssistantStartedAt = undefined;
    }

    updateUi(ctx);
  });

  pi.on("turn_end", async (_event, ctx) => {
    updateUi(ctx);
  });

  pi.registerCommand("session-stats", {
    description: "Show token speed and context window stats",
    handler: async (_args, ctx) => {
      const lines = buildLines(ctx);
      if (ctx.hasUI) {
        ctx.ui.notify(lines.join("\n"), "info");
        updateUi(ctx);
      } else {
        console.log(lines.join("\n"));
      }
    },
  });
}
