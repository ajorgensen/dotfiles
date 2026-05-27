import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import { accessSync, constants } from "node:fs";
import { readFile } from "node:fs/promises";
import { extname, isAbsolute, join, resolve, sep } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

type JsonRpcId = number;

type RequestResolver = {
  resolve: (value: any) => void;
  reject: (error: Error) => void;
  timer: NodeJS.Timeout;
};

type DocumentState = {
  version: number;
  text: string;
};

type DiagnosticState = {
  items: any[];
  stamp: number;
};

type ResolvedServer = {
  command: string;
  args: string[];
  path: string;
};

type ServerSpec = {
  key: string;
  name: string;
  extensions: string[];
  languageId: string;
  commands: Array<{ command: string; args?: string[] }>;
};

const SERVER_SPECS: ServerSpec[] = [
  {
    key: "typescript",
    name: "TypeScript Language Server",
    extensions: [".ts", ".tsx", ".js", ".jsx", ".mts", ".cts", ".mjs", ".cjs"],
    languageId: "typescript",
    commands: [{ command: "typescript-language-server", args: ["--stdio"] }],
  },
  {
    key: "python",
    name: "Pyright",
    extensions: [".py"],
    languageId: "python",
    commands: [
      { command: "pyright-langserver", args: ["--stdio"] },
      { command: "basedpyright-langserver", args: ["--stdio"] },
    ],
  },
  {
    key: "rust",
    name: "rust-analyzer",
    extensions: [".rs"],
    languageId: "rust",
    commands: [{ command: "rust-analyzer" }],
  },
  {
    key: "go",
    name: "gopls",
    extensions: [".go"],
    languageId: "go",
    commands: [{ command: "gopls" }],
  },
  {
    key: "clangd",
    name: "clangd",
    extensions: [".c", ".cc", ".cpp", ".cxx", ".h", ".hh", ".hpp", ".hxx"],
    languageId: "cpp",
    commands: [{ command: "clangd", args: ["--background-index"] }],
  },
  {
    key: "json",
    name: "JSON Language Server",
    extensions: [".json", ".jsonc"],
    languageId: "json",
    commands: [{ command: "vscode-json-language-server", args: ["--stdio"] }],
  },
  {
    key: "yaml",
    name: "YAML Language Server",
    extensions: [".yaml", ".yml"],
    languageId: "yaml",
    commands: [{ command: "yaml-language-server", args: ["--stdio"] }],
  },
  {
    key: "lua",
    name: "Lua Language Server",
    extensions: [".lua"],
    languageId: "lua",
    commands: [{ command: "lua-language-server" }],
  },
];

const SYMBOL_KIND_NAMES = [
  "File",
  "Module",
  "Namespace",
  "Package",
  "Class",
  "Method",
  "Property",
  "Field",
  "Constructor",
  "Enum",
  "Interface",
  "Function",
  "Variable",
  "Constant",
  "String",
  "Number",
  "Boolean",
  "Array",
  "Object",
  "Key",
  "Null",
  "EnumMember",
  "Struct",
  "Event",
  "Operator",
  "TypeParameter",
] as const;

function stripPathSigil(path: string): string {
  return path.startsWith("@") ? path.slice(1) : path;
}

function isWithin(root: string, target: string): boolean {
  return target === root || target.startsWith(`${root}${sep}`);
}

function findExecutable(command: string): string | null {
  if (command.includes("/")) {
    try {
      accessSync(command, constants.X_OK);
      return command;
    } catch {
      return null;
    }
  }

  const pathEnv = process.env.PATH ?? "";
  for (const dir of pathEnv.split(":")) {
    if (!dir) continue;
    const fullPath = join(dir, command);
    try {
      accessSync(fullPath, constants.X_OK);
      return fullPath;
    } catch {
      // Ignore and continue
    }
  }

  return null;
}

function resolveServer(spec: ServerSpec): ResolvedServer | null {
  for (const candidate of spec.commands) {
    const executable = findExecutable(candidate.command);
    if (executable) {
      return {
        command: candidate.command,
        args: candidate.args ?? [],
        path: executable,
      };
    }
  }

  return null;
}

function specForFile(path: string): ServerSpec | undefined {
  const extension = extname(path).toLowerCase();
  return SERVER_SPECS.find((spec) => spec.extensions.includes(extension));
}

