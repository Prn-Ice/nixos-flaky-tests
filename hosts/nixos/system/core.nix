{ lib, pkgs, ... }:

{
  # List services that you want to enable:

  # Enable fstrim for extending ssd life
  services.fstrim.enable = lib.mkDefault true;

  # When bios gets updated, grub breaks
  # Its difficult to fix grub when auth is controlled by fprint

  # Enable fingerprint reader
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd-tod;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-elan;
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable dconf
  programs.dconf.enable = true;

  # Enable adb
  programs.adb.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}
