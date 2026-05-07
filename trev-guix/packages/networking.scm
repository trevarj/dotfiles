(define-module (trev-guix packages networking)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system go)
  #:use-module (gnu packages base)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages linux)
  #:use-module (nonguix build-system binary)
  #:use-module (guix licenses))

(define-public nym-vpn
  (package
    (name "nym-vpn")
    (version "1.29.2")
    (source
     (origin
       (method url-fetch)
       (uri
        (string-append
         "https://github.com/nymtech/nym-vpn-client/releases/download/"
         "nym-vpn-core-v" version
         "/nym-vpn-core-v" version "_linux_x86_64.tar.gz"))
       (sha256 (base32 "0d8v4390kd4aj7776vyv22sj97y5a63fk02m87j7pv64ihfqrr7r"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:strip-binaries? #f
      #:validate-runpath? #t
      #:patchelf-plan
      #~(let ((common-libs '("glibc"
                             "gcc"
                             "libmnl"
                             "libnftnl"
                             "dbus")))
          `(("nym-vpnd" ,common-libs)
            ("nym-vpnc" ,common-libs)
            ("nym-diagnostic" ,common-libs)))
      #:install-plan
      #~'(("nym-vpnd" "bin/")
          ("nym-vpnc" "bin/")
          ("nym-diagnostic" "bin/"))
      #:phases
      #~(modify-phases %standard-phases
          (replace 'unpack
            (lambda* (#:key inputs #:allow-other-keys)
              (invoke "tar" "xzf" (assoc-ref inputs "source") "--strip-components=1")
              (chmod "nym-vpnc" #o755)
              (chmod "nym-vpnd" #o755)
              (chmod "nym-diagnostic" #o755)
              #t)))))
    (propagated-inputs
     (list `(,gcc "lib") glibc libmnl libnftnl dbus))
    (home-page "https://github.com/nymtech/nym-vpn-client")
    (synopsis "Nym VPN core client binaries")
    (description
     "Nym VPN core binaries providing nym-vpnd, the daemon, and nym-vpnc,
the command-line client, for connecting to the Nym mixnet VPN service.
These are pre-built binaries patched for Guix compatibility.")
    (license gpl3)))

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
