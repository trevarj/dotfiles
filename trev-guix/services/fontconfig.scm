(define-module (trev-guix services fontconfig)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services fontutils))

(define-public %home-fontconfig-service-extension
  (simple-service
   'home-fontconfig-extension home-fontconfig-service-type
   (list
    (let ((prefer '(prefer (family "Iosevka JBM")
                           (family "Symbols Nerd Font Mono"))))
      `((alias (@ (binding "strong"))
               (family "monospace")
               ,prefer))))))
