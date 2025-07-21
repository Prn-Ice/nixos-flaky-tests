{
  lib,
  pkgs,
  inputs,
  ...
}: {
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

  security.pam.services = {
    # Use fingerprint for sudo
    sudo.fprintAuth = true;
    # But not for login
    login.fprintAuth = false;
    sddm.fprintAuth = false;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable dconf
  programs.dconf.enable = true;

  # Enable adb
  programs.adb.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable nix-ld
  programs.nix-ld.enable = true;
  environment.systemPackages = [
    inputs.nix-alien.packages.${pkgs.system}.nix-alien
  ];
  # environment.variables = {
  #   NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
  #     pkgs.stdenv.cc.cc.lib
  #     pkgs.zlib
  #     pkgs.libGL
  #     pkgs.openssl
  #     # add here the libraries you want...
  #   ];
  #   NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
  # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}
