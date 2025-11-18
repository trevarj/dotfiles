#!/usr/bin/env bash
# ============================================
# GNOME Settings Restore Script
# Generated from dconf dump: dconf dump / > /tmp/dump.dconf
# ============================================

LOGFILE="/tmp/gnome-settings-apply.log"
echo "Applying GNOME settings..." | tee "$LOGFILE"

apply_setting() {
    local schema="$1"
    local key="$2"
    local value="$3"

    if gsettings list-schemas | grep -q "^${schema%%:*}" || gsettings list-relocatable-schemas | grep -q "^${schema%%:*}"; then
        echo "✅ Applying: $schema → $key = $value" | tee -a "$LOGFILE"
        if ! gsettings set "$schema" "$key" "$value" 2>>"$LOGFILE"; then
            echo "⚠️ Failed: $schema $key" | tee -a "$LOGFILE"
        fi
    else
        echo "⏭️ Skipping missing schema: $schema" | tee -a "$LOGFILE"
    fi
}

apply_setting org.gnome.GWeather4 temperature-unit "'centigrade'"

apply_setting org.gnome.clocks world-clocks "[{'location': <(uint32 2, <('New York', 'KNYC', true, [(0.71180344078725644, -1.2909618758762367)], [(0.71059804659265924, -1.2916478949920254)])>)>}, {'location': <(uint32 2, <('London', 'EGWU', true, [(0.89971722940307675, -0.007272211034407213)], [(0.89884456477707964, -0.0020362232784242244)])>)>}, {'location': <(uint32 2, <('Hong Kong', 'VHHH', true, [(0.38979019379430269, 1.9928751117510946)], [(0.38949931722116538, 1.9928751117510946)])>)>}, {'location': <(uint32 2, <('Seoul', 'RKSS', true, [(0.65537113412387071, 2.2130774915288098)], [(0.65565717613498009, 2.2165632980174781)])>)>}, {'location': <(uint32 2, <('Sydney', 'YSSY', true, [(-0.59253928105207498, 2.6386469349889961)], [(-0.59137572239964786, 2.6392287230418559)])>)>}, {'location': <(uint32 2, <('Athens', 'LGAV', true, [(0.66206155710541803, 0.41771546182621205)], [(0.66293422173141536, 0.41422480332222328)])>)>}]"

apply_setting org.gnome.desktop.datetime automatic-timezone "true"

apply_setting org.gnome.desktop.input-sources mru-sources "[('xkb', 'us'), ('xkb', 'ru')]"
apply_setting org.gnome.desktop.input-sources show-all-sources "true"
apply_setting org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru')]"

apply_setting org.gnome.desktop.interface clock-show-weekday "true"
apply_setting org.gnome.desktop.interface color-scheme "'prefer-dark'"
apply_setting org.gnome.desktop.interface cursor-size "24"
apply_setting org.gnome.desktop.interface enable-animations "false"
apply_setting org.gnome.desktop.interface enable-hot-corners "false"
apply_setting org.gnome.desktop.interface font-antialiasing "'rgba'"
apply_setting org.gnome.desktop.interface font-hinting "'medium'"
apply_setting org.gnome.desktop.interface gtk-theme "'adw-gtk3-dark'"
apply_setting org.gnome.desktop.interface icon-theme "'Adwaita'"
apply_setting org.gnome.desktop.interface show-battery-percentage "true"
apply_setting org.gnome.desktop.interface toolkit-accessibility "false"

apply_setting org.gnome.desktop.peripherals.keyboard delay "250"
apply_setting org.gnome.desktop.peripherals.keyboard repeat-interval "20"

apply_setting org.gnome.desktop.peripherals.mouse accel-profile "'flat'"
apply_setting org.gnome.desktop.peripherals.mouse speed "0.0"

apply_setting org.gnome.desktop.peripherals.touchpad accel-profile "'flat'"
apply_setting org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled "true"

apply_setting org.gnome.desktop.session idle-delay "900"

apply_setting org.gnome.desktop.wm.keybindings close "['<Super>w']"
apply_setting org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Shift><Super>1']"
apply_setting org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Shift><Super>2']"
apply_setting org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Shift><Super>3']"
apply_setting org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<Shift><Super>4']"
apply_setting org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
apply_setting org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
apply_setting org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
apply_setting org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"

apply_setting org.gnome.desktop.wm.preferences focus-mode "'sloppy'"

apply_setting org.gnome.mutter center-new-windows "true"
apply_setting org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

apply_setting org.gnome.settings-daemon.plugins.color night-light-enabled "true"

apply_setting org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/']"
apply_setting org.gnome.settings-daemon.plugins.media-keys www "['<Super>b']"

# Custom keybindings
apply_setting org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "'<Super>Return'"
apply_setting org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "'kitty'"
apply_setting org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "'Launch Terminal'"

apply_setting org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "'<Alt><Super>Page_Up'"
apply_setting org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command "'ddcutil -b 18 setvcp 10 + 10'"
apply_setting org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name "'Brightness Up'"

