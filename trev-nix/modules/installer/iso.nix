{
  disko,
  lib,
  modulesPath,
  pkgs,
  self,
  ...
}: let
  diskoPackage = disko.packages.${pkgs.stdenv.hostPlatform.system}.disko;
  installStinkpad = pkgs.writeShellScriptBin "install-stinkpad" ''
    set -euo pipefail

    source_dir="/etc/trev-dotfiles"
    target_dir="/mnt/home/trev/Workspace/dotfiles"
    flake_ref="$target_dir#stinkpad"
    disko_flake_ref="$source_dir#stinkpad"

    if ! nm-online --timeout=10 >/dev/null 2>&1; then
      echo "NetworkManager is not online yet." >&2
      echo "Connect Wi-Fi with 'nmtui' or 'nmcli device wifi connect ...' first." >&2
      exit 1
    fi

    if mountpoint -q /mnt; then
      echo "/mnt is already mounted." >&2
      echo "Unmount it before running the automated disk installer." >&2
      exit 1
    fi

    echo "Candidate target disks:" >&2
    mapfile -t disks < <(
      lsblk --noheadings --nodeps --paths --exclude 7,11 \
        --output PATH,TYPE,RM |
        awk '$2 == "disk" && $3 == "0" {print $1}'
    )

    if [ "''${#disks[@]}" -eq 0 ]; then
      echo "No non-removable target disks found." >&2
      echo "Check lsblk manually before installing." >&2
      exit 1
    fi

    for index in "''${!disks[@]}"; do
      disk="''${disks[$index]}"
      printf '  %d) %s\n' "$((index + 1))" "$(lsblk --nodeps --noheadings --output PATH,SIZE,MODEL "$disk")" >&2
    done

    read -r -p "Select disk number to WIPE and install NixOS onto: " selection
    if ! [[ "$selection" =~ ^[0-9]+$ ]] ||
      [ "$selection" -lt 1 ] ||
      [ "$selection" -gt "''${#disks[@]}" ]; then
      echo "Invalid disk selection." >&2
      exit 1
    fi

    disk="''${disks[$((selection - 1))]}"
    echo "Selected target disk: $disk" >&2
    lsblk "$disk" >&2

    read -r -p "Type 'WIPE $disk' to destroy all data on $disk: " confirmation
    if [ "$confirmation" != "WIPE $disk" ]; then
      echo "Confirmation did not match; aborting." >&2
      exit 1
    fi

    echo "Partitioning, encrypting, formatting, and mounting $disk." >&2
    ${diskoPackage}/bin/disko \
      --mode destroy,format,mount \
      --flake "$disko_flake_ref" \
      --argstr diskDevice "$disk" \
      --yes-wipe-all-disks

    if ! mountpoint -q /mnt; then
      echo "disko finished but /mnt is not mounted; aborting." >&2
      exit 1
    fi

    mkdir -p /mnt/home/trev/Workspace

    if [ -e "$target_dir" ]; then
      echo "$target_dir already exists; leaving it in place." >&2
    else
      echo "Copying bundled dotfiles to $target_dir." >&2
      mkdir -p "$target_dir"
      cp -aL --no-preserve=ownership "$source_dir/." "$target_dir/"
    fi

    echo "Generating hardware configuration for the mounted system." >&2
    nixos-generate-config --root /mnt --show-hardware-config \
      > "$target_dir/trev-nix/hosts/stinkpad/hardware-configuration.nix"

    echo "Installing $flake_ref." >&2
    NIX_CONFIG="experimental-features = nix-command flakes" \
      nixos-install --flake "$flake_ref"

    echo "Set the login password for trev." >&2
    nixos-enter --root /mnt -c 'passwd trev'

    # Keep the copied checkout editable by trev after first boot.  The NixOS
    # default normal-user uid/gid pair is 1000:100, and the host module pins the
    # uid to keep this installer script deterministic.
    chown -R 1000:100 "$target_dir"
  '';
in {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  image.fileName = lib.mkForce "trev-nix-installer.iso";

  # The installer does not need to force-import root ZFS pools.  Setting this
  # explicitly keeps future NixOS defaults and warnings aligned.
  boot.zfs.forceImportRoot = false;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    diskoPackage
    git
    parted
    gptfdisk
    cryptsetup
    nixos-enter
    vim
    installStinkpad
  ];

  # Bundle the dotfiles tree into the ISO so installation does not depend on a
  # network clone or a local checkout existing on the target machine.
  environment.etc."trev-dotfiles".source = self;

  services.openssh.enable = true;
}
