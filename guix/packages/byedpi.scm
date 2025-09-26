
(define-module (byedpi)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (guix licenses)
  #:use-module (gnu services)
  #:use-module (gnu home services shepherd))

(define-public byedpi
  (package
    (name "byedpi")
    (version "0.17.3")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/hufrea/byedpi.git")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0izhnr6rfxrpzrrhfr6zh6nyw6dccjx9xs360v4f3qmjhl42cdbl"))))
    (build-system gnu-build-system)
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               (delete 'configure)
               (delete 'check))
           #:make-flags
           #~(list "CC=gcc" (string-append "PREFIX=" #$output))))
    (synopsis "Implements DPI bypass methods by running a local SOCKS proxy server.")
    (description
     "Runs as a local SOCKS proxy server that provides mechanisms to circumvent
deep-packet inspection made by an ISP.")
    (home-page "https://github.com/hufrea/byedpi")
    (license expat)))

(define-public (byedpi-home-shepherd-service args)
  (list
   (shepherd-service
    (provision '(byedpi))
    (requirement '())
    (modules '((shepherd support))) ; For %user-log-dir
    (start #~(make-forkexec-constructor
              (cons* "ciadpi" '#$args)
              #:log-file (string-append %user-log-dir "/byedpi.log")))
    (stop #~(make-kill-destructor)))))

(define-public byedpi-service-type
  (service-type
    (name 'byedpi-service)
    (extensions
     (list (service-extension home-shepherd-service-type
                              byedpi-home-shepherd-service)))
    (description "Run byedpi as a user daemon.")))
