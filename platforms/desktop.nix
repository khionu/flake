{ ... }: {
  meta.properties = [ "platform.desktop" ];

  services.printing.enable = true;
  hardware.enableAllFirmware = true;
}
