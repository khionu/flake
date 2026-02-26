{ ... }: {
  meta.properties = [ "trait.tailscale" ];
  networking.firewall.checkReversePath = "loose";
  services.tailscale.enable = true;
}
