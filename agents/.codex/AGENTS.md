# AGENTS.md

Global agent guidance for Trevor's machine (NixOS with Nix project
tooling, zsh). Project-level `AGENTS.md` files extend or override this baseline.

## Agent orchestration

### Default workflow

- Main agent coordinates every actionable task: inspect enough to scope it,
  then delegate one bounded implementation task to the closest specialist
  before substantial execution.
- Main agent owns synthesis, integration, validation, and final reporting. It
  may perform targeted reads and checks, but does not duplicate delegated work.
- Skip delegation for conversation-only replies, clarification questions,
  trivial targeted lookups, or when the user explicitly asks for direct work.
- Ask the user only when intent, permissions, destructive actions, or
  consequential tradeoffs require a decision.
- Keep output paced and concise. Default to one evidence-backed delegate. A
  small parallel batch of read-only specialists is allowed only for genuinely
  independent research, diagnosis, or review tracks when it materially reduces
  latency.

### Specialist routing

- Prefer the closest matching specialist over a generic worker.
- Use one implementation specialist at a time. Parallel specialists must be
  read-only and follow the default-workflow limits.

#### Codex specialist routing

- Use Terra agents for routine research, debugging, implementation, and review.
- Use the Sol architect only for ambiguous, architectural, security-sensitive,
  concurrency-heavy, migration-related, multi-repository, public-API-facing, or
  unresolved root-cause work.
- Use a Sol reviewer only for those same risk classes, or for security,
  performance, or safety-critical Bitcoin work.

### Coordination and completion

- Do not allow recursive delegation. Child agents never spawn or consult other
  agents; only the lead coordinator may create and schedule team work.
- One writer at a time per shared repository remains the default outside the
  coordinator. The coordinator may run writers concurrently only with explicit,
  disjoint repository-relative path leases; overlapping paths queue and the lead
  remains responsible for integration and verification.
- Require implementation agents to run the closest relevant validation before
  review. Reviewers report concrete correctness findings, not style-only noise.
- Allow at most one fix-and-review cycle by default. Coordinator-managed
  automatic review may continue until pass only while the diff changes, material
  finding fingerprints do not repeat, and task turn/time budgets remain.
- The lead verifies delegated output and retains final Git authority. Child Git
  actions require the task lease and granted authority; commit/push for
  auto-reviewed work waits for an approved finalize phase.

## General agent principles

- Keep global memory concise. Put repo-specific facts in project `AGENTS.md`
  files and move conditional workflows into skills when possible.
- When a durable preference or repeated correction is learned, update the most
  specific memory file directly. Keep the edit brief and agent-agnostic.
- Do not add session logs, task notes, transcripts, or long explanations to
  global memory.
- After repeated correction or one costly or high-risk failure, briefly suggest
  a skill; never create one automatically. Approved personal skills live in
  `~/Workspace/agent-skills` and follow that repository's `AGENTS.md`.
- Keep repository-specific guidance project-local instead of promoting it to a
  global skill.
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
- Report completed work as: one-line result, 1 to 3 sentences of what was done,
  then `Verification`, then `Blockers / next steps` only when non-empty.

## Markdown & docs

- Concise. No preamble, no filler. Never use emojis.
- Short paragraphs and bullet lists for scanability.
- Don't write READMEs or docs files unless explicitly asked.

## Environment: NixOS (with Guix available)

The host runs NixOS (zsh). Prefer the Nix package manager and Nix dev
environments by default; Guix is still available for projects that already use
it. Use Guix when the project already has a `manifest.scm` or the user
specifically requests Guix.

- **Never** use `nix profile install` or `guix install`. Prefer temporary
  shells and project-pinned environments.
- **Never** suggest apt, dnf, pacman, brew, or global npm/pip.
- **Never** modify NixOS system-manager paths (`/run/current-system`, the system
  profile) or Guix-managed paths (`~/.config/guix/current/`,
  `~/.guix-profile/`) by hand — manage the former through the NixOS
  configuration and the latter through `guix pull` / `guix package`.
- One-off tools: `nix shell nixpkgs#<package> -c <command>` (or `guix shell`
  when a Guix package is needed).

### Runtime tool availability

Python, node, make, gcc, etc. are **not** guaranteed on PATH. Check before use;
if missing, use a temporary Nix shell:

```sh
nix shell nixpkgs#python3 nixpkgs#python3Packages.requests -c python3 script.py
nix shell nixpkgs#nodejs -c npm run build
nix shell nixpkgs#gcc nixpkgs#gnumake -c make
```

### Project dependencies & builds

When a project lacks them, **auto-scaffold**:

- `flake.nix` — a pinned Nix development shell listing dev dependencies.
- `flake.lock` — generated from the flake inputs and committed with the project.
- `.envrc` — containing exactly `use flake` so direnv auto-loads the shell.

Common flake commands:

- `nix develop` — enter the default development shell.
- `nix develop -c <command>` — run a command in the development shell.
- `nix build` — build the default package.
- `nix flake check` — run the flake's checks.

Add new tools to `flake.nix` rather than assuming they're globally present.

Example `flake.nix`:

```nix
{
  description = "Project development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [ rustc cargo pkg-config ];
      };
    };
}
```

Example `.envrc`:

```
use flake
```

### Existing Guix manifests

When `manifest.scm` is already present, use `guix shell -m manifest.scm` and add
new development tools to that manifest. Do not introduce a Nix flake unless the
user asks to migrate the project.

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

### Deploy

When the user says **deploy**, treat it as explicit authorization to complete
this sequence:

1. Commit and push the current repository.
2. Update its flake input in `~/Workspace/trev-nix`.
3. Commit the resulting `trev-nix` changes.
4. Tell the user to rebuild Nix; do not run the rebuild.

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

Inspect config to find the project's linters/typecheckers/tests, then use
`nix develop` by default or `guix shell -m manifest.scm` for an existing Guix
manifest:

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
