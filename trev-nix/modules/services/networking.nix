{
  self,
  pkgs,
  ...
}: let
  localPkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
in {
  boot.kernelModules = ["tun"];

  services.tor = {
    enable = true;
    client.enable = true;
    settings.ClientTransportPlugin = "webtunnel exec ${pkgs.lyrebird}/bin/lyrebird";
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "com.nymvpn.vpnd.unix-access" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  systemd.services.nym-vpnd = {
    description = "Nym VPN daemon";
    after = ["network-online.target" "dbus.service"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${localPkgs.nym-vpn}/bin/nym-vpnd";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    path = [pkgs.iproute2];
  };

  # This mirrors the Guix Home shepherd service: a user daemon, not a system
  # daemon.  The package name stays explicit so failures are easy to trace.
  systemd.user.services.byedpi = {
    description = "ByeDPI local DPI bypass proxy";
    serviceConfig = {
      ExecStart = "${localPkgs.byedpi}/bin/ciadpi";
      Restart = "on-failure";
    };
    wantedBy = ["default.target"];
  };
}
