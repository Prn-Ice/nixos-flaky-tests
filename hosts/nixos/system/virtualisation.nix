{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome-boxes
    virt-manager
    spice
    spice-gtk
    spice-protocol
  ];

  # Make android-studio happy about license
  nixpkgs.config.android_sdk.accept_license = true;

  virtualisation = {
    libvirtd = {
      enable = true;
    };

    spiceUSBRedirection.enable = true;

    # docker = {
    #   enable = true;
    #   autoPrune.enable = true;
    # };

    waydroid.enable = true;
  };
}
