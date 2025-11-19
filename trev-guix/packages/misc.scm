(define-module (trev-guix packages misc)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:))

(define-public guix-reconfigure
  (package
    (name "guix-reconfigure")
    (version "1.0.0")
    (source (local-file "../files/scripts/reconfigure.scm" "guix-reconfigure"))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("guix-reconfigure" "/bin/guix-reconfigure"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'make-executable
            (lambda _
              (chmod (string-append #$output "/bin/guix-reconfigure")
                     #o755))))))
    (home-page "")
    (synopsis "Helper script to reconfigure system and home.")
    (description synopsis)
    (license license:gpl3)))
