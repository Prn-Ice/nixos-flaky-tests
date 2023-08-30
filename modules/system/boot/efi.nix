{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;

      # Limit the number of generations to keep
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
