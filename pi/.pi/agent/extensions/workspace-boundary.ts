import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import {
  createEditTool,
  createFindTool,
  createGrepTool,
  createLsTool,
  createReadTool,
  createWriteTool,
} from "@mariozechner/pi-coding-agent";
import { realpath } from "node:fs/promises";
import { homedir } from "node:os";
import { basename, dirname, isAbsolute, resolve, sep } from "node:path";

function stripPathSigil(path: string): string {
  return path.startsWith("@") ? path.slice(1) : path;
}

function normalizeToolPath(cwd: string, rawPath?: unknown): string | undefined {
  if (typeof rawPath !== "string" || rawPath.trim().length === 0) return undefined;
  const path = stripPathSigil(rawPath.trim());
  return isAbsolute(path) ? path : resolve(cwd, path);
}

async function canonicalizePath(path: string): Promise<string> {
  try {
    return await realpath(path);
  } catch {
    const parent = dirname(path);
    if (parent === path) return path;

    try {
      return resolve(await realpath(parent), basename(path));
    } catch {
      return path;
    }
  }
}

function isWithin(root: string, target: string): boolean {
  return target === root || target.startsWith(`${root}${sep}`);
}

function tokenizeCommand(command: string): string[] {
  const tokens: string[] = [];
  const regex = /"([^"]*)"|'([^']*)'|(\S+)/g;

  for (const match of command.matchAll(regex)) {
    const token = match[1] ?? match[2] ?? match[3] ?? "";
    const cleaned = token.replace(/^[;|&()]+|[;|&()]+$/g, "").trim();
    if (cleaned) tokens.push(cleaned);
  }

  return tokens;
}

function extractBashPathCandidates(command: string, cwd: string): string[] {
  const candidates = new Set<string>();
  const home = homedir();

  for (const token of tokenizeCommand(command)) {
    if (token === "~") {
      candidates.add(home);
      continue;
    }

    if (token.startsWith("~/")) {
      candidates.add(resolve(home, token.slice(2)));
      continue;
    }

    if (token === ".." || token.startsWith("../")) {
      candidates.add(resolve(cwd, token));
      continue;
    }

    if (isAbsolute(token)) {
      candidates.add(token);
    }
  }

  return [...candidates];
}

export default function (pi: ExtensionAPI) {
  const startupCwd = process.cwd();
  const originalRead = createReadTool(startupCwd);
  const originalWrite = createWriteTool(startupCwd);
  const originalEdit = createEditTool(startupCwd);
  const originalGrep = createGrepTool(startupCwd);
  const originalFind = createFindTool(startupCwd);
  const originalLs = createLsTool(startupCwd);

  let workspaceRoot = resolve(startupCwd);
  const approvedPaths = new Set<string>();

  async function refreshWorkspaceRoot() {
    workspaceRoot = await canonicalizePath(startupCwd);
    approvedPaths.clear();
  }

  async function requestPermission(targetPath: string, reason: string, ctx: ExtensionContext): Promise<boolean> {
    const canonicalTarget = await canonicalizePath(targetPath);
    if (isWithin(workspaceRoot, canonicalTarget)) return true;

    for (const approved of approvedPaths) {
      if (isWithin(approved, canonicalTarget)) return true;
    }

    if (!ctx.hasUI) {
      return false;
    }

    const choice = await ctx.ui.select(
      [
        "Outside-workspace access requested.",
        `Workspace root: ${workspaceRoot}`,
        `Requested path: ${canonicalTarget}`,
        "",
        reason,
        "",
        "Choose an action:",
      ].join("\n"),
      ["Allow once", "Allow this path for session", "Deny"],
    );

    if (choice === "Allow this path for session") {
      approvedPaths.add(canonicalTarget);
      return true;
    }

    return choice === "Allow once";
  }

  async function enforcePath(rawPath: unknown, toolName: string, ctx: ExtensionContext): Promise<void> {
    const absolutePath = normalizeToolPath(startupCwd, rawPath) ?? startupCwd;
    const allowed = await requestPermission(
      absolutePath,
      `The ${toolName} tool wants to access a path outside the directory pi was started in.`,
      ctx,
    );

    if (!allowed) {
      throw new Error(`Access to \"${absolutePath}\" is outside the startup directory and was not approved.`);
    }
  }

  pi.on("session_start", async (_event, ctx) => {
    await refreshWorkspaceRoot();
    if (ctx.hasUI) {
      ctx.ui.notify(`Workspace boundary active: ${workspaceRoot}`, "info");
    }
  });

  pi.registerTool({
    name: "read",
    label: originalRead.label,
    description: originalRead.description,
    parameters: originalRead.parameters,
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      await enforcePath(params.path, "read", ctx);
      return originalRead.execute(toolCallId, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    name: "write",
    label: originalWrite.label,
    description: originalWrite.description,
    parameters: originalWrite.parameters,
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      await enforcePath(params.path, "write", ctx);
      return originalWrite.execute(toolCallId, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    name: "edit",
    label: originalEdit.label,
    description: originalEdit.description,
    parameters: originalEdit.parameters,
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      await enforcePath(params.path, "edit", ctx);
      return originalEdit.execute(toolCallId, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    name: "grep",
    label: originalGrep.label,
    description: originalGrep.description,
    parameters: originalGrep.parameters,
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      await enforcePath(params.path, "grep", ctx);
      return originalGrep.execute(toolCallId, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    name: "find",
    label: originalFind.label,
    description: originalFind.description,
    parameters: originalFind.parameters,
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      await enforcePath(params.path, "find", ctx);
      return originalFind.execute(toolCallId, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    name: "ls",
    label: originalLs.label,
    description: originalLs.description,
    parameters: originalLs.parameters,
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      await enforcePath(params.path, "ls", ctx);
      return originalLs.execute(toolCallId, params, signal, onUpdate);
    },
  });

  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return;

    const candidates = extractBashPathCandidates(String(event.input.command ?? ""), startupCwd);
    const outsidePaths: string[] = [];

    for (const candidate of candidates) {
      const canonicalCandidate = await canonicalizePath(candidate);
      if (!isWithin(workspaceRoot, canonicalCandidate)) {
        outsidePaths.push(canonicalCandidate);
      }
    }

    if (outsidePaths.length === 0) return;

    const summary = outsidePaths.slice(0, 5).map((path) => `- ${path}`).join("\n");
    const more = outsidePaths.length > 5 ? `\n- ...and ${outsidePaths.length - 5} more` : "";
    const allowed = await requestPermission(
      outsidePaths[0],
      [
        "The bash command appears to reference paths outside the startup directory:",
        summary + more,
        "",
        `Command: ${event.input.command}`,
        "",
        "Note: bash path detection is heuristic. File/path tools are enforced strictly by tool overrides.",
      ].join("\n"),
      ctx,
    );

    if (!allowed) {
      return {
        block: true,
        reason: "Bash command references paths outside the startup directory and was not approved.",
      };
    }
  });
}
