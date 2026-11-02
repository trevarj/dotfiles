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

## Fonts and Kitty themes

The `fonts` package installs fontconfig policy, not font binaries. Install Iosevka
(including SS12 where selected), Noto, Noto Color Emoji, Terminus, and the Symbols
Nerd Font families through the host package manager. Waybar's optional crypto
module also needs CryptoFont. Native Nerd Symbols can have different glyph
metrics from the formerly vendored, locally adjusted copies.

Kitty has exactly one runtime color include:
`include ~/.local/share/trev-themes/active/kitty.conf`. It no longer loads local
`current-theme.conf` or the Niri selection directly. Without a runtime bundle,
Kitty reports the missing include and keeps its defaults. Managed Nix homes link
only `kitty.conf`: stowing Kitty's automatic light/dark theme files would override
the runtime colors. Fonts, opacity and other preferences are unchanged.

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
This costs more GPU time than Mango's wallpaper-only cache.

Workspace changes retain a small overshoot; window open/move animations keep
their stronger curve.

Native lid bindings disable `eDP-1` on fold and enable it on unfold. At startup,
Mango also checks logind's `LidClosed` property and disables `eDP-1` if the lid is
already closed, leaving the external output available for initial focus. This
uses output state, not cursor warping, and does not request a lock.

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
Mango's native session target starts the supervised desktop daemons; its config
does not call Niri's `svc session-start` or spawn an extra topbar.

## Noctalia and Umbriel

`noctalia/.config/noctalia/config.toml` and
`umbriel/.config/umbriel/config.toml` contain host-neutral preferences. Managed
Nix homes parse them into generated configurations, adding immutable package
paths and keeping physical displays and lockscreen widget placement in the host
module. Umbriel's managed root includes the generated baseline, host facts,
active colors and local overrides in that order; it does not replace
`~/.config/umbriel/overrides.toml`. Noctalia GUI overrides remain in
`~/.local/state/noctalia/settings.toml` and survive rebuilds.

Umbriel uses 16px corners, 2px borders, soft shadows and native spring curves.
Its own title bars are off, and `prefer_no_csd = true` requests that cooperating
Wayland applications omit their client-side decorations. Restart applications
after changing that preference; a new window may reuse the old Wayland
connection. Application content headers/toolbars remain, and no global Kitty
decoration setting changes Niri.
Blur is opt-in for Kitty (its existing 0.88 opacity is unchanged) and the pinned
Noctalia layer namespaces, not every application. Noctalia's launcher and
clipboard float centrally; control-center, wallpaper and session panels attach
to the bar. The full native launcher retains recent apps, categories and
providers. Dock, desktop widgets and the control-center media visualizer are
disabled. Iosevka application fonts and Noto Sans shell text remain unchanged.

The single `main` bar spans every output flush to the top edge, with square
upper corners and 16px inverse lower corners that visually round the desktop
area below. Zero end/edge margins select these native inner-edge curves; an end
inset would instead curve the upper corners. Workspaces are output-local,
unnumbered native pills. Module and status-group backgrounds/outlines are
transparent at rest; native hover feedback remains. The logical status group
keeps native service actions and volume scrolling; right-clicking any member
locks the session. The clock opens control-center Home on left-click and World
Clock on right-click. Only root-disk usage stays in the bar; click it for native
Control Center → System, including CPU/RAM readings and graphs. Microphone
controls remain available while inactive. The rightmost launcher button renders
the NixOS snowflake through the installed Symbols Nerd Font: native icon glyphs
use bundled Tabler, where U+F313 is a clock, so this built-in `custom_button`
uses its font-aware label and opens the same native launcher panel.

Managed Nix homes pin two plugin repository roots and disable automatic plugin
updates. Only World Clock, HeadsetControl and Binance are enabled. These are
unsandboxed user plugins: pinning constrains source drift, not their filesystem,
process or network permissions. HeadsetControl uses the installed
`headsetcontrol` executable; missing dependency/IPC errors remain visible.

Activation seeds only absent private plugin files with New York/UTC zones and a
BTCUSDT/ETHUSDT/ETHBTC public watchlist. Existing regular state wins, with a
warning if it differs; unsafe paths are refused rather than replaced. Use the
World Clock panel to edit existing zones and the Binance panel to edit an
existing watchlist. No `account.json` or credentials are created. An existing
connected account requires the user's **Account → Disconnect** action before
that installation can be called keyless; seeding does not disconnect it.
Crypto cycles exchange USDT quotes and the ETH/BTC ratio, not aggregate USD
prices. Upstream's history parser maps a malformed candle close to zero; that
limitation is distinct from its ticker's unavailable-price/error handling.

In Umbriel, the upstream Home Manager `noctalia.service` alone owns the shell,
wallpaper, notifications, tray, native Polkit and lock/idle policy. It belongs
only to `umbriel-session.target`; Niri keeps its separate desktop services.
Launcher applications use separate systemd services, outside shell restart
cleanup. GNOME keyring/GCR and the host's power/lid policy remain unchanged.

