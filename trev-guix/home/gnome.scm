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
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (trev-guix home base)
  #:use-module (trev-guix packages gnome-xyz-local))

(use-package-modules gnome gnome-xyz)

(home-environment
  (inherit %home-base-environment)
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
  (packages
   (append
    (home-environment-packages %home-base-environment)
    (list
     adw-gtk3-theme
     gnome-tweaks
     gnome-shell-extension-appindicator
     gnome-shell-extension-executor
     gnome-shell-extension-weather-oclock)))
  (services
   (cons*
    (service home-dotfiles-service-type
             (home-dotfiles-configuration
               (directories '("../../"))
               (layout 'stow)
               (packages '("zsh" "dconf" "guix"))
               (excluded '("\\.zshenv" "\\.zshrc" "\\.zprofile"))))
    (home-environment-user-services %home-base-environment))))
