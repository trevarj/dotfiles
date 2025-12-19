(define-module (trev-guix home base)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services sound)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (nongnu packages firmware)
  #:use-module (trev-guix packages emacs)
  #:use-module (trev-guix packages fonts)
  #:use-module (trev-guix packages headsetcontrol)
  #:use-module (trev-guix packages misc)
  #:use-module (trev-guix packages networking)
  #:use-module (trev-guix services flatpak)
  #:use-module (trev-guix services fontconfig)
  #:use-module (trev-guix services networking))

(use-package-modules
 admin aspell audio compression containers curl
 emacs-xyz file-systems fonts freedesktop glib gnome gnome-xyz gnupg guile
 hardware image-viewers linux mail
 package-management pretty-print rust-apps shells shellutils ssh
 terminals tls tor version-control video vim vpn web xdisorg)

(eval-when (expand load eval)
  (define-public %home-base-packages
    (list
     adwaita-icon-theme
     aspell
     aspell-dict-en
     aspell-dict-ru
     byedpi
     curl
     direnv
     distrobox
     ddcutil
     easyeffects
     emacs-next-next-pgtk
     (list emacs-next-next-pgtk "doc")
     emacs-vterm
     eza
     fd
     flatpak
     font-cryptofont
     font-google-noto
     font-google-noto-emoji
     font-google-noto-sans-cjk
     font-iosevka-jbm
     font-iotrevka
     font-nerd-fonts-symbols
     font-terminus
     fzf
     fzf-tab
     fwupd-nonfree
     git
     (specification->package+output "git:send-email")
     (list glib "bin")
     gnupg
     gost
     guile-next
     guix-reconfigure
     headsetcontrol-3.1.0
     hicolor-icon-theme
     jq
     kitty
     mpv
     msmtp
     nautilus
     neofetch
     netcat
     papirus-icon-theme
     pinentry-tty
     ripgrep
     stow
     torsocks
     unzip
     wireguard-tools
     xdg-utils
     yt-dlp
     zsh
     zsh-autopair
     zsh-autosuggestions
     zsh-completions
     zsh-syntax-highlighting))

  (define-public %home-base-services
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
                '(("ASPELL_DICT_DIR" . "${HOME}/.guix-home/profile/lib/aspell")))))
     (service home-flatpak-service-type)
     (service byedpi-service-type)
     (service gost-service-type)
     %home-fontconfig-service-extension)))
