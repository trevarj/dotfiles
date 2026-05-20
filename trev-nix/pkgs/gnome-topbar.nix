{
  rustPlatform,
  pkg-config,
  wrapGAppsHook4,
  dbus,
  glib,
  gtk4,
  gtk4-layer-shell,
  libpulseaudio,
  libudev-zero,
  pango,
  cairo,
  gdk-pixbuf,
  graphene,
  networkmanager,
  bluez,
  upower,
  src,
}:
rustPlatform.buildRustPackage {
  pname = "gnome-topbar";
  version = "0.14.1";

  inherit src;
  cargoLock.lockFile = "${src}/Cargo.lock";
  buildAndTestSubdir = "crates/gnome-topbar";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    bluez
    cairo
    dbus
    gdk-pixbuf
    glib
    graphene
    gtk4
    gtk4-layer-shell
    libpulseaudio
    libudev-zero
    networkmanager
    pango
    upower
  ];

  doCheck = false;

  meta = {
    description = "GNOME Shell-inspired GTK top bar for Wayland";
    homepage = "https://github.com/trevarj/gnome-topbar";
  };
}