function languageIdForPath(spec: ServerSpec, path: string): string {
  const extension = extname(path).toLowerCase();
  if (spec.key === "typescript") {
    if ([".js", ".jsx", ".mjs", ".cjs"].includes(extension)) return "javascript";
    return extension === ".tsx" ? "typescriptreact" : "typescript";
  }
  if (spec.key === "clangd") {
    return [".c", ".h"].includes(extension) ? "c" : "cpp";
  }
  return spec.languageId;
}

function uriForPath(path: string): string {
  return pathToFileURL(path).href;
}

function formatRange(range: any): string {
  if (!range?.start || !range?.end) return "unknown";
  return `L${range.start.line + 1}:C${range.start.character + 1}-L${range.end.line + 1}:C${range.end.character + 1}`;
}

function asArray<T>(value: T | T[] | null | undefined): T[] {
  if (value == null) return [];
  return Array.isArray(value) ? value : [value];
}

function formatHoverContents(contents: any): string {
  if (!contents) return "";
  if (typeof contents === "string") return contents;
  if (Array.isArray(contents)) {
    return contents
      .map((item) => formatHoverContents(item))
      .filter(Boolean)
      .join("\n\n");
  }
  if (typeof contents === "object") {
    if (typeof contents.language === "string" && typeof contents.value === "string") {
      return ["```" + contents.language, contents.value, "```"].join("\n");
    }
    if (typeof contents.value === "string") return contents.value;
  }
  return JSON.stringify(contents, null, 2);
}

async function readSnippet(path: string, line: number, padding = 2): Promise<string> {
  try {
    const text = await readFile(path, "utf8");
    const lines = text.split(/\r?\n/);
    const start = Math.max(0, line - padding);
    const end = Math.min(lines.length, line + padding + 1);
    return lines
      .slice(start, end)
      .map((content, index) => {
        const lineNo = start + index + 1;
        const marker = lineNo === line + 1 ? ">" : " ";
        return `${marker} ${String(lineNo).padStart(4, " ")}: ${content}`;
      })
      .join("\n");
  } catch {
    return "";
  }
}

class LspClient {
  private readonly process: ChildProcessWithoutNullStreams;
  private readonly workspaceRoot: string;
  private readonly spec: ServerSpec;
  private readonly command: ResolvedServer;
  private readonly pending = new Map<JsonRpcId, RequestResolver>();
  private readonly documents = new Map<string, DocumentState>();
  private readonly diagnostics = new Map<string, DiagnosticState>();
  private readonly diagnosticWaiters = new Map<string, Array<(state: DiagnosticState) => void>>();
  private readonly startup: Promise<void>;
  private buffer = Buffer.alloc(0);
  private nextId = 1;
  private alive = true;

  constructor(spec: ServerSpec, command: ResolvedServer, workspaceRoot: string) {
    this.spec = spec;
    this.command = command;
    this.workspaceRoot = workspaceRoot;
    this.process = spawn(command.path, command.args, {
      cwd: workspaceRoot,
      stdio: ["pipe", "pipe", "pipe"],
      env: process.env,
    });

    this.process.stdout.on("data", (chunk: Buffer) => this.handleData(chunk));
    this.process.stderr.on("data", () => {
      // Ignore stderr noise from language servers.
    });
    this.process.on("exit", () => this.handleExit());
    this.process.on("error", (error) => this.handleExit(error));

    this.startup = this.initialize();
  }

  get isAlive(): boolean {
    return this.alive;
  }

  dispose() {
    if (!this.alive) return;
    this.alive = false;
    for (const pending of this.pending.values()) {
      clearTimeout(pending.timer);
      pending.reject(new Error(`${this.spec.name} was stopped`));
    }
    this.pending.clear();
    this.process.kill();
  }

  async hover(path: string, line: number, character: number) {
    const uri = await this.ensureDocument(path);
    return this.request("textDocument/hover", {
      textDocument: { uri },
      position: { line, character },
    });
  }

  async definition(path: string, line: number, character: number) {
    const uri = await this.ensureDocument(path);
    return this.request("textDocument/definition", {
      textDocument: { uri },
      position: { line, character },
    });
  }

  async references(path: string, line: number, character: number, includeDeclaration: boolean) {
    const uri = await this.ensureDocument(path);
    return this.request("textDocument/references", {
      textDocument: { uri },
      position: { line, character },
      context: { includeDeclaration },
    });
  }

