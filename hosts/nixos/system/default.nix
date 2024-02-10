{ config, pkgs, lib, ... }:

{
  imports = [
    ./core.nix
    ./boot/efi.nix
    ./desktop/kde.nix
    ./services/ssh.nix
    ./theme/sddm.nix

    ./custom_defaults.nix
    ./i18n.nix
    ./networking.nix
    ./nix.nix
    ./users.nix
    ./security.nix
    ./audio.nix
    ./fonts.nix
  ];

  # if use vscode in wayland, uncomment this line
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    kate
    yakuake
    linuxKernel.packages.linux_latest_libre.cpupower
    egl-wayland
    gnome.adwaita-icon-theme
    gnome.gnome-themes-extra
    gnome.gnome-boxes
    spice
    spice-gtk
    pop-gtk-theme
    xorg.libxcb
    xorg.libxcb.dev
    kdeconnect
    sddm-kcm
    partition-manager
    gparted
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
