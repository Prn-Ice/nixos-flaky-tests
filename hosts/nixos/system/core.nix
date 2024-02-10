{ config, pkgs, lib, ... }:

{
  # List services that you want to enable:

  # Asus linux stuff
  services.supergfxd.enable = true;
  # systemd.services.supergfxd.path = [ pkgs.pciutils ];
  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
  };

  # Enable the cpu management tool 
  services.cpupower-gui.enable = true;

  # Enable fstrim for extending ssd life
  services.fstrim.enable = lib.mkDefault true;

  # Enable fingerprint support
  # see https://wiki.archlinux.org/title/fprint for usage
  # services.fprintd.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable dconf
  programs.dconf.enable = true;

  # Enable adb
  programs.adb.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };


  # Enable virtualisation
  virtualisation = {
    libvirtd.enable = true;
    docker = {
      enable = true;
      autoPrune.enable = true;
    };
  };
  programs.virt-manager.enable = true;
}
