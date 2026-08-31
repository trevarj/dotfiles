# pi specifics

The instructions in AGENTS.md are shared with codex and Claude Code. Where they
describe another harness, these rules win.

## Delegation

- Pi delegation uses `@narumitw/pi-subagents` tools: `subagent_spawn`,
  `subagent_inspect`, `subagent_cancel`, `subagent_wait`, and
  context-specific `subagent_send`.
- Inspect enough first to write a self-contained task. For substantial
  implementation, start one task-specialized job with minimum built-in tools,
  then wait before main writes. Main verifies actual files, checks, and final
  integration.
- Research and diagnosis default to one read-only job. Use up to four
  independent read-only jobs only when parallelism materially helps.
- Jobs are background and asynchronous. Continue independent main work or use
  `subagent_wait`; use `subagent_send` for bounded questions. Cancel active
  jobs when abandoning them. Never run concurrent writers.
- Child jobs run in separate Pi processes in same sandbox/current cwd and
  disable unrelated extensions and skills. No recursive delegation, named
  agent/model routing, schedules, workflows, custom catalogs, worktrees, or
  alternate transports. Jobs inherit current provider/model and session jobs
  are cancelled on shutdown.
- Selected built-in tools define authority: `read`, `grep`, `find`, and `ls`
  are read-only; `bash` grants command execution and may mutate files;
  `edit` and `write` grant direct file mutation. Grant minimum needed.

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
