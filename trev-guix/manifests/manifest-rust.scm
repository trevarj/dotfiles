(define-module (trev-guix manifests manifest-rust)
  #:use-module (guix packages)
  #:use-module (guix profiles)
  #:use-module (gnu)
  #:use-module (gnu packages base)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages crypto)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages node)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages xorg)
  #:use-module (rustup build toolchain))

(packages->manifest
 (list
  gcc-toolchain
  gnu-make
  clang-toolchain-21
  binutils
  pkg-config

  ;; Guix stable rust
  rust
  (list rust "cargo")
  (list rust "tools")
  (list rust "rust-src")

  ;; Rustup
  ;; (rustup)

  ;; (rustup "nightly"
  ;;         #:components
  ;;         '("rust-analyzer" "rustfmt" "rust-src" "rust-std" "clippy")
  ;;         #:targets
  ;;         '("wasm32-unknown-unknown"))

  ;; (rustup "nightly-2026-03-14"
  ;;         #:components
  ;;         '("rust-analyzer" "rustfmt" "rust-src" "rust-std" "clippy")
  ;;         #:targets
  ;;         '("wasm32-unknown-unknown"))

  ;; 1.63.0
  ;; (rustup "stable-2022-08-11"
  ;;         #:components
  ;;         '("rust-analyzer" "rustfmt" "rust-src" "clippy"))

  ;; Libraries for certain sys crates
  openssl
  eudev                                 ; libudev replacement
  libsecp256k1

  ;; WASM stuff
  node

  ;; Extras
  perl
  python
  python-pip
  python-virtualenv
  sqlite
  ))
