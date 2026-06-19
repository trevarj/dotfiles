# Global Rules

## System

The user runs GNU Guix System. The default shell is zsh.
You have unrestricted access to `/tmp/`: read, write, and execute without asking.

## Package Management

- Do not use `guix install`. Prefer temporary shells for everything.
- Do not suggest apt, dnf, pacman, brew, npm global, pip global, or any other package manager.
- Use `guix shell <package> -- <command>` for one-off tool invocations.
- Never modify `~/.config/guix/current/` or `~/.guix-profile/`. These are managed by `guix pull` and `guix package`.

## Runtime Tool Availability

Python, node, make, gcc, and other common tools are not guaranteed to be on PATH.
Before running any tool, check if it is available. If not, wrap the command in `guix shell`:

```sh
guix shell python python-<library> -- python script.py
guix shell nodejs -- npm run build
guix shell gcc-toolchain make -- make
```

## Project Dependencies & Builds

For any project that needs dependencies or a build step:

1. First, create a `manifest.scm` file defining the project's dependencies.
2. To build the project: `guix build -f manifest.scm`.
3. To enter a development environment with the project's dependencies: `guix shell -m manifest.scm`.
4. To run the built binary or use project tools: `guix shell -m manifest.scm` then invoke the binary.

Common manifest commands:

- `guix build -f manifest.scm`: build the package defined in manifest.
- `guix shell -m manifest.scm`: enter shell with manifest dependencies available.
- `guix shell --pure -m manifest.scm`: isolated shell, only manifest deps visible.
- `guix shell -D -m manifest.scm`: enter shell with development dependencies.

## Git Commits

- Use Conventional Commits style: `type: description`.
- Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `build`, `ci`, `perf`, `style`.
- Keep messages brief and direct: single line when possible, no walls of text.
- Use bullet points for body if more detail is needed.
- Do not include ticket references unless the user asks.
- Never create an unsigned commit. Every commit must be signed with the user's GPG key.
- If GPG signing fails because the key is locked, run `/home/trev/.codex/bin/codex-gpg-unlock`, retry the signed commit, and repeat this unlock-and-retry cycle up to 3 times. If signing still fails after 3 attempts, pause and wait for explicit user guidance instead of committing unsigned.

Examples:

- `feat: add user authentication`
- `fix: correct off-by-one error in pagination`
- `refactor: extract database helpers into shared module`

## Forge Hosting

- Use `gh` for GitHub operations when the user references issues, pull requests, repositories, releases, or other GitHub-hosted resources.
- Use `fj` for Forgejo operations, including Codeberg, when the user references issues, pull requests, repositories, releases, or other Forgejo-hosted resources.
- Run `gh` and `fj` commands outside the sandbox because they need network access and local credentials.

## Markdown Documentation

- Keep it concise. No preamble, no fluff, no filler paragraphs.
- Never use emojis.
- Use short paragraphs and bullet lists for scanability.
- Do not write READMEs or docs files unless the user explicitly asks.

## File Search Tools

- Prefer `rg` for content searching instead of `grep`.
- Prefer `fd` for file pattern searching instead of `find` when available.
- Both `rg` and `fd` respect `.gitignore` by default and are significantly faster than alternatives.

## Code Conventions

- Mimic existing code style, libraries, and conventions in the project. Do not introduce new patterns.
- Add comments to code by default. Prefer brief inline comments explaining intent.
- For large doc/comment tasks, defer until the code task is confirmed successful by the user.
- Prefer editing existing files over creating new ones.

## Security

- Never expose or log secrets, API keys, tokens, or credentials.
- Warn the user before committing `.env`, `credentials.json`, or similar sensitive files.
- If a commit containing secrets is requested, warn and refuse.
- If GPG needs a key passphrase, never ask the user to type it into chat. Run `/home/trev/.codex/bin/codex-gpg-unlock` so the user can enter the passphrase in a local terminal, then retry the GPG or signed Git command. If the unlock helper fails or hangs, try the unlock-and-retry cycle up to 3 total times; after that, pause and wait for explicit user guidance.

## Verification

- After writing significant code, determine which linters, typecheckers, and tests the project uses by inspecting config files.
- Run the relevant checks. If they fail, fix the issues before handing off to the user.
