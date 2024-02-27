{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-uuid/13058418873051565413";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
	      bootable = true;
            };
            LUKS = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
                settings = {
                  fido2.credentials = [
		    readFile ../../../users/khionu/sec/fde_luks_fido2_primary
		    readFile ../../../users/khionu/sec/fde_luks_fido2_secondary
                  ];
                };
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        datasets = {
	  swap = {
	    type = "zfs_volume";
	    size = "16G";
	    end = "100%";
	    options = {
	      compression = "zle";
	      sync = "always";
	      primarycache = "metadata";
	      secondarycache = "none";
	      "com.sun:auto-snapshot" = false;
	    };
	    content = {
	      type = "swap";
	    };
	  };
          ephem = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          persist = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              "com.sun:auto-snapshot" = "true";
            };
          };
          "ephem/ROOT" = {
            type = "zfs_fs";
            options.mountpoint = "/";
          };
          "persist/var/log" = {
            type = "zfs_fs";
            options.mountpoint = "/var/log";
          };
          "persist/etc/nix" = {
            type = "zfs_fs";
            options.mountpoint = "/etc/nix";
          };
          "persist/etc/nixos" = {
            type = "zfs_fs";
            options.mountpoint = "/etc/nixos";
          };
          "persist/nix" = {
            type = "zfs_fs";
            options.mountpoint = "/nix";
          };
          "persist/home" = {
            type = "zfs_fs";
            options.mountpoint = "/home";
          };
        };
      };
    };
  };
}
