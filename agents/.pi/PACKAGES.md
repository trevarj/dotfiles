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
| `@narumitw/pi-tui-kit` | 0.60.0 | Library only: shared read-only/menu TUI and RPC adapters; registers no Pi resources and has no credential, process, or network authority. |
| `pi-caveman` | 1.0.8 | Output-style prompt mode only. |
| `@gotgenes/pi-anthropic-auth` | 2.0.6 | Reads Pi's Anthropic OAuth state and talks to Anthropic APIs. |
| `@llblab/pi-telegram` | 0.40.0 | Reads bot token/owner from Pi state and polls/sends through Telegram only after local `/telegram-connect`; its inbound queue is owned by the active Pi session. Local Nix patch denies missing owners instead of pairing first contact. |
| `pi-memory` | 0.4.2 | Writes Pi memory/state; optional `qmd` is absent and its install notice is patched out. |
| `pi-simplify` | 0.2.3 | Reviews changed code for clarity. |
| `pi-web-access` | 0.27.0 | Reaches configured search/fetch providers, GitHub PRs/issues, PDFs, and video sources, with explicit per-call or configured proxy support plus Gemini ADC, Kimi, and XCrawl capabilities. GitHub credentials remain hidden; browser-cookie and hosted authenticated fetch profiles remain disabled. |

## Local extensions

- `@trevarj/pi-agents` 1.0.0: local persistent subagent coordinator. Runs only
  reviewed core, `pi-web-access`, and Anthropic-auth extensions in separate Pi
  RPC child processes with inherited model selection, bounded filtered context,
  private inherited-fd collaboration, versioned 0600 state, DAG/turn/time caps,
  and no nested spawning. Mutating children require current-team path leases;
  direct writes are blocked outside them and shell drift pauses without revert.
  Git authority is task-scoped, serialized, signed/path-limited, and gated by
  parent work mode or immediate UI confirmation. Automatic review retains leases
  through guarded fix cycles and defers final Git actions until approval.
- `ollama-autostart.ts`: ensures configured Ollama models are available. Ollama
  itself runs as a loopback-only Home Manager service, so Pi does not mount
  `~/.ollama`.
- `@trevarj/pi-zentui` 0.22.0: local source fork of `pi-zentui` at upstream
  commit `5ed286e8877b1b79e0a3d7fadbfe508b78684c32`; sole UI skin owner for editor,
  user messages, selector borders, and footer. Reads project/Git/runtime state,
  runs bounded local version probes, and writes only `~/.pi/agent/zentui.json`
  through explicit `/zentui` configuration. Local fork changes only the Git
  branch icon from Nerd Fonts Octicons U+F418 to Powerline U+E0A0 for broader
  terminal-font compatibility. Experimental private thinking rendering and
  animated working line remain disabled by default.
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
