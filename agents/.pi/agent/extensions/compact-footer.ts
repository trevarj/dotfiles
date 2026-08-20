/**
 * compact-footer - a two-line pi footer.
 *
 * Line 1 is session state and is always present: model and thinking level,
 * where you are with the branch and working-tree markers, the session name if
 * one is set, and how full the context is.
 *
 * Line 2 is whatever the extensions are reporting through setStatus() -
 * caveman's level, ponytail, plan mode, lens, the subagents fleet, quota - and
 * is omitted entirely when nothing has anything to say.
 *
 * The built-in footer spends the same two or three lines on token, cache and
 * cost counters instead, and has no way to turn them off.
 *
 * Deliberately importless apart from node builtins: an extension dropped into
 * ~/.pi/agent/extensions is a loose file rather than an npm package, so it
 * cannot rely on resolving @earendil-works/* at runtime. Colors come from the
 * theme handed to the factory, and the width math is local.
 */

import { execFile } from "node:child_process";

// Minimal shapes for the parts of pi's API this uses.
type Theme = { fg(color: string, text: string): string };
type Tui = { requestRender(force?: boolean): void };
type FooterData = {
	getGitBranch(): string | null;
	getExtensionStatuses(): ReadonlyMap<string, string>;
};
type Ctx = {
	cwd: string;
	mode: string;
	model?: { id: string; reasoning?: unknown };
	thinkingLevel?: string;
	sessionManager: { getSessionName(): string | undefined };
	getContextUsage(): { percent: number | null } | undefined;
	ui: { setFooter(factory: unknown): void };
};

