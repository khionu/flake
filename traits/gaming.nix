{ pkgs, ... }: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    gamescopeSession.enable = true;
    # package = pkgs.steam.override {
    #   withPrimus = true;
    #   extraPkgs = with pkgs; [ bumblebee glxinfo ];
    # };
  };
  programs.gamescope.enable = true;
  programs.gamescope.capSysNice = true;
}
