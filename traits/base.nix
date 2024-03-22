{ pkgs, ... }: { config = {
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 25;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.pcscd.enable = true;

  i18n.defaultLocale = "en_US.utf8";

  programs.mtr.enable = true;

  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };
  
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
      "https://crane.cachix.org"
    ];
    settings.trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
    ];
  };
  system.stateVersion = "23.11";
};}
