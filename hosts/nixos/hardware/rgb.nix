{ pkgs, ... }:
{
  boot.kernelModules = [
    "i2c-core"
    "i2c-dev"
    "i2c-piix4"
  ];

  environment.systemPackages = with pkgs; [
    i2c-tools
  ];

  hardware.i2c.enable = true;

  users.extraUsers.prnice = {
    extraGroups = [ "i2c" ];
  };

  services.udev.packages = [ pkgs.openrgb-with-all-plugins ];

  services = {
    hardware.openrgb = {
      # Keep OpenRGB off AMDI0010:03 while testing CS35L41 probe failures.
      enable = false;
      motherboard = "amd";
      package = pkgs.openrgb-with-all-plugins;
    };
  };
}
