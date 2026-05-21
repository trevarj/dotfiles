(define-module (trev-guix systems installer)
  #:use-module (gnu)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system install)
  #:use-module (srfi srfi-13))

(use-service-modules base guix)

(use-package-modules
 bash
 version-control)

(define %nonguix-pubkey-file
  (plain-file
   "nonguix.pub"
   "(public-key
     (ecc (curve Ed25519)
          (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))

(define %build-host-pubkey-file
  (local-file "/etc/guix/signing-key.pub"
              "build-host-guix-signing-key.pub"))

(define %installer-substitute-urls
  '("https://ci.guix.gnu.org"
    "https://bordeaux.guix.gnu.org"
    "https://substitutes.nonguix.org"))

(define (path-component? component file)
  (or (string-suffix? (string-append "/" component) file)
      (string-contains file (string-append "/" component "/"))))

(define (dotfiles-file? file stat)
  (not (or (path-component? ".git" file)
           (string-suffix? "/stinkpad-installer.iso" file)
           (path-component? "stinkpad-target-system" file))))

(define (source-checkout-file? file stat)
  (not (or (path-component? ".git" file)
           (path-component? "target" file))))

(define %dotfiles-checkout
  (local-file "../.." "trev-dotfiles"
              #:recursive? #t
              #:select? dotfiles-file?))

(define %gnome-topbar-checkout
  (local-file "../../../gnome-topbar" "gnome-topbar"
              #:recursive? #t
              #:select? source-checkout-file?))

(define %guixboy-checkout
  (local-file "../../../guixboy" "guixboy"
              #:recursive? #t
              #:select? source-checkout-file?))

(define %target-closure-archive-path
  (let ((path (getenv "STINKPAD_TARGET_CLOSURE_ARCHIVE")))
    (and path
         (not (string-null? path))
         path)))

;; The build script can embed a prebuilt target-system archive so the live
;; installer imports the closure before running `guix system init`.
(define %target-closure-archive
  (and %target-closure-archive-path
       (local-file %target-closure-archive-path
                   "stinkpad-target-system.nar")))

(define %host-torrc
  (local-file "/home/trev/.config/tor/torrc" "torrc"))

(define %install-stinkpad-script
  (local-file "../files/scripts/install-stinkpad-guix"
              "install-stinkpad-guix"))

(define %finish-stinkpad-install-script
  (local-file "../files/scripts/finish-stinkpad-install"
              "finish-stinkpad-install"))

(define %install-stinkpad-command
  (program-file
   "install-stinkpad"
   #~(apply execl
            #$(file-append bash "/bin/bash")
            "bash"
            #$%install-stinkpad-script
            (cdr (command-line)))))

(define %finish-stinkpad-install-command
  (program-file
   "finish-stinkpad-install"
   #~(apply execl
            #$(file-append bash "/bin/bash")
            "bash"
            #$%finish-stinkpad-install-script
            (cdr (command-line)))))

(define %install-stinkpad-package
  (package
    (name "install-stinkpad")
    (version "0")
    (source #f)
    (build-system trivial-build-system)
    (arguments
     (list
      #:builder
      #~(begin
          (let ((bin (string-append #$output "/bin")))
            (mkdir #$output)
            (mkdir bin)
            (copy-file #$%install-stinkpad-command
                       (string-append bin "/install-stinkpad"))
            (copy-file #$%finish-stinkpad-install-command
                       (string-append bin "/finish-stinkpad-install"))
            (chmod (string-append bin "/install-stinkpad") #o555)
            (chmod (string-append bin "/finish-stinkpad-install") #o555)))))
    (home-page #f)
    (synopsis "Install the stinkpad Guix system")
    (description "Install the bundled stinkpad Guix system configuration.")
    (license #f)))

(define-public %stinkpad-installer
  (operating-system
    (inherit installation-os-nonfree)
    (host-name "stinkpad-installer")
    (timezone "Etc/UTC")
    (kernel-arguments '("quiet"))
    (firmware (cons* i915-firmware
                     iwlwifi-firmware
                     ibt-hw-firmware
                     sof-firmware
                     linux-firmware
                     amdgpu-firmware
                     (operating-system-firmware installation-os-nonfree)))
    (services
     (append
      (modify-services (operating-system-user-services installation-os-nonfree)
        (guix-service-type
         config =>
         (guix-configuration
          (inherit config)
          (substitute-urls %installer-substitute-urls)
          (authorized-keys
           (cons* %nonguix-pubkey-file
                  %build-host-pubkey-file
                  %default-authorized-guix-keys)))))
      (list
       (simple-service 'trev-dotfiles etc-service-type
                       (append
                        `(("trev-dotfiles" ,%dotfiles-checkout)
                          ("gnome-topbar"
                           ,%gnome-topbar-checkout)
                          ("guixboy"
                           ,%guixboy-checkout))
                        (if %target-closure-archive
                            `(("stinkpad-target-system.nar"
                               ,%target-closure-archive))
                            '())))
       (extra-special-file "/home/trev/.config/tor/torrc"
                           %host-torrc))))
    (packages
     (cons* %install-stinkpad-package
            git
            (operating-system-packages installation-os-nonfree)))))
