(define-module (trev-guix packages emacs)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages emacs))

(define-public emacs-next-next-pgtk
  (let* ((commit "a8b9fad89720847a869bf288eb41473b6c82b833")
         (version (git-version "31.0.50" "1" commit)))
    (package
      (inherit emacs-next-pgtk)
      (name "emacs-next-next-pgtk")
      (version version)
      (arguments
       (substitute-keyword-arguments (package-arguments emacs-next-pgtk)
         ((#:tests? tests? #f) #f)
         ((#:phases phases #~%standard-phases)
          #~(modify-phases #$phases
              (add-after 'unpack 'fix-module-env-snippet-32
                (lambda _
                  ;; Upstream typo leaves @module_env_snippet_32@
                  ;; unsubstituted in generated src/emacs-module.h.
                  (substitute* "configure.ac"
                    (("module_env_snippet_31=\"\\$srcdir/src/module-env-32.h\"")
                     "module_env_snippet_32=\"$srcdir/src/module-env-32.h\""))))))))
      (source (origin
                (inherit (package-source emacs-next-minimal))
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/emacs-mirror/emacs.git")
                      (commit commit)))
                (file-name (git-file-name "emacs-next-next-pgtk" commit))
                (sha256
                 (base32 "1b0523bha67apz1w4w6srdc117062ip9y8xd5prgy3iciv1c1lpw"))
                (patches
                 (search-patches "emacs-next-disable-jit-compilation.patch"
                                 "emacs-next-exec-path.patch"
                                 "emacs-fix-scheme-indent-function.patch"
                                 "emacs-native-comp-driver-options.patch"
                                 "emacs-next-native-comp-fix-filenames.patch"
                                 "emacs-native-comp-pin-packages.patch")))))))
