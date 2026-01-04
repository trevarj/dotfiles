(define-module (trev-guix packages emacs)
  #:use-module (guix packages)
  #:use-module (guix gexp)
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
     "python-shell--convert-file-name-to-send-1"
     "package-vc-tests")))

(module-set! (resolve-module '(gnu packages emacs)) '%selector %selector)

(define-public emacs-next-next-pgtk
  (let* ((commit "c1b8a00da923c0c88821675537f173d630ddb8b3")
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
                 (base32 "1z7q2d36zkh1cijm6hzwdprxybniqa790yzrg9vialrd35vbms3r"))
                (patches
                 (search-patches "emacs-next-disable-jit-compilation.patch"
                                 "emacs-next-exec-path.patch"
                                 "emacs-fix-scheme-indent-function.patch"
                                 "emacs-native-comp-driver-options.patch"
                                 "emacs-next-native-comp-fix-filenames.patch"
                                 "emacs-native-comp-pin-packages.patch"
                                 "emacs-pgtk-super-key-fix.patch")))))))
