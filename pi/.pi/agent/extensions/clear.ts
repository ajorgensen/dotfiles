import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const SETTINGS_ENTRY = "clear-settings";

type Settings = {
  provider: string;
  modelId: string;
  thinkingLevel: ReturnType<ExtensionAPI["getThinkingLevel"]>;
};

export default function (pi: ExtensionAPI) {
  // /new replaces the extension runtime. Pass settings as non-context session
  // data, then restore them through the new runtime's API, not the stale pi.
  pi.on("session_start", async (event, ctx) => {
    if (event.reason !== "new") return;
    const entry = ctx.sessionManager.getLeafEntry();
    if (entry?.type !== "custom" || entry.customType !== SETTINGS_ENTRY) return;

    const settings = entry.data as Settings;
    const model = ctx.modelRegistry.find(settings.provider, settings.modelId);
    if (!model || !(await pi.setModel(model))) {
      ctx.ui.notify("Context cleared, but the previous model could not be restored.", "error");
      return;
    }
    pi.setThinkingLevel(settings.thinkingLevel);
    ctx.ui.notify("Context cleared. Model and thinking level preserved.", "info");
  });

  pi.registerCommand("clear", {
    description: "Start an empty session with the current model and thinking level",
    handler: async (_args, ctx) => {
      await ctx.waitForIdle();
      if (!ctx.model) {
        ctx.ui.notify("No model selected; session unchanged.", "error");
        return;
      }

      const settings: Settings = {
        provider: ctx.model.provider,
        modelId: ctx.model.id,
        thinkingLevel: pi.getThinkingLevel(),
      };
      await ctx.newSession({
        setup: async (sessionManager) => {
          sessionManager.appendCustomEntry(SETTINGS_ENTRY, settings);
        },
      });
    },
  });
}
