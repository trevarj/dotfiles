(define-module (trev-guix packages fonts)
  #:use-module (gnu)
  #:use-module (gnu packages fonts)
  #:use-module (guix)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system font)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix license:))

(define-public font-nerd-fonts-symbols
  (package
    (name "font-nerd-fonts-symbols")
    (version "3.4.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/ryanoasis/nerd-fonts/"
                           "releases/download/v" version
                           "/NerdFontsSymbolsOnly.zip"))
       (sha256
        (base32 "0iscas5bvb8bgk5pcls95nfwjl7yi23q05mili43dzl0p427jqcf"))))
    (build-system font-build-system)
    (home-page "https://www.nerdfonts.com/")
    (synopsis "Nerd Font including only the symbols")
    (description "Nerd Font that includes only the icons.")
    (license license:silofl1.1)))

(define-public font-iosevka-jbm
  (package
    (name "font-iosevka-jbm")
    (version "1.0.0")
    (source (local-file "../../fonts/.local/share/fonts/IosevkaJbm" #:recursive? #t))
    (build-system font-build-system)
    (description "My custom Iosevka font inspired by JetBrains Mono.")
    (home-page "https://www.nerdfonts.com/")
    (synopsis "Nerd Font including only the symbols")
    (license license:expat)))

(define-public font-cryptofont
  (package
    (name "font-cryptofonts")
    (version "1.0.0")
    (source (local-file "../../fonts/.local/share/fonts/cryptofont.ttf"))
    (build-system font-build-system)
    (description "A font for cryptocurrency symbols")
    (home-page "N/A")
    (synopsis "A font for cryptocurrency symbols")
    (license license:expat)))
