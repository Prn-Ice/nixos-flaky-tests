{pkgs, ...}: {
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
    ];
    # there is some weirdness happening here
    # https://github.com/NixOS/nixpkgs/issues/160923
    xdgOpenUsePortal = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.displayManager = {
    sddm.wayland.enable = true;
    sddm.settings.General.DisplayServer = "wayland";
    sddm.enable = true;
    sddm.enableHidpi = true;
    defaultSession = "plasma";
    sddm.theme = "where_is_my_sddm_theme";
    # sddm.theme = "catppuccin-mocha";
  };

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager = {
    plasma6.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kdePackages.yakuake
    kdePackages.krecorder
    kdePackages.kget
    kdePackages.dragon
    kdePackages.kdenlive
    kdePackages.spectacle
    kdePackages.filelight

    kdePackages.kcalc # Calculator
    kdePackages.kcharselect # Tool to select and copy special characters from all installed fonts
    kdePackages.kcolorchooser # A small utility to select a color
    kdePackages.kolourpaint # Easy-to-use paint program
    kdePackages.ksystemlog # KDE SystemLog Application
    kdePackages.sddm-kcm # Configuration module for SDDM
    kdiff3 # Compares and merges 2 or 3 files or directories
    kdePackages.isoimagewriter # Optional: Program to write hybrid ISO files onto USB disks
    kdePackages.partitionmanager # Optional Manage the disk devices, partitions and file systems on your computer
    hardinfo2 # System information and benchmarks for Linux systems
    haruna # Open source video player built with Qt/QML and libmpv
    wayland-utils # Wayland utilities
    wl-clipboard # Command-line copy/paste utilities for Wayland

    # Theme packages
    (pkgs.where-is-my-sddm-theme.override {
      # themeConfig.General = {
      #   background = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      #   backgroundMode = "none";
      # };
    })
    (
      catppuccin-sddm.override {
        flavor = "mocha";
        background = "${../theme/assets/legion_armored_soldier.png}";
        loginBackground = true;
      }
    )
  ];
}
