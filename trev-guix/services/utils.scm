(define-module (trev-guix services utils)
  #:use-module (gnu services)
  #:use-module (gnu home services shepherd)
  #:use-module (guix gexp)
  #:use-module (ice-9 match)
  #:use-module (ice-9 rdelim)
  #:use-module (ice-9 optargs))

(define simple-daemon-home-shepherd-service
  (match-lambda
    ((pkg exe use-config?)
     (list
      (let ((args
             (if use-config?
                 (with-input-from-file
                     (string-append (getenv "XDG_CONFIG_HOME") "/" (symbol->string pkg) "/args.conf")
                   (lambda () (string-split (string-trim (read-line)) #\space)))
                 '())))
        (shepherd-service
          (provision `(,pkg))
          (modules '((shepherd support))) ; For %user-log-dir
          (start #~(make-forkexec-constructor
                    (cons* #$exe '#$args)
                    #:log-file (string-append %user-log-dir "/" #$exe ".log")))
          (stop #~(make-kill-destructor))))))))

(define*-public (simple-daemon-service-type pkg exe #:optional (use-config? #t))
  (service-type
    (name (symbol-append pkg '-service))
    (extensions
     (list (service-extension
            home-shepherd-service-type
            simple-daemon-home-shepherd-service)))
    (default-value (list pkg exe use-config?))
    (description (format #f "Run ~a as a user daemon." pkg))))
