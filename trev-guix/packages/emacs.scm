(define-module (trev-guix packages emacs)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (gnu packages)
  #:use-module (gnu packages emacs))

(define-public emacs-next-next-pgtk
  (let* ((commit "1bae55cdbfed5b8a8b5a289edb42aac229f02f95")
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
                 (base32 "1xkabypvmqd44y36nzrydjfs8s43j5fhbngav06xb0hlm7wqakxg"))
                (patches
                 (search-patches "emacs-next-disable-jit-compilation.patch"
                                 "emacs-next-exec-path.patch"
                                 "emacs-fix-scheme-indent-function.patch"
                                 "emacs-native-comp-driver-options.patch"
                                 "emacs-next-native-comp-fix-filenames.patch"
                                 "emacs-native-comp-pin-packages.patch")))))))
