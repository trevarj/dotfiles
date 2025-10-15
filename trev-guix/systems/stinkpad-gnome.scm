(define-module (trev-guix systems stinkpad-gnome)
  #:use-module (gnu)
  #:use-module (guix utils)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (trev-guix services fwupd))

(use-service-modules
  cups
  desktop
  guix
  linux
  networking
  ssh
  virtualization
  xorg)
 
(use-package-modules
  audio
  bash
  cups
  emacs
  file-systems
  fonts
  gnome
  golang-web
  libusb
  linux
  package-management
  scanner
  shells
  ssh
  tor
  version-control
  video)

(define root-uuid "4b3be666-93bc-49e1-b275-cfccbc9c2729")
(define efi-uuid "4B66-8689")
(define swap-uuid "f95483f8-7921-4f0f-b509-2752e67b7a2f")

(define nonguix-pubkey-file
  (plain-file
   "nonguix.pub"
   "(public-key
     (ecc (curve Ed25519)
          (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))

(operating-system
  (host-name "stinkpad")
  (timezone "Europe/Moscow")
  (locale "en_US.utf8")

  ;; Non-free Linux and firmware
  (kernel linux)
  (kernel-arguments (cons* "modprobe.blacklist=pcspkr,snd_pcsp"
                           %default-kernel-arguments))
  (firmware (list linux-firmware radeon-firmware))
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
          (source (uuid root-uuid))
          (target "root")
          (type luks-device-mapping))))

  (file-systems (cons*
                 (file-system
                   (device "/dev/mapper/root")
                   (mount-point "/")
                   (type "ext4")
                   (dependencies mapped-devices))
                 (file-system
                   (device (uuid efi-uuid 'fat32))
                   (mount-point "/boot/efi")
                   (type "vfat"))
                 %base-file-systems))
  
  ;; Find swap UUID with `swaplabel /dev/[device name]`
  (swap-devices (list
                 (swap-space
                  (target (uuid swap-uuid)))))

  (groups (cons*
           (user-group (name "trev"))
           (user-group (name "i2c"))
           %base-groups))
  (users
   (cons (user-account
          (name "trev")
          (comment "Trevor Arjeski")
          (group "users")
          (shell (file-append zsh "/bin/zsh"))
          (home-directory "/home/trev")
          (supplementary-groups
           '("trev" "wheel" "netdev" "kvm" "tty" "input" "libvirt"
             "dialout" "i2c" "lp" "audio" "video" "kmem" "kvm")))
         %base-user-accounts))

  ;; Base packages, others will be installed in using a manifest
  (packages (cons* exfat-utils
                   fuse-exfat
                   git
                   lyrebird
                   tor
                   zsh
                   %base-packages))

  ;; Configure only the services necessary to run the system
  (services
   (append
    (modify-services %desktop-services
      ;; Use Wayland
      (gdm-service-type
       config =>
       (gdm-configuration
        (inherit config)
        (wayland? #t)))
      ;; Configure TTYs
      (console-font-service-type
       config =>
       (map (lambda (tty)
              ;; Use a larger font for HIDPI screens
              (cons tty (file-append
                         font-terminus
                         "/share/consolefonts/ter-128n")))
            '("tty1" "tty2" "tty3")))
      ;; Prevent sleep when switching on KVM+Dock
      (elogind-service-type
       config =>
       (elogind-configuration
        (inherit config)
        (handle-lid-switch-external-power 'ignore)))
      (sane-service-type
       _ =>
       (sane-configuration
        (backends (list sane-backends sane-airscan)))))
    (list
     (service gnome-desktop-service-type)

     (service fwupd-service-type)
     ;; Configure the Guix service and ensure we use Nonguix substitutes
     (simple-service
      'add-nonguix-substitutes
      guix-service-type
      (guix-extension
       (substitute-urls
        (list
         "https://ci.guix.trop.in"
         "https://bordeaux.guix.gnu.org"
         "https://substitutes.nonguix.org"
         "https://ci.guix.trevs.site"))
       (authorized-keys
        (cons* nonguix-pubkey-file
               %default-authorized-guix-keys))))

     ;; Enable SSH access
     (service openssh-service-type
              (openssh-configuration
               (openssh openssh-sans-x)
               (port-number 22)))

     (service tor-service-type
              (tor-configuration
               (transport-plugins
                (list (tor-transport-plugin
                       (protocol "webtunnel")
                       (program (file-append lyrebird "/bin/lyrebird")))))
               (config-file
                (local-file "/home/trev/.config/tor/torrc"))))

     (service cups-service-type
              (cups-configuration
               (web-interface? #t)
               (extensions
                (list cups-filters
                      epson-inkjet-printer-escpr))))

     (service libvirt-service-type)

     (udev-rules-service 'pipewire-add-udev-rules pipewire)
     (udev-rules-service
      'arctis-7-nova-udev-rules
      (udev-rule
       "50-arctis-headset.rules"
       (string-append
        "KERNEL==\"hidraw*\", SUBSYSTEM==\"hidraw\","
        "ATTRS{idVendor}==\"1038\", ATTRS{idProduct}==\"2202\","
        "TAG+=\"uaccess\"")))
     (udev-rules-service
      'ddcutil-i2c-udev-rules
      (udev-rule
       "60-ddcutil-i2c.rules"
       "KERNEL==\"i2c-[0-9]*\", GROUP=\"i2c\", MODE=\"0660\""))))))
