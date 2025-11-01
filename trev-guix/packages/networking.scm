(define-module (trev-guix packages networking)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system go)
  #:use-module (guix licenses))

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

(define-public gost
  (package
    (name "gost")
    (version "3.2.5")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/go-gost/gost/releases/download/v"
                    version
                    "/gost_" version
                    "_linux_amd64v3.tar.gz"))
              (sha256
               (base32
                "1qiih2hj4psns2sx7905q4d17jm8hk54jqb808kl9p0887fijzwx"))))
    (build-system copy-build-system)
    (arguments '(#:install-plan '(("gost" "bin/"))))
    (home-page "https://github.com/go-gost")
    (synopsis "GO Simple Tunnel - a simple tunnel written in golang")
    (description "GO Simple Tunnel - a simple tunnel written in golang")
    (license expat)))
