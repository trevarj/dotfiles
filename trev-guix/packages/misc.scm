(define-module (trev-guix packages misc)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages rust-apps)
  #:use-module (gnu packages terminals)
  #:use-module (guix build-system copy)
  #:use-module (guix git-download)
  #:use-module (guix search-paths)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (nonguix build-system binary)
  #:use-module (ice-9 match)

  ;; swaync + granite
  #:use-module (guix build-system meson)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages man)
  #:use-module (gnu packages pantheon)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages python)
  #:use-module (gnu packages web))

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
          ("doc/guixboy.texi" "share/doc/guixboy/guixboy.texi"))
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
    (version "0.128.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/openai/codex/releases/download/rust-v"
             version "/codex-"
             (match (or (%current-system) (%current-target-system))
               ("x86_64-linux" "x86_64-unknown-linux-musl")
               ("aarch64-linux" "aarch64-unknown-linux-musl")) ".tar.gz"))
       (sha256
        (base32
         (match (or (%current-system) (%current-target-system))
           ("x86_64-linux" "0fp243xswx5fsgh00g8h7fji2dljprzh1jip8hil62wc27k8asw8")
           ("aarch64-linux" "1l6blqxsl00ashvfzqx73gil1vm7z4dv9z5hzfzggsjg63av8q9i"))))))
    (build-system binary-build-system)
    (arguments
     (list
      #:validate-runpath? #f
      #:install-plan
      #~`((,(string-append "codex-"
                           #$(match (or (%current-system) (%current-target-system))
                               ("x86_64-linux" "x86_64-unknown-linux-musl")
                               ("aarch64-linux" "aarch64-unknown-linux-musl")))
           "bin/codex"))))
    (supported-systems '("x86_64-linux" "aarch64-linux"))
    (home-page "https://github.com/openai/codex")
    (synopsis "AI coding agent from OpenAI")
    (description
     "Codex CLI is an AI-powered coding agent from OpenAI that runs locally
on your computer.  It assists with software development tasks directly within
a terminal environment, providing code suggestions, explanations, and
automated coding assistance.")
    (license license:asl2.0)))

(define-public granite-7.6
  (package
    (inherit granite)
    (version "7.6.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/elementary/granite")
                    (commit "7.6.0")))
              (file-name (git-file-name "granite" "7.6.0"))
              (sha256
               (base32
                "0fv33pcvlws2pibzii21682y70ip0lq2zp3715jhziksmlxapzbf"))))
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'skip-gtk-update-icon-cache
            (lambda _
              (substitute* "meson.build"
                (("gtk_update_icon_cache: true")
                 "gtk_update_icon_cache: false")
                (("update_desktop_database: true")
                 "update_desktop_database: false")))))))
    (propagated-inputs
     (modify-inputs (package-propagated-inputs granite)
       (append libshumate)))))

(define-public trevarj/swaynotificationcenter
  (package
    (name "swaynotificationcenter")
    (version "0.12.6")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/trevarj/SwayNotificationCenter")
                    (commit "037f0e896acefdf43d4b7522cb46c050d3176be3")))
              (file-name (git-file-name "SwayNotificationCenter" "0.12.6"))
              (sha256
               (base32
                "1m49sdc1jg26maj686p7ixzpi7y5s91mw6ljyl84f5wrd8ixi9b7"))))
    (build-system meson-build-system)
    (arguments
     (list
      #:configure-flags
      #~(list "-Dsystemd-service=false")
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'fix-sassc-path
            (lambda _
              (let ((sassc-bin (which "sassc")))
                (substitute* "data/style/meson.build"
                  (("find_program\\('sassc'\\)")
                   (string-append "find_program('" sassc-bin "')")))))))))
    (native-inputs
     (list gettext-minimal
           `(,glib "bin")
           gobject-introspection
           pkg-config
           python
           scdoc
           vala
           sassc))
    (inputs
     (list blueprint-compiler
           json-glib
           glib
           granite-7.6
           gtk
           gtk4-layer-shell
           libadwaita
           libhandy
           libgee
           libshumate
           pulseaudio
           wayland-protocols))
    (synopsis "Notification daemon with a graphical interface")
    (description
     "This package provides a notification daemon for the Sway Wayland
compositor, supporting keyboard shortcuts, notification body markup,
a panel for previous notifications, do not disturb, and customization
through CSS and JSON config files.")
    (home-page "https://github.com/ErikReider/SwayNotificationCenter")
    (license license:expat)))
