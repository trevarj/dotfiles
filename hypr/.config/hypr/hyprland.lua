-- Portable desktop behavior. The optional host file supplies connector facts.
local home = assert(os.getenv("HOME"), "HOME is required")
local config_home = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")

local function load_optional(path)
    local exists, err, code = os.rename(path, path)
    if not exists and code == 2 then return nil end
    local loader, load_error = loadfile(path)
    assert(loader, load_error or err)
    return loader()
end

local host = load_optional(config_home .. "/hypr/host.lua") or {}
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
for _, monitor in ipairs(host.monitors or {}) do
    hl.monitor(monitor)
end

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
    general = {
        gaps_in = 14,
        gaps_out = 28,
        border_size = 3,
        layout = "scrolling",
        col = {
            active_border = "rgba(70b49bcc)",
            inactive_border = "rgba(77777770)",
        },
    },
    scrolling = {
        column_width = 0.5,
        explicit_column_widths = "0.33333, 0.5, 0.66667",
        fullscreen_on_one_column = false,
        focus_fit_method = 1,
        wrap_focus = false,
        wrap_swapcol = false,
        follow_min_visible = 1.0,
    },
    decoration = {
        rounding = 12,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1.0,
        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            noise = 0.02,
            new_optimizations = true,
            popups = true,
        },
        shadow = {
            enabled = true,
            range = 24,
            render_power = 3,
            offset = { 3, 5 },
            color = "rgba(00000088)",
        },
    },
    group = {
        col = {
            border_active = "rgba(70b49bcc)",
            border_inactive = "rgba(77777770)",
            border_locked_active = "rgba(ffd166cc)",
            border_locked_inactive = "rgba(77777770)",
        },
        groupbar = {
            gradients = true,
            col = {
                active = "rgba(182029ff)",
                inactive = "rgba(111827ff)",
                locked_active = "rgba(182029ff)",
                locked_inactive = "rgba(111827ff)",
            },
            text_color = "rgba(f4f4f5ff)",
            text_color_inactive = "rgba(f4f4f5b3)",
            text_color_locked_active = "rgba(f4f4f5ff)",
            text_color_locked_inactive = "rgba(f4f4f5b3)",
        },
    },
    input = {
        kb_layout = "us,ru",
        kb_options = "grp:win_space_toggle,compose:ralt,ctrl:nocaps",
        repeat_delay = 250,
        repeat_rate = 50,
        numlock_by_default = true,
        accel_profile = "flat",
        touchpad = { tap_to_click = true, natural_scroll = true },
    },
    binds = { scroll_event_delay = 150 },
    misc = {
        disable_hyprland_logo = true,
        force_default_wallpaper = -1,
        vrr = 0,
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "scroll_move" })
hl.gesture({ fingers = 3, direction = "vertical", action = "workspace" })

