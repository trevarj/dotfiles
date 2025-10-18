;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(define-module (trev-guix home sway)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (trev-guix home base))

(use-package-modules freedesktop glib linux pulseaudio wm xdisorg)

(home-environment
  (inherit %home-base-environment)
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
  (packages
   (append
    (home-environment-packages %home-base-environment)
    (list
     fuzzel
     gammastep
     grimshot
     pavucontrol
     pipewire
     wireplumber
     xdg-dbus-proxy
     xdg-desktop-portal
     xdg-desktop-portal-gtk
     xdg-desktop-portal-wlr)))
  (services
   (cons*
    (service home-dotfiles-service-type
             (home-dotfiles-configuration
               (directories '("../../"))
               (layout 'stow)
               (packages '("zsh" "dconf" "guix" "sway" "swaylock"))
               (excluded '("\\.zshenv" "\\.zshrc" "\\.zprofile"))))
    (home-environment-user-services %home-base-environment))))
