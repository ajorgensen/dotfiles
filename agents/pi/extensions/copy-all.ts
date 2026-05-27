import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { spawn } from "node:child_process";

type MessagePart = {
	type?: string;
	text?: string;
	name?: string;
	arguments?: unknown;
	result?: unknown;
	content?: unknown;
};

type Message = {
	role?: string;
	content?: string | MessagePart[];
};

function stringify(value: unknown): string {
	if (typeof value === "string") return value;
	try {
		return JSON.stringify(value, null, 2);
	} catch {
		return String(value);
	}
}

function formatPart(part: MessagePart): string {
	if (part.type === "text") return part.text ?? "";
	if (part.type === "toolCall") return `[tool call: ${part.name ?? "unknown"}]\n${stringify(part.arguments ?? {})}`;
	if (part.type === "toolResult") return `[tool result]\n${stringify(part.result ?? part.content ?? {})}`;
	return `[${part.type ?? "part"}]\n${stringify(part)}`;
}

function formatMessage(message: Message): string {
	const role = message.role ?? "unknown";
	const content = Array.isArray(message.content)
		? message.content.map(formatPart).filter(Boolean).join("\n\n")
		: stringify(message.content ?? "");

	return `## ${role}\n\n${content.trim()}`.trimEnd();
}

function getConversation(ctx: ExtensionContext): { text: string; count: number } {
	const messages: string[] = [];

	for (const entry of ctx.sessionManager.getBranch()) {
		if (entry.type !== "message") continue;
		messages.push(formatMessage(entry.message as Message));
	}

	return { text: messages.join("\n\n---\n\n"), count: messages.length };
}

function clipboardCommand(): { command: string; args: string[] } {
	if (process.platform === "darwin") return { command: "pbcopy", args: [] };
	if (process.platform === "win32") return { command: "clip", args: [] };
	if (process.env.WAYLAND_DISPLAY) return { command: "wl-copy", args: [] };
	return { command: "xclip", args: ["-selection", "clipboard"] };
}

function writeClipboard(text: string): Promise<void> {
	const { command, args } = clipboardCommand();

	return new Promise((resolve, reject) => {
		const child = spawn(command, args, { stdio: ["pipe", "ignore", "pipe"] });
		let stderr = "";

		child.stderr.on("data", (chunk) => {
			stderr += chunk.toString();
		});

		child.on("error", reject);
		child.on("close", (code) => {
			if (code === 0) resolve();
			else reject(new Error(stderr.trim() || `${command} exited with code ${code}`));
		});

		child.stdin.end(text);
	});
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("copy-all", {
		description: "Copy the full conversation history to the clipboard",
		handler: async (_args, ctx) => {
			const conversation = getConversation(ctx);

			if (!conversation.text) {
				if (ctx.hasUI) ctx.ui.notify("No conversation messages to copy.", "warn");
				else console.warn("No conversation messages to copy.");
				return;
			}

			try {
				await writeClipboard(conversation.text);
				const message = `Copied ${conversation.count} conversation message${conversation.count === 1 ? "" : "s"}.`;
				if (ctx.hasUI) ctx.ui.notify(message, "info");
				else console.log(message);
			} catch (error) {
				const message = `Failed to copy conversation: ${error instanceof Error ? error.message : String(error)}`;
				if (ctx.hasUI) ctx.ui.notify(message, "error");
				else console.error(message);
			}
		},
	});
}
