{ ... }: {
  meta.properties = [ "trait.tailscale-ssh" ];
  
  services.tailscale.extraUpFlags = ["--ssh"];
}