const ANSI_PATTERN = /\x1b\[[0-9;]*m/g;
const ELLIPSIS = "…";
const SEPARATOR = " · ";
const MIN_GAP = 2;

/**
 * The status key pi-quota-status registers under. Its text already carries both
 * windows for a subscription provider - "5h 72% 3h12m · Wk 48% 4d" - so this is
 * only about where the line puts it.
 */
const QUOTA_STATUS_KEY = "pi-quota-status";

// Grapheme-aware width: emoji and wide CJK count as 2 cells, not 1. The footer
// contract is that a returned line never exceeds `width`, and pi-tui measures
// with the same rule; counting code points made emoji-heavy status lines
// (ponytail's 🌿🐴, etc.) underflow, the right-pinned quota overflowed the
// viewport, and kitty outside tmux (no tmux clipping) wrapped it into
// gibberish. Inside tmux the line just clipped, so it looked fine there.
// ponytail: not the full East-Asian width table - only the ranges this footer
// actually meets (emoji, misc symbols, CJK, fullwidth); widen if a status ever
// shows something it misses.
const graphemeSegmenter = new Intl.Segmenter(undefined, { granularity: "grapheme" });

function isWideCp(cp: number): boolean {
	return (
		(cp >= 0x1100 && cp <= 0x115f) ||
		(cp >= 0x231a && cp <= 0x231b) ||
		(cp >= 0x2329 && cp <= 0x232a) ||
		(cp >= 0x2e80 && cp <= 0x303e) ||
		(cp >= 0x3041 && cp <= 0x33ff) ||
		(cp >= 0x3400 && cp <= 0x4dbf) ||
		(cp >= 0x4e00 && cp <= 0x9fff) ||
		(cp >= 0xa000 && cp <= 0xa4cf) ||
		(cp >= 0xac00 && cp <= 0xd7a3) ||
		(cp >= 0xf900 && cp <= 0xfaff) ||
		(cp >= 0xfe10 && cp <= 0xfe19) ||
		(cp >= 0xfe30 && cp <= 0xfe6f) ||
		(cp >= 0xff01 && cp <= 0xff60) ||
		(cp >= 0xffe0 && cp <= 0xffe6) ||
		(cp >= 0x1f000 && cp <= 0x1faff) ||
		(cp >= 0x2600 && cp <= 0x27bf) ||
		(cp >= 0x2b50 && cp <= 0x2bff)
	);
}

function graphemeWidth(segment: string): number {
	if (!segment) return 0;
	const cp = segment.codePointAt(0)!;
	if (cp < 0x20 || (cp >= 0x7f && cp < 0xa0)) return 0; // control
	// A VS16 (emoji presentation selector) or ZWJ in the cluster forces width 2.
	if (isWideCp(cp) || segment.includes("\uFE0F") || segment.includes("\u200D")) return 2;
	return 1;
}

/** Printable width, ignoring color escapes. */
function width(text: string): number {
	let total = 0;
	for (const { segment } of graphemeSegmenter.segment(text.replace(ANSI_PATTERN, ""))) {
		total += graphemeWidth(segment);
	}
	return total;
}

/** Free-form status text has to survive on one line. */
function flatten(text: string): string {
	return text
		.replace(/[\r\n\t]/g, " ")
		.replace(/ {2,}/g, " ")
		.trim();
}

function contractHome(cwd: string): string {
	const home = process.env.HOME;
	if (!home) return cwd;
	if (cwd === home) return "~";
	return cwd.startsWith(`${home}/`) ? `~${cwd.slice(home.length)}` : cwd;
}

/** Cut to fit, dropping the styling only when the text actually has to be cut. */
function truncate(text: string, max: number): string {
	if (width(text) <= max) return text;
	if (max <= 0) return "";
	const plain = text.replace(ANSI_PATTERN, "");
	const out: string[] = [];
	let used = 0;
	for (const { segment } of graphemeSegmenter.segment(plain)) {
		const gw = graphemeWidth(segment);
		if (used + gw > max - 1) break; // reserve one cell for the ellipsis
		out.push(segment);
		used += gw;
	}
	return out.join("") + ELLIPSIS;
}

/** Last two path components, for when the full path will not fit. */
function shorten(path: string): string {
	const parts = path.split("/").filter(Boolean);
	return parts.length <= 2 ? path : `${ELLIPSIS}/${parts.slice(-2).join("/")}`;
}

// ---------------------------------------------------------------------------
// Working-tree state
//
// pi hands extensions the branch name and nothing else, so the counters come
// from our own `git status`. It runs on a timer and caches, never inside
// render(): render is called on every frame.
// ---------------------------------------------------------------------------

type GitCounts = {
	staged: number;
	dirty: number;
	untracked: number;
	ahead: number;
	behind: number;
};

const GIT_TIMEOUT_MS = 2000;
const GIT_POLL_MS = 5000;
const GIT_MAX_BUFFER = 8 * 1024 * 1024;

// Keyed by directory: a session replacement can land in another repository, and
// showing the previous one's counters would be worse than showing none.
const gitState: { cwd: string | undefined; counts: GitCounts | null; inFlight: boolean } = {
	cwd: undefined,
	counts: null,
	inFlight: false,
};

function countsFor(cwd: string): GitCounts | null {
	return gitState.cwd === cwd ? gitState.counts : null;
}

/** Set by the live footer component so background refreshes can repaint. */
let notifyRender: (() => void) | undefined;

function parseGitStatus(stdout: string): GitCounts {
	const counts: GitCounts = { staged: 0, dirty: 0, untracked: 0, ahead: 0, behind: 0 };
	for (const line of stdout.split("\n")) {
		if (line.startsWith("# branch.ab ")) {
			const ab = /\+(\d+) -(\d+)/.exec(line);
			if (ab) {
				counts.ahead = Number(ab[1]);
				counts.behind = Number(ab[2]);
			}
		} else if (line.startsWith("1 ") || line.startsWith("2 ")) {
			// "1 XY ..." - X is the staged status, Y the unstaged one, "." is unchanged.
			const staged = line[2];
			const unstaged = line[3];
			if (staged && staged !== ".") counts.staged += 1;
			if (unstaged && unstaged !== ".") counts.dirty += 1;
		} else if (line.startsWith("? ")) {
			counts.untracked += 1;
		}
	}
	return counts;
}

function formatGitCounts(counts: GitCounts | null): string {
	if (!counts) return "";
	const parts: string[] = [];
	if (counts.staged) parts.push(`+${counts.staged}`);
	if (counts.dirty) parts.push(`~${counts.dirty}`);
	if (counts.untracked) parts.push(`?${counts.untracked}`);
	if (counts.ahead) parts.push(`⇡${counts.ahead}`);
	if (counts.behind) parts.push(`⇣${counts.behind}`);
	return parts.join(" ");
}

function refreshGit(cwd: string): void {
	if (gitState.inFlight) return;
	gitState.inFlight = true;
	const before = formatGitCounts(countsFor(cwd));
	execFile(
		"git",
		["status", "--porcelain=v2", "--branch"],
		{ cwd, timeout: GIT_TIMEOUT_MS, maxBuffer: GIT_MAX_BUFFER, encoding: "utf8" },
		(error, stdout) => {
			gitState.inFlight = false;
			gitState.cwd = cwd;
			// Not a repository, no git, a timeout, a pathological amount of
			// output: all mean "no markers", never an error in the footer.
			gitState.counts = error ? null : parseGitStatus(stdout);
			if (formatGitCounts(gitState.counts) !== before) notifyRender?.();
		},
	);
}

// ---------------------------------------------------------------------------
// The footer itself
// ---------------------------------------------------------------------------

class CompactFooter {
	// Written out rather than declared as constructor parameter properties:
	// TypeScript loaders that only strip types, node's included, reject those.
	readonly ctx: Ctx;
	readonly theme: Theme;
	readonly footerData: FooterData;
	readonly notify: () => void;
	timer: ReturnType<typeof setInterval> | undefined;

	constructor(tui: Tui, ctx: Ctx, theme: Theme, footerData: FooterData) {
		this.ctx = ctx;
		this.theme = theme;
		this.footerData = footerData;

		this.notify = () => tui.requestRender();
		notifyRender = this.notify;
		refreshGit(ctx.cwd);
		this.timer = setInterval(() => refreshGit(ctx.cwd), GIT_POLL_MS);
		// Nothing here should keep pi alive on its own.
		this.timer.unref?.();
	}

	dispose(): void {
		if (this.timer) clearInterval(this.timer);
		this.timer = undefined;
		// Only stand down if a newer component has not already taken over.
		if (notifyRender === this.notify) notifyRender = undefined;
	}

	/** Line 1, at three levels of desperation about horizontal space. */
	private sessionLine(viewport: number): string {
		const dim = (text: string) => this.theme.fg("dim", text);

		const model = this.ctx.model?.id ?? "no-model";
		const modelText = this.ctx.model?.reasoning ? `${model} ${this.ctx.thinkingLevel ?? "off"}` : model;

		const branch = this.footerData.getGitBranch();
		const counts = countsFor(this.ctx.cwd);
		const markers = formatGitCounts(counts);
		const inRepo = branch !== null || counts !== null;
		const suffix = inRepo ? ` (${[branch ?? "detached", markers].filter(Boolean).join(" ")})` : "";

		const name = this.ctx.sessionManager.getSessionName();

		// Context percentage keeps pi's own thresholds, so the number means what
		// it used to mean.
		const usage = this.ctx.getContextUsage();
		let context = "";
		let contextStyled = "";
		if (usage) {
			const percent = usage.percent;
			context = percent === null ? "ctx ?" : `ctx ${percent.toFixed(0)}%`;
			const color = percent === null ? "dim" : percent > 90 ? "error" : percent > 70 ? "warning" : "dim";
			contextStyled = this.theme.fg(color, context);
		}

		const assemble = (path: string, withName: boolean) => {
			const plain: string[] = [modelText, path + suffix];
			const styled: string[] = [dim(modelText), dim(path + suffix)];
			if (withName && name) {
				plain.push(name);
				styled.push(dim(name));
			}
			if (context) {
				plain.push(context);
				styled.push(contextStyled);
			}
			return { plain: plain.join(SEPARATOR), styled: styled.join(dim(SEPARATOR)) };
		};

		const home = contractHome(this.ctx.cwd);
		for (const candidate of [assemble(home, true), assemble(home, false), assemble(shorten(home), false)]) {
			if (width(candidate.plain) <= viewport) return candidate.styled;
		}

		return dim(truncate(assemble(shorten(home), false).plain, viewport));
	}

	/**
	 * Line 2, or nothing at all when no extension is reporting. Active-model
	 * subscription usage is pinned to the right edge; everything else runs
	 * from the left.
	 */
	private statusLine(viewport: number): string | undefined {
		let usage: string | undefined;
		const others: string[] = [];
		for (const [key, status] of [...this.footerData.getExtensionStatuses()].sort(([a], [b]) => a.localeCompare(b))) {
			// Statuses arrive styled by their own extension; pass them through.
			const text = flatten(status);
			if (!text) continue;
			if (key === QUOTA_STATUS_KEY) usage = text;
			else others.push(text);
		}
		const right = usage ?? "";
		if (!right && others.length === 0) return undefined;

		const left = others.join(this.theme.fg("dim", SEPARATOR));
		if (!right) return truncate(left, viewport);

		const rightWidth = width(right);
		const room = viewport - rightWidth - MIN_GAP;
		// When it is that tight, the right cluster is the thing worth keeping -
		// but it still has to fit the viewport rather than wrap.
		if (!left || room <= 0) {
			const fitted = truncate(right, viewport);
			return " ".repeat(Math.max(0, viewport - width(fitted))) + fitted;
		}

		const fitted = truncate(left, room);
		return fitted + " ".repeat(Math.max(MIN_GAP, viewport - width(fitted) - rightWidth)) + right;
	}

	render(viewport: number): string[] {
		const lines = [this.sessionLine(viewport)];
		const statuses = this.statusLine(viewport);
		if (statuses) lines.push(statuses);
		return lines;
	}
}

type ExtensionAPI = { on(event: string, handler: (event: unknown, ctx: Ctx) => void): void };

export default function compactFooter(pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		// setFooter only means anything in the interactive TUI; print, json and
		// rpc modes render no footer at all.
		if (ctx.mode !== "tui") return;
		refreshGit(ctx.cwd);
		ctx.ui.setFooter(
			(tui: Tui, theme: Theme, footerData: FooterData) => new CompactFooter(tui, ctx, theme, footerData),
		);
	});

	// The agent has just finished writing files, so the counters are stale.
	pi.on("agent_end", (_event, ctx) => refreshGit(ctx.cwd));
}
