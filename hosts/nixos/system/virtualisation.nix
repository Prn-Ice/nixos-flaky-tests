{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome.gnome-boxes
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-vdagent
    spice-protocol
    win-virtio
    win-spice
  ];

  virtualisation = {
    libvirtd = {
      enable = true;

      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };

      # qemuVerbatimConfig = ''
      #   nvram = [ "${pkgs.OVMF}/FV/OVMF.fd:${pkgs.OVMF}/FV/OVMF_VARS.fd" ]
      # '';
    };

    spiceUSBRedirection.enable = true;

    docker = {
      enable = true;
      autoPrune.enable = true;
    };
  };

  services.spice-vdagentd.enable = true;
}
