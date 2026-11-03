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

Kitty's shared `kitty.conf` contains base preferences, not a runtime palette.
Full-profile Nix homes link it as `~/.config/kitty/base.conf` and seed a writable
tiny `kitty.conf` containing only `include base.conf`. Noctalia's native Kitty
hook is the sole palette writer: it adds its own palette include and reloads
Kitty, independently of guarded Umbriel/cache publication. Do not stow a link over
that mutable root or let a hook write into Git/Nix store.

Bootstrap keeps a Nix-managed root including base plus the named Niri
`~/.local/share/trev-themes/current/kitty.conf`, without Noctalia dependencies.
Migration removes only the exact old Home Manager root link, seeds only absent
files, preserves user regular files and refuses unknown links/nonregular paths.
Full → bootstrap may need a manual backup of the mutable root before linking.
Local `current-theme.conf` and automatic light/dark theme files are not managed
includes. Fonts, opacity and other base preferences are unchanged.

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
The shared baseline statically captures saved non-location preferences; it does
not read that private file at evaluation or activation. Geographic `location.*`,
the migration-only `config_version`, and unrelated runtime/plugin data are not
imported. The existing private location and other GUI overrides stay untouched.

Umbriel uses 16px corners, 2px borders, soft shadows and native spring curves.
Its own title bars are off, and `prefer_no_csd = true` requests that cooperating
Wayland applications omit their client-side decorations. Restart applications
after changing that preference; a new window may reuse the old Wayland
connection. Application content headers/toolbars remain, and no global Kitty
decoration setting changes Niri.
Tiled Brave windows (`brave-browser`) open at full usable scrolling-column width
with `default_scrolling_extent = 1.0`; native floating/dialog detection keeps
those windows out of the rule. This is an initial size, not fullscreen or
maximize, and remains manually resizable.
Blur is opt-in for Kitty (its existing 0.88 opacity is unchanged) and the pinned
Noctalia layer namespaces, not every application. Noctalia's launcher and
clipboard float centrally; control-center, wallpaper and session panels attach
to the bar. The full native launcher uses an app grid and top search field,
retaining recent apps, categories and providers with navigation labels hidden.
Dock, desktop widgets and the control-center media visualizer are disabled.
Iosevka application fonts and Noto Sans shell text remain unchanged.

The single `main` bar spans every output flush to the top edge, with square
upper corners and 16px inverse lower corners that visually round the desktop
area below. Zero end/edge margins select these native inner-edge curves; an end
inset would instead curve the upper corners. Workspaces are output-local,
unnumbered native pills, including empty ones: occupied uses `tertiary` and
empty uses `tertiary_container`. Module and status-group backgrounds/outlines are
transparent at rest; native hover feedback remains. The logical status group
keeps configured service actions and output-volume scrolling; its configured
right-click lock actions remain. Privacy hides when inactive, Bluetooth hides
only when the adapter is off (not enabled/disconnected), with connection
notifications enabled. Network and output volume are icon-only; network
`vpn_status` is `both`. CPU/RAM/disk/input-microphone widgets and a separate
Control Center button are absent from the bar. The center lane is weather,
clock, World Clock (`widget.bar`, `font_scale = 1.01`), then notifications;
notifications hide with no unread items. Clock left-click opens Control Center
Home and right-click opens World Clock.

Bar thickness stays 38px, with opaque background and font weight 700.
Notifications use 0.8 background opacity without a border. Icons are 25% larger
(`scale = 1.25`), ordinary text stays unchanged (`font_scale = 0.8`), and
accessibility UI scale is independently 1.15. Workspaces use `scale = 0.8` and
`pill_scale = 0.75` to compensate the bar
scale for 25% smaller pills. The NixOS snowflake is a Symbols Nerd Font text
label with `font_scale = 1.25` compensation, since Tabler's U+F313 is a clock.
It opens the launcher on left-click, with no right-click action bound.
Umbriel Companion sits near workspaces with a layout glyph,
no labels and no wheel cycling; use its click controls.

Managed Nix homes pin official/community sources plus local `trev/tunnel-status`;
automatic plugin updates are `none`. Enabled plugins are World Clock,
HeadsetControl, Binance, `dmopp/nixos-updates`, Umbriel Companion,
Wallhaven, tunnel-status and `theblackdon/theme-switcher`. These execute
unsandboxed as the user: pinning
limits drift, not permissions. The highest review is **HIGH** for Nix fetching
and native hooks; tun0's new read-only scope is **LOW**.
HeadsetControl requires the installed `headsetcontrol`; dependency/IPC errors
remain visible.

