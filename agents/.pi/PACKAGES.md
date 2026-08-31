# pi extensions: reviewed inventory and authority

The pinned package set lives in `~/Workspace/pi-config/extensions/package.json`
and its lockfile. Nix installs it with lifecycle scripts disabled and a fixed
content hash. Renovate waits seven days for npm releases and never automerges.

Normal `pi` runs in a systemd user sandbox. Extensions can read and modify all
of `~/Workspace`, use network egress, execute project toolchains, and read Pi's
own state under `~/.pi/agent` (including provider auth and Telegram bot config).
They receive SSH-agent authentication plus the configured GPG public key,
agent socket, and scoped encrypted signing-key copy for signed commits, without
raw SSH key files or the host GPG home. Claude/Codex/GitHub CLI
credentials, browser data, D-Bus, libvirt/Podman/Nym sockets, input devices, and
the rest of home remain hidden. Run `pi --sandbox-check` after system changes.

Reviewed pinned packages:

| Package | Version | Credential, process, and network authority |
|---|---:|---|
| `@dietrichgebert/ponytail` | 4.9.0 | Prompt/skill policy; no host credentials required. |
| `@narumitw/pi-plan-mode` | 0.56.0 | Enforces read-only Plan mode by changing active tools and prompt/session state; no process or network access of its own. |
| `@narumitw/pi-goal` | 0.54.4 | Persists one autonomous objective and queues bounded continuation turns; can drive any tools already authorized in the Pi session. |
| `@narumitw/pi-herdr` | 0.1.1 | Sole Herdr socket lifecycle/metadata/widget reporter. Sends bounded session identity, model, and status metadata only to the active local Herdr socket; after an explicit Herdr request, its bundled skill loads authoritative instructions from the pinned local `herdr --skill`. |
| `@narumitw/pi-stamp` | 0.50.0 | Adds TUI-only custom transcript timestamp entries. Built-in defaults disable assistant metadata, response timing, and tool stamps; no process or network access. |
| `@narumitw/pi-tui-kit` | 0.60.0 | Library only: shared read-only/menu TUI and RPC adapters; registers no Pi resources and has no credential, process, or network authority. |
| `pi-caveman` | 1.0.8 | Output-style prompt mode only. |
| `@gotgenes/pi-anthropic-auth` | 2.0.6 | Reads Pi's Anthropic OAuth state and talks to Anthropic APIs. |
| `@llblab/pi-telegram` | 0.40.0 | Reads bot token/owner from Pi state and polls/sends through Telegram only after local `/telegram-connect`; its inbound queue is owned by the active Pi session. Local Nix patch denies missing owners instead of pairing first contact. |
| `pi-memory` | 0.4.2 | Writes Pi memory/state; optional `qmd` is absent and its install notice is patched out. |
| `pi-simplify` | 0.2.3 | Reviews changed code for clarity. |
| `@narumitw/pi-subagents` | 3.0.1 | Runs separate Pi child processes in same sandbox/current cwd; defaults read-only. `bash`, `edit`, and `write` grant process or mutation authority. Uses loopback authenticated broker; child inherits current provider/model/auth. No extension tools, worktrees, nesting, or persistence; session-owned jobs cancel on shutdown. |
| `pi-web-access` | 0.27.0 | Reaches configured search/fetch providers, GitHub PRs/issues, PDFs, and video sources, with explicit per-call or configured proxy support plus Gemini ADC, Kimi, and XCrawl capabilities. GitHub credentials remain hidden; browser-cookie and hosted authenticated fetch profiles remain disabled. |

## Local extensions

- `ollama-autostart.ts`: ensures configured Ollama models are available. Ollama
  itself runs as a loopback-only Home Manager service, so Pi does not mount
  `~/.ollama`.
- `trev-pi`: compact header/footer and session status.
- `work-mode.ts`: Plan/Goal/direct workflow guard. Guided/collaborative modes
  require push confirmation; solo/quick authority permits signed commit and push
  from the sandbox.
- `herdr-fork.ts`: keeps Herdr pane identity correct across Pi forks. Herdr has
  no socket ACL, so every loaded extension can technically control sibling panes;
  only the active socket is mounted into the sandbox.
- `@trevarj/pi-usage`: local bundled usage display.

## Review rules

- Never run `pi install`; Home Manager rewrites the generated package paths.
- Review npm tarball and lockfile diffs as executable code, especially shell
  execution, credential paths, outbound hosts, and new native binaries.
- Keep the Telegram fail-closed substitution exact-match so an upstream code
  change fails the Nix build. Remove it only after upstream ships
  operator-confirmed pairing.
- Pi-specific provider tokens remain reachable to every loaded extension. Use
  separate credentials or extension process isolation if that residual risk
  becomes unacceptable.
