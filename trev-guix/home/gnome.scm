;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

;; TODO
;; Figure out how to work this in:
;; guix shell glib:bin
;; gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
(define-module (trev-guix home gnome)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services fontutils)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services sound)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (trev-guix packages byedpi)
  #:use-module (trev-guix packages gnome-xyz-local)
  #:use-module (trev-guix packages headsetcontrol)
  #:use-module (trev-guix services flatpak))

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
  (packages
   (specifications->packages
    (list
     "aspell"
     "aspell-dict-en"
     "aspell-dict-ru"
     "adw-gtk3-theme"
     "byedpi"
     "curl"
     "direnv"
     "ddcutil"
     "emacs-next-pgtk"
     "eza"
     "fd"
     "flatpak"
     "font-google-noto"
     "font-google-noto-emoji"
     "font-google-noto-sans-cjk"
     "font-terminus"
     "fzf"
     "fzf-tab"
     "fwupd-nonfree"
     "git"
     "git:send-email"
     "glib:bin"
     "gnome-tweaks"
     "gnome-shell-extension-appindicator"
     "gnome-shell-extension-executor"
     "gnome-shell-extension-weather-oclock"
     "gnupg"
     "headsetcontrol-3.1.0"
     "jq"
     "kitty"
     "mpv"
     "msmtp"
     "neofetch"
     "netcat"
     "papirus-icon-theme"
     "pinentry-tty"
     "ripgrep"
     "stow"
     "torsocks"
     "wireguard-tools"
     "xdg-utils"
     "zsh"
     "zsh-autopair"
     "zsh-autosuggestions"
     "zsh-completions"
     "zsh-syntax-highlighting")))

  (services
   (list
    (service home-dbus-service-type)
    (service home-pipewire-service-type)
    (service home-zsh-service-type
             (home-zsh-configuration
               (xdg-flavor? #f)
               (zshenv (list (local-file "../../zsh/.zshenv" "zshenv")))
               (zshrc (list (local-file "../../zsh/.zshrc" "zshrc")))
               (zprofile (list (local-file "../../zsh/.zprofile" "zprofile")))
               (environment-variables
                `(("ASPELL_DICT_DIR" .
                   ,(string-append (getenv "HOME")
                                   "/.guix-home/profile/lib/aspell"))))))
    ;; TODO: add home-dotfiles-service-type for the symlinks to other dotfiles
    (service home-dotfiles-service-type
             (home-dotfiles-configuration
               (directories '("../../"))
               (layout 'stow)
               (packages '("zsh" "dconf"))
               (excluded '("\\.zshenv" "\\.zshrc" "\\.zprofile"))))

    (service home-flatpak-service-type)
    (service byedpi-service-type '("-o1" "-o25+s" "-T3" "-At" "1+s"))
    (simple-service 'additional-fonts-service home-fontconfig-service-type
                    (list "~/Workspace/dotfiles/fonts/.local/share/fonts")))))
