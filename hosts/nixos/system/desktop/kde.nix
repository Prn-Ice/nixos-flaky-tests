{ config, pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    # there is some weirdness happening here
    # https://github.com/NixOS/nixpkgs/issues/160923
    xdgOpenUsePortal = true;
  };

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
