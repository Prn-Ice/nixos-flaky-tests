{ pkgs, ... }:

{
  users.users.prnice = {
    isNormalUser = true;
    description = "Prince Nna";
    extraGroups = [ "qemu-libvirtd" "libvirtd" "networkmanager" "wheel" "adbusers" "disk" ];
  };

  # Set default shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
}
