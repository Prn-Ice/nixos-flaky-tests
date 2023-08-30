{ pkgs, ... }:

{
  users.users.prnice = {
    isNormalUser = true;
    description = "Prince Nna";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "adbusers" ];
  };

  # Set default shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
}
