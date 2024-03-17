{ home-manager, config, globals, pkgs,... }@inputs:
let
  manageHomeConfigPkg = pkgs.nuenv.writeScriptBin {
    name = "upsert-hm";
    script = ''
      let hm_path = path join $env.home ".config/home-manager"
      if not ( $hm_path | path exists) {
        
      }
    '';
  };
in {
  imports = [
    home-manager.nixosModules.home-manager
  ];

  options.sybiern.users = 
    (import <nixpkgs/nixos/modules/services/networking/ssh/sshd.nix> inputs)
    .options.users.users;

  users.users = config.sybiern.users;
  
  systemd.user.units = {
    "pullHome" = {
      script = ''
      mkdir -p
      '';
      serviceConfig = {
        RootDirectory = "/etc/nixos";
        RuntimeDirectory = "nixos";
      };
    };
  };



  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
