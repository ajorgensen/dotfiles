import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Adapt pi-subagents' public lifecycle/RPC events to Workmux's activity contract.
export default function (pi: ExtensionAPI) {
  const runs = new Set<string>();
  const subscriptions: Array<() => void> = [];
  let active = false;
  let revision = 0;
  let sequence = 0;
  let cancelSnapshot: (() => void) | undefined;

  const publish = () => {
    if (active) pi.events.emit("suba:activity", { activeCount: runs.size });
  };
  const record = (value: unknown): Record<string, unknown> | undefined =>
    value !== null && typeof value === "object" ? value as Record<string, unknown> : undefined;

  function snapshot() {
    if (!active) return;
    cancelSnapshot?.();
    const requestId = `workmux-${process.pid}-${++sequence}`;
    const requestedRevision = revision;
    const unsubscribe = pi.events.on(`subagents:rpc:v1:reply:${requestId}`, (value) => {
      cancelSnapshot?.();
      const reply = record(value);
      const data = record(reply?.data);
      const status = record(data?.asyncSnapshot);
      if (!active || reply?.success !== true || status?.version !== 1 ||
          status.kind !== "pi-subagents.async-status-snapshot" || !Array.isArray(status.runs)) return;
      // Never let a delayed snapshot overwrite a newer start/completion event.
      if (revision !== requestedRevision) {
        snapshot();
        return;
      }
      runs.clear();
      function collect(nodes: unknown[]) {
        for (const value of nodes) {
          const node = record(value);
          if (!node) continue;
          if ((node.kind === "subagent" || node.kind === "workflow") &&
              (node.state === "running" || node.state === "queued") && typeof node.id === "string") runs.add(node.id);
          if (Array.isArray(node.children)) collect(node.children);
        }
      }
      collect(status.runs);
      publish();
    });
    const timer = setTimeout(() => cancelSnapshot?.(), 5000);
    timer.unref?.();
    cancelSnapshot = () => {
      unsubscribe();
      clearTimeout(timer);
      cancelSnapshot = undefined;
    };
    pi.events.emit("subagents:rpc:v1:request", { version: 1, requestId, method: "status" });
  }

  pi.on("session_start", () => {
    active = true;
    runs.clear();
    revision++;
    subscriptions.push(
      pi.events.on("suba:activity:request", () => { publish(); snapshot(); }),
      pi.events.on("subagents:rpc:v1:ready", snapshot),
      pi.events.on("subagent:async-started", (value) => {
        const id = record(value)?.id;
        if (typeof id !== "string" || !id) return;
        revision++;
        runs.add(id);
        publish();
      }),
      pi.events.on("subagent:async-complete", (value) => {
        const data = record(value);
        const id = data?.runId ?? data?.id;
        if (typeof id !== "string" || !id) return;
        revision++;
        runs.delete(id);
        publish();
        snapshot();
      }),
    );
    publish();
    snapshot();
  });

  pi.on("session_shutdown", () => {
    active = false;
    cancelSnapshot?.();
    for (const unsubscribe of subscriptions.splice(0)) unsubscribe();
    runs.clear();
  });
}
