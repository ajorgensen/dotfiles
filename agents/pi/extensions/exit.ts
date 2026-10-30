import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Alias for the built-in /quit.
export default function (pi: ExtensionAPI) {
  pi.registerCommand("exit", {
    description: "Quit pi",
    handler: async (_args, ctx) => {
      ctx.shutdown();
    },
  });
}
