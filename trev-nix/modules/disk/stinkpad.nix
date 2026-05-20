{diskDevice}: {
  disko.devices = {
    disk.main = {
      # This value is supplied by install-stinkpad after interactive selection.
      # Keeping it out of the static config avoids hardcoding a destructive
      # target such as /dev/nvme0n1.
      device = diskDevice;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };

          root = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              # Allow SSD discard/TRIM through LUKS.  This improves long-term
              # NVMe behavior but leaks which encrypted blocks are unused.
              settings.allowDiscards = true;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
