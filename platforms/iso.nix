{ config, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5.nix> ];

  environment.systemPackages = with pkgs; [
    neovim ripgrep git du-dust eza fido2luks
  ];

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = [ "nixos" ];

  nixpkgs.config.allowUnfree = true;
}
