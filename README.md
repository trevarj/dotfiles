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

## MangoWM

`mango/.config/mango/config.conf` targets stock Mango **0.18.2**, alongside the
existing Niri session. It sources colors from
`~/.local/share/trev-themes/current/mango.conf`; install/select a generated theme
bundle before starting Mango. Niri remains the default/recovery session.

Layer blur samples live content (`blur_optimized=0`), matching Niri popovers.
This costs more GPU time than Mango's wallpaper-only cache. The main topbar
remains opaque; popovers retain their configured translucency.

The primary modifier is `var=mainmod,SUPER`. Super+Space switches US/Russian;
Super+Alt+Space cycles Scroller/Fair/Dwindle per tag. Tags 1–3 are persistent
browser/Emacs/chat destinations, matching `[advanced.mango]` in topbar's config.
Super+O opens native overview; Super+Alt+grave toggles the named Kitty scratchpad.
Its explicit 80% × 90% floating-size rule preserves sizing on stock 0.18.2.
Logout shortcuts open quick settings rather than immediately quitting.

Application and utility shortcuts retain Niri's keys: Super+Return terminal,
Super+E launcher, Super+B browser, Super+Ctrl+W topbar restart, Super+Alt+T theme
picker, Super+P wallpaper picker and Super+Ctrl+P wallpaper refresh.
Super+Alt+L locks with Mango's lockscreen config; Super+Shift+P powers off all
outputs. DDC, Orca, audio/mic and brightness controls remain configured; only
Orca and media/brightness keys work while locked. Host-changing helpers are
intentionally excluded from the isolated nested preview.

Niri-only same-app grave switching, workspace reordering, first/last-column
actions, height presets/reset, center-visible-columns, expand-to-remaining-width,
floating/tiling focus switching, hotkey overlay, tabbed-column display,
comma/period consume/expel and the shortcut-inhibit escape toggle are deliberately
unbound. Mango supports global/per-window inhibition permission, not Niri's
escape-toggle dispatcher. Cross-output/tag transfers move one window, not a
whole Niri column. mpv VRR is fullscreen-only.

`mango-screenshot region|output|window` needs Grim 1.5+, Slurp, Satty 0.20.1+,
`mmsg`, `jq`, `wl-copy` and optionally `notify-send`. Print selects a region for
annotation; Enter/copy saves and copies it, while Escape cancels. Ctrl+Print
captures the focused output and Alt+Print the focused native toplevel. Protected
window capture failures never fall back to screen cropping. Images are published
without overwrite under `~/Pictures/Screenshots/Screenshot_from_*.png`; failed
publication reports and preserves the completed image in its private staging
directory.

`hypridle-mango.conf` retains 150 s internal-panel dimming, 600 s locking, 601 s
all-output power-off and 30 s already-locked power-off. It requires the generated
`~/.config/hypr/hyprlock-mango.conf`, sourced visually from the shared lockscreen,
and uses `wlopm` for all-output power. Keep Niri's idle configuration unchanged.
`svc restart topbar` respawns through the current compositor while leaving the
panel's application children alive.

Isolated helper regressions (Python 3, `jq` and normal shell utilities required):

```sh
python3 tests/svc.py
python3 tests/mango-screenshot.py
```

## Remove

Unstow every package:

```sh
./sync.sh -d
```
