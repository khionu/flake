{ ... }: { config = {
  networking.firewall.checkReversePath = "loose";
  services.tailscale.enable = true;
};}
