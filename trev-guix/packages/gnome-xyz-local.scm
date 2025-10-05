(define-module (trev-guix packages gnome-xyz-local)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module (guix licenses)
  #:use-module (gnu packages compression))

(define-public gnome-shell-extension-executor
  (package
    (name "gnome-shell-extension-executor")
    (version "26")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/raujonas/executor/releases/download/"
                                  (string-append "v" version)
                                  "/executor@raujonas.github.io"))
              (sha256
               (base32
                "1hydn1n141318b5w8sr62mlyywafkh4lgir05nrcffzl7hhv3ck2"))
              (file-name (string-append name "-" version ".zip"))))
    (build-system copy-build-system)
    (native-inputs (list unzip))
    (arguments
     (list
      #:install-plan
      #~'(("./" "share/gnome-shell/extensions/"))
      #:phases
      #~(modify-phases %standard-phases
        (replace 'unpack
          (lambda* (#:key source #:allow-other-keys)
            (invoke "mkdir" "-p" "executor@raujonas.github.io")
            (invoke "unzip" source "-d" "executor@raujonas.github.io")
            #t)))))
    (synopsis "Executor extension for GNOME Shell")
    (description "Execute multiple shell commands periodically with separate intervals and display
the output in GNOME Shell's top bar.")
    (home-page "https://raujonas.github.io/executor/")
    (license gpl3)))