Theme Switcher 0.2.1 (API 43, MIT, publisher `theblackdon`) was statically
reviewed in the pinned `noctalia-dev/community-plugins` source, revision
`eecb1579dff13d4334b2af9875e38084c42c8d50`; no new dependency is required.
Risk is **MODERATE** for user-triggered actions, **LOW** from enabling alone:
startup registers a wallpaper IPC service and checks the CLI path, without
automatically applying a theme, running a subprocess or making a network request.
Opening views reads private saved themes; edits write `themes.json` in its plugin
data directory. The community editor fetches `https://api.noctalia.dev/palettes`
and caches the response. Opening the wallpaper picker can execute an installed
image tool to cache thumbnails; Capture desktop executes an installed screenshot
tool. Apply changes wallpaper/palette and invokes the configured native templates
and hooks via argv-based CLI calls. No telemetry, upload, credential collection
or remote-code loading was found. Enabling is reasonable with trusted local
images, image tools and existing hooks, not a sandbox or guarantee about future
versions; interrupted unchecked theme-store writes can lose saved themes.

Updates is inputs-only, every six hours, with package/Flatpak checks disabled,
no token and no activation command; the empty command opens Settings. The
checkout/profile follows the signing role, not hostname. Native 15-minute error
retries remain; lockfile or system/user Flatpak stamp changes can trigger checks
after a 20-second settle even with Flatpak checks disabled.

The six Control Center slots are, in order: dark mode, clipboard,
`noctalia/wallhaven:shortcut`, `theblackdon/theme-switcher:open`, notifications,
session. Wallhaven defaults remain keyless SFW with the existing wallpaper
directory and no automatic rotation. No extra cursor tile or hidden overflow is
configured.

`trev/tunnel-status:widget` is an icon-only native asynchronous filesystem reader
of `/sys/class/net/tun0/flags` and `carrier`. Missing/down tun0 or carrier 0 hides
it; malformed/unreadable data shows an alert. It reads flags before carrier to
avoid treating down-device EINVAL as failure. An up icon proves only tun0
up/carrier 1, not Nym health or traffic protection. There is no subprocess,
RPC, Polkit, network, Nym CLI/auth workaround or credential dependency.

Activation seeds only absent private plugin files with New York/UTC zones and a
BTCUSDT/ETHUSDT/ETHBTC public watchlist. Existing regular state wins, with a
warning if it differs; unsafe paths are refused rather than replaced. Use the
World Clock panel to edit existing zones and the Binance panel to edit an
existing watchlist. No `account.json` or credentials are created. An existing
connected account requires the user's **Account → Disconnect** action before
that installation can be called keyless; seeding does not disconnect it.
Crypto shows the current price rather than cycling; its retained watchlist holds
exchange USDT quotes and the ETH/BTC ratio, not aggregate USD prices. The update
widget hides when up to date. Upstream's history parser maps a malformed candle
close to zero; that limitation is distinct from ticker unavailable-price/errors.

In Umbriel, the upstream Home Manager `noctalia.service` alone owns the shell,
wallpaper, notifications, tray, native Polkit and lock/idle policy. It belongs
only to `umbriel-session.target`; Niri keeps its separate desktop services.
Launcher applications use separate systemd services, outside shell restart
cleanup. GNOME keyring/GCR and the host's power/lid policy remain unchanged.

Wallpaper selection is manual from `~/Pictures/Wallpapers`, with both default
and last selection set to `autumn-valley-and-deer-painting.jpg`; transitions are
fade-only. The avatar is `~/Pictures/Art_and_Design/duckling-brick-wall.jpg`.
These paths reference local images; declaring them does not package the files.
The default palette is community **Kanagawa Paper**, with **Ayu** as the builtin
fallback, dark mode, pure-black dark and color-scheme synchronization enabled.
The community palette is downloaded/cached by Noctalia, not pinned here.
Wallpaper-derived soft colors remain an available user choice. Native `btop`, `kitty`, `qt`,
`gtk3` and `gtk4` templates/hooks are enabled; community templates are disabled.
Qt5/6ct select the generated custom palette, GTK uses mutable native imports,
and the native btop hook selects `noctalia` on apply and signals running btop.
Activation preserves existing regular configs; other btop preferences survive.
Weather uses metric units and remains unconfigured until a city is chosen
privately in the GUI. Automatic location, external-IP lookup, telemetry and
nightlight are disabled.

