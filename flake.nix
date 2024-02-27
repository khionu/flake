{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nuenv = {
      url = github:DeterminateSystems/nuenv;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = github:ryantm/agenix;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly = {
      url = github:nix-community/neovim-nightly-overlay;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, nuenv, agenix, neovim-nightly, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = func: nixpkgs.lib.genAttrs supportedSystems (system: func system);
      overlays = [
        nuenv.overlays.default
        neovim-nightly.overlay
        (final: prev: { fido2luks = prev.callPackage ./overlays/fido2luks { }; })
      ];
      globals = {
        system.stateVersion = "23.11";
      };
      lib = nixpkgs.lib;
    in {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system overlays;
            config.allowUnfree = true;
          };
        in {
          inherit (pkgs);
        });
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system overlays;
            config.allowUnfree = true;
          };
        in {
          default = pkgs.mkShell {
            inputsFrom = with pkgs; [ ];
            buildInputs = with pkgs; [ nixpkgs-fmt ];
          };
        });
      nixosConfigurations =
        let
          # Shared config between both the liveimage and real system
          aarch64Base = {
            system = "aarch64-linux";
            modules = with self.nixosModules; [
              ({ config = { nix.registry.nixpkgs.flake = nixpkgs; }; })
              ({ nixpkgs.overlays = overlays; })
              home-manager.nixosModules.home-manager
              traits.base
            ];
        specialArgs = inputs;
          };
          x86_64Base = {
            system = "x86_64-linux";
            modules = with self.nixosModules; [
              ({ config = { nix.registry.nixpkgs.flake = nixpkgs; }; })
              ({ nixpkgs.overlays = overlays; })
              home-manager.nixosModules.home-manager
              traits.base
            ];
            specialArgs = inputs;
          };
        in
          with self.nixosModules; {
            "iso-x86_64" = nixpkgs.lib.nixosSystem {
              inherit (x86_64Base) system specialArgs overlays;
              modules = x86_64Base.modules ++ [
                platforms.iso
              ];
            };
            "iso-aarch64" = nixpkgs.lib.nixosSystem {
              inherit (aarch64Base) system specialArgs overlays;
              modules = aarch64Base.modules ++ [
                platforms.iso
                {
                  virtualisation.vmware.guest.enable = nixpkgs.lib.mkForce false;
                  services.xe-guest-utilities.enable = nixpkgs.lib.mkForce false;
                }
              ];
            };
            "khionu-dragonfly" = nixpkgs.lib.nixosSystem {
              inherit (x86_64Base) system specialArgs;
              modules = x86_64Base.modules ++ [
                ./devices/khionu/dragonfly
                platforms.laptop
                traits.networking
                traits.bluetooth
                traits.plasma
                traits.tz_us_pacific
              ];
            };
            "khionu-tower" = nixpkgs.lib.nixosSystem {
              inherit (x86_64Base) system specialArgs;
              modules = x86_64Base.modules ++ [
                ./devices/khionu/tower
                platforms.desktop
                traits.networking
                traits.tailscale
                traits.bluetooth
                traits.plasma
                traits.tz_us_pacific
              ];
            };
            "household-benchtop" = nixpkgs.lib.nixosSystem {
              inherit (x86_64Base) system specialArgs;
              modules = x86_64Base.modules ++ [
                ./devices/household/benchtop
                platforms.desktop
                traits.networking
                traits.plasma
                traits.tz_us_pacific
              ];
            };
          };
      nixosModules.traits = {
        base = ./traits/base.nix;
        networking = ./traits/networking.nix;
        tailscale = ./traits/tailscale.nix;
        bluetooth = ./traits/bluetooth.nix;
        plasma = ./traits/plasma.nix;
        gaming = ./traits/gaming.nix;
        tz_us_pacific = { time.timeZone = "US/Pacific"; };
        tz_utc = { time.timeZone = "UTC"; };
      };
      nixosModules.platforms = {
        iso = ./platforms/iso.nix;
        isoMinimal = ./platforms/iso_min.nix;
        laptop = ./platforms/laptop.nix;
        desktop = ./platforms/desktop.nix;
      };
  };
}

