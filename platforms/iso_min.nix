{ config, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix> ];

  environment.systemPackages = with pkgs; [
    neovim ripgrep git du-dust eza fido2luks
  ];

  programs._1password.enable = true;

  nixpkgs.config.allowUnfree = true;
}
