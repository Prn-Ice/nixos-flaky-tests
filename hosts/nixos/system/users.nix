{ pkgs, ... }:

{
  users.users.prnice = {
    isNormalUser = true;
    description = "Prince Nna";
    extraGroups = [ "qemu-libvirtd" "kvm" "libvirtd" "docker" "networkmanager" "wheel" "adbusers" "disk" ];
  };

  # Set default shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
}