  async documentSymbols(path: string) {
    const uri = await this.ensureDocument(path);
    return this.request("textDocument/documentSymbol", {
      textDocument: { uri },
    });
  }

  async diagnosticsForFile(path: string): Promise<any[]> {
    const uri = await this.ensureDocument(path);
    const previousStamp = this.diagnostics.get(uri)?.stamp ?? 0;
    return this.waitForDiagnostics(uri, previousStamp);
  }

  private async initialize() {
    await this.request("initialize", {
      processId: process.pid,
      rootUri: uriForPath(this.workspaceRoot),
      capabilities: {
        textDocument: {
          hover: { contentFormat: ["markdown", "plaintext"] },
          definition: {},
          references: {},
          documentSymbol: {},
          publishDiagnostics: {},
          synchronization: {
            didSave: true,
            dynamicRegistration: false,
          },
        },
        workspace: {
          workspaceFolders: true,
        },
      },
      workspaceFolders: [
        {
          uri: uriForPath(this.workspaceRoot),
          name: this.workspaceRoot.split(sep).pop() || this.workspaceRoot,
        },
      ],
      clientInfo: {
        name: "pi-lsp-tools",
        version: "1.0.0",
      },
      initializationOptions: {},
    });

    this.notify("initialized", {});
  }

  private async ensureDocument(path: string): Promise<string> {
    await this.startup;
    const text = await readFile(path, "utf8");
    const uri = uriForPath(path);
    const existing = this.documents.get(uri);

    if (!existing) {
      this.documents.set(uri, { version: 1, text });
      this.notify("textDocument/didOpen", {
        textDocument: {
          uri,
          languageId: languageIdForPath(this.spec, path),
          version: 1,
          text,
        },
      });
      return uri;
    }

    if (existing.text !== text) {
      const nextVersion = existing.version + 1;
      this.documents.set(uri, { version: nextVersion, text });
      this.notify("textDocument/didChange", {
        textDocument: {
          uri,
          version: nextVersion,
        },
        contentChanges: [{ text }],
      });
    }

    return uri;
  }

  private async waitForDiagnostics(uri: string, previousStamp: number): Promise<any[]> {
    const current = this.diagnostics.get(uri);
    if (current && current.stamp > previousStamp) return current.items;

    return new Promise((resolve) => {
      const timeout = setTimeout(() => {
        const latest = this.diagnostics.get(uri);
        resolve(latest?.items ?? []);
      }, 1200);

      const waiters = this.diagnosticWaiters.get(uri) ?? [];
      waiters.push((state) => {
        clearTimeout(timeout);
        resolve(state.items);
      });
      this.diagnosticWaiters.set(uri, waiters);
    });
  }

  private handleData(chunk: Buffer) {
    this.buffer = Buffer.concat([this.buffer, chunk]);

    while (true) {
      const headerEnd = this.buffer.indexOf("\r\n\r\n");
      if (headerEnd === -1) return;

      const header = this.buffer.subarray(0, headerEnd).toString("utf8");
      const lengthLine = header
        .split("\r\n")
        .find((line) => line.toLowerCase().startsWith("content-length:"));
      if (!lengthLine) {
        this.buffer = this.buffer.subarray(headerEnd + 4);
        continue;
      }

      const contentLength = Number(lengthLine.split(":")[1]?.trim() ?? "0");
      const messageStart = headerEnd + 4;
      const messageEnd = messageStart + contentLength;
      if (this.buffer.length < messageEnd) return;

      const payload = this.buffer.subarray(messageStart, messageEnd).toString("utf8");
      this.buffer = this.buffer.subarray(messageEnd);

      try {
        this.handleMessage(JSON.parse(payload));
      } catch {
        // Ignore malformed payloads.
      }
    }
  }

  private handleMessage(message: any) {
    if (typeof message.id === "number") {
      const pending = this.pending.get(message.id);
      if (!pending) return;

      clearTimeout(pending.timer);
      this.pending.delete(message.id);
      if (message.error) {
        pending.reject(new Error(message.error.message ?? `${this.spec.name} request failed`));
      } else {
        pending.resolve(message.result);
      }
      return;
    }

    if (message.method === "textDocument/publishDiagnostics") {
      const uri = String(message.params?.uri ?? "");
      const state = {
        items: Array.isArray(message.params?.diagnostics) ? message.params.diagnostics : [],
        stamp: Date.now(),
      } satisfies DiagnosticState;
      this.diagnostics.set(uri, state);
      const waiters = this.diagnosticWaiters.get(uri) ?? [];
      this.diagnosticWaiters.delete(uri);
      for (const waiter of waiters) waiter(state);
    }
  }

