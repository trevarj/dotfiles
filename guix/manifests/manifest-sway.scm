;; This "manifest" file can be passed to 'guix package -m' to reproduce
;; the content of your profile.  This is "symbolic": it only specifies
;; package names.  To reproduce the exact same profile, you also need to
;; capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(specifications->manifest
  (list "weechat"
        "msmtp"
        "pinentry-tty"
        "flatpak-xdg-utils"
        "wireplumber"
        "emacs-pgtk"
        "font-terminus"
        "ncurses"
        "ripgrep"
        "fd"
        "gammastep"
        "pavucontrol"
        "dbus"
        "flatpak"
        "libtool"
        "libvterm"
        "jq"
        "grimshot"
        "mpv"
        "fzf"
        "zsh-autopair"
        "zsh-syntax-highlighting"
        "zsh-autosuggestions"
        "zsh-completions"
        "zsh"
        "gnupg"
        "kitty"
        "curl"
        "stow"))