apply_setting org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding "'<Alt><Super>Page_Down'"
apply_setting org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command "'ddcutil -b 18 setvcp 10 - 10'"
apply_setting org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name "'Brightness Down'"

apply_setting org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ binding "'<Alt><Super>Return'"
apply_setting org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ command "'ddcutil -b 18 setvcp 60 0x0f'"
apply_setting org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ name "'Switch Input to DP-1'"

apply_setting org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "'nothing'"
apply_setting org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout "1200"
apply_setting org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "'suspend'"

apply_setting org.gnome.shell disabled-extensions "['user-theme@gnome-shell-extensions.gcampax.github.com', 'apps-menu@gnome-shell-extensions.gcampax.github.com']"
apply_setting org.gnome.shell enabled-extensions "['auto-move-windows@gnome-shell-extensions.gcampax.github.com', 'weatheroclock@CleoMenezesJr.github.io', 'appindicatorsupport@rgcjonas.gmail.com', 'executor@raujonas.github.io']"
apply_setting org.gnome.shell favorite-apps "['com.brave.Browser.desktop', 'emacs.desktop', 'kitty.desktop', 'org.telegram.desktop.desktop', 'org.gnome.Nautilus.desktop']"
apply_setting org.gnome.shell looking-glass-history "['let app = Shell.AppSystem.get_default().lookup_app(\\'org.telegram.desktop.desktop\\'); app.launch([], global.create_app_launch_context());', 'let app = Shell.AppSystem.get_default()', 'let app = Shell.AppSystem.get_default().lookup_app(\\'org.example.App.desktop\\');', 'let app = Shell.AppSystem.get_default().lookup_app(\\'org.telegram.desktop.desktop\\');', 'Shell.AppSystem.get_default().get_all()', 'let appSys = imports.gi.Shell.AppSystem.get_default();', 'r(0)', 'inspect(1326, 1373).get_action()', 'inspect(1326, 1373).get_actions()']"
apply_setting org.gnome.shell welcome-dialog-last-shown-version "'46.10'"

apply_setting org.gnome.shell.extensions.auto-move-windows application-list "['com.brave.Browser.desktop:1', 'emacs.desktop:2', 'org.telegram.desktop.desktop:4']"

apply_setting org.gnome.shell.extensions.executor center-active "false"
apply_setting org.gnome.shell.extensions.executor left-commands-json "'{\"commands\":[{\"isActive\":true,\"command\":\"sh /home/trev/Workspace/dotfiles/polybar/.config/polybar/crypto.sh  -r\",\"interval\":3600,\"uuid\":\"77f1ddae-84ff-4029-b606-ce4890236fd2\"}]}'"
apply_setting org.gnome.shell.extensions.executor location "0"
apply_setting org.gnome.shell.extensions.executor right-commands-json "'{\"commands\":[{\"isActive\":true,\"command\":\"sh /home/trev/Workspace/dotfiles/polybar/.config/polybar/headsetcontrol.sh\",\"interval\":30,\"uuid\":\"084256c1-45e4-44ae-b91b-78f86b9c3a2e\"}]}'"

apply_setting org.gnome.shell.keybindings switch-to-application-1 "@as []"
apply_setting org.gnome.shell.keybindings switch-to-application-2 "@as []"
apply_setting org.gnome.shell.keybindings switch-to-application-3 "@as []"
apply_setting org.gnome.shell.keybindings switch-to-application-4 "@as []"

apply_setting org.gnome.shell.weather automatic-location "true"
apply_setting org.gnome.shell.weather locations "[<(uint32 2, <('Moscow', 'UUWW', true, [(0.97127572873484425, 0.65042604039431762)], [(0.97305983920281813, 0.65651530216830811)])>)>]"

apply_setting org.gnome.shell.world-clocks locations "[<(uint32 2, <('New York', 'KNYC', true, [(0.71180344078725644, -1.2909618758762367)], [(0.71059804659265924, -1.2916478949920254)])>)>, <(uint32 2, <('London', 'EGWU', true, [(0.89971722940307675, -0.007272211034407213)], [(0.89884456477707964, -0.0020362232784242244)])>)>, <(uint32 2, <('Hong Kong', 'VHHH', true, [(0.38979019379430269, 1.9928751117510946)], [(0.38949931722116538, 1.9928751117510946)])>)>, <(uint32 2, <('Seoul', 'RKSS', true, [(0.65537113412387071, 2.2130774915288098)], [(0.65565717613498009, 2.2165632980174781)])>)>, <(uint32 2, <('Sydney', 'YSSY', true, [(-0.59253928105207498, 2.6386469349889961)], [(-0.59137572239964786, 2.6392287230418559)])>)>, <(uint32 2, <('Athens', 'LGAV', true, [(0.66206155710541803, 0.41771546182621205)], [(0.66293422173141536, 0.41422480332222328)])>)>]"

# =====================================================
# Done
# =====================================================
echo "👣 GNOME settings applied. Log saved to $LOGFILE"
