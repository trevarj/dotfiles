(define-module (trev-guix services udiskie)
  #:use-module (gnu packages freedesktop)
  #:use-module (trev-guix services utils))

(define-public udiskie-service-type
  (simple-daemon-service-type 'udiskie "udiskie" #f))
