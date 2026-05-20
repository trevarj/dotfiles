{pkgs, ...}: {
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  services.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    adw-gtk3
    gnome-tweaks
    gnomeExtensions.appindicator
  ];

  # Keep GNOME leaner on the older ThinkPad without disabling the session.
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    geary
    epiphany
  ];
}
