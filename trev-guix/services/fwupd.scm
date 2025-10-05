(define-module (trev-guix services fwupd)
  #:use-module (gnu services)
  #:use-module (gnu services admin)
  #:use-module (gnu services dbus)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (nongnu packages firmware))

(define-record-type* <fwupd-configuration>
  fwupd-configuration make-fwupd-configuration
  fwupd-configuration?
  (fwupd fwupd-configuration-fwupd
         (default fwupd-nonfree)))

(define (fwupd-activation config)
    (with-imported-modules '((guix build utils))
      #~(begin
          (use-modules (guix build utils))
          (mkdir-p "/var/cache/fwupd")
          (mkdir-p "/var/lib/fwupd/local.d")
          (mkdir-p "/var/lib/fwupd/"))))

(define-public fwupd-service-type
  (let ((fwupd-package (compose list fwupd-configuration-fwupd)))
    (service-type
     (name 'fwupd)
     (extensions
      (list (service-extension polkit-service-type fwupd-package)
	    (service-extension dbus-root-service-type fwupd-package)
            (service-extension activation-service-type fwupd-activation)))
     (default-value (fwupd-configuration))
     (description "A service that runs the necessary daemons for fwupd."))))
