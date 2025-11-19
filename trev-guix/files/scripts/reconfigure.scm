#!/usr/bin/env sh
exec guix repl -L "/home/trev/Workspace/dotfiles" -- "$0" "$@"
!#
;;; Meant to be installed as a script into a home enviroment
;;; and then can be called like:
;;; $ guix-reconfigure system gnome

(define-module (trev-guix files scripts reconfigure)
  #:use-module (ice-9 match)
  #:use-module (guix scripts system)
  #:use-module (guix scripts home))

(define parse-home
  (match-lambda
    (("sway") (display "Should install sway home env\n"))
    (_ "(@ (trev-guix home gnome) %home-gnome-environment)")))

(define parse-system
  (match-lambda
    (("sway") (display "Should install sway system env\n"))
    (_ "(@ (trev-guix systems stinkpad-gnome) %stinkpad-gnome)")))

(define parse-command
  (match-lambda
    ((_ "home" . rest) (list guix-home parse-home rest))
    ((_ "system" . rest) (list guix-system parse-system rest))
    (_ (display "Expected \"system\" or \"home\"\n"))))

(define-public (reconfigure args)
  (match (parse-command args)
    ((fn parser rest)
     (fn "reconfigure" (format #f "-e ~a" (parser rest))))
    (_ #f)))

(reconfigure (command-line))
