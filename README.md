# Dotfiles

GNU Stow packages for my Guix System and home environment.

## Requirements

- `fd`
- `stow`
- `bash`

For a temporary Guix environment:

```sh
guix shell bash fd stow -- ./sync.sh
```

## Install

Stow every top-level package into `$HOME`:

```sh
./sync.sh
```

`sync.sh` skips `_untracked` and handles Firefox by stowing into the detected
`default-release` profile's `chrome` directory.

## Global agent guidance

Edit only `agents/.agents/AGENTS.md`. Stowing `agents` installs this shared
policy at `~/.agents/AGENTS.md` with native relative symlinks:

- `~/.codex/AGENTS.md` → `../.agents/AGENTS.md`
- `~/.claude/CLAUDE.md` → `../.agents/AGENTS.md`
- `~/.omp/agent/AGENTS.md` → `../../.agents/AGENTS.md`
- `~/.pi/agent/AGENTS.md` → `../../.agents/AGENTS.md`

Nix configurations source the canonical file directly. Project instructions
remain project-local.

## Wallpapers

`wallpaper-random` reports uncached blur rendering as **Theme Switcher**,
replacing “Rendering wallpaper” with “Wallpaper rendered” when ready.

Run the helper's isolated behavior checks without changing the desktop wallpaper
(requires Python 3 and ImageMagick):

```sh
python3 tests/wallpaper-random.py
```

## Topbar

The main topbar remains opaque; popovers retain their configured translucency.

Niri's Super+Ctrl+W runs `svc restart topbar`.

On systemd, `topbar.service` owns the panel and `svc restart topbar` routes to
that unit. It restarts even after a clean exit when a VT switch temporarily
removes all outputs; stopping the graphical session still stops the service.
`svc session-start` imports the session environment and starts the unit, without
spawning a second compositor-owned panel. On Shepherd, the compositor still
owns topbar: restart kills only the panel holding its lock, waits for the lock
to release, then respawns through the compositor, preserving application children.

Isolated service regressions (Python 3 and normal shell utilities required):

```sh
python3 tests/svc.py
```

## Remove

Unstow every package:

```sh
./sync.sh -d
```
