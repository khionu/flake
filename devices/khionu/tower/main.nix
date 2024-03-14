{ pkgs, config, users, ... }: {
  networking.hostName = "khionu-tower";
  networking.hostId = "156c6434";

  users.users.khionu = {
    isNormalUser = true;
    password = "changeme1234";
    extraGroups = [ "wheel" "audio" "networkmanager" ];
    shell = pkgs.nushell;
  };

  home-manager.users.khionu = import ../../../users/khionu/home.nix;

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = [ "khionu" ];

  # Hardware related
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [
    "video=DP-2:5120x1440@240"
  ];
  boot.initrd.availableKernelModules = [ "thunderbolt" "xhci_pci" "nvme" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.systemd.enable = true;
  boot.initrd.luks.devices.nixos = {
    device = "/dev/disk/by-id/nvme-nvme.8086-50484d32393133303030523939363043474e-494e54454c2053534450453231443936304741-00000001-part2";
  };

  hardware.opengl = {
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = [ pkgs.amdvlk ];
    extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
  };

  hardware.cpu.amd.updateMicrocode = true;

  # Volumes and filesystems
  # TODO: Better Disko

  fileSystems."/" =
    { device = "zroot/EPHEM/root";
      fsType = "zfs";
    };

  fileSystems."/var" =
    { device = "zroot/PERSIST/var";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "zroot/PERSIST/home";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "zroot/PERSIST/nix";
      fsType = "zfs";
    };

  fileSystems."/etc/nix" =
    { device = "zroot/PERSIST/etc_nix";
      fsType = "zfs";
    };

  fileSystems."/etc/nixos" =
    { device = "zroot/PERSIST/etc_nixos";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/8906-B8A0";
      fsType = "vfat";
    };

  fileSystems."/gaming" =
    { device = "/dev/disk/by-path/pci-0000:58:00.0-nvme-1-part2";
      fsType = "ntfs3";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/3724d72b-7c8a-4669-a92e-15fbf8e5fef4"; }
    ];
}
