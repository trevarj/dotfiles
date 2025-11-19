(define-module (trev-guix systems stinkpad-gnome)
  #:use-module (gnu)
  #:use-module (gnu services desktop)
  #:use-module (guix utils)
  #:use-module (trev-guix systems stinkpad))

(define-public %stinkpad-gnome
  (operating-system
    (inherit %stinkpad)
    (services
     (cons*
      (service gnome-desktop-service-type)
      (operating-system-user-services %stinkpad)))))
