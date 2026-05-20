{
  self,
  pkgs,
  ...
}: {
  programs.niri.enable = true;
  programs.xwayland.enable = true;
  security.pam.services.hyprlock = {};

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };

  environment.systemPackages = with pkgs;
    [
      adwaita-icon-theme
      brightnessctl
      cava
      cliphist
      fuzzel
      hypridle
      hyprlock
      hyprpaper
      kitty
      libnotify
      pavucontrol
      procps
      rygel
      swaybg
      udiskie
      wlsunset
      xwayland-satellite
    ]
    ++ [
      self.packages.${pkgs.stdenv.hostPlatform.system}.gnome-topbar
    ];
}
