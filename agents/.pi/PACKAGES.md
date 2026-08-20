# pi extensions: what is installed and what it can reach

pi extensions run with full user permissions. Nothing sandboxes them, so the
only real control is knowing what each one does before its version moves. The
set is pinned in `trev-nix/packages/pi/extensions/package-lock.json` and mounted
read-only from the nix store; a bump is a lockfile diff to review, not a
background `pi install`.

Reviewed at the versions below. Findings come from reading the shipped sources
in the built bundle (exec use, outbound hosts, credential paths).

| Package | Version | What it does |
|---|---|---|
| `@narumitw/pi-plan-mode` | 0.49.3 | Read-only `/plan` mode |
| `@narumitw/pi-tui-kit` | 0.56.x | Shared TUI widgets; pulled in by plan-mode, not listed as a package |
| `pi-quota-status` | 0.3.0 | `/quota`: 5-hour and weekly subscription limits |
| `pi-subagents` | 0.51.0 | `/subagents`: delegation and scripted multi-agent runs |
| `pi-web-access` | 0.24.0 | `web_search`, `fetch_content`, repo clone, PDF, YouTube |
| `@dietrichgebert/ponytail` | 4.9.0 | Pushback against writing unnecessary code |
| `pi-lens` | 4.0.1 | Live LSP, linter and formatter feedback |
| `pi-simplify` | 0.2.3 | Reviews changed code for clarity |
| `pi-memory` | 0.4.2 | Daily logs, long-term memory, scratchpad |
| `pi-caveman` | 1.0.8 | `/caveman`: token-saving output modes |
| `pi-claude-bridge` | 0.7.0 | Claude Code Agent SDK provider (Opus/Sonnet/Haiku) + opt-in AskClaude tool |

## Notes worth keeping

**`pi-subagents` is the largest surface.** 19 of its files shell out. It spawns
further pi processes, and its share command exports a session to HTML and
uploads it with `gh gist create` using your GitHub login, then prints a
`shittycodingagent.ai/session/?<gist-id>` viewer link. That path only runs when
invoked, but it is a one-command route from a local transcript to a URL-public
gist. Do not use it on work sessions.

**`pi-quota-status` talks to the auth endpoints on purpose.** It polls
`api.anthropic.com/api/oauth/usage`, `chatgpt.com/backend-api/wham/usage` and
`api.openai.com/auth`, and shells out to the local `codex` CLI to reconcile a
stale 5-hour zero. That is the feature; it reads the OAuth session pi already
holds and does not touch `~/.ssh` or the gpg agent.

**`pi-web-access` reaches many hosts, by design.** Its provider fallback chain
covers two dozen search and extraction services. Configured keyless here (Exa,
plus OpenAI search reusing the Codex `/login` auth), with browser-cookie access
and remote hosted fetch providers disabled in `web-search.json`. Leave both off:
the first would hand page fetches your Chrome cookie jar, the second would let a
third-party service perform fetches on your behalf.

**`pi-lens` executes toolchains.** 17 files shell out to linters, formatters and
language servers, and it queries package registries and `api.github.com` for
tool metadata. It runs whatever the project configures, which is the same trust
you already extend by running a project's test suite.

**`pi-memory` writes memory files and optionally shells out to `qmd`** for
semantic search; without qmd it degrades to plain files. Its npm postinstall
script is a no-op outside its own git checkout (verified), and scripts are
disabled in the nix build regardless.

**`pi-claude-bridge` shells out to the `claude` CLI.** Each turn runs Claude Code's Agent SDK (via the `claude` binary on PATH, overridable with `provider.pathToClaudeCodeExecutable`), so pi's tools are bridged into a real Claude Code session that uses its own OAuth auth at `~/.claude/.credentials.json`. Tool calls and results flow back through pi's TUI. The opt-in `AskClaude` tool (off by default; set `askClaude.enabled` in `~/.pi/agent/claude-bridge.json`) lets any other provider delegate a read/full task to Claude Code. Config lives in `~/.pi/agent/claude-bridge.json` (`provider.plan` for 1M context, `askClaude.*`). Replaces the old `pi-claude-auth` OAuth-reuse hack with the supported Agent SDK path.

**The rest are prompt-shaping or TUI only.** `ponytail`, `pi-simplify`,
`pi-caveman`, `pi-plan-mode` and `pi-tui-kit` contain no exec calls and no
outbound hosts.

**Removed:** `@narumitw/pi-statusline`. Its powerline lead-in and caps are
hardcoded in the renderer, so pi's own footer is the quieter option and carries
the same information.

## Residual risk

There is no sandbox, by choice: agents keep access to `$HOME`, `~/.config` and
devices (adb). A malicious update to any package above would run as the user, in
reach of `~/.ssh`, the gpg agent, `~/.codex/auth.json` and
`~/.claude/.credentials.json`. The renovate PR on the lockfile is the only
checkpoint between an upstream compromise and execution, so read those diffs as
code, not as noise.

## Local extensions

Not from npm, not pinned by the lockfile: `agent/extensions/compact-footer.ts`
is linked into `~/.pi/agent/extensions/` by `modules/home/agents.nix` and
replaces pi's built-in footer with a two-line one (session state, plus a second
line only when an extension is reporting). It shells out to `git status` on a
5s timer for the working-tree markers and touches nothing else. Quota comes
from `pi-quota-status`, so Codex weekly usage appears only while an
`openai-codex/*` OAuth model is active.
