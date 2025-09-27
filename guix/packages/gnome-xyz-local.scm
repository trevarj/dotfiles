(define-module (gnome-xyz-local)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system copy)
  #:use-module (guix licenses)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages compression))

(define-public gnome-shell-extension-weather-oclock
  (package
    (name "gnome-shell-extension-weather-oclock")
    (version "46.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/CleoMenezesJr/weather-oclock")
                    (commit version)))
              (sha256
               (base32
                "0misr6cs17636yak82fx6gx48qqsj8glccsxxkh96adrihbhni48"))
              (file-name (git-file-name name version))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:make-flags #~(list (string-append "INSTALLBASE="
                                          #$output
                                          "/share/gnome-shell/extensions"))
       #:phases
       #~(modify-phases %standard-phases
           (delete 'bootstrap)
           (delete 'configure))))
    (native-inputs (list `(,glib "bin") pkg-config))
    (propagated-inputs (list glib))
    (synopsis "Display the current weather inside next to the clock for GNOME Shell")
    (description "This extension adds the current weather next to the clock on the top bar of the
GNOME Shell.")
    (home-page "https://github.com/CleoMenezesJr/weather-oclock")
    (license gpl3)))

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
