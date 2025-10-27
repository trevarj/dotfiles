(define-module (trev-guix services networking)
  #:use-module (gnu services)
  #:use-module (gnu home services shepherd)
  #:use-module (guix gexp)
  #:use-module (ice-9 rdelim)
  #:use-module (trev-guix packages networking))

(define-public (byedpi-home-shepherd-service args)
  (list
   (shepherd-service
    (provision '(byedpi))
    (modules '((shepherd support))) ; For %user-log-dir
    (start #~(make-forkexec-constructor
              (cons* "ciadpi" '#$args)
              #:log-file (string-append %user-log-dir "/byedpi.log")))
    (stop #~(make-kill-destructor)))))

(define-public byedpi-service-type
  (service-type
    (name 'byedpi-service)
    (extensions
     (list (service-extension home-shepherd-service-type
                              byedpi-home-shepherd-service)))
    (description "Run byedpi as a user daemon.")))

(define-public (wstunnel-home-shepherd-service config-file)
  (let ((args (with-input-from-file (car config-file)
                (lambda ()
                  (string-split (string-trim (read-line)) #\space)))))
    (list
     (shepherd-service
       (provision '(wstunnel))
       (modules '((shepherd support)))  ; For %user-log-dir
       (start #~(make-forkexec-constructor
                 (cons* "wstunnel" '#$args)
                 #:log-file (string-append %user-log-dir "/wstunnel.log")))
       (stop #~(make-kill-destructor))))))

(define-public wstunnel-service-type
  (service-type
    (name 'wstunnel-service)
    (extensions
     (list (service-extension home-shepherd-service-type
                              wstunnel-home-shepherd-service)))
    (default-value `(,(string-append (getenv "XDG_CONFIG_HOME")
                                     "/wstunnel/args.conf")))
    (description "Run wstunnel as a user daemon.")))
