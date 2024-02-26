{ ... }: { config = {
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 25;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  swapDevices = [ {
    device = "/swap";
    size = 16384;
  } ];

  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.pcscd.enable = true;

  i18n.defaultLocale = "en_US.utf8";

  programs.mtr.enable = true;
  
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    settings.substituters = [
      "https://nix-community.cachix.org"
    ];
    settings.trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  system.stateVersion = "23.11";
};}
