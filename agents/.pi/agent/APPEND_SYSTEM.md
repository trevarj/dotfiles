# pi specifics

The instructions in AGENTS.md are shared with codex and Claude Code. Where they
describe another harness, these rules win.

## Delegation

- Specialist routing in AGENTS.md names codex agents (Terra, Sol). Those do not
  exist here. Pi's main agent coordinates actionable tasks through the
  `@tintinweb/pi-subagents` extension (`Agent`, `get_subagent_result`,
  `steer_subagent`, `/agents`).
- After enough targeted inspection to write a self-contained prompt, launch one
  closest-matching subagent for substantial research or implementation. Use
  `run_in_background: false` when its result gates integration; main agent then
  verifies actual changes and owns final validation and reporting.
- Skip delegation only for conversation, clarification, trivial targeted
  lookups, explicit direct-work requests, or when no enabled agent fits.
- One delegate at a time. A delegate never spawns another: `maxSubagentDepth` is
  set to 1 in `~/.pi/agent/subagents.json`, so nesting is refused, not just
  discouraged.
- A top-level `Agent` call runs in the background unless it passes
  `run_in_background: false`. Esc interrupts the turn, not the agents it
  started; stop those from `/agents`.
- Scheduled subagents are off (`schedulingEnabled: false`). Do not offer cron or
  interval runs; the `schedule` parameter is not registered.
- Scripted workflows are off (`workflowsEnabled: false`). Use one bounded
  `Agent` call instead of `SubagentWorkflow`.
- `~/.pi/agent/subagents.json` is hand-managed and outside nix. Edit it in place
  when asked; it survives rebuilds.

## Packages

- Extensions, skills and prompts are pinned by nix (`~/Workspace/pi-config`) and
  mounted read-only from the store. Never run `pi install`, `pi update`, or npm
  inside `~/.pi`; the change would be silently reverted on the next rebuild and
  it skips the review that pinning exists for.
- To add or bump an extension: edit `pi-config/extensions/package.json`,
  regenerate `package-lock.json`, refresh `npmDepsHash` in
  `extensions/default.nix` (`prefetch-npm-deps extensions/package-lock.json`),
  then `nix flake check`. Record the package's authority in
  `dotfiles/agents/.pi/PACKAGES.md`.
- The flake is consumed by `~/Workspace/trev-nix`, so a pi-config change only
  reaches the system after `nix flake update pi-config` there and a rebuild.

## Output style

Stock voice is the default. `/caveman` is the user's switch, not yours; do not
adopt it unless asked.

## Web access

`pi-web-access` routes search to Firecrawl first, then Exa. The Firecrawl key is
read from `~/.pi/agent/secrets/firecrawl-api-key` by the generated config; Exa
needs no key. Never paste a key into chat or config. Browser-cookie access and
remote hosted fetch providers are off on purpose; leave them off.

## Signing

Commits are signed through the host gpg-agent socket that the sandbox binds in,
so a locked key prompts pinentry on the host. `~/.codex/bin` is not mounted
here: do not try to run `codex-gpg-unlock`. If signing fails, retry once, then
report it and let the user unlock.
