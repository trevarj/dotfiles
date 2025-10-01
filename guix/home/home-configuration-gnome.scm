;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

;; TODO
;; Figure out how to work this in:
;; guix shell glib:bin
;; gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
(use-modules (gnu home)
             (gnu home services)
             (gnu home services desktop)
             (gnu home services fontutils)
             (gnu home services sound)
             (gnu packages)
             (gnu services)
             (gnu home services shells)
             (guix gexp)
             (byedpi)
             (gnome-xyz-local)
             (headsetcontrol))

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
    (simple-service 'additional-fonts-service home-fontconfig-service-type
                    (list "~/Workspace/dotfiles/fonts/.local/share/fonts"))
    (simple-service 'flatpak-service home-shell-profile-service-type
		    (list
		     (local-file
		      (string-append (getenv "HOME")
				     "/.guix-home/profile/etc/profile.d/flatpak.sh")
		      "flatpak.sh")))
    (simple-service 'xdg-for-dbus home-environment-variables-service-type
                    `(("XDG_DATA_DIRS" .
                       ,(string-append (getenv "XDG_DATA_HOME")
                                       "share/flatpak/exports/share:"
                                       (getenv "XDG_DATA_DIRS")))))
    (service byedpi-service-type '("-o1" "-o25+s" "-T3" "-At" "1+s")))))
