;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(define-module (trev-guix home sway)
  #:use-module (gnu home)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services fontutils)
  #:use-module (gnu home services sound)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (gnu home services shells))

(home-environment
 ;; Below is the list of packages that will show up in your
 ;; Home profile, under ~/.guix-home/profile.
 (packages
  (specifications->packages
   (list
    "curl"
    "dbus"
    "direnv"
    "emacs-pgtk"
    "eza"
    "fd"
    "flatpak"
    "font-google-noto"
    "font-google-noto-emoji"
    "font-terminus"
    "fuzzel"
    "fzf"
    "fzf-tab"
    "fwupd"
    "gammastep"
    "git"
    "git:send-email"
    "gnupg"
    "grimshot"
    "jq"
    "kitty"
    "libtool"
    "mpv"
    "msmtp"
    "ncurses"
    "neofetch"
    "papirus-icon-theme"
    "pavucontrol"
    "pinentry-tty"
    "pipewire"
    "ripgrep"
    "stow"
  ; "telegram-desktop"
    "wireplumber"
    "xdg-dbus-proxy"
    "xdg-desktop-portal"
    "xdg-desktop-portal-gtk"
    "xdg-desktop-portal-wlr"
    "xdg-utils"
    "zsh"
    "zsh-autopair"
    "zsh-autosuggestions"
    "zsh-completions"
    "zsh-syntax-highlighting")))

 ;; Below is the list of Home services.  To search for available
 ;; services, run 'guix home search KEYWORD' in a terminal.
 (services
  (list
   (service home-dbus-service-type)
   (service home-pipewire-service-type)
   (service home-zsh-service-type
            (home-zsh-configuration
             (zshenv (list (local-file "../../zsh/.zshenv" "zshenv")))
             (zshrc (list (local-file "../../zsh/.zshrc" "zshrc")))
             (zprofile (list (local-file "../../zsh/.zprofile" "zprofile")))))
   (simple-service 'additional-fonts-service
                   home-fontconfig-service-type
                   (list "~/Workspace/dotfiles/fonts/.local/share/fonts"
                         (let ((prefer '(prefer
                                         (family "Iosevka JBM")
                                         (family "Symbols Nerd Font Mono"))))
                            `((alias (@ (binding "strong"))
                                     (family "monospace")
                                     ,prefer)
                              (alias (@ (binding "strong"))
                                     (family "system-ui")
                                     ,prefer)
                              (alias (@ (binding "strong"))
                                     (family "sans-serif")
                                     (prefer (family "Noto Sans")))))))
   (simple-service 'flatpak-service home-shell-profile-service-type
		   (list
		    (local-file
		     (string-append (getenv "HOME")
				    "/.guix-home/profile/etc/profile.d/flatpak.sh")
		     "flatpak.sh"))))))
