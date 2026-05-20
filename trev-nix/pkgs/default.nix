{
  pkgs,
  gnome-topbar-src,
}: {
  byedpi = pkgs.callPackage ./byedpi.nix {};
  codex = pkgs.callPackage ./codex.nix {};
  gnome-topbar = pkgs.callPackage ./gnome-topbar.nix {
    src = gnome-topbar-src;
  };
  nym-vpn = pkgs.callPackage ./nym-vpn.nix {};
  opencode = pkgs.callPackage ./opencode.nix {};
}
