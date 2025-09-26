;; A manifest that will be applied to Emacs when working on generic C/C++
;; projects

(setenv "CC" "gcc") ; doesn't work...
(specifications->manifest
 (list
  ;; Build tools
  "make" "automake" "autoconf" "cmake"
  ;; Toolchains
  "gcc-toolchain"
  "clang"
  ))
