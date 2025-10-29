(define-module (trev-guix services flatpak)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (guix gexp))

(define (home-flatpak-script _)
  (list
   (local-file
    (string-append
     (getenv "HOME")
     "/.guix-home/profile/etc/profile.d/flatpak.sh")
    "flatpak.sh")))

;; workaround to get dbus to load flatpak services because flatpak.sh gets
;; run too late
(define (home-flatpak-environment-variables _)
  `(("XDG_DATA_DIRS" .
     ,(string-append (getenv "XDG_DATA_HOME")
                     "share/flatpak/exports/share:"
                     (getenv "XDG_DATA_DIRS")))))

(define-public home-flatpak-service-type
  (service-type
    (name 'home-flatpak)
    (extensions
     (list (service-extension
            home-shell-profile-service-type
            home-flatpak-script)
           (service-extension
            home-environment-variables-service-type
            home-flatpak-environment-variables)))
    (default-value '())
    (description "A service for flatpak integration with guix home.")))
