# Updating And Rebuilding

The main system target is:

```sh
~/Workspace/dotfiles/trev-nix#stinkpad
```

Home Manager is integrated into the NixOS system config, so normal changes use
`nixos-rebuild`, not a separate `home-manager switch`.

## Rebuild After Editing Config

Apply config changes immediately:

```sh
sudo nixos-rebuild switch --flake ~/Workspace/dotfiles/trev-nix#stinkpad
```

Build without activating:

```sh
nix build ~/Workspace/dotfiles/trev-nix#nixosConfigurations.stinkpad.config.system.build.toplevel
```

## Update Packages And Inputs

Flake inputs are pinned in `trev-nix/flake.lock`.  Updating the lock file is
similar to updating pinned Guix channels.

Update everything:

```sh
cd ~/Workspace/dotfiles/trev-nix
nix flake update
```

Update one input:

```sh
cd ~/Workspace/dotfiles/trev-nix
nix flake update gnome-topbar-src
```

Then rebuild:

```sh
sudo nixos-rebuild switch --flake ~/Workspace/dotfiles/trev-nix#stinkpad
```

## Check Before Switching

Run the flake checks:

```sh
nix flake check ~/Workspace/dotfiles/trev-nix
```

Dry-run the installed system build:

```sh
nix build --dry-run ~/Workspace/dotfiles/trev-nix#nixosConfigurations.stinkpad.config.system.build.toplevel
```

Dry-run the custom installer ISO:

```sh
nix build --dry-run ~/Workspace/dotfiles/trev-nix#nixosConfigurations.trev-installer.config.system.build.isoImage
```

## Roll Back

Temporarily switch to the previous generation:

```sh
sudo nixos-rebuild switch --rollback
```

List generations:

```sh
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

Boot an older generation from the systemd-boot menu if the current generation
does not boot cleanly.

## Clean Old Store Paths

Delete old system generations and collect unused store paths:

```sh
sudo nix-collect-garbage --delete-older-than 30d
```

Then optimize the store:

```sh
sudo nix store optimise
```

The system config already enables store auto-optimization for future builds.

