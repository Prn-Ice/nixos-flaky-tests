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
      # efiSysMountPoint = "/boot/efi";
    };

    # Uncomment before bios update
    # systemd-boot = {
    #   enable = true;

    #   # Limit the number of generations to keep
    #   configurationLimit = 10;
    # };

    grub = {
      efiSupport = true;
      useOSProber = true;
      device = "nodev";
      memtest86.enable = true;
      # efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
      theme = grub-theme;
    };
  };

  # Make sure our package is installed
  environment.systemPackages = [
    grub-theme
  ];

  # Pinned to 6.18 — linuxPackages_latest jumped to 7.1 which broke NVIDIA open driver 595.45.04
  # (linux/of_gpio.h removed in 7.x; nixpkgs hasn't patched NVIDIA for 7.x yet as of 2026-06-19)
  # Switch back to linuxPackages_latest once nixpkgs adds 7.x compat patches for NVIDIA 595.x
  # boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Previously confirmed working on 6.19+ (2026-04-07) — now EOL and removed from nixpkgs
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use 6.15 kernel
  # boot.kernelPackages = pkgs.linuxPackages_6_15;

  # Use 6.11.1 kernel (Pinned)
  # boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_11.override {
  #   argsOverride = rec {
  #     src = pkgs.fetchurl {
  #       url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
  #       sha256 = "sha256-Kjcjc7Th6vVfKi8QS/qRR37JsmOs+POu0I9Ni9x47j0=";
  #     };
  #     version = "6.11.1";
  #     modDirVersion = "6.11.1";
  #   };
  # });
}
