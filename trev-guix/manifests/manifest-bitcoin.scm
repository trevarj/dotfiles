(use-modules (gnu packages))


(specifications->manifest
 (list
  ;; Build tools
  "make" "automake" "autoconf" "cmake" "libtool"
  ;; Toolchains
  "gcc-toolchain@14"
  "clang"
  ;; Extras
  "perl"
  "pkg-config"
  "python"
  "qttools@5.15"
  "util-linux"

  ;; Bitcoin dependencies
  "boost"
  "capnproto"
  "libevent"
  "qtbase@5"
  "sqlite"
  "zeromq"))
