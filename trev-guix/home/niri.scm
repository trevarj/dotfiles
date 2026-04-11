(define-module (trev-guix home niri)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (trev-guix home base)
  #:use-module (trev-guix services udiskie))

(define-public %home-niri-environment
  (home-environment
   (packages %home-base-packages)
   (services
    (cons*
     (service home-dotfiles-service-type
              (home-dotfiles-configuration
               (directories '("../../"))
               (layout 'stow)
               (packages
                '("zsh" "guix" "niri" "waybar" "icons" "swaync" "fuzzel" "hypr" "X"))
               (excluded '("\\.zshenv" "\\.zshrc" "\\.zprofile"))))
     (service udiskie-service-type)
     %home-base-services))))
