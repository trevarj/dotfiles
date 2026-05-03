# Global Rules

## System

The user runs GNU Guix System. The default shell is zsh.
You have unrestricted access to `/tmp/` — read, write, and execute without asking.

## Package Management

- Do not use `guix install`. Prefer temporary shells for everything.
- Do not suggest apt, dnf, pacman, brew, npm global, pip global, or any other package manager.
- Use `guix shell <package> -- <command>` for one-off tool invocations.
- Never modify `~/.config/guix/current/` or `~/.guix-profile/` — these are managed by `guix pull` and `guix package`.

## Runtime Tool Availability

Python, node, make, gcc, and other common tools are **not** guaranteed to be on PATH.
Before running any tool, check if it's available. If not, wrap the command in `guix shell`:

```
guix shell python python-<library> -- python script.py
guix shell nodejs -- npm run build
guix shell gcc-toolchain make -- make
```

## Project Dependencies & Builds

For any project that needs dependencies or a build step:

1. First, create a `manifest.scm` file defining the project's dependencies (build inputs, propagated inputs, etc.).
2. To build the project: `guix build -f manifest.scm`
3. To enter a development environment with the project's dependencies: `guix shell -m manifest.scm`
4. To run the built binary or use project tools: `guix shell -m manifest.scm` then invoke the binary.

Common manifest commands:
- `guix build -f manifest.scm` — build the package defined in manifest
- `guix shell -m manifest.scm` — enter shell with manifest dependencies available
- `guix shell --pure -m manifest.scm` — isolated shell, only manifest deps visible
- `guix shell -D -m manifest.scm` — enter shell with development dependencies

## Git Commits

- Use Conventional Commits style: `type: description`
- Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `build`, `ci`, `perf`, `style`
- Keep messages brief and direct — single line when possible, no walls of text.
- Use bullet points for body if more detail is needed:
  - List what changed
  - List why it changed (if not obvious)
- Do not include ticket references unless the user asks.

Examples:
  feat: add user authentication
  fix: correct off-by-one error in pagination
  refactor: extract database helpers into shared module

## Markdown Documentation

- Keep it concise. No preamble, no fluff, no filler paragraphs.
- Never use emojis.
- Use short paragraphs and bullet lists for scanability.
- Do not write READMEs or docs files unless the user explicitly asks.

## File Search Tools

- Prefer the `rg` tool (ripgrep) for content searching instead of `grep`.
- Prefer the `fd` tool for file pattern searching instead of `glob` or `find`.
- Both `rg` and `fd` respect `.gitignore` by default and are significantly faster than the alternatives.

## Code Conventions

- Mimic existing code style, libraries, and conventions in the project. Do not introduce new patterns.
- Add comments to code by default. Prefer brief inline comments explaining intent.
- For large doc/comment tasks, defer until the code task is confirmed successful by the user.
- Prefer editing existing files over creating new ones.

## Security

- Never expose or log secrets, API keys, tokens, or credentials.
- Warn the user before committing `.env`, `credentials.json`, or similar sensitive files.
- If a commit containing secrets is requested, warn and refuse.

## Verification

- After writing significant code, determine which linters, typecheckers, and tests the project
  uses by inspecting config files (e.g. `package.json` scripts, `Makefile`, `pyproject.toml`).
- Run the relevant checks. If they fail, fix the issues before handing off to the user.
