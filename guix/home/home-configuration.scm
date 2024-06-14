;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (gnu home)
             (gnu home services desktop)
             (gnu home services sound)
             (gnu packages)
             (gnu services)
             (guix gexp))

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
 ;; (packages
 ;;  (specifications->packages
 ;;   (list "pipewire"
 ;;         "xdg-desktop-portal"
 ;;         "xdg-desktop-portal-wlr"
 ;;         "git"
 ;;         "fuzzel"
 ;;         "neofetch"
 ;;         "telegram-desktop"
 ;;         "git:send-email"
 ;;         "weechat"
 ;;         "msmtp"
 ;;         "pinentry-tty"
 ;;         "flatpak-xdg-utils"
 ;;         "wireplumber"
 ;;         "emacs-pgtk"
 ;;         "font-terminus"
 ;;         "ncurses"
 ;;         "ripgrep"
 ;;         "fd"
 ;;         "gammastep"
 ;;         "pavucontrol"
 ;;         "dbus"
 ;;         "flatpak"
 ;;         "libtool"
 ;;         "jq"
 ;;         "grimshot"
 ;;         "mpv"
 ;;         "fzf"
 ;;         "zsh"
 ;;         "gnupg"
 ;;         "kitty"
 ;;         "curl"
 ;;         "stow"
 ;;         "font-google-noto-emoji"
 ;;         "direnv"
 ;;         "hicolor-icon-theme"
 ;;         "fzf-tab"
 ;;         "libvterm"
 ;;         "zsh-autopair"
 ;;         "zsh-syntax-highlighting"
 ;;         "zsh-autosuggestions"
 ;;         "zsh-completions")))

  ;; Below is the list of Home services.  To search for available
  ;; services, run 'guix home search KEYWORD' in a terminal.
 (services
  (list
   (service home-dbus-service-type)
   (service home-pipewire-service-type))))
