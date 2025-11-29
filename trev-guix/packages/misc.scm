(define-module (trev-guix packages misc)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  #:use-module (guix build-system copy)
  #:use-module (guix git-download)
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

(define-public quickshell-noctalia-shell
  (package
    (name "quickshell-noctalia-shell")
    (version "3.4.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/noctalia-dev/noctalia-shell")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1y10zbafq4n6jjwm1r78dn63zrgmrvikbbcdy8flswk75zs2sfbr"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("." "$XDG_CONFIG_HOME/quickshell/noctalia-shell/"))))
    (home-page "https://github.com/noctalia-dev/noctalia-shell")
    (synopsis "A sleek and minimal desktop shell thoughtfully crafted for Wayland.")
    (description "A shell written using quickshell for use with Wayland compositors.")
    (license license:expat)))
