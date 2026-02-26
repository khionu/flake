{ lib, ... }:
{
  imports = [];

  options = {
    meta.properties = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = [ "platform.desktop" "trait.networking" ];
      description = "Properties that accumulate by enabling traits, platforms, etc";
    };
  }
}
