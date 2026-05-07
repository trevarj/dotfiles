#!/usr/bin/env sh
exec guix repl -L "/home/trev/Workspace/dotfiles" -- "$0" "$@"
!#
;;; Meant to be installed as a script into a home environment
;;; and then can be called like:
;;; $ sudo guix-reconfigure system gnome

(define-module (trev-guix files scripts reconfigure)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (guix scripts home)
  #:use-module (guix scripts system)
  #:use-module (srfi srfi-13))

(define %home-environments
  '(("gnome" . (@ (trev-guix home gnome) %home-gnome-environment))
    ("niri" . (@ (trev-guix home niri) %home-niri-environment))))

(define %systems
  '(("gnome" . (@ (trev-guix systems stinkpad-gnome) %stinkpad-gnome))
    ("niri" . (@ (trev-guix systems stinkpad-niri) %stinkpad-niri))))

(define (names targets)
  (string-join (map car targets) ", "))

(define (usage port)
  (format port "Usage: guix-reconfigure home|system gnome|niri [guix-option ...]~%"))

(define (die fmt . args)
  (apply format (current-error-port) fmt args)
  (newline (current-error-port))
  (usage (current-error-port))
  (exit 1))

(define (lookup-target kind flavor targets)
  (or (assoc-ref targets flavor)
      (die "Unknown ~a '~a'. Expected one of: ~a"
           kind flavor (names targets))))

(define parse-command
  (match-lambda
    (("home" flavor rest ...)
     (list guix-home (lookup-target "home environment" flavor %home-environments)
           rest))
    (("system" flavor rest ...)
     (list guix-system (lookup-target "system" flavor %systems)
           rest))
    (("-h") (usage (current-output-port)) (exit 0))
    (("--help") (usage (current-output-port)) (exit 0))
    (_ (die "Expected 'home' or 'system' followed by a target."))))

(define-public (reconfigure)
  (match (parse-command (cdr (command-line)))
    ((fn env extra-args)
     (apply fn (append (list "reconfigure" "-e" (object->string env))
                       extra-args)))))

(define (same-file? a b)
  (catch #t
    (lambda () (string=? (canonicalize-path a) (canonicalize-path b)))
    (lambda _ #f)))

(define (invoked-as-script?)
  (same-file? (car (command-line)) (current-filename)))

(when (invoked-as-script?)
  (reconfigure))
