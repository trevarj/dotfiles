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
  #:use-module (srfi srfi-1))

(define %system-profile "/var/guix/profiles/system")
(define %home-profile
  (string-append "/var/guix/profiles/per-user/"
                 (getenv "USER") "/guix-home"))

(define (resolve-link path)
  (catch #t (lambda () (readlink path)) (lambda _ #f)))

(define (entries-from-profile profile-path)
  (let ((target (resolve-link profile-path)))
    (if target
        (let ((full-path (if (string-prefix? "/" target) target
                             (string-append (dirname profile-path) "/" target))))
          (catch #t
            (lambda () (manifest-entries
                        (profile-manifest (string-append full-path "/profile"))))
            (lambda _ '())))
        '())))

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

(define (build-package-table avail-current avail-latest entries)
  (let ((rows '()))
    (for-each
     (lambda (entry)
       (let* ((name (manifest-entry-name entry))
              (installed (manifest-entry-version entry))
              (current (assoc-ref avail-current name))
              (latest (assoc-ref avail-latest name)))
         (set! rows
               (cons (list name (or installed "-") (or current "-") (or latest "-"))
                     rows))))
     entries)
    rows))

(define (display-table rows)
  (define w-pkg 30)
  (define w-ver 14)
  (define sep "  ")
  (format #t "~a~a~a~a~a~a~a~%"
          (pad "Package" w-pkg) sep
          (pad "Installed" w-ver) sep
          (pad "Current Guix" w-ver) sep
          (pad "Latest Guix" w-ver))
  (format #t "~a~%" (make-string (+ w-pkg w-ver w-ver w-ver 8) #\-))
  (let ((count 0))
    (for-each
     (match-lambda
       ((name installed current latest)
        (when (and (not (string=? current "-")) (not (string=? latest "-"))
                   (not (string=? current latest)))
          (set! count (+ count 1))
          (format #t "~a~a~a~a~a~a~a~%"
                  (pad name w-pkg) sep
                  (pad installed w-ver) sep
                  (pad current w-ver) sep
                  (pad latest w-ver)))))
     rows)
    (format #t "~%~a packages updated upstream~%" count)))

(define (main)
  (format (current-error-port) "Reading profiles...~%")
  (let* ((sys-entries  (entries-from-profile %system-profile))
         (home-entries (entries-from-profile %home-profile))
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
            (display-table (reverse rows))))))))

(main)
