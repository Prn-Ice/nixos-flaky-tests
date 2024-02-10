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

  # Add VFIO boot option
  specialisation."VFIO".configuration = {
    system.nixos.tags = [ "with-vfio" ];
    vfio.enable = true;
  };
}
