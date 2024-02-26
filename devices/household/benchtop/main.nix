{ ... }: { config = {
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  import ../../users/khionu/home.nix;

  users.users.khionu = {
    isNormalUser = true;
    password = "changeme1234";
    extraGroups = [ "wheel" "audio" "networkmanager" ];
  };

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = [ "khionu" ];
};}
