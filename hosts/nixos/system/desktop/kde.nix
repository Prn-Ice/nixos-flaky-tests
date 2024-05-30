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
    sddm.theme = "where_is_my_sddm_theme";
    # sddm.theme = "catppuccin-mocha";
  };

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager = {
    plasma6.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kdePackages.yakuake
    (pkgs.where-is-my-sddm-theme.override {
      # themeConfig.General = {
      #   background = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      #   backgroundMode = "none";
      # };
    })
    (
      catppuccin-sddm.override {
        flavor = "mocha";
        background = "${../theme/assets/wallpaper.png}";
        loginBackground = true;
      }
    )
  ];
}
