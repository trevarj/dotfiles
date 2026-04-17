(define-module (trev-guix packages misc)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages rust-apps)
  #:use-module (gnu packages terminals)
  #:use-module (guix build-system copy)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (nonguix build-system binary))

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

(define-public ollama
  (package
    (name "ollama")
    (version "0.20.7")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/ollama/ollama/releases/download/v"
             version "/ollama-linux-amd64.tar.zst"))
       (sha256
        (base32 "07qkmy4j8vy34mlhkdvpz3wddhnlrplxm124mxv1lh9hxvzl2g0r"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:strip-binaries? #f
      #:validate-runpath? #f
      #:patchelf-plan
      #~'(("bin/ollama" ("glibc" "gcc")))
      #:install-plan
      #~'(("bin/ollama" "bin/"))
      #:phases
      #~(modify-phases %standard-phases
          (replace 'unpack
            (lambda* (#:key inputs #:allow-other-keys)
              (invoke "tar" "--use-compress-program=zstd" "-xf"
                      (assoc-ref inputs "source")))))))
    (native-inputs
     (list zstd))
    (propagated-inputs
     (list glibc
           `(,gcc "lib")))
    (supported-systems '("x86_64-linux"))
    (home-page "https://ollama.com")
    (synopsis "Run large language models locally")
    (description
     "Ollama allows you to run large language models locally.
It provides a simple API for creating, running and managing models,
as well as a library of pre-built models that can be easily used.")
    (license license:expat)))

(define-public opencode
  (package
    (name "opencode")
    (version "1.4.7")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/anomalyco/opencode/releases/download/v"
             version "/opencode-linux-x64.tar.gz"))
       (sha256
        (base32 "09pwda4q9mv37scgkqzbx1kap6a1azjf8gbx4l424r5ya73xrflf"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:strip-binaries? #f
      #:validate-runpath? #f
      #:patchelf-plan
      #~'(("opencode" ()))
      #:install-plan
      #~'(("opencode" "bin/opencode"))
      #:phases
      #~(modify-phases %standard-phases
          (replace 'unpack
            (lambda* (#:key inputs #:allow-other-keys)
              (invoke "tar" "xzf" (assoc-ref inputs "source"))
              (chmod "opencode" #o755)))
          (add-after 'install 'wrap-binary
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((fzf (assoc-ref inputs "fzf"))
                     (ripgrep (assoc-ref inputs "ripgrep"))
                     (path (string-append
                            fzf "/bin:"
                            ripgrep "/bin")))
                (wrap-program (string-append #$output "/bin/opencode")
                  `("PATH" ":" prefix (,path))
                  `("OPENCODE_DISABLE_UPDATE" ":" = ("1")))))))))
    (inputs
     (list bash-minimal fzf ripgrep))
    (native-inputs
     (list gzip))
    (supported-systems '("x86_64-linux"))
    (home-page "https://github.com/anomalyco/opencode")
    (synopsis "Open source AI coding agent for the terminal")
    (description
     "OpenCode is an open source AI coding agent that lives in your terminal.
It can understand your codebase, edit files, run terminal commands, and
handle entire workflows.  It supports multiple AI providers including
Claude, OpenAI, Google, and local models.  This package disables
auto-updates for reproducibility and bundles fzf and ripgrep in PATH.")
    (license license:expat)))
