;; A manifest that will be applied to Emacs when working on generic C/C++
;; projects
(define-module (trev-guix manifests manifest-gcc)
  #:use-module (gnu packages))

(setenv "CC" "gcc") ; doesn't work...
(specifications->manifest
 (list
  ;; Build tools
  "make" "automake" "autoconf" "cmake" "libtool"
  ;; Toolchains
  "gcc-toolchain"
  "clang"
  ;; Extras
  "perl"
  ))