hl.curve("trev-spring", { type = "spring", mass = 1, stiffness = 170, dampening = 16 })
hl.curve("trev-ease", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
for _, animation in ipairs({
    { leaf = "windows", speed = 4, spring = "trev-spring" },
    { leaf = "windowsMove", speed = 4, spring = "trev-spring" },
    { leaf = "windowsIn", speed = 4, spring = "trev-spring", style = "popin 87%" },
    { leaf = "windowsOut", speed = 1.5, bezier = "trev-ease", style = "popin 95%" },
    { leaf = "fade", speed = 1.6, bezier = "trev-ease" },
    { leaf = "workspaces", speed = 3, bezier = "trev-ease", style = "slidevert" },
    { leaf = "layers", speed = 2, bezier = "trev-ease", style = "fade" },
    { leaf = "border", speed = 2.5, bezier = "trev-ease" },
}) do
    animation.enabled = true
    hl.animation(animation)
end

hl.layer_rule({ match = { namespace = "^topbar.*$" }, no_anim = true })
hl.layer_rule({ match = { namespace = "^launcher$" }, blur = true, xray = false })

for id, name in ipairs({ "browser", "emacs", "chat" }) do
    hl.workspace_rule({ workspace = tostring(id), default_name = name, persistent = true })
end
hl.window_rule({ match = { class = "^brave-browser$" }, workspace = "1", scrolling_width = 1.0 })
hl.window_rule({ match = { class = "^emacs$" }, workspace = "2", scrolling_width = 1.0 })
hl.window_rule({ match = { class = "^org.telegram.desktop$" }, workspace = "3", scrolling_width = 1.0 })
hl.window_rule({ match = { class = "firefox$", title = "^Picture-in-Picture$" }, float = true })
hl.window_rule({ match = { class = ".*" }, no_vrr = true })
hl.window_rule({ match = { class = "^mpv$" }, no_vrr = false })

if host.overview_plugin then
    hl.plugin.load(host.overview_plugin)
end
if hl.plugin.hyprexpo ~= nil then
    hl.config({ plugin = { hyprexpo = {
        keynav_enable = 1,
        cancel_key = "escape",
        show_cursor = 1,
        scrolling_thumbnail_budget = 4,
        scrolling_input_debug = 0,
    } } })
end

local d = hl.dsp
local function bind(keys, action, description, opts)
    opts = opts or {}
    opts.description = description
    hl.bind(keys, action, opts)
end
local function mod(keys) return "SUPER + " .. keys end

-- Direction aliases follow H/J/K/L and the arrow keys.
for _, direction in ipairs({
    { "left", "H", "l" }, { "down", "J", "d" },
    { "up", "K", "u" }, { "right", "L", "r" },
}) do
    local arrow, letter, native = table.unpack(direction)
    for _, key in ipairs({ arrow, letter }) do
        bind(mod(key), d.focus({ direction = native }), "Focus " .. arrow)
        bind(mod("SHIFT + " .. key), d.focus({ monitor = native }), "Focus " .. arrow .. " monitor")
        bind(mod("CTRL + SHIFT + " .. key),
            d.window.move({ monitor = native, follow = true }), "Move window to " .. arrow .. " monitor")
    end
    if native == "l" or native == "r" then
        for _, key in ipairs({ arrow, letter }) do
            bind(mod("CTRL + " .. key), d.layout("swapcol " .. native), "Swap column " .. arrow)
        end
    else
        for _, key in ipairs({ arrow, letter }) do
            bind(mod("CTRL + " .. key), d.window.move({ direction = native }), "Move window " .. arrow)
        end
    end
end

for _, item in ipairs({
    { "Page_Down", "+1", "next" }, { "U", "+1", "next" },
    { "Page_Up", "-1", "previous" }, { "I", "-1", "previous" },
    { "mouse_down", "+1", "next" }, { "mouse_up", "-1", "previous" },
}) do
    local key, workspace, label = table.unpack(item)
    bind(mod(key), d.focus({ workspace = workspace }), "Focus " .. label .. " workspace")
    bind(mod("CTRL + " .. key),
        d.window.move({ workspace = workspace, follow = true }),
        "Move window to " .. label .. " workspace")
end
for id = 1, 9 do
    bind(mod(tostring(id)), d.focus({ workspace = tostring(id) }), "Focus workspace " .. id)
    bind(mod("CTRL + " .. id),
        d.window.move({ workspace = tostring(id), follow = true }), "Move window to workspace " .. id)
end
for _, item in ipairs({
    { "mouse_left", "l", "left" }, { "mouse_right", "r", "right" },
    { "SHIFT + mouse_up", "l", "left" }, { "SHIFT + mouse_down", "r", "right" },
}) do
    local key, native, label = table.unpack(item)
    bind(mod(key), d.focus({ direction = native }), "Focus " .. label .. " column")
    bind(mod("CTRL + " .. key), d.layout("swapcol " .. native), "Swap column " .. label)
end

for _, item in ipairs({
    { "bracketleft", "prev", "left" }, { "bracketright", "next", "right" },
}) do
    bind(mod(item[1]), d.layout("consume_or_expel " .. item[2]), "Consume or expel " .. item[3])
end
bind(mod("comma"), d.layout("consume"), "Consume focused window")
bind(mod("period"), d.layout("expel"), "Expel focused window")
bind(mod("R"), d.layout("colresize +conf"), "Next preset column width")
bind(mod("SHIFT + R"), d.layout("colresize -conf"), "Previous preset column width")
bind(mod("CTRL + R"), d.layout("colresize 0.5"), "Reset column width")
bind(mod("minus"), d.layout("colresize -0.1"), "Narrow column")
bind(mod("equal"), d.layout("colresize +0.1"), "Widen column")
bind(mod("SHIFT + minus"), d.window.resize({ x = 0, y = -50, relative = true }), "Shorten window")
bind(mod("SHIFT + equal"), d.window.resize({ x = 0, y = 50, relative = true }), "Taller window")
bind(mod("F"), d.window.fullscreen({ mode = "maximized", action = "toggle", layout_aware = true }), "Maximize window")
bind(mod("SHIFT + F"), d.window.fullscreen({ mode = "fullscreen", action = "toggle", layout_aware = true }), "Toggle fullscreen")
bind(mod("CTRL + F"), d.layout("fit expand"), "Expand column to available width")
bind(mod("C"), d.layout("fit_into_view"), "Bring column into view")
bind(mod("CTRL + C"), d.layout("fit visible"), "Fit visible columns")
bind(mod("V"), d.window.float({ action = "toggle" }), "Toggle floating")
bind(mod("SHIFT + V"), function()
    local active = hl.get_active_window()
    if active then
        hl.dispatch(d.focus({ window = active.floating and "tiled" or "floating" }))
    end
end, "Focus floating or tiled window")
bind(mod("T"), d.group.toggle(), "Toggle native window group")
bind(mod("ALT + left"), d.group.prev(), "Previous group tab")
bind(mod("ALT + right"), d.group.next(), "Next group tab")
bind(mod("Escape"), function()
    local disabled = hl.get_config("binds.disable_keybind_grabbing")
    hl.config({ binds = { disable_keybind_grabbing = not disabled } })
end, "Toggle shortcut grabbing", { dont_inhibit = true })
bind(mod("SHIFT + P"), function()
    hl.timer(function() hl.dispatch(d.dpms({ action = "off" })) end, { timeout = 500, type = "oneshot" })
end, "Turn displays off after a short delay")

bind(mod("Return"), d.exec_cmd("uwsm app -- kitty"), "Open Kitty")
bind(mod("E"), d.exec_cmd("uwsm app -- fuzzel"), "Open launcher")
bind(mod("B"), d.exec_cmd("uwsm app -- " .. home .. "/.local/bin/browser"), "Open browser")
bind(mod("ALT + L"), d.exec_cmd("loginctl lock-session"), "Lock session")
if host.ddc_input_command then
    bind(mod("ALT + Return"), d.exec_cmd(host.ddc_input_command), "Switch monitor input")
end
bind(mod("CTRL + W"), d.exec_cmd(home .. "/.local/bin/svc restart topbar"), "Restart topbar")
bind(mod("ALT + T"), d.exec_cmd("theme-switch"), "Choose theme")
bind(mod("P"), d.exec_cmd("theme-switch --wallpaper"), "Change wallpaper")
bind(mod("CTRL + P"), d.exec_cmd("theme-switch --refresh-wallpaper"), "Refresh wallpaper")
bind(mod("W"), d.window.close(), "Close focused window")

local locked_repeat = { locked = true, repeating = true }
bind("XF86AudioRaiseVolume", d.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+"), "Raise volume", locked_repeat)
bind("XF86AudioLowerVolume", d.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"), "Lower volume", locked_repeat)
bind("XF86AudioMute", d.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), "Toggle sound", { locked = true })
bind("XF86AudioMicMute", d.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), "Toggle microphone", { locked = true })
bind("XF86MonBrightnessUp", d.exec_cmd("brightnessctl --class=backlight set +10%"), "Raise brightness", locked_repeat)
bind("XF86MonBrightnessDown", d.exec_cmd("brightnessctl --class=backlight set 10%-"), "Lower brightness", locked_repeat)
bind(mod("ALT + S"), d.exec_cmd("pkill orca || exec orca"), "Toggle Orca", { locked = true })

local function screenshot(mode)
    return d.exec_cmd("sh -c 'hyprshot " .. mode
        .. " -o \"$HOME/Pictures/Screenshots\""
        .. " -f \"Screenshot_from_$(date +%Y-%m-%d_%H-%M-%S).png\"'")
end
bind("Print", screenshot("-m region"), "Capture region")
bind("CTRL + Print", screenshot("-m output -m active"), "Capture active output")
bind("ALT + Print", screenshot("-m window -m active"), "Capture active window")

-- Fuzzel displays described binds; its selection is never executed.
bind(mod("SHIFT + slash"), d.exec_cmd(
    [[hyprctl -j binds | jq -r '.[] | select(.has_description) | "\(.key)\t\(.description)"' | fuzzel --dmenu --prompt 'Shortcuts: ' >/dev/null]]
), "Show shortcuts")
local logout_prompt = [[choice=$(printf 'Cancel\nLog out\n' | fuzzel --dmenu --only-match --prompt 'Session: '); [ "$choice" = 'Log out' ] && uwsm stop]]
bind(mod("SHIFT + E"), d.exec_cmd(logout_prompt), "Confirm log out")
bind("CTRL + ALT + Delete", d.exec_cmd(logout_prompt), "Confirm log out")

if hl.plugin.hyprexpo ~= nil then
    bind(mod("O"), function() hl.plugin.hyprexpo.expo("toggle all") end, "Open visual overview")
    hl.define_submap("hyprexpo", function()
        hl.bind(mod("O"), function() hl.plugin.hyprexpo.expo("cancel") end)
        hl.bind("Escape", function() hl.plugin.hyprexpo.expo("cancel") end)
        for _, item in ipairs({
            { "left", "left" }, { "right", "right" },
            { "up", "up" }, { "down", "down" },
        }) do
            hl.bind(item[1], function() hl.plugin.hyprexpo.kb_focus(item[2]) end)
        end
        hl.bind("Return", function() hl.plugin.hyprexpo.kb_confirm() end)
    end)
end

local function open_switcher(modifier, key, reverse)
    local right = modifier == "ALT" and "Alt_R" or "Super_R"
    local physical = modifier .. (hl.is_key_down(right) and "_R" or "_L")
    local command = "hyprswitch gui --mod-key " .. physical
        .. " --key " .. key
        .. " --close mod-key-release --reverse-key=mod=SHIFT"
        .. " --sort-recent --switch-type client --include-special-workspaces"
        .. " --max-switch-offset 0"
    if key == "grave" then command = command .. " --filter-same-class" end
    hl.exec_cmd(command .. " && hyprswitch dispatch" .. (reverse and " -r" or ""))
end
for _, modifier in ipairs({ "ALT", "SUPER" }) do
    for _, key in ipairs({ "Tab", "grave" }) do
        bind(modifier .. " + " .. key, function() open_switcher(modifier, key, false) end, "Switch windows")
        bind(modifier .. " + SHIFT + " .. key, function() open_switcher(modifier, key, true) end, "Switch windows backward")
    end
end

if host.lid then
    local panel = host.lid.output
    local last_disabled = nil
    local pending = nil

    local function lid_closed()
        local file, err = io.open(host.lid.state, "r")
        if not file then
            print("Hyprland lid state unavailable: " .. tostring(err))
            return false
        end
        local state = file:read("*a")
        file:close()
        if state:match("%f[%a]closed%f[%A]") then return true end
        if state:match("%f[%a]open%f[%A]") then return false end
        print("Hyprland lid state is invalid: " .. host.lid.state)
        return false
    end

    local function has_real_external(monitors)
        for _, monitor in ipairs(monitors) do
            if monitor.name ~= panel and monitor.name ~= "FALLBACK" and not monitor.is_mirror then
                return true
            end
        end
        return false
    end

    local function reconcile_lid()
        local disabled = lid_closed() and has_real_external(hl.get_monitors())
        if disabled ~= last_disabled then
            last_disabled = disabled
            hl.monitor({ output = panel, disabled = disabled })
        end
    end

    local function schedule_reconcile()
        -- Config verification has no compositor event loop or monitor state.
        if not os.getenv("HYPRLAND_INSTANCE_SIGNATURE") then return end
        if pending and pending:is_enabled() then return end
        pending = hl.timer(function()
            pending = nil
            reconcile_lid()
        end, { timeout = 1, type = "oneshot" })
    end

    for _, event in ipairs({
        "monitor.added", "monitor.removed", "monitor.layout_changed",
        "config.reloaded", "hyprland.start",
    }) do
        hl.on(event, schedule_reconcile)
    end
    hl.bind("switch:on:" .. host.lid.switch, function()
        hl.exec_cmd("loginctl lock-session")
        schedule_reconcile()
    end, { locked = true })
    hl.bind("switch:off:" .. host.lid.switch, schedule_reconcile, { locked = true })
end

-- Theme data is optional for a standalone checkout. A present malformed file fails visibly.
load_optional(home .. "/.local/share/trev-themes/current/hyprland.lua")
