(define-module (trev-guix packages headsetcontrol)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (gnu packages hardware))

(define-public headsetcontrol-3.1.0
  (package
    (inherit headsetcontrol)
    (name "headsetcontrol-3.1.0")
    (version "3.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/Sapd/HeadsetControl")
              (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1i251r2kpac2qac8a3c6iqbzkhlh6mzi4hl62mjknc8cbmhjmdgl"))))))

headsetcontrol-3.1.0
