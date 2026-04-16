(define-module (trev-guix manifests manifest-rust)
  #:use-module (guix packages)
  #:use-module (guix profiles)
  #:use-module (gnu)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages pkg-config))

(packages->manifest (list openssl
                          pkg-config
                          rust
                          (list rust "cargo")
                          (list rust "tools")
                          rust-analyzer))
