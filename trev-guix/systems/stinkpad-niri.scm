(define-module (trev-guix systems stinkpad-niri)
  #:use-module (gnu)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (trev-guix systems stinkpad))

(use-service-modules
 desktop
 xorg)

(use-package-modules
 audio
 freedesktop
 glib
 gnome
 gnome-xyz
 linux
 pulseaudio
 qt
 shells
 rust-apps
 wm
 xdisorg
 xorg)


(define-public %stinkpad-niri
  (operating-system
    (inherit %stinkpad)
    (packages
     (cons*
      brightnessctl
      cava
      cliphist
      fuzzel
      matugen
      ;; niri
      (package ;; https://codeberg.org/guix/guix/pulls/4363
        (inherit niri)
        (arguments
         (ensure-keyword-arguments (package-arguments niri)
                                   '(#:cargo-install-paths '(".")))))
      papirus-icon-theme
      pavucontrol
      pipewire
      qtwayland
      quickshell
      swayidle
      swaylock
      wireplumber
      wlsunset
      xdg-desktop-portal
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
      xwayland-satellite
      (operating-system-packages %stinkpad)))

    (setuid-programs %setuid-programs)

    (services
     (cons*
      (service greetd-service-type
               (greetd-configuration
                 (greeter-supplementary-groups (list "video" "input"))
                 (terminals
                  (list
                   (greetd-terminal-configuration
                     (terminal-vt "1")
                     (terminal-switch #t)
                     ;; Use zsh as default shell
                     (default-session-command
                       (greetd-agreety-session
                         (command
                          (greetd-user-session
                            (command (file-append zsh "/bin/zsh"))
                            (command-args '("-l")))))))
                   ;; Set up remaining TTYs for terminal use
                   (greetd-terminal-configuration (terminal-vt "2"))
                   (greetd-terminal-configuration (terminal-vt "3"))))))
      (service screen-locker-service-type
               (screen-locker-configuration
                 (name "swaylock")
                 (program (file-append swaylock "/bin/swaylock"))
                 (using-pam? #t)
                 (using-setuid? #f)))
      (modify-services (operating-system-user-services %stinkpad)
        (delete gdm-service-type)
        ;; greetd-service-type provides "greetd" PAM service
        (delete login-service-type)
        ;; and can be used in place of mingetty-service-type
        (delete mingetty-service-type))))))
