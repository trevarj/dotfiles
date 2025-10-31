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

(define-public %home-gnome-environment
  (home-environment
    ;; Below is the list of packages that will show up in your
    ;; Home profile, under ~/.guix-home/profile.
    (packages
     (cons*
      adw-gtk3-theme
      gnome-tweaks
      gnome-shell-extension-appindicator
      gnome-shell-extension-executor
      gnome-shell-extension-weather-oclock
      %trev-home-base-packages))
    (services
     (cons*
      (service home-dotfiles-service-type
               (home-dotfiles-configuration
                 (directories '("../../"))
                 (layout 'stow)
                 (packages '("zsh" "dconf" "guix"))
                 (excluded '("\\.zshenv" "\\.zshrc" "\\.zprofile"))))
      %trev-home-base-services))))
