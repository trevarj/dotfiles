/**
 * codex-weekly - always show Codex weekly quota in the pi footer.
 *
 * pi-quota-status only surfaces quota for the ACTIVE /login model, so while you
 * run a non-subscription model (ollama, glm, ...) the Codex weekly figure is
 * hidden even though the `codex` CLI can read it itself. This extension polls
 * the Codex app-server JSON-RPC (`account/rateLimits/read`) on a timer and
 * publishes the weekly remaining % through its own setStatus slot, which
 * compact-footer collects like any other extension status.
 *
 * Importless by design (loose file, not an npm package). The RPC shape mirrors
 * pi-quota-status's codex-rpc client: initialize -> initialized notify ->
 * account/rateLimits/read, one line of JSON per message on stdout.
 */

type Theme = { fg(color: string, text: string): string };
type Ctx = {
	mode: string;
	cwd: string;
	model?: { id?: string };
	ui: { setStatus(key: string, text: string | undefined): void };
};

const STATUS_KEY = "codex-weekly";
const POLL_MS = 5 * 60 * 1000;
const INIT_TIMEOUT_MS = 8_000;
const REQUEST_TIMEOUT_MS = 3_000;
const WEEKLY_WINDOW_MINUTES = 7 * 24 * 60;

type Pending = {
	resolve: (value: unknown) => void;
	reject: (error: Error) => void;
	timer: ReturnType<typeof setTimeout>;
};

/** Minimal Codex app-server JSON-RPC client (stdio, newline-delimited JSON). */
class CodexRpcClient {
	private child: import("node:child_process").ChildProcess;
	private buffer = "";
	private nextId = 1;
	private pending = new Map<number, Pending>();
	private closed = false;

	constructor() {
		const { spawn } = require("node:child_process") as typeof import("node:child_process");
		this.child = spawn("codex", ["-s", "read-only", "-a", "untrusted", "app-server"], {
			stdio: ["pipe", "pipe", "pipe"],
			env: process.env,
		});
		this.child.stdout!.setEncoding("utf8");
		this.child.stdout!.on("data", (chunk: string) => this.onData(chunk));
		this.child.stderr!.resume();
		this.child.on("error", (e: Error) => this.rejectAll(e));
		this.child.on("close", () => {
			this.closed = true;
			this.rejectAll(new Error("codex app-server closed"));
		});
	}

	async initialize(): Promise<void> {
		await this.request(
			"initialize",
			{ clientInfo: { name: "codex-weekly", version: "0.0.0" } },
			INIT_TIMEOUT_MS,
		);
		this.notify("initialized");
	}

	request(method: string, params: Record<string, unknown> = {}, timeoutMs = REQUEST_TIMEOUT_MS): Promise<unknown> {
		if (this.closed) return Promise.reject(new Error("codex app-server closed"));
		const id = this.nextId++;
		return new Promise((resolve, reject) => {
			const timer = setTimeout(() => {
				this.pending.delete(id);
				reject(new Error(`codex RPC timed out: ${method}`));
			}, timeoutMs);
			this.pending.set(id, { resolve, reject, timer });
			this.write({ id, method, params }, (err) => {
				if (!err) return;
				const p = this.pending.get(id);
				if (!p) return;
				clearTimeout(p.timer);
				this.pending.delete(id);
				p.reject(err);
			});
		});
	}

	shutdown(): void {
		this.rejectAll(new Error("shut down"));
		if (!this.child.killed) this.child.kill();
	}

	private notify(method: string, params: Record<string, unknown> = {}): void {
		this.write({ method, params });
	}

	private write(payload: Record<string, unknown>, cb?: (e?: Error | null) => void): void {
		try {
			this.child.stdin!.write(`${JSON.stringify(payload)}\n`, cb);
		} catch (e) {
			cb?.(e instanceof Error ? e : new Error(String(e)));
		}
	}

	private onData(chunk: string): void {
		this.buffer += chunk;
		let nl = this.buffer.indexOf("\n");
		while (nl >= 0) {
			const line = this.buffer.slice(0, nl).trim();
			this.buffer = this.buffer.slice(nl + 1);
			this.onLine(line);
			nl = this.buffer.indexOf("\n");
		}
	}

	private onLine(line: string): void {
		if (!line) return;
		let msg: any;
		try { msg = JSON.parse(line); } catch { return; }
		if (typeof msg?.id !== "number") return;
		const p = this.pending.get(msg.id);
		if (!p) return;
		clearTimeout(p.timer);
		this.pending.delete(msg.id);
		if (msg.error) p.reject(new Error(msg.error?.message ?? "codex RPC failed"));
		else p.resolve(msg.result);
	}

	private rejectAll(e: Error): void {
		for (const [id, p] of this.pending) {
			clearTimeout(p.timer);
			this.pending.delete(id);
			p.reject(e);
		}
	}
}

function num(v: unknown): number | undefined {
	return typeof v === "number" && Number.isFinite(v) ? v : undefined;
}

function clamp(n: number): number {
	return Math.max(0, Math.min(100, Math.round(n)));
}

/**
 * Pull the weekly remaining % out of the rateLimits result. The weekly window
 * is `secondary` (primary is the 5h window); fall back to whichever window
 * reports windowDurationMins === 7d in case the ordering differs.
 */
function weeklyRemainingPercent(result: unknown): number | undefined {
	const root = (result ?? {}) as Record<string, any>;
	const rateLimits = root.rateLimits ?? root.rate_limits;
	if (!rateLimits || typeof rateLimits !== "object") return undefined;
	const windows = [rateLimits.primary, rateLimits.secondary].filter(Boolean) as any[];
	let weekly = rateLimits.secondary;
	for (const w of windows) {
		const mins = num(w.windowDurationMins ?? w.window_duration_mins ?? w.window_minutes ?? w.windowMinutes);
		if (mins === WEEKLY_WINDOW_MINUTES) { weekly = w; break; }
	}
	if (!weekly) return undefined;
	const used = num(weekly.usedPercent ?? weekly.used_percent ?? weekly.used);
	if (used === undefined) return undefined;
	return clamp(100 - used);
}

async function readWeekly(): Promise<number | undefined> {
	const client = new CodexRpcClient();
	try {
		await client.initialize();
		const result = await client.request("account/rateLimits/read");
		return weeklyRemainingPercent(result);
	} catch {
		return undefined;
	} finally {
		client.shutdown();
	}
}

type ExtensionAPI = { on(event: string, handler: (event: unknown, ctx: Ctx) => void): void };

export default function codexWeekly(pi: ExtensionAPI): void {
	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return; // print/json/rpc render no footer

		const render = async () => {
			// Defer to pi-quota-status when a codex /login model is active: it
			// already shows the full 5h + weekly line for that case.
			if (ctx.model?.id?.startsWith("openai-codex/")) {
				ctx.ui.setStatus(STATUS_KEY, undefined);
				return;
			}
			try {
				const pct = await readWeekly();
				ctx.ui.setStatus(STATUS_KEY, pct === undefined ? undefined : `Codex Wk ${pct}%`);
			} catch {
				ctx.ui.setStatus(STATUS_KEY, undefined);
			}
		};

		void render();
		const timer = setInterval(render, POLL_MS);
		timer.unref?.();
	});
}