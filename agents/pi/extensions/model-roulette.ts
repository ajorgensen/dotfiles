// Model roulette — randomly switch models from a configured list.
//
// Two modes:
//   settled (default) — switch once the agent is done working, so a single
//                       task runs start-to-finish on one model.
//   crazy             — switch on every turn, so the model can change
//                       between tool calls in the middle of a task.
//
// Commands:
//   /roulette              toggle on/off, keeping the current mode
//   /roulette on|off
//   /roulette crazy        enable, switching every turn
//   /roulette calm         enable, switching per completed task
//   /roulette status       show state, mode, and the active model list
//
// Config lives in ~/.pi/agent/settings.json under a custom key (pi parses
// settings with a plain JSON.parse, so unknown keys are preserved):
//
//   "modelRoulette": {
//     "mode": "settled",
//     "models": ["anthropic/claude-opus-5", "openai/gpt-5.6-sol", ...]
//   }
//
// Settings are re-read on every spin, so list edits apply without /reload.
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const SETTINGS_PATH = join(homedir(), ".pi", "agent", "settings.json");

type Mode = "settled" | "crazy";

const FALLBACK_MODELS = [
  "anthropic/claude-opus-5",
  "anthropic/claude-fable-5",
  "openai/gpt-5.6-sol",
  "openai/gpt-5.3-codex",
  "openrouter/moonshotai/kimi-k3",
];

function loadConfig(): { models: string[]; mode: Mode; fromSettings: boolean } {
  try {
    const settings = JSON.parse(readFileSync(SETTINGS_PATH, "utf8"));
    const config = settings?.modelRoulette;
    const models = config?.models;
    const mode: Mode = config?.mode === "crazy" ? "crazy" : "settled";
    if (
      Array.isArray(models) &&
      models.length > 0 &&
      models.every((m) => typeof m === "string" && m.includes("/"))
    ) {
      return { models, mode, fromSettings: true };
    }
    return { models: FALLBACK_MODELS, mode, fromSettings: false };
  } catch {
    return { models: FALLBACK_MODELS, mode: "settled", fromSettings: false };
  }
}

export default function (pi: ExtensionAPI) {
  let enabled = false;
  let mode: Mode = loadConfig().mode;

  // The thinking level the user actually asked for. setModel clamps thinking
  // to the new model's capabilities, so reading the live level after a hop
  // through a non-reasoning model would silently pin us to "off" forever.
  let intendedLevel: string | undefined;
  // Set while we drive setModel/setThinkingLevel, so the resulting
  // thinking_level_select events are not mistaken for user intent.
  let spinning = false;

  const showStatus = (ctx: any) => {
    ctx.ui.setStatus(
      "roulette",
      enabled ? (mode === "crazy" ? "🎰 roulette CRAZY" : "🎰 roulette") : "",
    );
  };

  async function spin(ctx: any) {
    const { models } = loadConfig();
    const current = ctx.model;
    const candidates = models
      .map((entry) => {
        const slash = entry.indexOf("/");
        return {
          entry,
          model: ctx.modelRegistry.find(
            entry.slice(0, slash),
            entry.slice(slash + 1),
          ),
        };
      })
      .filter(
        ({ model }) =>
          model &&
          (!current ||
            model.provider !== current.provider ||
            model.id !== current.id),
      );

    if (candidates.length === 0) return;

    const pick = candidates[Math.floor(Math.random() * candidates.length)];
    const level = intendedLevel ?? pi.getThinkingLevel();

    spinning = true;
    try {
      const ok = await pi.setModel(pick.model!);
      if (!ok) {
        ctx.ui.notify(
          `roulette: no API key for ${pick.entry}, skipping`,
          "warning",
        );
        return;
      }
      pi.setThinkingLevel(level as any);
    } finally {
      spinning = false;
    }

    ctx.ui.notify(`🎰 roulette → ${pick.entry}`, "info");
  }

  pi.registerCommand("roulette", {
    description:
      "Random model switching (on|off|crazy|calm|status); crazy switches every turn",
    handler: async (args, ctx) => {
      const arg = args.trim().toLowerCase();

      if (arg === "status" || arg === "list") {
        const { models, mode: configMode, fromSettings } = loadConfig();
        ctx.ui.notify(
          [
            `roulette: ${enabled ? "on" : "off"} — mode: ${mode}` +
              (mode === "crazy" ? " (switches every turn)" : " (switches per completed task)"),
            `list: ${fromSettings ? "settings.json" : "fallback"} (settings mode: ${configMode})`,
            ...models,
          ].join("\n"),
          "info",
        );
        return;
      }

      if (arg === "off") enabled = false;
      else if (arg === "on") {
        enabled = true;
        mode = loadConfig().mode;
      } else if (arg === "crazy") {
        enabled = true;
        mode = "crazy";
      } else if (arg === "calm" || arg === "settled" || arg === "normal") {
        enabled = true;
        mode = "settled";
      } else enabled = !enabled;

      showStatus(ctx);
      ctx.ui.notify(
        enabled
          ? `🎰 model roulette ON — ${mode === "crazy" ? "every turn" : "per completed task"}`
          : "🎰 model roulette OFF",
        "info",
      );
    },
  });

  pi.on("session_start", (_event, ctx) => {
    mode = loadConfig().mode;
    intendedLevel = pi.getThinkingLevel();
    showStatus(ctx);
  });

  pi.on("thinking_level_select", (event) => {
    if (spinning) return;
    intendedLevel = event.level;
  });

  pi.on("turn_end", async (_event, ctx) => {
    if (!enabled || mode !== "crazy") return;
    await spin(ctx);
  });

  // agent_settled, not agent_end: agent_end can fire mid-run before automatic
  // retries, auto-compaction, and queued follow-ups.
  pi.on("agent_settled", async (_event, ctx) => {
    if (!enabled || mode !== "settled") return;
    await spin(ctx);
  });
}
