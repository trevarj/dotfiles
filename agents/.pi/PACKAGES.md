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
| `@narumitw/pi-workflow` | 0.6.0 | Plan/Goal modes and session workflow state; coordinates Pi tools. |
| `pi-caveman` | 1.0.8 | Output-style prompt mode only. |
| `@gotgenes/pi-anthropic-auth` | 2.0.6 | Reads Pi's Anthropic OAuth state and talks to Anthropic APIs. |
| `@llblab/pi-telegram` | 0.36.8 | Reads bot token/owner from Pi state and polls/sends through Telegram only after local `/telegram-connect`. Local Nix patch denies missing owners instead of pairing first contact. |
| `pi-lens` | 4.0.1 | Executes project LSPs, linters, formatters, and analyzers; queries package/GitHub metadata. |
| `pi-memory` | 0.4.2 | Writes Pi memory/state; optional `qmd` is absent and its install notice is patched out. |
| `pi-simplify` | 0.2.3 | Reviews changed code for clarity. |
| `pi-subagents` | 0.51.0 | Spawns nested Pi processes and scripted workflows inside the same sandbox, including inherited signed-commit and SSH-push access. |
| `pi-web-access` | 0.24.0 | Reaches configured search/fetch providers, GitHub, PDFs, and video sources. Browser-cookie and hosted authenticated fetch profiles remain disabled. |

## Local extensions

- `ollama-autostart.ts`: ensures configured Ollama models are available. Ollama
  itself runs as a loopback-only Home Manager service, so Pi does not mount
  `~/.ollama`.
- `trev-pi`: compact header/footer and session status.
- `work-mode.ts`: Plan/Goal/direct workflow guard. Guided/collaborative modes
  require push confirmation; solo/quick authority permits signed commit and push
  from the sandbox.
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
