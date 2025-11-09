(define-module (trev-guix files udev-rules)
  #:use-module (gnu))

(define-public %arctis-7-nova-udev-rule
  (udev-rule
   "50-arctis-headset.rules"
   (string-append
    "KERNEL==\"hidraw*\", SUBSYSTEM==\"hidraw\","
    "ATTRS{idVendor}==\"1038\", ATTRS{idProduct}==\"2202\","
    "TAG+=\"uaccess\"")))

(define-public %ledger-udev-rule
  (udev-rule
   "20-ledger-hw.rules"
   (string-append
    "KERNEL==\"hidraw*\", ATTRS{idVendor}==\"2c97\", MODE=\"0666\"\n"
    "SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"2c97\", TAG+=\"uaccess\", TAG+=\"udev-acl\"")))

(define-public %ddcutil-udev-rule
  (udev-rule
   "60-ddcutil-i2c.rules"
   "KERNEL==\"i2c-[0-9]*\", GROUP=\"i2c\", MODE=\"0660\""))
