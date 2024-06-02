(define-module (guix packages zsh-fzf-tab)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system copy))

(package
  (name "fzf-tab")
  (version "1.1.2")
  (home-page "https://github.com/Aloxaf/fzf-tab")
  (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/Aloxaf/fzf-tab.git")
                  (commit (string-append "v" version))))
            (file-name (git-file-name name version))
            (sha256
             (base32
              "061jjpgghn8d5q2m2cd2qdjwbz38qrcarldj16xvxbid4c137zs2"))))
  (build-system copy-build-system)
  (arguments
   '(#:install-plan '(("lib" "/share/zsh/plugins/fzf-tab/")
                      ("modules" "/share/zsh/plugins/fzf-tab/")
                      ("fzf-tab.plugin.zsh" "/share/zsh/plugins/fzf-tab/")
                      ("fzf-tab.zsh" "/share/zsh/plugins/fzf-tab/")
                      ("README.md" "/share/doc/fzf-tab/"))))
  (synopsis "Replace zsh's default completion menu with fzf.")
  (description
   "Replaces zsh's default completion menu with fzf, enabling fuzzy finding
and multi-selection.")
  (license license:expat))
