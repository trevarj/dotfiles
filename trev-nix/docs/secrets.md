# Secrets

`trev-nix` is wired for `sops-nix`, but secret provisioning is disabled until an
encrypted secrets file exists.

## Model

- `sops-nix` decrypts secrets during NixOS activation.
- The machine identity is `/etc/ssh/ssh_host_ed25519_key`.
- User SSH keys are written to `/home/trev/.ssh`.
- Emacs secrets are written to `/home/trev/Workspace/emacs.d/secrets.el.gpg`.
- Authinfo is written to `/home/trev/.authinfo.gpg`.
- Plaintext secrets never belong in this repository.

## First Setup

Generate or reuse an age identity for editing secrets:

```sh
mkdir -p ~/.config/sops/age
guix shell age -- age-keygen -o ~/.config/sops/age/keys.txt
```

Get the public key for that identity:

```sh
guix shell age -- age-keygen -y ~/.config/sops/age/keys.txt
```

After the target system has generated SSH host keys, get the host age recipient:

```sh
guix shell ssh-to-age -- ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

Create `.sops.yaml` in the repo root with your editor key and host key:

```yaml
keys:
  - &trev age1...
  - &stinkpad age1...
creation_rules:
  - path_regex: trev-nix/secrets/[^/]+\.yaml$
    key_groups:
      - age:
          - *trev
          - *stinkpad
```

Create the encrypted file:

```sh
mkdir -p trev-nix/secrets
guix shell sops -- sops trev-nix/secrets/stinkpad.yaml
```

Expected keys:

```yaml
ssh:
  id_ed25519: |
    encrypted private key contents
  id_ed25519.pub: ssh-ed25519 ...
emacs:
  secrets.el.gpg: |
    ...
authinfo.gpg: |
  ...
```

Then enable it in `trev-nix/hosts/stinkpad/default.nix`:

```nix
trev.secrets = {
  enable = true;
  sopsFile = ../../secrets/stinkpad.yaml;
};
```

Run the normal rebuild. The next activation writes the SSH key files, Emacs
secret file, and authinfo file with user ownership.

## Emacs

Home Manager keeps `~/.emacs.d` as an out-of-store symlink to:

```sh
~/Workspace/emacs.d
```

If the checkout is missing, the `trev-emacs-checkout` user service clones:

```sh
https://github.com/trevarj/emacs.d.git
```

The service can run after `sops-nix` has already written `secrets.el.gpg`; it
preserves that file while copying the checkout into place.

This keeps Emacs mutable for package installs while making a fresh NixOS system
recover the config automatically.
