(define-module (trev-guix files udev-rules)
  #:use-module (gnu))

(define-public %arctis-7-nova-udev-rule
  (udev-rule
   "50-arctis-headset.rules"
   (string-append
    "KERNEL==\"hidraw*\", SUBSYSTEM==\"hidraw\","
    "ATTRS{idVendor}==\"1038\", ATTRS{idProduct}==\"2202\","
    "TAG+=\"uaccess\"")))

(define-public %upower-battery-threshold-udev-rule
  (udev-rule
   "60-upower-battery.rules"
   (string-append
    "ACTION==\"remove\", GOTO=\"battery_end\"\n\n"
    "SUBSYSTEM==\"power_supply\", ATTR{charge_control_start_threshold}!=\"\", "
    "IMPORT{builtin}=\"hwdb 'battery:$kernel:$attr{model_name}:$attr{[dmi/id]modalias}'\", "
    "GOTO=\"battery_permissions\"\n\n"
    "LABEL=\"battery_permissions\"\n"
    "SUBSYSTEM==\"power_supply\", KERNEL==\"BAT0\", "
    "TEST==\"charge_control_start_threshold\", "
    "TEST==\"charge_control_end_threshold\", "
    "RUN+=\"/run/current-system/profile/bin/chgrp trev "
    "/sys$devpath/charge_control_start_threshold "
    "/sys$devpath/charge_control_end_threshold\", "
    "RUN+=\"/run/current-system/profile/bin/chmod g+w "
    "/sys$devpath/charge_control_start_threshold "
    "/sys$devpath/charge_control_end_threshold\", "
    "GOTO=\"battery_end\"\n\n"
    "LABEL=\"battery_end\"\n")))

(define-public %stinkpad-battery-charge-limit-hwdb
  (udev-hardware
   "61-battery-local.hwdb"
   (string-append
    "battery:BAT0:5B10W51863:dmi:*svnLENOVO:*pn21K3CTO1WW:*\n"
    " CHARGE_LIMIT=75,80\n")))

(define-public %ledger-udev-rule
  (udev-rule
   "20-ledger-hw.rules"
   (string-append
    "KERNEL==\"hidraw*\", ATTRS{idVendor}==\"2c97\", MODE=\"0666\"\n"
    "SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"2c97\", TAG+=\"uaccess\", TAG+=\"udev-acl\"")))

(define-public %jade-udev-rule
  (udev-rule
   "21-jade-hw.rules"
   (string-append
    "KERNEL==\"ttyACM*\", ATTRS{idVendor}==\"303a\", MODE=\"0666\"\n"
    "SUBSYSTEMS==\"usb\", ATTRS{idProduct}==\"4001\", GROUP=\"dialout\", TAG+=\"uaccess\", TAG+=\"udev-acl\"")))

(define-public %ddcutil-udev-rule
  (udev-rule
   "60-ddcutil-i2c.rules"
   "KERNEL==\"i2c-[0-9]*\", GROUP=\"i2c\", MODE=\"0660\""))
