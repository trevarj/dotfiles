# AGENTS.md

Global agent guidance for Trevor's machine (Guix System, zsh). Project-level
`AGENTS.md` files extend or override this baseline.

## Agent orchestration

### Default workflow

- Work directly by default. Do not spawn subagents unless the user explicitly
  asks for subagents, parallel agents, or a named specialist.
- Run the normal single-agent pipeline autonomously: investigate, plan when
  needed, implement, validate, review your own work, revise, and report. Ask the
  user only when intent, permissions, destructive actions, or consequential
  tradeoffs require a decision.
- Keep output paced and concise. Prefer slower, evidence-backed progress in the
  main thread over parallel fan-out.

### Optional specialist routing

- When the user explicitly requests delegation, prefer the closest matching
  specialist over a generic worker.
- Use at most one specialist at a time unless the user asks for parallel work.

#### Codex specialist routing

- Use Terra agents for routine research, debugging, implementation, and review.
- Use the Sol architect only for ambiguous, architectural, security-sensitive,
  concurrency-heavy, migration-related, multi-repository, public-API-facing, or
  unresolved root-cause work.
- Use a Sol reviewer only for those same risk classes, or for security,
  performance, or safety-critical Bitcoin work.

### Coordination and completion

- Do not allow recursive delegation. A delegated specialist must not spawn or
  consult another agent unless the user explicitly asks for that structure.
- Parallel writers require explicit, non-overlapping file or subsystem
  ownership. Serialize work that shares files, interfaces, schemas, or generated
  artifacts.
- Require implementation agents to run the closest relevant validation before
  review. Reviewers report concrete correctness findings, not style-only noise.
- Allow at most one fix-and-review cycle by default. If a material finding
  remains, stop and report the blocker with evidence.

## General agent principles

- Keep global memory concise. Put repo-specific facts in project `AGENTS.md`
  files and move conditional workflows into skills when possible.
- When a durable preference or repeated correction is learned, update the most
  specific memory file directly. Keep the edit brief and agent-agnostic.
- Do not add session logs, task notes, transcripts, or long explanations to
  global memory.
- For technical decisions, do not give much weight to development cost. Prefer
  quality, simplicity, robustness, scalability, and maintainability.
- For bug fixes, reproduce the issue in the closest realistic workflow before
  changing code when feasible.
- Prefer regression tests at the closest useful level: integration or end-to-end
  for product behavior, unit tests for isolated logic.
- Use plain, non-robotic prose. Avoid em dashes unless explicitly requested.

## Response style

- Terse. Lead with results and key decisions; skip preamble.
- Explain only non-obvious choices.

## Markdown & docs

- Concise. No preamble, no filler. Never use emojis.
- Short paragraphs and bullet lists for scanability.
- Don't write READMEs or docs files unless explicitly asked.

## Environment: Guix System

This is a Guix System (zsh). Every project pins its dev dependencies in a
`manifest.scm` and loads them via `guix shell`.

- **Never** use `guix install`. Prefer temporary shells for everything.
- **Never** suggest apt, dnf, pacman, brew, or global npm/pip.
- **Never** modify `~/.config/guix/current/` or `~/.guix-profile/` — those are
  managed by `guix pull` / `guix package`.
- One-off tools: `guix shell <package> -- <command>`.

### Runtime tool availability

Python, node, make, gcc, etc. are **not** guaranteed on PATH. Check before use;
if missing, wrap in a guix shell:

```sh
guix shell python python-<lib> -- python3 script.py
guix shell node -- npm run build
guix shell gcc-toolchain make -- make
```

### Project dependencies & builds

When a project lacks them, **auto-scaffold**:

- `manifest.scm` — a `specifications->manifest` listing dev dependencies.
- `.envrc` — containing exactly `use guix;` so direnv auto-loads the shell.

Common manifest commands:

- `guix build -m manifest.scm` — build the package defined in the manifest.
- `guix shell -m manifest.scm` — dev shell with manifest deps available.
- `guix shell --pure -m manifest.scm` — isolated shell, only manifest deps.
- `guix shell -D -m manifest.scm` — shell with a package's *build* deps.

Add new tools to `manifest.scm` rather than assuming they're globally present.

Example `manifest.scm`:

```scheme
(specifications->manifest
 (list "rust"
       "rust-cargo"
       "pkg-config"))
```

Example `.envrc`:

```
use guix;
```

## Git & commits

- **Commit only when asked.** Don't auto-commit.
- **Never open a PR without my approval.** Only when I explicitly tell you to.
- Use **Conventional Commits**: `type(scope): summary`.
  - Add a scope when there's a natural one; bare `type:` is fine otherwise.
  - Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `build`, `ci`,
    `perf`, `style`.
- **Body**: concise bulleted points describing the changes. No ticket
  references unless asked.
- **No** `Co-Authored-By` / attribution trailers.

### Signing (required)

- **Never create an unsigned commit.** Every commit must be GPG-signed with the
  user's key.
- If signing fails because the key is locked, run
  `/home/trev/.codex/bin/codex-gpg-unlock`, then retry the signed commit. Repeat
  the unlock-and-retry cycle up to 3 times. If it still fails, stop and ask —
  never fall back to an unsigned commit.

Example:

```
feat(parser): support nested manifests

- resolve transitive specs before flattening
- error on cyclic includes
```

### Branching

- **Personal repos**: committing directly to `main` is fine.
- **Repos not owned by me**: never commit to `main` — branch first.

### Forge tooling (by remote)

- Remote on **GitHub** → use the `gh` CLI for PRs/issues/API.
- Remote on **Codeberg** (Forgejo) → use the `fj` CLI.

## Search tools

- Prefer `rg` over `grep` for content search.
- Prefer `fd` over `find` for file search when available.
- Both respect `.gitignore` and are much faster.

## Code conventions

- Mimic existing style, libraries, and conventions; don't introduce new patterns.
- Add brief inline comments explaining intent by default.
- Prefer editing existing files over creating new ones.

## Verification before "done"

Inspect config to find the project's linters/typecheckers/tests, then within the
guix shell:

- Run the test suite and report results.
- Build / typecheck cleanly.
- Run the formatter and linter; fix failures before handing off.

If any step is skipped or fails, say so plainly with the output.

## Security

- Never expose or log secrets, API keys, tokens, or credentials.
- Warn before committing `.env`, `credentials.json`, or similar; refuse if a
  commit would include secrets.
- For GPG passphrases, never ask the user to type one into chat — run
  `/home/trev/.codex/bin/codex-gpg-unlock` so they can enter it in a terminal,
  then retry.
