(define-module (trev-guix systems stinkpad-sway)
  #:use-module (gnu)
  #:use-module (guix utils)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (trev-guix systems stinkpad))

(use-service-modules
 desktop
 xorg)

(use-package-modules
 linux
 shells
 wm)

(operating-system
  (inherit %stinkpad)
  (packages
   (cons*
    brightnessctl
    sway
    swaylock
    swaybg
    swayidle
    (operating-system-packages %stinkpad)))

  (setuid-programs %setuid-programs)

  (services
   (cons*
    (service greetd-service-type
             (greetd-configuration
              (greeter-supplementary-groups (list "video" "input"))
              (terminals
               (list
                ;; TTY1 is the graphical login screen for Sway
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
               ;; greetd-service-type provides "greetd" PAM service
               (delete login-service-type)
               ;; and can be used in place of mingetty-service-type
               (delete mingetty-service-type)))))
