{ pkgs, config, users, ... }: {
  networking.hostName = "khionu-tower";
  networking.hostId = "156c6434";

  security.sudo.wheelNeedsPassword = false;

  users.users.khionu = {
    isNormalUser = true;
    password = "changeme1234";
    extraGroups = [ "wheel" "audio" "networkmanager" "docker" "libvirtd" ];
    shell = pkgs.nushell;
  };

  home-manager.users.khionu = import ../../../users/khionu/home.nix;

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = [ "khionu" ];

  virtualisation.docker = {
    enable = true;
    # TODO: make it so
    # storageDriver = "zfs";
  };
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      swtpm.enable = true;
      ovmf.enable = true;
      ovmf.packages = [ pkgs.OVMFFull.fd ];
    };
  };
  virtualisation.spiceUSBRedirection.enable = true;
  services.spice-vdagentd.enable = true;

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

  boot.loader.systemd-boot.consoleMode = "max";

  hardware.opengl = {
    extraPackages = [ pkgs.amdvlk ];
    extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
  };
  environment.variables.AMD_VULKAN_ICD = "RADV";

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
      options = [
        "users"
        "nofail"
      ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/3724d72b-7c8a-4669-a92e-15fbf8e5fef4"; }
    ];
}
