{ pkgs, ... }:

{
  # Bootloader
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      efiSupport = true;
      device = "nodev";
    };
  };

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
