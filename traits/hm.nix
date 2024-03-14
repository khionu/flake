{ home-manager, config, globals, pkgs,... }@inputs: {
  imports = [
    home-manager.nixosModules.home-manager
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
