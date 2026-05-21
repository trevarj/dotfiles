{
  config,
  lib,
  ...
}: let
  cfg = config.trev.secrets;
in {
  options.trev.secrets = {
    enable = lib.mkEnableOption "Trev's sops-managed user secrets";

    sopsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Encrypted sops YAML file containing SSH and personal secrets.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.sopsFile != null;
        message = "trev.secrets.sopsFile must point at an encrypted sops YAML file.";
      }
    ];

    sops = {
      defaultSopsFile = cfg.sopsFile;
      age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

      secrets = {
        "ssh/id_ed25519" = {
          path = "/home/trev/.ssh/id_ed25519";
          owner = "trev";
          group = "users";
          mode = "0600";
        };

        "ssh/id_ed25519.pub" = {
          path = "/home/trev/.ssh/id_ed25519.pub";
          owner = "trev";
          group = "users";
          mode = "0644";
        };

        "emacs/secrets.el.gpg" = {
          path = "/home/trev/Workspace/emacs.d/secrets.el.gpg";
          owner = "trev";
          group = "users";
          mode = "0600";
        };

        "authinfo.gpg" = {
          path = "/home/trev/.authinfo.gpg";
          owner = "trev";
          group = "users";
          mode = "0600";
        };
      };
    };

    system.activationScripts.trevSecretDirs.text = ''
      install -d -m 0700 -o trev -g users /home/trev/.ssh
      install -d -m 0755 -o trev -g users /home/trev/Workspace
      install -d -m 0755 -o trev -g users /home/trev/Workspace/emacs.d
    '';
  };
}
