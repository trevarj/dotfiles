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
      ;; TODO: find out why this clobbered my stinkpad-niri on reconfigure
      ;; (simple-service 'apply-gsettings etc-profile-d-service-type
      ;;                 (list
      ;;                  (local-file "../files/scripts/apply-gnome-settings.sh"
      ;;                              "apply-gsettings.sh")))
      (operating-system-user-services %stinkpad)))))
