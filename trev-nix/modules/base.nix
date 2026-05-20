{
  pkgs,
  lib,
  ...
}: {
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [22];

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      font-awesome
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      terminus_font
    ];
  };

  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      PermitRootLogin = "no";
    };
  };

  services.printing = {
    enable = true;
    webInterface = true;
    drivers = with pkgs; [
      cups-filters
      epson-escpr
    ];
  };

  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [sane-airscan];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  security.rtkit.enable = true;

  virtualisation = {
    libvirtd.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  services.upower.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;

  # Kept commented to mirror the Guix config: useful on NixOS, but not enabled
  # until the package/service closure is acceptable on this laptop.
  # services.fwupd.enable = true;
}
