{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome-boxes
    virt-manager
    spice
    spice-gtk
    spice-protocol
  ];

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
