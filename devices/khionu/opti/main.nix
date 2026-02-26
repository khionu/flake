{ ... }: { config = {
  networking.hostName = "khionu-opti";
  
  users.users.khionu = {
    isNormalUser = true;
    password = "changeme1234";
    extraGroups = [ "wheel" "networkmanager" ];
  };
};}
