{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-uuid/3E7ED051-AF6F-433E-9E3D-58EBC45BEE74";
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
                mountOptions = [ "fmask=0077" "dmask=0077" ];
              };
              bootable = true;
            };
            ROOT = {
              size = "100%";
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
