{...}: {
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="2202", TAG+="uaccess"

    KERNEL=="hidraw*", ATTRS{idVendor}=="2c97", MODE="0666"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", TAG+="uaccess", TAG+="udev-acl"

    KERNEL=="ttyACM*", ATTRS{idVendor}=="303a", MODE="0666"
    SUBSYSTEMS=="usb", ATTRS{idProduct}=="4001", GROUP="dialout", TAG+="uaccess", TAG+="udev-acl"

    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
  '';
}
