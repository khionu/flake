{  ... }: { config = {
  networking.networkmanager.enable = true;
  # Disabled because it can make rebuild fail if it takes too long to reconnect to the internet
  systemd.services.NetworkManager-wait-online.enable = false;
};}
