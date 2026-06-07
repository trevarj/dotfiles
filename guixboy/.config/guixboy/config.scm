;; This file is managed as part of the dotfiles repo. Guixboy may rewrite it.
(guixboy-config
 (version . 1)
 (defaults
  . ((load-paths . ("/home/trev/Workspace/trev-guix/channel"
                 "/home/trev/Workspace/trev-guix/host"))
     (flags . ())
     (substitutes . ("stinkpad"))
     (updates-mode . available)))
 (commands
  . ((reconfigure . ((flags . ())))
     (updates . ((profiles . ("default"))))
     (gc . ((confirm? . #t)))
     (run . ((flags . ())))))
 (targets
  . (("gnome"
      . ((system . (module-variable
                    (trev-guix systems stinkpad-gnome)
                    %stinkpad-gnome))
         (home . (module-variable
                  (trev-guix home gnome)
                  %home-gnome-environment))))
     ("niri"
      . ((system . (module-variable
                    (trev-guix systems stinkpad-niri)
                    %stinkpad-niri))
         (home . (module-variable
                  (trev-guix home niri)
                  %home-niri-environment))))))
 (default-target . "niri")
 (profiles
  . (("system" . ((path . "/var/guix/profiles/system")
                  (kind . system)))
     ("home" . ((path . "/var/guix/profiles/per-user/trev/guix-home")
                (kind . home)))
     ("user" . ((path . "/var/guix/profiles/per-user/trev/guix-profile")
                (kind . user)))))
 (profile-groups
  . (("default" . ("system" "home"))
     ("desktop" . ("system" "home" "user"))))
 (substitutes
  . (("stinkpad"
      . ((urls . ("https://ci.guix.trop.in"
                  "https://cache-sg.guix.moe"
                  "https://nonguix-proxy.ditigal.xyz"
                  "https://substitutes.nonguix.org"
                  "https://bordeaux-singapore-mirror.cbaines.net"
                  "https://guix.bordeaux.inria.fr"))
         (keys . ())))
     ("official"
      . ((urls . ("https://ci.guix.gnu.org"
                  "https://bordeaux.guix.gnu.org"))
         (keys . ())))
     ("guix-moe"
      . ((urls . ("https://cache-cdn.guix.moe"
                  "https://cache-fi.guix.moe"
                  "https://cache-sg.guix.moe"))
         (keys . ())))
     ("nonguix"
      . ((urls . ("https://nonguix-proxy.ditigal.xyz"
                  "https://substitutes.nonguix.org"))
         (keys . ())))
     ("bordeaux"
      . ((urls . ("https://bordeaux.guix.gnu.org"
                  "https://bordeaux-singapore-mirror.cbaines.net"
                  "https://guix.bordeaux.inria.fr"))
         (keys . ())))
     ("regional"
      . ((urls . ("https://mirror.yandex.ru/mirrors/guix"))
         (keys . ())))
     ("trev"
      . ((urls . ("https://ci.guix.trevs.site"))
         (keys . ())))
     ("all-known"
      . ((urls . ("https://ci.guix.trop.in"
                  "https://ci.guix.gnu.org"
                  "https://bordeaux.guix.gnu.org"
                  "https://cache-cdn.guix.moe"
                  "https://cache-fi.guix.moe"
                  "https://cache-sg.guix.moe"
                  "https://mirror.yandex.ru/mirrors/guix"
                  "https://nonguix-proxy.ditigal.xyz"
                  "https://substitutes.nonguix.org"
                  "https://ci.guix.trevs.site"
                  "https://bordeaux-singapore-mirror.cbaines.net"
                  "https://guix.bordeaux.inria.fr"))
         (keys . ())))))
 (gc-recipes
  . (("free-5G" . ("-F" "5G"))
     ("delete-2m-free-10G" . ("-d" "2m" "-F" "10G"))
     ("optimize" . ("--optimize"))
     ("vacuum-database" . ("--vacuum-database")))))
