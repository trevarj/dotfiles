#!/usr/bin/env sh
exec guix repl -L "/home/trev/Workspace/dotfiles" -- "$0" "$@"
!#

(define-module (trev-guix files scripts guix-outdated)
  #:use-module (guix channels)
  #:use-module (guix describe)
  #:use-module (guix inferior)
  #:use-module (guix profiles)
  #:use-module (guix store)
  #:use-module (gnu packages)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13))

(define %system-profile "/var/guix/profiles/system")

(define (current-user-name)
  (or (getenv "USER")
      (getenv "LOGNAME")
      (passwd:name (getpwuid (getuid)))))

(define (home-profile)
  (string-append "/var/guix/profiles/per-user/"
                 (current-user-name)
                 "/guix-home"))

(define (resolve-link path)
  (catch #t (lambda () (readlink path)) (lambda _ #f)))

(define (profile-generation-path profile-path)
  (let ((target (resolve-link profile-path)))
    (and target
         (if (string-prefix? "/" target)
             target
             (string-append (dirname profile-path) "/" target)))))

(define (entries-from-profile profile-path)
  (match (profile-generation-path profile-path)
    (#f '())
    (generation
     (catch #t
       (lambda ()
         (manifest-entries
          (profile-manifest (string-append generation "/profile"))))
       (lambda args
         (format (current-error-port)
                 "warning: could not read profile ~a: ~a~%"
                 profile-path args)
         '())))))

(define (dedupe entries)
  (let loop ((entries entries) (seen '()) (result '()))
    (match entries
      (() (reverse result))
      ((entry . rest)
       (let ((name (manifest-entry-name entry)))
         (if (member name seen)
             (loop rest seen result)
             (loop rest (cons name seen) (cons entry result))))))))

(define (pad str len)
  (define s (cond ((not str) "-") ((string? str) str) (else (object->string str))))
  (if (>= (string-length s) len) s
      (string-append s (make-string (- len (string-length s)) #\space))))

(define (column-width rows index label)
  (max (string-length label)
       (fold (lambda (row width)
               (max width (string-length (list-ref row index))))
             0
             rows)))

(define (open-current-inferior)
  (let ((profile (resolve-link (string-append (getenv "HOME") "/.config/guix/current"))))
    (if profile
        (open-inferior profile)
        (error "Could not find ~/.config/guix/current"))))

(define (make-latest-channels)
  (with-store store
    (map (lambda (inst)
           (channel (inherit (channel-instance-channel inst))
                    (commit (channel-instance-commit inst))))
         (let ((chans (map (lambda (c) (channel (inherit c) (commit #f)))
                           (current-channels))))
           (latest-channel-instances store chans)))))

(define (available-version packages name)
  (or (assoc-ref packages name) "-"))

(define (upstream-updated? current latest)
  (and (not (string=? current "-"))
       (not (string=? latest "-"))
       (not (string=? current latest))))

(define (build-package-table avail-current avail-latest entries)
  (filter-map
   (lambda (entry)
     (let* ((name (manifest-entry-name entry))
            (installed (or (manifest-entry-version entry) "-"))
            (current (available-version avail-current name))
            (latest (available-version avail-latest name)))
       (and (upstream-updated? current latest)
            (list name installed current latest))))
   entries))

(define (display-table rows)
  (define w-pkg (column-width rows 0 "Package"))
  (define w-installed (column-width rows 1 "Installed"))
  (define w-current (column-width rows 2 "Current Guix"))
  (define w-latest (column-width rows 3 "Latest Guix"))
  (define sep "  ")
  (format #t "~a~a~a~a~a~a~a~%"
          (pad "Package" w-pkg) sep
          (pad "Installed" w-installed) sep
          (pad "Current Guix" w-current) sep
          (pad "Latest Guix" w-latest))
  (format #t "~a~%"
          (make-string (+ w-pkg w-installed w-current w-latest 6) #\-))
  (for-each
   (match-lambda
     ((name installed current latest)
      (format #t "~a~a~a~a~a~a~a~%"
              (pad name w-pkg) sep
              (pad installed w-installed) sep
              (pad current w-current) sep
              (pad latest w-latest))))
   rows)
  (format #t "~%~a packages updated upstream~%" (length rows)))

(define (main)
  (format (current-error-port) "Reading profiles...~%")
  (let* ((sys-entries  (entries-from-profile %system-profile))
         (home-entries (entries-from-profile (home-profile)))
         (all-entries  (dedupe (append sys-entries home-entries))))
    (format (current-error-port) "  ~a system, ~a home, ~a unique~%"
            (length sys-entries) (length home-entries) (length all-entries))

    (format (current-error-port) "Opening current Guix inferior...~%")
    (let* ((inf-current (open-current-inferior))
           (avail-current (inferior-available-packages inf-current)))
      (format (current-error-port) "  ~a packages~%" (length avail-current))

      (format (current-error-port) "Fetching latest channels...~%")
      (let* ((latest-chans (make-latest-channels))
             (_ (format (current-error-port) "  guix @ ~a~%"
                        (channel-commit (first latest-chans)))))
        (format (current-error-port) "Opening latest Guix inferior...~%")
        (let* ((inf-latest (inferior-for-channels latest-chans
                             #:ttl (* 3600 24 60)))
               (avail-latest (inferior-available-packages inf-latest)))
          (format (current-error-port) "  ~a packages~%" (length avail-latest))
          (let ((rows (build-package-table avail-current avail-latest
                                            all-entries)))
            (display-table rows))
          (close-inferior inf-latest)))
      (close-inferior inf-current))))

(define (same-file? a b)
  (catch #t
    (lambda () (string=? (canonicalize-path a) (canonicalize-path b)))
    (lambda _ #f)))

(define (invoked-as-script?)
  (same-file? (car (command-line)) (current-filename)))

(when (invoked-as-script?)
  (main))
