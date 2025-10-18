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
  #:use-module (trev-guix packages byedpi)
  #:use-module (trev-guix packages emacs)
  #:use-module (trev-guix packages headsetcontrol)
  #:use-module (trev-guix services flatpak)
  #:use-module (trev-guix services fontconfig))

(use-package-modules
 admin aspell compression curl file-systems fonts freedesktop
 gnome gnome-xyz gnupg guile hardware image-viewers linux mail
 package-management pretty-print rust-apps shells shellutils ssh
 terminals tls tor version-control video vim vpn web xdisorg)

(define-public %home-base-environment
  (home-environment
    ;; Below is the list of packages that will show up in your
    ;; Home profile, under ~/.guix-home/profile.
    (packages
     (list
      aspell
      aspell-dict-en
      aspell-dict-ru
      byedpi
      curl
      direnv
      ddcutil
      emacs-next-next-pgtk
      eza
      fd
      flatpak
      font-google-noto
      font-google-noto-emoji
      font-google-noto-sans-cjk
      font-terminus
      fzf
      fzf-tab
      fwupd-nonfree
      git
      (specification->package+output "git:send-email")
      gnupg
      guile-next
      headsetcontrol-3.1.0
      jq
      kitty
      mpv
      msmtp
      neofetch
      netcat
      papirus-icon-theme
      pinentry-tty
      ripgrep
      stow
      torsocks
      wireguard-tools
      xdg-utils
      zsh
      zsh-autopair
      zsh-autosuggestions
      zsh-completions
      zsh-syntax-highlighting))

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
      (service home-flatpak-service-type)
      (service byedpi-service-type '("-o1" "-o25+s" "-T3" "-At" "1+s"))
      %home-fontconfig-service-extension))))
