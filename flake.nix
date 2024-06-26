{
  inputs = {
    # Stable moves a little too slow for me. Would be nice
    # if it were easier to test...
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    # I don't use this, but the other ones do, and this will
    # reduce redundancy through following
    flake-utils.url = "github:numtide/flake-utils";
    # TODO: Document
    lix = {
      url = "git+ssh://git@git.lix.systems/lix-project/lix";
      flake = false;
    };
    lix-module = {
      url = "git+ssh://git@git.lix.systems/lix-project/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
      inputs.flake-utils.follows = "flake-utils";
    };
    # All user configurations are home-manager modules, which
    # have the advantage of many modules that each user can
    # tweak to their own preferences
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # So I can make helper packages using Nushell, which is so
    # much nicer than Bash
    nuenv = {
      url = github:DeterminateSystems/nuenv;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # At-rest encryption for secrets, using YubiKeys and 
    # SSH keys
    agenix = {
      url = github:ryantm/agenix;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # We should be able to build nightly without the 
    # neovim-nightly flake, but for some reason it just
    # doesn't work right now. TODO
    neovim = {
    # url = "github:neovim/neovim?dir=contrib";
      url = github:nix-community/neovim-nightly-overlay;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Gonna be changing this version basically as soon as
    # the releases happen.
    jj = {
      url = github:martinvonz/jj;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self, nixpkgs, home-manager, nuenv, agenix, neovim, jj, ...
  }:
    let
      # These are all the architectures this flake builds for
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      lib = nixpkgs.lib;
      # TODO: fancy stuff in Hazel's lib
      # lib = import ./lib.nix { inherit inputs; };
      specialArgs = inputs // { globals = globals; };
      overlays = [
        nuenv.overlays.default
        neovim.overlays.default
        jj.overlays.default
        (import ./packages { inherit lib; })
      ];
      globals = {
        nixpkgs.overlays = overlays;
        system.stateVersion = "23.11";
      };
      # This is a wrapper function so we can make sure each architecture is treated the same
      eachSystem = f: lib.genAttrs supportedSystems (system: f {
        inherit system;
        # A special point that imports the overlays and packages defined in this flake
        pkgs = import nixpkgs { inherit overlays system; };
      });
    in {
      nixosModules.traits = {
        base          = ./traits/base.nix;
        hm            = ./traits/hm.nix;
        networking    = ./traits/networking.nix;
        tailscale     = ./traits/tailscale.nix;
        bluetooth     = ./traits/bluetooth.nix;
        plasma        = ./traits/plasma.nix;
        gaming        = ./traits/gaming.nix;
        tz_utc        = { time.timezone = "UTC"; };
        tz_us_pacific = { time.timeZone = "US/Pacific"; };
      };
      nixosModules.platforms = {
        iso           = ./platforms/iso.nix;
        isoMinimal    = ./platforms/iso_min.nix;
        laptop        = ./platforms/laptop.nix;
        desktop       = ./platforms/desktop.nix;
      };
      users = eachSystem({ pkgs, system }: {
        khionu = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./users/khionu/home.nix ];
          extraSpecialArgs = specialArgs;
        };
      });
      nixosConfigurations =
        let
          aarch64Base = import ./platforms/archs/aarch64.nix specialArgs;
          x86_64Base  = import ./platforms/archs/x86_64.nix specialArgs;
        in with self.nixosModules; {
          "iso-x86_64" = lib.nixosSystem {
            inherit (x86_64Base) system specialArgs overlays;
            modules = x86_64Base.modules ++ [
              platforms.iso
              traits.base
              traits.hm
            ];
          };
          "iso-aarch64" = lib.nixosSystem {
            inherit (aarch64Base) system specialArgs overlays;
            modules = aarch64Base.modules ++ [
              platforms.iso
              traits.base
              traits.hm
              home-manager.nixosModules.home-manager
              {
                virtualisation.vmware.guest.enable = lib.mkForce false;
                services.xe-guest-utilities.enable = lib.mkForce false;
              }
            ];
          };
          "khionu-dragonfly" = lib.nixosSystem {
            inherit (x86_64Base) system specialArgs;
            modules = x86_64Base.modules ++ [
              ./devices/khionu/dragonfly
              platforms.laptop
              traits.base
              traits.hm
              traits.networking
              traits.bluetooth
              traits.plasma
              traits.tz_us_pacific
            ];
          };
          "khionu-tower" = lib.nixosSystem {
            inherit (x86_64Base) system specialArgs;
            modules = x86_64Base.modules ++ [
              ./devices/khionu/tower
              platforms.desktop
              traits.base
              traits.hm
              traits.networking
              traits.tailscale
              traits.bluetooth
              traits.plasma
              traits.gaming
              traits.tz_us_pacific
            ];
          };
          "household-benchtop" = lib.nixosSystem {
            inherit (x86_64Base) system specialArgs;
            modules = x86_64Base.modules ++ [
              ./devices/household/benchtop
              platforms.desktop
              traits.base
              traits.hm
              traits.networking
              traits.plasma
              traits.tz_us_pacific
            ];
          };
        };
  };
}

