{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    home-manager = {
      url = github:nix-community/home-manager;
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
    disko = {
      url = github:khionu/disko;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, ... }@inputs:
  let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = func: nixpkgs.lib.genAttrs supportedSystems (system: func system);   
    forTheseUsers = func: users: (nixpkgs.lib.genAttrs (u: func u) users);
    utils = ./utils.nix;
    globals = rec {
      stateVersion = "23.01";
    };
  in
  {
    packages = forAllSystems
      (system:
        let
	  pkgs = import nixpkgs {
	    inherit system;
	    config.allowUnfree = true;
	  };
	in {
	  inherit (pkgs);
	});

    devShells = forAllSystems
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
	    config.allowUnfree = true;
          };
        in {
          default = pkgs.mkShell
            {
              inputsFrom = with pkgs; [ ];
              buildInputs = with pkgs; [
                nixpkgs-fmt
	      ];
            };
        });

    nixosConfigurations =
      let
        # Shared config between both the liveimage and real system
        aarch64Base = {
          system = "aarch64-linux";
          modules = with self.nixosModules; [
            ({ config = { nix.registry.nixpkgs.flake = nixpkgs; }; })
            home-manager.nixosModules.home-manager
            traits.overlay
            traits.base
            services.openssh
          ];
        };
        x86_64Base = {
          system = "x86_64-linux";
          modules = with self.nixosModules; [
            ({ config = { nix.registry.nixpkgs.flake = nixpkgs; }; })
            home-manager.nixosModules.home-manager
            traits.overlay
            traits.base
            services.openssh
          ];
        };
      in
      with self.nixosModules; {
        x86_64IsoImage = nixpkgs.lib.nixosSystem {
          inherit (x86_64Base) system;
          modules = x86_64Base.modules ++ [
            platforms.iso
          ];
        };
        aarch64IsoImage = nixpkgs.lib.nixosSystem {
          inherit (aarch64Base) system;
          modules = aarch64Base.modules ++ [
            platforms.iso
            {
              config = {
                virtualisation.vmware.guest.enable = nixpkgs.lib.mkForce false;
                services.xe-guest-utilities.enable = nixpkgs.lib.mkForce false;
              };
            }
          ];
        };
	khionu_dragonfly = nixpkgs.lib.nixosSystem {
	  inherit (x86_64Base) system;
	  modules = x86_64Base.modules ++ [
	    ./devices/khionu/dragonfly/main.nix
	    platforms.laptop
	    traits.base
	    traits.networking
	    traits.bluetooth
	    traits.plasma
	    traits.generalDev
	    traits.tz_us_pacific
	  ];
	};
      };

    nixosModules.traits = {
      overlay = { nixpkgs.overlays = [ self.overlays.default ]; };
      base = ./traits/base.nix;
      networking = ./traits/networking.nix;
      tailscale = ./traits/tailscale.nix;
      bluetooth = ./traits/bluetooth.nix;
      plasma = ./traits/plasma.nix;
      generalDev = ./traits/dev.nix;
      # gameDev = ./traits/game_dev.nix;
      gaming = ./traits/gaming.nix;
      # nas = ./traits/nas.nix;
      # nomadClient = ./traits/nomad/client.nix;
      # nomadServer = ./traits/nomad/server.nix;
      # consulClient = ./traits/consul/client.nix;
      # consulServer = ./traits/consul/server.nix;
      # vaultAgent = ./traits/vault/agent.nix;
      # vaultProxy = ./traits/vault/proxy.nix;
      # vaultServer = ./traits/vault/server.nix;
      tz_us_pacific = { config, ... }: { config.time.timeZone = "US/Pacific"; };
      tz_utc = { config, ... }: { config.time.timeZone = "UTC"; };
    };
    nixosModules.platforms = {
      iso = ./platforms/iso.nix;
      isoMinimal = ./platforms/iso_min.nix;
      # container = ./platforms/container.nix;
      laptop = ./platforms/laptop.nix;
      # desktop = ./platforms/desktop.nix;
      # server = ./platforms/server.nix;
    };
  };
}
