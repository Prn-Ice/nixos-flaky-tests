{ config, pkgs, ... }:

{
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Enable the KDE Plasma Desktop Environment.
    desktopManager.plasma5.enable = true;

    displayManager = {
      sddm.enable = true;
      sddm.enableHidpi = true;
      defaultSession = "plasmawayland";
    };
  };
}
