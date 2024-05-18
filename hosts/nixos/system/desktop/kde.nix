{ pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    # there is some weirdness happening here
    # https://github.com/NixOS/nixpkgs/issues/160923
    xdgOpenUsePortal = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.displayManager = {
    sddm.wayland.enable = true;
    sddm.enable = true;
    sddm.enableHidpi = true;
    defaultSession = "plasma";
  };

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager = {
    plasma6.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kdePackages.yakuake
    kdePackages.sddm-kcm
  ];
}
