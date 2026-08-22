# pi specifics

The instructions in AGENTS.md are shared with codex and Claude Code. Where they
describe another harness, these rules win.

## Delegation

- Specialist routing in AGENTS.md names codex agents (Terra, Sol). Those do not
  exist here. Delegation in pi goes through the `pi-subagents` extension, and
  only when the user asks for it.
- One delegate at a time. A delegate never spawns another.

## Packages

- Extensions, skills and prompts are pinned by nix
  (`~/Workspace/trev-nix/packages/pi/extensions`) and mounted read-only from the
  store. Never run `pi install`, `pi update`, or npm inside `~/.pi`; the change
  would be silently reverted on the next rebuild and it skips the review that
  pinning exists for.
- To add or bump an extension: edit `packages/pi/extensions/package.json`,
  regenerate the lockfile, rebuild. Say so instead of installing it.

## Output style

Stock voice is the default. `/caveman` is the user's switch, not yours; do not
adopt it unless asked.

## Web access

`pi-web-access` is configured keyless: Exa needs no key, and OpenAI search
reuses the Codex subscription auth from `/login`. Never ask for or set an API
key for it. Browser-cookie access and remote hosted fetch providers are off on
purpose; leave them off.
