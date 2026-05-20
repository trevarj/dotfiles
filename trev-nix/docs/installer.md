# Custom Installer ISO

The custom installer ISO bundles the dotfiles tree and includes an
`install-stinkpad` command.

The installed system target is:

```sh
~/Workspace/dotfiles#stinkpad
```

Build it from a Nix system:

```sh
nix build ~/Workspace/dotfiles#nixosConfigurations.trev-installer.config.system.build.isoImage
```

The ISO is written to:

```sh
result/iso/trev-nix-installer.iso
```

## Write To USB

Replace `/dev/sdX` with the whole USB device, not a partition:

```sh
sudo dd if=result/iso/trev-nix-installer.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## Install

Boot from the USB.

Connect Wi-Fi first:

```sh
nmtui
```

Or with `nmcli`:

```sh
nmcli device wifi list
nmcli device wifi connect "SSID" --ask
```

Check that the network is online:

```sh
nm-online --timeout=10
```

Then run:

```sh
sudo install-stinkpad
```

Do not mount anything at `/mnt` first.  The helper refuses to run when `/mnt`
is already mounted.  It also refuses to continue unless NetworkManager reports
that the network is online.

The helper will:

- check that networking is online
- show candidate non-removable disks
- ask which disk to wipe
- require typing `WIPE /dev/...`
- create a GPT disk layout
- create a 1 GiB EFI partition at `/boot`
- create a LUKS-encrypted ext4 root filesystem
- enable SSD discard/TRIM through LUKS
- mount the installed system at `/mnt`
- copy the dotfiles flake to `/mnt/home/trev/Workspace/dotfiles`
- generate hardware config
- run `nixos-install`
- ask you to set the `trev` login password

The LUKS passphrase is entered interactively.  It is never stored in the repo
or ISO.  `nixos-install` asks for the root password; the installer helper then
uses `nixos-enter --root /mnt -c 'passwd trev'` to set the normal user password
before reboot.

## Disk Layout

The declarative disk layout lives in:

```sh
trev-nix/modules/disk/stinkpad.nix
```

The current layout is:

- `ESP`: 1 GiB vfat EFI system partition mounted at `/boot`
- `cryptroot`: LUKS container using the rest of the disk
- `/`: ext4 filesystem inside `cryptroot`
- `/swapfile`: 8 GiB swapfile created by the installed system

Hibernation is not configured.

## Safety Notes

The ISO contains the dotfiles checkout.  Do not build or share it from a tree
that contains secrets.

The installer destroys the selected target disk.  Read the disk list carefully
before confirming the `WIPE /dev/...` prompt.

`system.stateVersion` and `home.stateVersion` are compatibility baselines, not
package version pins.  Set them when first installing and leave them alone
unless the NixOS or Home Manager manual says otherwise.
