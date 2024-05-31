{ pkgs, ... }:

let
  grub-theme = pkgs.sleek-grub-theme.override {
    withStyle = "dark";
    withBanner = "Choose Your Destiny"; 
  };
in
{
  # Bootloader
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      efiSupport = true;
      useOSProber = true;
      device = "nodev";
      memtest86.enable = true;
      theme = grub-theme;
    };
  };

  # Make sure our package is installed
  environment.systemPackages = [
    grub-theme
  ];

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
