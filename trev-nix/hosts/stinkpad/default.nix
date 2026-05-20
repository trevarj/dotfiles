{
  self,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/desktop/gnome.nix
    ../../modules/desktop/niri.nix
    ../../modules/services/networking.nix
    ../../modules/udev.nix
  ];

  networking.hostName = "stinkpad";
  time.timeZone = "Etc/UTC";

  # NixOS uses systemd/localed for this.  Niri still has its own XKB settings
  # in the KDL config, but this gives TTYs and other sessions the same baseline.
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb = {
    layout = "us,ru";
    model = "thinkpad";
    options = "grp:win_space_toggle,compose:ralt,ctrl:nocaps";
  };
  console.keyMap = "us";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "modprobe.blacklist=pcspkr,snd_pcsp"
      "thinkpad_acpi.fan_control=1"
    ];
    initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "sd_mod"];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    graphics.enable = true;
    i2c.enable = true;
  };

  # Runtime swap lives inside the encrypted root filesystem created by disko.
  # This is intentionally not sized for hibernation/resume.
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];

  users.groups.i2c = {};
  users.users.trev = {
    isNormalUser = true;
    # Pin the uid so files copied by the custom installer ISO can be chowned
    # before the installed system has booted for the first time.
    uid = 1000;
    description = "Trevor Arjeski";
    home = "/home/trev";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "dialout"
      "input"
      "lp"
      "audio"
      "video"
      "i2c"
      "podman"
    ];
  };

  # The Guix config had Nix installed as a foreign package manager.  On NixOS
  # this is the native daemon; flakes and nix-command are the modern CLI surface.
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    trusted-users = ["root" "@wheel"];
    auto-optimise-store = true;
  };

  # Unfree firmware and a few desktop apps such as Brave require this opt-in.
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs;
    [
      curl
      git
      gnupg
      jq
      ripgrep
      fd
      vim
      zsh
    ]
    ++ (with self.packages.${pkgs.stdenv.hostPlatform.system}; [
      byedpi
      nym-vpn
      gnome-topbar
    ]);

  programs.zsh.enable = true;
  programs.dconf.enable = true;

  # Pick the current release when this config is first activated, then leave it
  # alone.  It gates compatibility defaults and is not a package version pin.
  system.stateVersion = "26.05";
}
