(define-module (trev-guix services networking)
  #:use-module (gnu services)
  #:use-module (gnu home services shepherd)
  #:use-module (guix gexp)
  #:use-module (ice-9 match)
  #:use-module (ice-9 rdelim)
  #:use-module (trev-guix packages networking))

(define simple-daemon-home-shepherd-service
  (match-lambda
    ((pkg exe config-file)
     (list
      (let ((args (with-input-from-file config-file
                    (lambda () (string-split (string-trim (read-line)) #\space)))))
        (shepherd-service
          (provision `(,pkg))
          (modules '((shepherd support))) ; For %user-log-dir
          (start #~(make-forkexec-constructor
                    (cons* #$exe '#$args)
                    #:log-file (string-append %user-log-dir "/" #$exe ".log")))
          (stop #~(make-kill-destructor))))))))

(define (simple-daemon-service-type pkg exe)
  (service-type
    (name (symbol-append pkg '-service))
    (extensions
     (list (service-extension
            home-shepherd-service-type
            simple-daemon-home-shepherd-service)))
    (default-value (list pkg exe
                         (string-append
                          (getenv "XDG_CONFIG_HOME") "/"
                          (symbol->string pkg)
                          "/args.conf")))
    (description (format #f "Run ~a as a user daemon." pkg))))

(define-public byedpi-service-type
  (simple-daemon-service-type 'byedpi "ciadpi"))

(define-public wstunnel-service-type
  (simple-daemon-service-type 'wstunnel "wstunnel"))
