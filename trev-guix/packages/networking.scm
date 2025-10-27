(define-module (trev-guix packages networking)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
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

(define-public wstunnel
  (package
    (name "wstunnel")
    (version "10.5.0")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/erebe/wstunnel/releases/download/v" version
                    "/wstunnel_" version
                    "_linux_amd64.tar.gz"))
              (sha256
               (base32
                "12vshcaqqd8fz85acrwbb8nirc0wkf8drrvm3spnkqza8kyqc4mf"))))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan '(("wstunnel" "bin/"))
       #:phases
       (modify-phases %standard-phases
         (add-after 'install 'make-executable
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (wstunnel (string-append out "/bin/wstunnel")))
               (chmod wstunnel #o555)))))))
    (home-page "https://github.com/erebe/wstunnel")
    (synopsis "Tunnel all your traffic over Websocket or HTTP2.")
    (description "")
    (license expat)))
