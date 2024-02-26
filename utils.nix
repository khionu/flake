{nixpkgs, home-manager, ...}: {
  homeManagerForUser = user: args: (
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./users + "/${user}" + /home.nix
      ];
      extraSpecialArgs = args;
    }
  );
}
