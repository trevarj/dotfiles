# `trev-nix` Guides

The main NixOS system target is:

```sh
~/Workspace/dotfiles#stinkpad
```

Home Manager is loaded by the NixOS config, so there is no separate
`home-manager switch` step for normal use.

- [Installer ISO](./installer.md)
- [Desktop Sessions](./desktops.md)
- [Secrets](./secrets.md)
- [Updating And Rebuilding](./updating.md)

Current assumptions:

- `x86_64-linux`
- host name: `stinkpad`
- desktop stack: GNOME and Niri
- Home Manager managed through NixOS
