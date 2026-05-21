{
  config,
  lib,
  pkgs,
  ...
}: let
  emacsDir = "${config.home.homeDirectory}/Workspace/emacs.d";
  workspaceDir = "${config.home.homeDirectory}/Workspace";
  emacsRepo = "https://github.com/trevarj/emacs.d.git";
in {
  home.file.".emacs.d".source = config.lib.file.mkOutOfStoreSymlink emacsDir;

  home.activation.trevEmacsWorkspace = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p "${workspaceDir}"
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

        workspace="${workspaceDir}"
        emacs_dir="${emacsDir}"
        repo="${emacsRepo}"
        checkout_tmp="$workspace/.emacs.d-bootstrap"

        mkdir -p "$workspace"

        if [ -d "$emacs_dir/.git" ]; then
          exit 0
        fi

        mkdir -p "$emacs_dir"

        unexpected="$(${pkgs.findutils}/bin/find "$emacs_dir" \
          -mindepth 1 \
          -maxdepth 1 \
          ! -name secrets.el.gpg \
          -print \
          -quit)"

        if [ -n "$unexpected" ]; then
          echo "$emacs_dir exists but is not a Git checkout." >&2
          echo "Unexpected path: $unexpected" >&2
          exit 1
        fi

        ${pkgs.coreutils}/bin/rm -rf "$checkout_tmp"
        trap '${pkgs.coreutils}/bin/rm -rf "$checkout_tmp"' EXIT

        for attempt in 1 2 3 4 5; do
          if ${pkgs.git}/bin/git ls-remote --exit-code "$repo" HEAD >/dev/null 2>&1; then
            ${pkgs.git}/bin/git clone "$repo" "$checkout_tmp"
            break
          fi

          if [ "$attempt" -eq 5 ]; then
            echo "Could not reach $repo after $attempt attempts." >&2
            exit 1
          fi

          sleep_seconds=$((attempt * 5))
          echo "Waiting for network before cloning Emacs config; retrying in $sleep_seconds seconds." >&2
          ${pkgs.coreutils}/bin/sleep "$sleep_seconds"
        done

        if [ -e "$emacs_dir/secrets.el.gpg" ]; then
          ${pkgs.coreutils}/bin/rm -f "$checkout_tmp/secrets.el.gpg"
        fi

        ${pkgs.coreutils}/bin/cp -a "$checkout_tmp/." "$emacs_dir/"
      '';
    };

    Install.WantedBy = ["default.target"];
  };
}
