# AGENTS.md

Baseline for Trevor's NixOS machine. Project `AGENTS.md` files extend or override it.

## Memory & skills

- Keep global memory concise; repository facts and guidance stay in project
  `AGENTS.md`, not global skills. Move conditional workflows into skills when possible.
- Update the most specific memory file directly for durable preferences or
  repeated corrections; keep edits brief and agent-agnostic.
- No session logs, task notes, transcripts, or long explanations in global memory.

## Quality & verification

- Favor quality, simplicity, robustness, scalability, and maintainability;
  give development cost little weight.
- Follow existing style, libraries, and conventions; no new patterns. Prefer editing existing files.
- Do not add code comments unless requested to.
- Run verification only when requested or before a commit. Before committing,
  run incremental compilation, linting/formatting, and tests; target checks to
  the changes where possible. Report what was and was not verified.
- Prefer `rg` over `grep` for content and `fd` over `find` for files when available.

## Responses & docs

- Terse, plain prose: results and key decisions first, no preamble or filler.
  Explain only non-obvious choices. No em dashes unless requested; no emojis.
- Use short paragraphs and bullets. Completed-work format: one-line result,
  1–3 sentences about the work, then `Verification`; include `Blockers / next steps`
  only when nonempty.
- No new READMEs or docs files unless explicitly requested.

## Environment

- Default to Nix and project-pinned environments.
- Check tool availability before use and add missing tools to the project manifest.
- Use Bash or Python for scripting in non-JavaScript projects, not JavaScript or
  TypeScript.
- Never use `nix profile install`, or suggest apt, dnf, pacman,
  brew, or global npm/pip.
- Never hand-edit `/run/current-system`, the system profile. Manage these
  through NixOS.
- Auto-scaffold missing `flake.nix` with a pinned development shell listing dev
  dependencies, generated `flake.lock`, and `.envrc` containing exactly `use flake`.
  Commit the lock with the project only when committing is requested.
- Add tools to `flake.nix`, not global assumptions; run project commands with
  `nix develop -c <command>`.

## Git & commits

- Commit only when asked; open PRs only with explicit approval.
- Conventional Commits: `type(scope): summary`, with scope only when natural.
  Use concise bulleted bodies; no ticket references unless asked and no
  `Co-Authored-By` or attribution trailers.
- Personal repositories may commit directly to `main`; branch first in others.
- Use `gh` for GitHub PRs/issues/API and `fj` for Codeberg/Forgejo.

### Deploy

“Deploy” explicitly authorizes this sequence:
1. Commit and push the current repository.
2. Update its flake input in `~/Workspace/trev-nix`.
3. Commit the resulting `trev-nix` changes.
4. Tell the user to rebuild Nix; never run the rebuild.

### Signing

- Every commit must be GPG-signed with the user's key via `git commit -S`.
  Uncached requests use pinentry on the key-owning host's running desktop.
- Without a host desktop, sign only with a cached key. Report absent desktop or
  signing/unlock failures; on failure, stop and ask the user to unlock interactively
  before retrying. No automatic retry or unsigned fallback.

## Security

- Never expose or log secrets, API keys, tokens, or credentials.
- Warn before committing `.env`, `credentials.json`, or similar; refuse commits
  containing secrets.
- GPG passphrases belong only in pinentry, never chat, command arguments, logs,
  or helper scripts; follow the signing failure rules above.
