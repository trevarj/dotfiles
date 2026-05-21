# Custom Installer ISO

The custom installer ISO bundles this dotfiles tree and provides an
`install-stinkpad` command.

The live installer inherits Nonguix `installation-os-nonfree`, using the
nonfree Linux kernel path and `base-initrd`.  It includes Intel and AMD
firmware needed by the target laptops without using `microcode-initrd`, which
has caused unbootable live ISOs.

Build it from this repository:

```sh
trev-guix/scripts/build-stinkpad-installer-iso
```

The command creates `./stinkpad-installer.iso` as a symlink to the generated
store item and keeps it as a GC root.  It also builds the target system closure
and embeds a Guix archive of that closure in the ISO, reducing the amount that
`guix system init` needs to download during install.

The installer authorizes the build host's public Guix signing key so the live
system can import the embedded archive.

## Write To USB

Build and write the ISO in one command:

```sh
trev-guix/scripts/prepare-stinkpad-installer-usb
```

The helper lists removable/USB disks and requires typing
`WRITE ISO /dev/...` before overwriting anything.

To write an ISO that already exists:

```sh
trev-guix/scripts/write-stinkpad-installer-usb ./stinkpad-installer.iso
```

## Install

Boot from the USB.

Connect networking with the standard Guix installer tools.  For Wi-Fi:

```sh
connmanctl
enable wifi
scan wifi
services
agent on
connect wifi_...
state
```

Then run:

```sh
sudo install-stinkpad
```

The helper will:

- validate the bundled `stinkpad-niri` Guix system config
- show candidate non-removable disks
- ask which disk to wipe
- require typing `WIPE /dev/...`
- create the disk layout expected by `trev-guix/systems/stinkpad.scm`
- mount the installed system at `/mnt`
- copy the bundled dotfiles to `/mnt/home/trev/Workspace/dotfiles`
- copy bundled sibling source checkouts to `/mnt/home/trev/Workspace`
- import the preloaded target system closure when present
- run `guix system init`
- make the copied dotfiles checkout editable by `trev`
- ask you to set the `trev` login password

The helper checks that Connman reports `State = online` after disk selection
and before wiping the selected disk.

The LUKS passphrase is entered interactively.  It is never stored in the repo
or ISO.

After the install completes:

```sh
sudo finish-stinkpad-install
```

The helper requires typing `REBOOT`, then syncs disks, disables swap,
unmounts `/mnt`, closes the LUKS root mapping, and reboots.

On first boot, unlock the LUKS root, log in as `trev`, and activate Guix Home:

```sh
cd ~/Workspace/dotfiles
guix home reconfigure -L . -e '(@ (trev-guix home niri) %home-niri-environment)'
niri-session
```

The Home activation adds Flathub and installs the declared user Flatpaks.
Run the Home reconfigure with a working network connection.

## Disk Layout

The installer intentionally creates the storage layout already declared in:

```sh
trev-guix/systems/stinkpad.scm
```

Current layout:

- `EFI`: 1 GiB vfat EFI system partition mounted at `/boot/efi`
- `cryptroot`: LUKS2 container using the configured root UUID
- `/`: ext4 filesystem inside `/dev/mapper/root`
- `swap`: 8 GiB swap partition using the configured swap UUID

The installer formats the new disk with the UUIDs from the checked-in system
configuration.  This keeps the installer from changing the currently installed
system config.

## Safety Notes

The installer destroys the selected target disk.  Read the disk list carefully
before confirming the `WIPE /dev/...` prompt.

Do not boot the installed system while another attached disk has the same EFI,
LUKS, or swap UUIDs.

The ISO contains the dotfiles checkout.  Do not build or share it from a tree
that contains secrets.
