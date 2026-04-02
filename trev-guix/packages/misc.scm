(define-module (trev-guix packages misc)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  #:use-module (guix build-system copy)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)

  ;; remove if swaync is upstreamed
  #:use-module (guix build-system meson)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages web)
  #:use-module (gnu packages man)
  #:use-module (gnu packages gettext)
  )

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

(define-public swaynotificationcenter-git
  (package
    (name "swaynotificationcenter-git")
    (version "0.12.6")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/trevarj/SwayNotificationCenter")
                     (commit "3ecaaab6215d99776b93a5e79366b0c266078eba")))
              (file-name (git-file-name name version))
              (sha256
               (base32 "0hi3z87hd0k73rgjkanzi3rz9dp6gkflz34yxyh0rx1b9gd1ha46"))))
    (build-system meson-build-system)
    (arguments
     (list
      #:glib-or-gtk? #t
      #:configure-flags #~(list
                           "-Dsystemd-service=false")
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'fix-swaync-path
            (lambda _
              (substitute* "src/config.json.in"
                (("@JSONPATH@")
                 (string-append "\"" #$output
                                "/etc/xdg/swaync/configSchema.json\"")))
              (substitute* "src/functions.vala"
                (("/usr/local/etc/xdg/swaync")
                 (string-append #$output "/etc/xdg/swaync"))))))))
    (native-inputs
     (list `(,glib "bin")
           gobject-introspection
           pkg-config
           python-minimal
           sassc
           scdoc
           vala))
    (propagated-inputs
     (list gtk4-layer-shell))
    (inputs
     (list blueprint-compiler
           json-glib
           glib
           granite
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
compository, supporting the following features:

@itemize
@item Keyboard shortcuts
@item Notification body markup with image support
@item A panel to view previous notifications
@item Show album art for notifications like Spotify
@item Do not disturb
@item Click notification to execute default action
@item Show alternative notification actions
@item Customization through a CSS file
@item Trackpad/mouse gesture to close notification
@item The same features as any other basic notification daemon
@item Basic configuration through a JSON config file
@item Hot-reload config through swaync-client
@end itemize")
    (home-page "https://github.com/ErikReider/SwayNotificationCenter")
    (license license:expat)))

(define-public granite
  (package
    (name "granite")
    (version "7.6.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/elementary/granite")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0fv33pcvlws2pibzii21682y70ip0lq2zp3715jhziksmlxapzbf"))))
    (build-system meson-build-system)
    (arguments
     `(#:phases (modify-phases %standard-phases
                  (add-after 'unpack 'disable-icon-cache
                    (lambda _
                      (setenv "DESTDIR" "/")))
                  (add-after 'unpack 'skip-gtk-update-icon-cache
                    ;; Don't create 'icon-theme.cache'.
                    (lambda _
                      (substitute* "meson.build"
                        (("gtk_update_icon_cache: true")
                         "gtk_update_icon_cache: false")
                        (("update_desktop_database: true")
                         "update_desktop_database: false")))))))
    (inputs (list sassc libshumate))
    (propagated-inputs (list glib libgee gtk)) ;required in .pc file
    (native-inputs (list gettext-minimal
                         `(,glib "bin")
                         gobject-introspection
                         pkg-config
                         libshumate
                         python
                         vala))
    (home-page "https://github.com/elementary/granite")
    (synopsis "Library that extends GTK with common widgets and utilities")
    (description "Granite is a companion library for GTK+ and GLib.  Among other
things, it provides complex widgets and convenience functions designed for use
in apps built for the Pantheon desktop.")
    (license license:lgpl3+)))
