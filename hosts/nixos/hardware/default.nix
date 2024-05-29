{ pkgs, ... }:

{
  imports = [
    ./nvidia.nix
    ./no_nvidia.nix
    ./legion_slim.nix
  ];

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # √(3200² + 2000²) px / 16 in ≃ 236 dpi
  # services.xserver.dpi = 236;

  # rgb
  services.udev.packages = [ pkgs.openrgb-with-all-plugins ];
  boot.kernelModules = [ "eeprom" "ee1004" "i2c-core" "i2c-dev" "i2c-piix4" ];
  hardware.i2c.enable = true;

  environment.systemPackages = with pkgs; [
    i2c-tools
  ];

  users.extraUsers.prnice = {
    extraGroups = [ "i2c" ];
  };

  services = {
    hardware.openrgb = {
      enable = true;
      motherboard = "amd";
      package = pkgs.openrgb-with-all-plugins;
    };
  };
}
