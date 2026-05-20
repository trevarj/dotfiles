(define-module (trev-guix packages misc)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system copy)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix import crate)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages rust-apps)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages virtualization)
  #:use-module (gnu packages wm)
  #:use-module (guix search-paths)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (nonguix build-system binary)
  #:use-module (ice-9 match))

(define-public guixboy
  (package
    (name "guixboy")
    (version "0.1.0")
    (source (local-file "../../../guixboy" "guixboy-checkout"
                        #:recursive? #t
                        #:select?
                        (lambda (file stat)
                          ;; Keep the package source small and deterministic.
                          (not (string-contains file "/.git")))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("bin/guixboy" "bin/guixboy")
          ("modules/" "share/guile/site/3.0/")
          ("extensions/guix/extensions/boy.scm"
           "share/guix/extensions/boy.scm")
          ("completions/zsh/_guixboy"
           "share/zsh/site-functions/_guixboy")
          ("README.md" "share/doc/guixboy/README.md")
          ("assets/" "share/doc/guixboy/assets/")
          ("doc/guixboy.texi" "share/doc/guixboy/guixboy.texi")
          ("doc/guixboy.info" "share/info/guixboy.info"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'wrap-guixboy
            (lambda _
              ;; Keep modules discoverable when running the standalone binary.
              (let ((guile-path (string-append #$output
                                               "/share/guile/site/3.0")))
                (chmod (string-append #$output "/bin/guixboy") #o755)
                (wrap-program (string-append #$output "/bin/guixboy")
                  `("GUILE_LOAD_PATH" ":" prefix (,guile-path)))))))))
    (inputs (list guile-3.0 guile-json-4))
    (native-search-paths
     (list (search-path-specification
            (variable "GUILE_LOAD_PATH")
            (files '("share/guile/site/3.0")))
           (search-path-specification
            (variable "GUIX_EXTENSIONS_PATH")
            (files '("share/guix/extensions")))))
    (home-page "https://example.invalid/guixboy")
    (synopsis "Guix System helper megatool")
    (description
     "Guixboy provides a Guile command-line interface for common Guix System
maintenance workflows, including configured reconfiguration targets, update
checks, substitute URL aliases, garbage-collection recipes, profile discovery,
and beginner-oriented explanations.")
    (license license:gpl3+)))

(define %gnome-topbar-checkout
  (string-append (dirname (current-filename)) "/../../../gnome-topbar"))

(define-public gnome-topbar
  (package
    (name "gnome-topbar")
    (version "0.14.1")
    (source
     (local-file %gnome-topbar-checkout "gnome-topbar-checkout"
                 #:recursive? #t
                 #:select?
                 (lambda (file stat)
                   (and (not (string-contains file "/.git"))
                        (not (string-contains file "/target"))))))
    (build-system cargo-build-system)
    (arguments
     (list
      #:install-source? #f
      #:cargo-install-paths ''("crates/gnome-topbar")))
    (native-inputs
     (list pkg-config))
    (inputs
     (append (cargo-inputs-from-lockfile
              (string-append %gnome-topbar-checkout "/Cargo.lock"))
             (map specification->package
                  '("gtk"
                    "gtk4-layer-shell"
                    "glib"
                    "dbus"
                    "eudev"
                    "pango"
                    "gdk-pixbuf"
                    "cairo"
                    "graphene"
                    "pulseaudio"
                    "upower"
                    "network-manager"
                    "bluez"))))
    (home-page "https://github.com/trevarj/gnome-topbar")
    (synopsis "GNOME Shell-inspired GTK top bar for Wayland")
    (description
     "GNOME Topbar is a Wayland-only GTK top bar inspired by GNOME Shell.  It
provides a continuous system panel with notifications, quick settings, media
controls, workspaces, and custom script modules.")
    (license license:expat)))

(define-public ollama
  (package
    (name "ollama")
    (version "0.22.1")
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
    (version "1.14.19")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/anomalyco/opencode/releases/download/v"
             version "/opencode-linux-x64.tar.gz"))
       (sha256
        (base32 "0h0ljmkz26ab02is0yq8balw9x6229mkb8prdwmjxj0frqiigccc"))))
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

(define-public codex
  (package
    (name "codex")
    (version "0.132.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/openai/codex/releases/download/rust-v"
             version "/codex-x86_64-unknown-linux-musl.tar.gz"))
       (sha256 (base32 "1cl3m36ia40fkiv66haf7wi8bg3nl8slbbbs35yisnzgwhp46r4b"))))
    (build-system binary-build-system)
    (propagated-inputs (list bubblewrap))
    (arguments
     (list
      #:validate-runpath? #f
      #:install-plan #~'(("codex-x86_64-unknown-linux-musl" "bin/codex"))))
    (home-page "https://github.com/openai/codex")
    (synopsis "AI coding agent from OpenAI")
    (description
     "Codex CLI is an AI-powered coding agent from OpenAI that runs locally
on your computer.  It assists with software development tasks directly within
a terminal environment, providing code suggestions, explanations, and
automated coding assistance.")
    (license license:asl2.0)))

(define-public trevarj/swaynotificationcenter
  (package
    (inherit swaynotificationcenter)
    (name "swaynotificationcenter")
    (version "0.12.6")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/trevarj/SwayNotificationCenter")
                     (commit "524fbcf621d02dbbe63be5833da56e2eb930ea6c")))
              (file-name (git-file-name "SwayNotificationCenter" "0.12.6"))
              (sha256
               (base32
                "1m49sdc1jg26maj686p7ixzpi7y5s91mw6ljyl84f5wrd8ixi9b7"))))))

(define-public gh
  (package
    (name "gh")
    (version "2.92.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/cli/cli/releases/download/v"
                           version "/gh_" version "_linux_amd64.tar.gz"))
       (sha256
        (base32 "1i1yjhla92bync888wifif2rk0bim98jl7sysff2436z3c9lhy5m"))))
    (build-system copy-build-system)
    (arguments
     '(#:install-plan
       '(("bin/gh" "bin/")
         ("share/man" "share/"))
       #:phases
       (modify-phases %standard-phases
         (add-after 'install 'generate-completions
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bash-comp (string-append out "/etc/bash_completion.d"))
                    (zsh-comp (string-append out "/share/zsh/site-functions"))
                    (fish-comp (string-append out "/share/fish/vendor_completions.d"))
                    (gh (string-append out "/bin/gh")))
               (mkdir-p bash-comp)
               (mkdir-p zsh-comp)
               (mkdir-p fish-comp)
               ;; Generate shell completions
               (with-output-to-file (string-append bash-comp "/gh")
                 (lambda () (invoke gh "completion" "-s" "bash")))
               (with-output-to-file (string-append zsh-comp "/_gh")
                 (lambda () (invoke gh "completion" "-s" "zsh")))
               (with-output-to-file (string-append fish-comp "/gh.fish")
                 (lambda () (invoke gh "completion" "-s" "fish")))
               #t))))))
    (supported-systems '("x86_64-linux"))
    (home-page "https://cli.github.com")
    (synopsis "GitHub command-line tool")
    (description
     "gh is GitHub on the command line.  It brings pull requests, issues, and
other GitHub concepts to the terminal next to where you are already working
with git and your code.")
    (license license:expat)))
