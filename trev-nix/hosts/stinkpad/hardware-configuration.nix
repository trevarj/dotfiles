{
  lib,
  ...
}: {
  # Replace this file with the output of:
  #
  #   sudo nixos-generate-config --show-hardware-config \
  #     > trev-nix/hosts/stinkpad/hardware-configuration.nix
  #
  # Keeping hardware facts here matches idiomatic NixOS practice and avoids
  # baking the current Guix UUIDs into reusable modules.
  boot.initrd.luks.devices = lib.mkDefault {};
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/NIXOS_ROOT";
    fsType = "ext4";
  };
  swapDevices = lib.mkDefault [];
}
