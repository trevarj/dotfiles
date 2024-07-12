(use-modules (gnu)
             (guix utils)
             (nongnu packages linux)
             (nongnu system linux-initrd))

(use-service-modules
  admin
  audio
  avahi
  cups
  dbus
  desktop
  guix
  linux
  networking
  pm
  ssh
  sysctl
  xorg)

(use-package-modules
  audio
  bash
  certs
  cups
  emacs
  file-systems
  fonts
  freedesktop
  libusb
  linux
  networking
  package-management
  shells
  ssh
  version-control
  video
  wm)

(operating-system
  (host-name "stinkpad")
  (timezone "Europe/Moscow")
  (locale "en_US.utf8")

  ;; Non-free Linux and firmware
  (kernel linux)
  (kernel-arguments (cons* "modprobe.blacklist=pcspkr,snd_pcsp"
                           %default-kernel-arguments))
  (firmware (list linux-firmware))
  (initrd microcode-initrd)

  ;; Keyboard layout
  (keyboard-layout (keyboard-layout "us" #:model "thinkpad"))

  ;; Use the UEFI variant of GRUB with the EFI System
  ;; Partition mounted on /boot/efi.
  (bootloader (bootloader-configuration
               (bootloader grub-efi-bootloader)
               (targets '("/boot/efi"))
               (keyboard-layout keyboard-layout)))

  ;; Specify a mapped device for the encrypted root partition.
  ;; The UUID is that returned by 'cryptsetup luksUUID'.
  (mapped-devices
   (list (mapped-device
          (source (uuid "39b03665-89b2-476d-871a-372f23923ec5"))
          (target "root")
          (type luks-device-mapping))))

  (file-systems (cons*
                  (file-system
                    (device (file-system-label "root"))
                    (mount-point "/")
                    (type "ext4")
                    (dependencies mapped-devices))
                  (file-system
                    (device (uuid "7391-6E13" 'fat))
                    (mount-point "/boot/efi")
                    (type "vfat"))
                  %base-file-systems))

  ;; Find swap UUID with `swaplabel /dev/[device name]`
  (swap-devices (list
                 (swap-space
                   (target (uuid "17eb240b-531b-4b81-830e-22938b6f3305")))))

  (users (cons (user-account
                (name "trev")
                (comment "Trevor Arjeski")
                (group "users")
                (shell (file-append zsh "/bin/zsh"))
                (home-directory "/home/trev")
                (supplementary-groups '("wheel"  ;; sudo
                                        "netdev" ;; network devices
                                        "kvm"
                                        "tty"
                                        "input"
                                        "lp"       ;; control bluetooth devices
                                        "audio"    ;; control audio devices
                                        "video"))) ;; control video devices

               %base-user-accounts))

  (groups %base-groups)

  ;; Base packages, others will be installed in using a manifest
  (packages (cons* brightnessctl
                   exfat-utils
                   fuse-exfat
                   git
                   sway
                   swaylock
                   swaybg
                   swayidle
                   zsh
                   %base-packages))

  (setuid-programs %setuid-programs)

  ;; Configure only the services necessary to run the system
  (services
   (append
    (modify-services %base-services
     (delete login-service-type)
     (delete mingetty-service-type)
     (delete console-font-service-type)
     ;; Configure the Guix service and ensure we use Nonguix substitutes
     (guix-service-type
      config => (guix-configuration
                 (inherit config)
                 (substitute-urls
                  (list
                   "https://ci.guix.trop.in"
                   "https://bordeaux.guix.gnu.org"
                   "https://substitutes.nonguix.org"))
                 (authorized-keys
                  (append
                   (list (plain-file
                          "nonguix.pub"
                          "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
                   %default-authorized-guix-keys)))))
    (list
     ;; Seat management (can't use seatd because Wireplumber depends on elogind)
     (service elogind-service-type)

     ;; Configure TTYs and graphical greeter
     (service console-font-service-type
       (map (lambda (tty)
              ;; Use a larger font for HIDPI screens
              (cons tty (file-append
                         font-terminus
                         "/share/consolefonts/ter-122n")))
            '("tty1" "tty2" "tty3")))

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
                    (greetd-agreety-session (command (file-append zsh "/bin/zsh")))))
                 ;; Set up remaining TTYs for terminal use
                 (greetd-terminal-configuration (terminal-vt "2"))
                 (greetd-terminal-configuration (terminal-vt "3"))))))

     ;; Configure swaylock as a setuid program
     (service screen-locker-service-type
              (screen-locker-configuration
               (name "swaylock")
               (program (file-append swaylock "/bin/swaylock"))
               (using-pam? #t)
               (using-setuid? #f)))

     ;; Set up Polkit to allow `wheel' users to run admin tasks
     polkit-wheel-service

     ;; Networking services
     (service network-manager-service-type
              (network-manager-configuration))

     (service wpa-supplicant-service-type) ;; Needed by NetworkManager
     (service bluetooth-service-type
              (bluetooth-configuration
               (auto-enable? #t)))
     (service usb-modeswitch-service-type)

     ;; Basic desktop system services (copied from %desktop-services)
     (service avahi-service-type)
     (service udisks-service-type)
     (service upower-service-type)
     (service cups-pk-helper-service-type)
     (service geoclue-service-type)
     (service polkit-service-type)
     (service dbus-root-service-type)
     fontconfig-file-system-service ;; Manage the fontconfig cache

     ;; Power and thermal management services
     (service thermald-service-type)
     (service tlp-service-type
              (tlp-configuration
               (cpu-boost-on-ac? #t)
               (wifi-pwr-on-bat? #t)))

     ;; Enable SSH access
     (service openssh-service-type
              (openssh-configuration
               (openssh openssh-sans-x)
               (port-number 22)))

     ;; Enable printing and scanning
     (service sane-service-type)
     (service cups-service-type
              (cups-configuration
               (web-interface? #t)
               (extensions
                (list cups-filters
                      epson-inkjet-printer-escpr))))

     ;; Set up the X11 socket directory for XWayland
     (service x11-socket-directory-service-type)

     ;; Sync system clock with time servers
     (service ntp-service-type)

     ;; Add udev rules for MTP (mobile) devices for non-root user access
     (simple-service 'mtp udev-service-type (list libmtp))

     ;; Add udev rules for a few packages
     (udev-rules-service 'pipewire-add-udev-rules pipewire)
     (udev-rules-service 'brightnessctl-udev-rules brightnessctl)))))
