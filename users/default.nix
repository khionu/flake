{ pkgs, ... }: rec {
  khionu = { 
    hm = ./khionu/home.nix;
  };

  x = "hi";

  importManagedHomes = users: builtins.listToAttrs (
    builtins.map (u: {
      name = u;
      value = import "${u}".hm;
    }) (pkgs.lib.attrNames users));
}
