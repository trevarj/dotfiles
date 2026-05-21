{
  config,
  lib,
  pkgs,
  ...
}: let
  emacsDir = "${config.home.homeDirectory}/Workspace/emacs.d";
in {
  home.file.".emacs.d".source = config.lib.file.mkOutOfStoreSymlink emacsDir;

  home.activation.trevEmacsWorkspace = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p "${config.home.homeDirectory}/Workspace"
  '';

  systemd.user.services.trev-emacs-checkout = {
    Unit = {
      Description = "Clone Trev's Emacs configuration";
      After = ["network-online.target"];
    };

    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "trev-emacs-checkout" ''
        set -eu

        mkdir -p "${config.home.homeDirectory}/Workspace"

        if [ -d "${emacsDir}/.git" ]; then
          exit 0
        fi

        if [ -e "${emacsDir}" ] && [ -n "$(${pkgs.coreutils}/bin/ls -A "${emacsDir}")" ]; then
          echo "${emacsDir} exists but is not a Git checkout" >&2
          exit 1
        fi

        ${pkgs.git}/bin/git clone https://github.com/trevarj/emacs.d.git "${emacsDir}"
      '';
    };

    Install.WantedBy = ["default.target"];
  };
}
