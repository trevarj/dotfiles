(define-module (trev-guix services flatpak)
  #:export (home-flatpak-configuration
            home-flatpak-configuration?
            home-flatpak-service-type)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module ((gnu packages package-management) #:select (flatpak))
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (ice-9 match))

(define-record-type* <home-flatpak-configuration>
  home-flatpak-configuration make-home-flatpak-configuration
  home-flatpak-configuration?
  (remotes home-flatpak-configuration-remotes
           (default '(("flathub" . "https://dl.flathub.org/repo/flathub.flatpakrepo"))))
  (applications home-flatpak-configuration-applications
                (default '())))

(define (home-flatpak-script _)
  (list
   (local-file
    (string-append
     (getenv "HOME")
     "/.guix-home/profile/etc/profile.d/flatpak.sh")
    "flatpak.sh")))

;; workaround to get dbus to load flatpak services because flatpak.sh gets
;; run too late
(define (home-flatpak-environment-variables _)
  `(("XDG_DATA_DIRS" . "$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share")))

(define (home-flatpak-activation config)
  (let* ((remotes (home-flatpak-configuration-remotes config))
         (applications (home-flatpak-configuration-applications config))
         (default-remote (match remotes
                           (((name . _) _ ...) name)
                           (_ "flathub"))))
    #~(begin
        (define flatpak-command #$(file-append flatpak "/bin/flatpak"))

        (define (run-flatpak . arguments)
          (apply system* flatpak-command arguments))

        (define (run-flatpak/quiet . arguments)
          (call-with-output-file "/dev/null"
            (lambda (null-output)
              (call-with-output-file "/dev/null"
                (lambda (null-error)
                  (parameterize ((current-output-port null-output)
                                 (current-error-port null-error))
                    (apply run-flatpak arguments)))))))

        (define (warn action target)
          (format (current-error-port)
                  "warning: flatpak ~a failed for ~a\n"
                  action target))

        (define (add-remote name location)
          (unless (zero? (run-flatpak "remote-add" "--user" "--if-not-exists"
                                      name location))
            (warn "remote-add" name)))

        (define (installed? application)
          (zero? (run-flatpak/quiet "--user" "info" application)))

        (define (install-application application)
          (unless (installed? application)
            (format #t "installing Flatpak ~a\n" application)
            (unless (zero? (run-flatpak "install" "--user" "--noninteractive"
                                        #$default-remote application))
              (warn "install" application))))

        #$@(map (match-lambda
                  ((name . location)
                   #~(add-remote #$name #$location)))
                remotes)
        #$@(map (lambda (application)
                  #~(install-application #$application))
                applications))))

(define-public home-flatpak-service-type
  (service-type
    (name 'home-flatpak)
    (extensions
     (list (service-extension
            home-shell-profile-service-type
            home-flatpak-script)
           (service-extension
            home-environment-variables-service-type
            home-flatpak-environment-variables)
           (service-extension
            home-activation-service-type
            home-flatpak-activation)))
    (default-value (home-flatpak-configuration))
    (description "A service for flatpak integration with guix home.")))