  private handleExit(error?: Error) {
    if (!this.alive) return;
    this.alive = false;
    for (const pending of this.pending.values()) {
      clearTimeout(pending.timer);
      pending.reject(error ?? new Error(`${this.spec.name} exited unexpectedly`));
    }
    this.pending.clear();
  }

  private request(method: string, params: any): Promise<any> {
    if (!this.alive) {
      return Promise.reject(new Error(`${this.spec.name} is not running`));
    }

    const id = this.nextId++;
    const payload = { jsonrpc: "2.0", id, method, params };
    const serialized = JSON.stringify(payload);
    const message = `Content-Length: ${Buffer.byteLength(serialized, "utf8")}\r\n\r\n${serialized}`;

    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error(`${this.spec.name} request timed out: ${method}`));
      }, 10_000);

      this.pending.set(id, { resolve, reject, timer });
      this.process.stdin.write(message, "utf8");
    });
  }

  private notify(method: string, params: any) {
    if (!this.alive) return;
    const payload = { jsonrpc: "2.0", method, params };
    const serialized = JSON.stringify(payload);
    const message = `Content-Length: ${Buffer.byteLength(serialized, "utf8")}\r\n\r\n${serialized}`;
    this.process.stdin.write(message, "utf8");
  }
}

export default function (pi: ExtensionAPI) {
  const workspaceRoot = resolve(process.cwd());
  const resolvedServers = new Map<string, ResolvedServer | null>();
  const clients = new Map<string, LspClient>();

  function getResolvedServer(spec: ServerSpec): ResolvedServer | null {
    if (!resolvedServers.has(spec.key)) {
      resolvedServers.set(spec.key, resolveServer(spec));
    }
    return resolvedServers.get(spec.key) ?? null;
  }

  function getAvailableSpecs(): ServerSpec[] {
    return SERVER_SPECS.filter((spec) => getResolvedServer(spec));
  }

  function normalizeWorkspacePath(rawPath: string): string {
    const stripped = stripPathSigil(rawPath.trim());
    const absolutePath = isAbsolute(stripped) ? stripped : resolve(workspaceRoot, stripped);
    if (!isWithin(workspaceRoot, absolutePath)) {
      throw new Error(`LSP tools only operate inside the startup workspace: ${workspaceRoot}`);
    }
    return absolutePath;
  }

  async function getClientForPath(path: string): Promise<{ client: LspClient; spec: ServerSpec }> {
    const spec = specForFile(path);
    if (!spec) {
      throw new Error(`No LSP mapping is configured for ${extname(path) || "this file type"}.`);
    }

    const resolved = getResolvedServer(spec);
    if (!resolved) {
      throw new Error(
        `${spec.name} is not installed. Supported extensions for this server: ${spec.extensions.join(", ")}.`,
      );
    }

    const existing = clients.get(spec.key);
    if (existing?.isAlive) {
      return { client: existing, spec };
    }

    const client = new LspClient(spec, resolved, workspaceRoot);
    clients.set(spec.key, client);
    return { client, spec };
  }

  async function locationPreview(location: any): Promise<string> {
    const targetUri = String(location?.targetUri ?? location?.uri ?? "");
    const targetRange = location?.targetSelectionRange ?? location?.selectionRange ?? location?.targetRange ?? location?.range;
    if (!targetUri || !targetUri.startsWith("file://")) return JSON.stringify(location, null, 2);

    const path = fileURLToPath(targetUri);
    const snippet = await readSnippet(path, targetRange?.start?.line ?? 0);
    const preview = [path, `Range: ${formatRange(targetRange)}`];
    if (snippet) preview.push("", snippet);
    return preview.join("\n");
  }

  pi.on("session_start", async (_event, ctx) => {
    const available = getAvailableSpecs();
    if (!ctx.hasUI) return;

    if (available.length === 0) {
      ctx.ui.notify("LSP tools loaded, but no supported language servers were found on PATH.", "warning");
      return;
    }

    ctx.ui.notify(
      `LSP tools ready: ${available.map((spec) => spec.name).join(", ")}`,
      "info",
    );
  });

  pi.on("session_shutdown", async () => {
    for (const client of clients.values()) client.dispose();
    clients.clear();
  });

  pi.registerCommand("lsp-info", {
    description: "Show detected language servers for the LSP extension",
    handler: async (_args, ctx) => {
      const lines = SERVER_SPECS.map((spec) => {
        const resolved = getResolvedServer(spec);
        return `${resolved ? "✓" : "✗"} ${spec.name} (${spec.extensions.join(", ")})${
          resolved ? ` -> ${resolved.path}` : ""
        }`;
      });
      ctx.ui.notify(lines.join("\n"), "info");
    },
  });

  pi.registerCommand("lsp-restart", {
    description: "Restart all running language server processes",
    handler: async (_args, ctx) => {
      for (const client of clients.values()) client.dispose();
      clients.clear();
      ctx.ui.notify("Restarted LSP server processes", "info");
    },
  });

  pi.registerTool({
    name: "lsp_servers",
    label: "LSP Servers",
    description: "List detected language servers and which file types they support.",
    promptSnippet: "List available language servers before relying on semantic navigation tools.",
    parameters: Type.Object({}),
    async execute() {
      const rows = SERVER_SPECS.map((spec) => {
        const resolved = getResolvedServer(spec);
        return {
          server: spec.name,
          extensions: spec.extensions,
          available: Boolean(resolved),
          executable: resolved?.path,
        };
      });

      return {
        content: [{ type: "text", text: JSON.stringify(rows, null, 2) }],
        details: { servers: rows },
      };
    },
  });

  pi.registerTool({
    name: "lsp_hover",
    label: "LSP Hover",
    description: "Get hover information for the symbol at a file position using a language server.",
    promptSnippet: "Get symbol hover/type info from an installed language server.",
    promptGuidelines: [
      "Prefer lsp_hover, lsp_definition, lsp_references, lsp_symbols, and lsp_diagnostics for semantic code navigation when a language server is available.",
    ],
    parameters: Type.Object({
      path: Type.String({ description: "Path to a source file inside the startup workspace" }),
      line: Type.Number({ description: "1-based line number" }),
      character: Type.Number({ description: "1-based character/column number" }),
    }),
    async execute(_toolCallId, params) {
      const path = normalizeWorkspacePath(params.path);
      const { client, spec } = await getClientForPath(path);
      const result = await client.hover(path, params.line - 1, params.character - 1);
      const text = formatHoverContents(result?.contents) || "No hover information available.";

      return {
        content: [{ type: "text", text }],
        details: { server: spec.name, range: result?.range },
      };
    },
  });

  pi.registerTool({
    name: "lsp_definition",
    label: "LSP Definition",
    description: "Find definitions for the symbol at a file position using a language server.",
    promptSnippet: "Jump to symbol definitions semantically using a language server.",
    parameters: Type.Object({
      path: Type.String({ description: "Path to a source file inside the startup workspace" }),
      line: Type.Number({ description: "1-based line number" }),
      character: Type.Number({ description: "1-based character/column number" }),
      limit: Type.Optional(Type.Number({ description: "Maximum number of results to return", default: 10 })),
    }),
    async execute(_toolCallId, params) {
      const path = normalizeWorkspacePath(params.path);
      const { client, spec } = await getClientForPath(path);
      const result = await client.definition(path, params.line - 1, params.character - 1);
      const locations = asArray(result).slice(0, params.limit ?? 10);
      const previews = await Promise.all(locations.map((location) => locationPreview(location)));
      const text = previews.length > 0 ? previews.join("\n\n---\n\n") : "No definitions found.";

      return {
        content: [{ type: "text", text }],
        details: { server: spec.name, count: locations.length, locations },
      };
    },
  });

  pi.registerTool({
    name: "lsp_references",
    label: "LSP References",
    description: "Find references for the symbol at a file position using a language server.",
    promptSnippet: "Find semantic references to a symbol using a language server.",
    parameters: Type.Object({
      path: Type.String({ description: "Path to a source file inside the startup workspace" }),
      line: Type.Number({ description: "1-based line number" }),
      character: Type.Number({ description: "1-based character/column number" }),
      includeDeclaration: Type.Optional(Type.Boolean({ description: "Whether to include the symbol declaration", default: false })),
      limit: Type.Optional(Type.Number({ description: "Maximum number of results to return", default: 20 })),
    }),
    async execute(_toolCallId, params) {
      const path = normalizeWorkspacePath(params.path);
      const { client, spec } = await getClientForPath(path);
      const result = await client.references(path, params.line - 1, params.character - 1, params.includeDeclaration ?? false);
      const locations = asArray(result).slice(0, params.limit ?? 20);
      const previews = await Promise.all(locations.map((location) => locationPreview(location)));
      const text = previews.length > 0 ? previews.join("\n\n---\n\n") : "No references found.";

      return {
        content: [{ type: "text", text }],
        details: { server: spec.name, count: locations.length, locations },
      };
    },
  });

  pi.registerTool({
    name: "lsp_symbols",
    label: "LSP Symbols",
    description: "List document symbols for a source file using a language server.",
    promptSnippet: "Inspect a file's symbol outline using a language server.",
    parameters: Type.Object({
      path: Type.String({ description: "Path to a source file inside the startup workspace" }),
      limit: Type.Optional(Type.Number({ description: "Maximum number of symbols to return", default: 200 })),
    }),
    async execute(_toolCallId, params) {
      const path = normalizeWorkspacePath(params.path);
      const { client, spec } = await getClientForPath(path);
      const result = await client.documentSymbols(path);
      const rows: Array<{ name: string; kind: string; range: string; detail?: string; depth: number }> = [];

      function visit(symbol: any, depth: number) {
        if (rows.length >= (params.limit ?? 200)) return;
        const kindIndex = Number(symbol?.kind ?? 0);
        const kind = SYMBOL_KIND_NAMES[kindIndex - 1] ?? `Kind${kindIndex}`;
        rows.push({
          name: String(symbol?.name ?? "(anonymous)"),
          kind,
          range: formatRange(symbol?.selectionRange ?? symbol?.location?.range ?? symbol?.range),
          detail: typeof symbol?.detail === "string" ? symbol.detail : undefined,
          depth,
        });

        for (const child of symbol?.children ?? []) {
          visit(child, depth + 1);
        }
      }

      for (const symbol of asArray(result)) {
        visit(symbol, 0);
      }

      const text =
        rows.length > 0
          ? rows
              .map((row) => `${"  ".repeat(row.depth)}- ${row.name} [${row.kind}] ${row.range}${row.detail ? ` — ${row.detail}` : ""}`)
              .join("\n")
          : "No symbols found.";

      return {
        content: [{ type: "text", text }],
        details: { server: spec.name, symbols: rows },
      };
    },
  });

  pi.registerTool({
    name: "lsp_diagnostics",
    label: "LSP Diagnostics",
    description: "Get current diagnostics for a source file using a language server.",
    promptSnippet: "Fetch semantic/compiler diagnostics for a file using a language server.",
    parameters: Type.Object({
      path: Type.String({ description: "Path to a source file inside the startup workspace" }),
    }),
    async execute(_toolCallId, params) {
      const path = normalizeWorkspacePath(params.path);
      const { client, spec } = await getClientForPath(path);
      const diagnostics = await client.diagnosticsForFile(path);
      const rows = await Promise.all(
        diagnostics.map(async (diagnostic) => ({
          severity:
            diagnostic?.severity === 1
              ? "error"
              : diagnostic?.severity === 2
                ? "warning"
                : diagnostic?.severity === 3
                  ? "info"
                  : diagnostic?.severity === 4
                    ? "hint"
                    : "unknown",
          code: diagnostic?.code,
          message: String(diagnostic?.message ?? ""),
          range: formatRange(diagnostic?.range),
          snippet: await readSnippet(path, diagnostic?.range?.start?.line ?? 0, 1),
        })),
      );

      const text =
        rows.length > 0
          ? rows
              .map((row) => {
                const parts = [`${row.severity.toUpperCase()} ${row.range}`];
                if (row.code != null) parts.push(`code=${row.code}`);
                parts.push(row.message);
                if (row.snippet) parts.push("", row.snippet);
                return parts.join("\n");
              })
              .join("\n\n---\n\n")
          : "No diagnostics reported.";

      return {
        content: [{ type: "text", text }],
        details: { server: spec.name, diagnostics: rows },
      };
    },
  });
}
