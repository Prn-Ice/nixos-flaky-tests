{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome.gnome-boxes
    virt-manager
    spice
    spice-gtk
    spice-vdagent
    spice-protocol
  ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = { };
    };

    spiceUSBRedirection.enable = true;

    docker = {
      enable = true;
      autoPrune.enable = true;
    };
  };

  services.spice-vdagentd.enable = true;
}
