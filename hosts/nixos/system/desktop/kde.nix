{ pkgs, ... }:

{
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
    kdePackages.sddm-kcm
    kdePackages.krecorder
    kdePackages.kget
    kdePackages.dragon
    kdePackages.kdenlive
    kdePackages.spectacle
    kdePackages.filelight
    haruna

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
