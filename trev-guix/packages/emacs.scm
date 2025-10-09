(define-module (trev-guix packages emacs)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (gnu packages)
  #:use-module (gnu packages emacs))

(define* (emacs-ert-selector excluded-tests #:key run-nativecomp run-expensive run-unstable)
  "Create an ERT selector that excludes tests."
  (string-append
   "(not (or "
   (if run-nativecomp
       ""
       "(tag :nativecomp) ")
   (if run-expensive
       ""
       "(tag :expensive-test) ")
   (if run-unstable
       ""
       "(tag :unstable) ")
   (string-join
    (map
     (lambda (test)
       (string-append "\\\"" test "\\\""))
     excluded-tests))
   "))"))

(define %selector
  (emacs-ert-selector
   '("bytecomp--fun-value-as-head"
     "esh-util-test/path/get-remote"
     "esh-var-test/path-var/preserve-across-hosts"
     "ffap-tests--c-path"
     "find-func-tests--locate-macro-generated-symbols"
     "grep-tests--rgrep-abbreviate-properties-darwin"
     "grep-tests--rgrep-abbreviate-properties-gnu-linux"
     "grep-tests--rgrep-abbreviate-properties-windows-nt-dos-semantics"
     "grep-tests--rgrep-abbreviate-properties-windows-nt-sh-semantics"
     "info-xref-test-makeinfo"
     "man-tests-find-header-file"
     "tab-bar-tests-quit-restore-window"
     "tramp-test50-remote-load-path"
     "python-shell--convert-file-name-to-send-1")))

(module-set! (resolve-module '(gnu packages emacs)) '%selector %selector)

(define-public emacs-next-next-pgtk
  (let* ((commit "b469506030a7a0d4027922a72d8ed3355fac5163")
         (version (git-version "31.0.50" "1" commit)))
    (package
      (inherit emacs-next-pgtk)
      (name "emacs-next-next-pgtk")
      (version version)
      (source (origin
                (inherit (package-source emacs-next-minimal))
                (method git-fetch)
                (uri (git-reference
                       (url "https://github.com/emacs-mirror/emacs.git")
                       (commit commit)))
                (file-name (git-file-name "emacs-next-next-pgtk" commit))
                (sha256
                 (base32 "02r5a5asj8v30fywm41l8q9wkv9yvklmxfm2g6kd09zkkwlbr92i"))
                (patches
                 (search-patches "emacs-next-disable-jit-compilation.patch"
                                 "emacs-next-exec-path.patch"
                                 "emacs-fix-scheme-indent-function.patch"
                                 "emacs-native-comp-driver-options.patch"
                                 "emacs-next-native-comp-fix-filenames.patch"
                                 "emacs-native-comp-pin-packages.patch"
                                 "emacs-pgtk-super-key-fix.patch")))))))
