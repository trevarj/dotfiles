# Desktop Sessions

Both GNOME and Niri are enabled by the `stinkpad` system config:

- GNOME is configured in `trev-nix/modules/desktop/gnome.nix`
- Niri is configured in `trev-nix/modules/desktop/niri.nix`

Because both are installed, switching between them does not require rebuilding
the system.

## Switch At Login

Log out to GDM.

Select the user, then use the session selector before entering the password.
Choose either:

- `GNOME`
- `Niri`

The exact button location depends on the GDM theme, but it is normally a small
gear or session menu on the login screen.

## Start Niri From A TTY

Log in on a TTY and run:

```sh
niri-session
```

That shell function is defined by Home Manager in `trev-nix/home/trev.nix`.
It sets the expected Wayland session environment variables and then execs Niri.

## Change Which Desktops Are Installed

The enabled desktop modules are listed in:

```sh
trev-nix/hosts/stinkpad/default.nix
```

Current imports include:

```nix
../../modules/desktop/gnome.nix
../../modules/desktop/niri.nix
```

Remove one of those imports only if you want that desktop removed from the
system entirely.  After editing, rebuild:

```sh
sudo nixos-rebuild switch --flake ~/Workspace/dotfiles/trev-nix#stinkpad
```

## Niri Config

The Niri config is generated from the existing dotfiles:

```sh
niri/.config/niri/config.kdl
```

Home Manager applies a few NixOS-specific substitutions in
`trev-nix/home/trev.nix`, mostly replacing Flatpak launch commands with NixOS
package commands.

After editing Niri config, rebuild:

```sh
sudo nixos-rebuild switch --flake ~/Workspace/dotfiles/trev-nix#stinkpad
```

Then log out and back into Niri.

