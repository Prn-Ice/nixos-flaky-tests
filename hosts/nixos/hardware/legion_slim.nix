{ config, lib, pkgs, ... }:

{
  # Tools for managing legion laptop hardware

  # Fix sleep issue
  boot.blacklistedKernelModules = [ "ideapad_laptop" ];

  # Ignore sleep fix. For testing purposes only
  specialisation = {
    with-ideapad-laptop.configuration = {
      boot.blacklistedKernelModules = lib.mkForce (lib.filter (module: module != "ideapad_laptop") config.boot.blacklistedKernelModules);
    };
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [ lenovo-legion-module ];

  environment.systemPackages = with pkgs; [
    lenovo-legion
  ];
}
