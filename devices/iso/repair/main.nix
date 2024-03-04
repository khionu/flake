{ config, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5.nix> ];

  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
    displayManager = {
      sddm.enable = true;
      autoLogin = {
        enable = true;
        user = "nixos";
      };
    };
  };

  # This allows wheel users to do anything. DO NOT USE
  # OUTSIDE OF INSTALL MEDIUMS
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  networking.networkmanager.enable = true;

  powerManagement.enable = true;
  hardware.pulseaudio.enable = true;

  boot.plymouth.enable = true;

  environment.systemPackages = with pkgs; [
    neovim ripgrep git du-dust eza fido2luks firefox rsync glxinfo
  ];

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = [ "nixos" ];

  nixpkgs.config.allowUnfree = true;
}
