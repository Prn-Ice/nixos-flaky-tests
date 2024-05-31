{ pkgs, ... }:

{
  # rgb
  # services.udev.packages = [ pkgs.openrgb-with-all-plugins ];
  services.udev.packages = [ pkgs.openrgb ];
  # boot.kernelModules = [ "eeprom" "ee1004" "i2c-core" "i2c-dev" "i2c-piix4" ];
  boot.kernelModules = [ "i2c-dev" ];
  hardware.i2c.enable = true;

  environment.systemPackages = with pkgs; [
    i2c-tools
  ];

  # users.extraUsers.prnice = {
  #   extraGroups = [ "i2c" ];
  # };

  services = {
    hardware.openrgb = {
      enable = true;
      # motherboard = "amd";
      # package = pkgs.openrgb-with-all-plugins;
      package = pkgs.openrgb;
    };
  };
}