The saved Niri catalog and `~/.local/share/trev-themes/current` remain independent
of Noctalia colors. Emacs follows `active`, pointing to relative `current` after
explicit named-theme actions or a private Noctalia generation containing only
`umbriel.toml`. One synchronous composite renders pinned Umbriel and native
Kitty template bodies under the same palette/mode, without writing Kitty itself.
The validated terminal data becomes private, data-only
`$XDG_CACHE_HOME/noctalia/emacs-palette.json` (default
`~/.cache/noctalia/emacs-palette.json`).
Emacs applies its colors as theme-local native Modus overrides (`modus-vivendi`
for dark, `modus-operandi` for light); named catalog generation is unchanged.
The cache is written without an Emacs server and supports later Emacs starts
without the shell or native Kitty output while active selects that runtime state.
JSON replacement and active publication are individually atomic, not a cross-file
transaction; both precede compositor/Emacs callbacks. Consumer failures are
reported without rollback; the five native builtin hooks run independently.
Restart Emacs with the updated loader before applying this format; never reload
the live init for verification.

Noctalia stop/start preserves valid active state and last shared-app colors,
not automatic saved-Niri restoration. Full-profile Niri's `--niri-startup`
applies only its desktop/wallpaper, without shared reset or reload. Runtime
generation loss after reboot may still initialize active to current until a
successful render. Explicit manual named-theme actions can change current/active
and Emacs; full-profile Kitty stays owned by the native hook. `theme-switch`
without arguments opens Noctalia Appearance in Umbriel or the Niri picker in
Niri; catalog/wallpaper mutation is refused during managed Umbriel. Retry
Umbriel publication with `noctalia msg templates-apply`, not `--apply-current`.

Clipboard history is copy-only, capped at 100 unpinned items, with confirmation
for clearing/deleting and Secret Service encrypted persistence. Native
password-manager hints are honored, not a promise to detect arbitrary secrets.
Notifications are quiet, top-center on the focused output, at most three at
once, with seven-day history. Screenshots enable native annotation, copy and
local save under `~/Pictures/Screenshots`, without command piping/upload.

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
Super+Shift+Slash opens the native cheatsheet. Mod+R and reverse cycle extent
presets 0.333, 0.5, 0.667 and 1.0, where 1.0 is full usable width, not fullscreen.
The host's native lid events handle initial state and disable eDP-1 on close
only if another output is enabled; opening restores it. DP-5 gets startup focus,
without cursor/focus warp or changes to logind, suspend or power policy.
Three-finger horizontal strip panning, three-finger vertical workspace movement
and four-finger overview use the compositor's native gestures.

`umbriel-idle-brightness dim` saves the internal panel's original raw brightness
once before setting the explicit backlight device to raw 10. `restore` targets
that saved device even after output power-off and retains the recovery state if
restoration fails. After an externally interrupted idle-policy reload, run
`umbriel-idle-brightness restore` manually before changing the policy again.
There are no external-display/DDC writes.

Noctalia dims at 150 seconds, locks at 600, and powers outputs off at 601.
A separate 10-second locked timer handles manual locks without resetting the
601-second automatic deadline. Native activity wakes powered-off outputs.
D-Bus inhibitors can suppress every behavior, including the locked-off timer;
there is no second idle daemon in Umbriel. Startup and shutdown attempt saved
brightness restoration; failures retain recovery state and are logged without
blocking shell lifecycle.

The locker uses the existing PAM `login` service, immediate authentication and
fade-only transitions. Known-output clock/login placement is host-owned and
compact/private. Previously unknown outputs retain native login-box defaults
until configured; this is not a universal clock-only hotplug policy.

Run isolated helper checks without changing a desktop/backlight (Python 3, `jq`,
`flock`, Lua 5.1+ and normal shell utilities required):

```sh
python3 tests/umbriel.py
lua tests/tunnel-status.lua
# Optional offline native plugin/settings-code cross-check:
noctalia plugins lint noctalia/.config/noctalia/plugins/tunnel-status
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
