{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dbus,
  gcc,
  glibc,
  libmnl,
  libnftnl,
}:
stdenv.mkDerivation rec {
  pname = "nym-vpn";
  version = "1.29.2";

  src = fetchurl {
    url = "https://github.com/nymtech/nym-vpn-client/releases/download/nym-vpn-core-v${version}/nym-vpn-core-v${version}_linux_x86_64.tar.gz";
    sha256 = "0d8v4390kd4aj7776vyv22sj97y5a63fk02m87j7pv64ihfqrr7r";
  };

  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [
    dbus
    gcc.cc.lib
    glibc
    libmnl
    libnftnl
  ];

  sourceRoot = "nym-vpn-core-v${version}_linux_x86_64";

  installPhase = ''
    install -Dm755 nym-vpnd "$out/bin/nym-vpnd"
    install -Dm755 nym-vpnc "$out/bin/nym-vpnc"
    install -Dm755 nym-diagnostic "$out/bin/nym-diagnostic"
  '';

  meta = {
    description = "Nym VPN core client binaries";
    homepage = "https://github.com/nymtech/nym-vpn-client";
  };
}
