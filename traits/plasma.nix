{ pkgs, ... }: {
  xdg.mime.enable = true;
  xdg.portal.enable = true;

  services.xserver.enable = true;
  services.xserver.desktopManager = {
    plasma5.enable = true;
    plasma5.useQtScaling = true;
  };
  services.xserver.displayManager = {
    sddm.enable = true;
    sddm.autoNumlock = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  programs.noisetorch.enable = true;
 
  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [ (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; }) ];
    fontconfig.defaultFonts.monospace = [ "Berkeley Mono Variable" ];
    fontconfig.defaultFonts.emoji = [ "NerdFontsSymbolsOnly" ];
  };
}
