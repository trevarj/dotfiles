#!/usr/bin/env sh
exec guix repl -L "/home/trev/Workspace/dotfiles" -- "$0" "$@"
!#
;;; Meant to be installed as a script into a home environment
;;; and then can be called like:
;;; $ sudo guix-reconfigure system gnome

(define-module (trev-guix files scripts reconfigure)
  #:use-module (ice-9 match)
  #:use-module (guix scripts system)
  #:use-module (guix scripts home)
  #:use-module (guix build utils)
  #:use-module (guix store)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11))

(define parse-home
  (match-lambda
    ("niri" '(@ (trev-guix home niri) %home-niri-environment))
    ("sway" (error "Should return sway home env\n"))
    ("gnome" '(@ (trev-guix home gnome) %home-gnome-environment))
    (_ (error "Unexpected home environment\n"))))

(define parse-system
  (match-lambda
    ("niri" '(@ (trev-guix systems stinkpad-niri) %stinkpad-niri))
    ("sway" (error "Should return sway system\n"))
    ("gnome" '(@ (trev-guix systems stinkpad-gnome) %stinkpad-gnome))
    (_ (error "Unexpected system\n"))))

(define parse-command
  (match-lambda
    (("home" flavor) (list guix-home (parse-home flavor)))
    (("system" flavor) (list guix-system (parse-system flavor)))
    (_ (error "Expected \"system\" or \"home\"\n"))))

(define-public (reconfigure)
  (let*-values (((args) (cdr (command-line)))
               ((command rest) (split-at args 2)))
    (match (parse-command command)
      ((fn env)
       (when rest
         (setenv "GUIX_BUILD_OPTIONS" (string-join rest " ")))
       (fn "reconfigure" (format #f "-e ~a" env)))
      (_ #f))))

(reconfigure)
