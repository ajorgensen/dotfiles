import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { execFile } from "node:child_process";
import { platform } from "node:os";
import { basename } from "node:path";

const HOOK_STATE = Symbol.for("ajorgensen.pi.system-notifications.ui-hooks");
const VERSION = 2;
const DEFAULT_TITLE = "Pi";
const MAX_TITLE_LENGTH = 140;
const MAX_CONTEXT_LENGTH = 72;

type HookState = {
  version: number;
  originals: Record<string, Function>;
  dialogDepth: number;
};

type PiNotificationKind = "Agent Done" | "Needs Input" | "Needs Permission" | "Test";

function cleanText(value: unknown, maxLength = MAX_TITLE_LENGTH): string {
  const text = String(value ?? "")
    // ANSI escape sequences.
    .replace(/\x1b\[[0-9;?]*[ -/]*[@-~]/g, "")
    // Terminal control characters that should never go into notification payloads.
    .replace(/[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]/g, " ")
    .replace(/\s+/g, " ")
    .trim();

  if (text.length <= maxLength) return text;
  return `${text.slice(0, Math.max(0, maxLength - 1)).trimEnd()}…`;
}

function notificationEnabled(): boolean {
  const value = process.env.PI_SYSTEM_NOTIFY ?? process.env.PI_NOTIFY;
  return value !== "0" && value !== "false" && value !== "no";
}

function notifyOSC777(title: string, body: string): void {
  const safeTitle = title.replace(/[;\x07\x1b]/g, " ");
  const safeBody = body.replace(/[;\x07\x1b]/g, " ");
  process.stdout.write(`\x1b]777;notify;${safeTitle};${safeBody}\x07`);
}

function notifyOSC99(title: string, body: string): void {
  const safeTitle = title.replace(/[\x1b\\]/g, " ");
  const safeBody = body.replace(/[\x1b\\]/g, " ");
  process.stdout.write(`\x1b]99;i=1:d=0;${safeTitle}\x1b\\`);
  if (safeBody) process.stdout.write(`\x1b]99;i=1:p=body;${safeBody}\x1b\\`);
}

function notifyTerminal(title: string, body: string): void {
  if (process.env.KITTY_WINDOW_ID) {
    notifyOSC99(title, body);
    return;
  }

  notifyOSC777(title, body);
}

function notifyMacOS(title: string, body: string, subtitle: string, onError: () => void): void {
  const sound = process.env.PI_SYSTEM_NOTIFY_SOUND ?? process.env.PI_NOTIFY_SOUND ?? "";
  const script = `
on run argv
  set notificationTitle to item 1 of argv
  set notificationBody to item 2 of argv
  set notificationSubtitle to item 3 of argv
  set notificationSound to item 4 of argv

  if notificationSound is "" then
    display notification notificationBody with title notificationTitle subtitle notificationSubtitle
  else
    display notification notificationBody with title notificationTitle subtitle notificationSubtitle sound name notificationSound
  end if
end run
`;

  execFile("osascript", ["-e", script, title, body, subtitle, sound], { timeout: 5000 }, (error) => {
    if (error) onError();
  });
}

function notifyTermux(title: string, body: string, onError: () => void): void {
  const args = ["-t", title];
  if (body) args.push("-c", body);

  execFile("termux-notification", args, { timeout: 5000 }, (error) => {
    if (error) onError();
  });
}

function notifyWindows(title: string, body: string, onError: () => void): void {
  const script = `
param([string]$Title, [string]$Body)
$Type = 'Windows.UI.Notifications'
$Manager = "[$Type.ToastNotificationManager, $Type, ContentType = WindowsRuntime]"
Invoke-Expression "$Manager" | Out-Null
$Xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
$Texts = $Xml.GetElementsByTagName('text')
$Texts.Item(0).AppendChild($Xml.CreateTextNode($Title)) | Out-Null
$Texts.Item(1).AppendChild($Xml.CreateTextNode($Body)) | Out-Null
$Toast = [Windows.UI.Notifications.ToastNotification]::new($Xml)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Pi').Show($Toast)
`;

  const command = process.env.WSL_DISTRO_NAME ? "powershell.exe" : "powershell";
  execFile(command, ["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", script, title, body], { timeout: 5000 }, (error) => {
    if (error) onError();
  });
}

function sendSystemNotification(title: string, body = "", subtitle = ""): void {
  if (!notificationEnabled()) return;

  const cleanTitle = cleanText(title || DEFAULT_TITLE) || DEFAULT_TITLE;
  const cleanBody = cleanText(body);
  const cleanSubtitle = cleanText(subtitle, MAX_CONTEXT_LENGTH);
  const fallback = () => notifyTerminal(cleanTitle, cleanBody);

  if (platform() === "darwin") {
    notifyMacOS(cleanTitle, cleanBody, cleanSubtitle, fallback);
    return;
  }

  if (process.env.TERMUX_VERSION) {
    notifyTermux(cleanTitle, cleanBody, fallback);
    return;
  }

  if (platform() === "win32" || process.env.WT_SESSION || process.env.WSL_DISTRO_NAME) {
    notifyWindows(cleanTitle, cleanBody, fallback);
    return;
  }

  notifyTerminal(cleanTitle, cleanBody);
}

function cwdName(ctx: ExtensionContext): string {
  return cleanText(basename(ctx.cwd) || ctx.cwd, MAX_CONTEXT_LENGTH);
}

function execFileText(command: string, args: string[], cwd: string): Promise<string | undefined> {
  return new Promise((resolve) => {
    execFile(command, args, { cwd, timeout: 1200 }, (error, stdout) => {
      if (error) {
        resolve(undefined);
        return;
      }

      resolve(cleanText(stdout, MAX_CONTEXT_LENGTH) || undefined);
    });
  });
}

async function gitProjectName(ctx: ExtensionContext): Promise<string> {
  const root = await execFileText("git", ["rev-parse", "--show-toplevel"], ctx.cwd);
  return root ? cleanText(basename(root), MAX_CONTEXT_LENGTH) || cwdName(ctx) : cwdName(ctx);
}

async function gitBranch(ctx: ExtensionContext): Promise<string | undefined> {
  return execFileText("git", ["branch", "--show-current"], ctx.cwd);
}

async function notificationContext(pi: ExtensionAPI, ctx: ExtensionContext): Promise<string> {
  const sessionName = cleanText(pi.getSessionName?.() ?? "", MAX_CONTEXT_LENGTH);
  const [project, branch] = await Promise.all([
    gitProjectName(ctx),
    sessionName ? Promise.resolve(undefined) : gitBranch(ctx),
  ]);
  const detail = sessionName || branch;

  return detail ? `${project} — ${detail}` : project;
}

async function notifyPi(pi: ExtensionAPI, ctx: ExtensionContext, kind: PiNotificationKind): Promise<void> {
  sendSystemNotification(`Pi ${kind}: ${await notificationContext(pi, ctx)}`);
}

function classifyDialog(method: string, args: unknown[]): PiNotificationKind {
  const optionText = args
    .filter(Array.isArray)
    .flat()
    .join(" ");
  const combined = cleanText(`${args[0] ?? ""} ${args[1] ?? ""} ${optionText}`, 1000).toLowerCase();

  const looksLikePermission =
    method === "confirm" || method === "select"
      ? /permission|outside-workspace|outside workspace|access requested|allow once|allow this path|\ballow\b|\bdeny\b|trusted repositories/.test(
          combined,
        )
      : false;

  return looksLikePermission ? "Needs Permission" : "Needs Input";
}

function installUiNotificationHooks(pi: ExtensionAPI, ctx: ExtensionContext): void {
  if (!ctx.hasUI) return;

  const ui = ctx.ui as any;
  const existing = ui[HOOK_STATE] as HookState | undefined;
  if (existing?.version === VERSION) return;

  if (existing) {
    for (const [name, original] of Object.entries(existing.originals)) {
      ui[name] = original;
    }
  }

  const methods = ["select", "confirm", "input", "editor", "custom"];
  const state: HookState = { version: VERSION, originals: {}, dialogDepth: 0 };

  for (const method of methods) {
    if (typeof ui[method] !== "function") continue;

    const original = ui[method].bind(ctx.ui);
    state.originals[method] = original;

    ui[method] = (...args: unknown[]) => {
      if (state.dialogDepth === 0) {
        void notifyPi(pi, ctx, classifyDialog(method, args));
      }

      state.dialogDepth++;
      try {
        return Promise.resolve(original(...args)).finally(() => {
          state.dialogDepth = Math.max(0, state.dialogDepth - 1);
        });
      } catch (error) {
        state.dialogDepth = Math.max(0, state.dialogDepth - 1);
        throw error;
      }
    };
  }

  ui[HOOK_STATE] = state;
}

function uninstallUiNotificationHooks(ctx: ExtensionContext): void {
  const ui = ctx.ui as any;
  const state = ui[HOOK_STATE] as HookState | undefined;
  if (!state || state.version !== VERSION) return;

  for (const [name, original] of Object.entries(state.originals)) {
    ui[name] = original;
  }
  delete ui[HOOK_STATE];
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    installUiNotificationHooks(pi, ctx);
  });

  pi.on("agent_end", async (_event, ctx) => {
    if (!ctx.hasUI) return;
    await notifyPi(pi, ctx, "Agent Done");
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    uninstallUiNotificationHooks(ctx);
  });

  pi.registerCommand("notify-test", {
    description: "Send a test system notification",
    handler: async (_args, ctx) => {
      await notifyPi(pi, ctx, "Test");
      if (ctx.hasUI) ctx.ui.notify("Sent a test system notification.", "info");
    },
  });
}
