# First Boot

Use this after installing with the custom ISO and logging into the new system.

## Check The Base System

Confirm the installed flake evaluates:

```sh
nix eval ~/Workspace/dotfiles#nixosConfigurations.stinkpad.config.system.name
```

Check the Emacs checkout service:

```sh
systemctl --user status trev-emacs-checkout
```

If the network was not ready during login, retry it:

```sh
systemctl --user start trev-emacs-checkout
```

## Enable Secrets

Get the installed host age recipient:

```sh
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

Add that recipient to `.sops.yaml`, then create or update:

```sh
trev-nix/secrets/stinkpad.yaml
trev-nix/secrets/emacs-secrets.el.gpg.bin
trev-nix/secrets/authinfo.gpg.bin
```

Expected encrypted keys are documented in [Secrets](./secrets.md).

Enable the host secret file in:

```sh
trev-nix/hosts/stinkpad/default.nix
```

Use:

```nix
trev.secrets = {
  enable = true;
  sopsFile = ../../secrets/stinkpad.yaml;
  emacsSecretsFile = ../../secrets/emacs-secrets.el.gpg.bin;
  authinfoFile = ../../secrets/authinfo.gpg.bin;
};
```

Rebuild:

```sh
sudo nixos-rebuild switch --flake ~/Workspace/dotfiles#stinkpad
```

## Verify Secrets

Confirm files exist with private permissions:

```sh
ls -l ~/.ssh/id_ed25519 ~/.authinfo.gpg ~/Workspace/emacs.d/secrets.el.gpg
```

Expected private file mode is `0600`.
