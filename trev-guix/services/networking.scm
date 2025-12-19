(define-module (trev-guix services networking)
  #:use-module (trev-guix packages networking)
  #:use-module (trev-guix services utils))

(define-public byedpi-service-type
  (simple-daemon-service-type 'byedpi "ciadpi"))

(define-public gost-service-type
  (simple-daemon-service-type 'gost "gost"))
