{ ... }: {
  meta.properties = [ "platform.laptop" ];
  
  services.printing.enable = true;
  hardware.enableAllFirmware = true;
}
