;; This is an operating system configuration template
;; for a "desktop" setup without full-blown desktop
;; environments.

(use-modules (gnu) (gnu system nss)
             (nongnu packages linux)
             (nongnu packages nvidia)
             (nongnu services nvidia)
             (nongnu system linux-initrd))
(use-service-modules audio
                     cups
                     desktop
                     linux
                     networking
                     xorg)
(use-package-modules admin
                     bootloaders
                     certs
                     cups
                     file-systems
                     fonts
                     gnome-xyz
                     image-viewers
                     package-management
                     shells
                     terminals
                     tmux
                     version-control
                     video
                     wm
                     web
                     xdisorg
                     xorg)

;; Nvidia-enabled packages
(map replace-mesa '(kitty))

(operating-system
  (host-name "bad-idea")
  (timezone "Europe/Moscow")
  (locale "en_US.utf8")

  ;; Use the UEFI variant of GRUB with the EFI System
  ;; Partition mounted on /boot/efi.
  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets '("/boot/efi"))))

  ;; non-free kernel
  (kernel linux)
  ;; Nvidia kernel params
  (kernel-arguments '("modprobe.blacklist=nouveau"
                      "nvidia_drm.modeset=1"))

  ;; non-free firmware
  (initrd microcode-initrd)
  (firmware %base-firmware)

  ;; Assume the target root file system is labelled "my-root",
  ;; and the EFI System Partition has UUID 1234-ABCD.
  (file-systems (append
                 (list (file-system
                         (device (file-system-label "my-root"))
                         (mount-point "/")
                         (type "ext4"))
                       (file-system
                         (device (uuid "1234-ABCD" 'fat))
                         (mount-point "/boot/efi")
                         (type "vfat")))
                 %base-file-systems))

  ;; Swap partition
  (swap-devices
   (list (swap-space
          (target (uuid "1234-ABCD")))))

  (users (cons (user-account
                (name "trev")
                (comment "Trevor Arjeski")
                (group "users")
                (home-directory "/home/trev")
                (supplementary-groups '("audio"
                                        "input"
                                        "netdev"
                                        "tty"
                                        "video"
                                        "wheel")))
               %base-user-accounts))

  ;; Add a bunch of window managers; we can choose one at
  ;; the log-in screen with F1.
  (packages (append (list
                     ;; WM
                     bspwm polybar feh redshift
                     ;; shells
                     zsh zsh-autosuggestions
                     zsh-completions zsh-syntax-highlighting
                     ;; terminal
                     kitty tmux
                     ;; utils
                     exfat-utils git jq maim mpv neofetch
                     netcat stow xclip xsetroot
                     ;; fonts
                     font-google-noto font-google-noto-emoji
                     font-terminus bibata-cursor-theme
                     ;; printer
                     epson-inkjet-printer-escpr
                     ;; for HTTPS access
                     nss-certs)
                    %base-packages))

  (services
   (cons*
    %base-services

    ;; fontconfig cache and gc
    fontconfig-file-system-service

    ;; Don't need NetworkManager
    (service dhcpd-service-type)

    ;; Copied from %desktop-services
    (service accountsservice-service-type)
    (service elogind-service-type)
    (service dbus-root-service-type)
    (service ntp-service-type)

    ;; Sound
    (service pulseaudio-service-type)
    (service alsa-service-type)

    ;; Printing
    (service cups-service-type
             (cups-configuration
              (web-interface? #t)
              (extensions
               '(cups-filters epson-inkjet-printer-escpr))))

    ;; HiDPI tty
    (modify-services %base-services
      (delete console-font-service-type))
    (service console-font-service-type
              (map (lambda (tty)
                     ;; Use a larger font for HIDPI screens
                     (cons tty (file-append
                                font-terminus
                                "/share/consolefonts/ter-132n")))
                   '("tty1" "tty2" "tty3")))

    ;; Substitutes
    (services (modify-services %desktop-services)
           (guix-service-type config => (guix-configuration)
             (inherit config)
             (substitute-urls
              (list "https://substitutes.nonguix.org"
                    "https://ci.guix.trop.in"))

             (authorized-keys
               (append (list (plain-file "nonguix.pub"
                                         "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
                       %default-authorized-guix-keys))))
    ;; Nvidia
    (service nvidia-service-type)
    (set-xorg-configuration
     (xorg-configuration
      (modules (cons nvda %default-xorg-modules))
      (drivers '("nvidia")))))))