Wallpaper selection is manual from `~/Pictures/Wallpapers`, starting with the
packaged image; transitions are fade-only. Wallpaper colors use the soft scheme
in dark mode, with no independent GTK/Qt palette writers configured. Weather
uses metric units and remains unconfigured until a city is chosen privately in
the GUI. Automatic location, external-IP lookup, telemetry and nightlight are
disabled.

The saved Niri catalog and `~/.local/share/trev-themes/current` selection remain
independent of wallpaper-derived colors. Shared Kitty and Emacs follow `active`,
which points to relative `current` in Niri or a complete private Noctalia runtime
generation in Umbriel. One synchronous composite user template renders the
unchanged upstream Kitty, Umbriel and Emacs templates; the managed switcher
validates the complete bundle and Umbriel TOML before publishing active
atomically. Reload failures are reported separately after publication, without
rolling back other consumers.

Noctalia session startup resets active to current and removes stale pending
output. After shell/hooks stop, session cleanup restores saved Niri colors to
shared applications and GTK without changing the Niri wallpaper. Until the first
successful render, shared applications retain those saved colors and Umbriel
uses its baseline. Run `theme-switch` without arguments for Noctalia Appearance
settings in Umbriel or the Niri picker in Niri; Niri catalog/wallpaper mutation
commands are rejected while Umbriel is managed and active. Retry an Umbriel
publication with `noctalia msg templates-apply`, not Niri's `--apply-current`.

Clipboard history is copy-only, capped at 100 unpinned items, with confirmation
for clearing/deleting and Secret Service encrypted persistence. Native
password-manager hints are honored, not a promise to detect arbitrary secrets.
Notifications are quiet, top-center on the focused output, at most three at
once, with seven-day history. Screenshots copy and save locally under
`~/Pictures/Screenshots`, without annotation or command piping/upload.

Nix wraps `umbriel-layout-picker` and `umbriel-idle-brightness` with their
runtime dependencies. The layout chooser accepts only its four displayed
labels; cancellation and freeform input cannot change the layout.

Umbriel keeps the pinned compositor's complete native keymap. Super+Space is
reserved for US/Russian switching; scratchpad toggle moves to Super+Alt+Space.
Super+Ctrl+L cycles Scrolling/Dwindle/Master/Stacking, and Super+Ctrl+Shift+L
opens the packaged chooser for the current output-local workspace. Layout
overrides are runtime-local, not persistent named-workspace assignments.
Print, Shift+Print and Ctrl+Print request native region, fullscreen and window
screenshots respectively; they are not allowed while locked. Native launcher,
terminal, navigation, media and remaining scratchpad bindings are retained.
Three-finger horizontal strip panning, three-finger vertical workspace movement
and four-finger overview use the compositor's native gestures.

`umbriel-idle-brightness dim` saves the internal panel's original raw brightness
once before setting the explicit backlight device to raw 10. `restore` targets
that saved device even after output power-off and retains the recovery state if
restoration fails. After an externally interrupted idle-policy reload, run
`umbriel-idle-brightness restore` manually before changing the policy again.
There are no external-display/DDC writes.

Noctalia dims at 150 seconds, locks at 600, and powers outputs off at 601.
A separate 30-second locked timer handles manual locks without resetting the
601-second automatic deadline. Native activity wakes powered-off outputs.
D-Bus inhibitors can suppress every behavior, including the locked-off timer;
there is no second idle daemon in Umbriel. Startup and shutdown attempt saved
brightness restoration; failures retain recovery state and are logged without
blocking shell lifecycle.

The locker uses the existing PAM `login` service, immediate authentication and
fade-only transitions. Known-output clock/login placement is host-owned and
compact/private. Previously unknown outputs retain native login-box defaults
until configured; this is not a universal clock-only hotplug policy.

Run the helpers' isolated fake-command regressions without changing a desktop or
backlight (Python 3, `jq`, `flock` and normal shell utilities required):

```sh
python3 tests/umbriel.py
```

`TREV_DESKTOP_DOTFILES=/path/to/source` selects another source tree for this
check; unset or empty uses this checkout.

## Topbar

The main topbar remains opaque; popovers retain their configured translucency.

Niri's and Mango's Super+Ctrl+W run `svc restart topbar`.

On systemd, `topbar.service` owns the panel and `svc restart topbar` routes to
that unit in both sessions. It restarts even after a clean exit when a VT switch temporarily
removes all outputs; stopping the graphical session still stops the service.
`svc session-start` imports the session environment and starts the unit, without
spawning a second compositor-owned panel. On Shepherd, the compositor still
owns topbar: restart kills only the panel holding its lock, waits for the lock
to release, then respawns through the matching compositor, preserving application children.

Isolated helper regressions (Python 3, `jq` and normal shell utilities required):

```sh
python3 tests/svc.py
python3 tests/mango-screenshot.py
python3 tests/mango-lid.py
```

## Remove

Unstow every package:

```sh
./sync.sh -d
```
