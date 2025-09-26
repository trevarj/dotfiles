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
             (gnu home services desktop)
             (gnu home services fontutils)
             (gnu home services sound)
             (gnu packages)
             (gnu packages glib)
             (gnu services)
             (guix gexp)
             (gnu home services shells))

(home-environment
 ;; Below is the list of packages that will show up in your
 ;; Home profile, under ~/.guix-home/profile.
 (packages
  (specifications->packages
   (list
    "adw-gtk3-theme"
    "curl"
    "direnv"
    "emacs-pgtk"
    "eza"
    "fd"
    "flatpak"
    "font-google-noto"
    "font-google-noto-emoji"
    "font-terminus"
    "fzf"
    "fzf-tab"
    "fwupd-nonfree"
    "git"
    "git:send-email"
    "gnome-tweaks"
    "gnupg"
    "jq"
    "kitty"
    "mpv"
    "msmtp"
    "neofetch"
    "papirus-icon-theme"
    "pinentry-tty"
    "ripgrep"
    "stow"
  ; "telegram-desktop"
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
