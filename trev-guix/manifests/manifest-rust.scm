(use-modules (guix packages)
             (gnu)
             (gnu packages rust)
             (gnu packages tls)
             (gnu packages pkg-config))

(packages->manifest (list openssl
                          pkg-config
                          rust
                          (list rust "cargo")
                          (list rust "tools")
                          rust-analyzer))
