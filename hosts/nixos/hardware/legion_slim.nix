{ config, pkgs, ... }:

{
  # Tools for managing legion laptop hardware

  # fix sleep issue
  boot.blacklistedKernelModules = [ "ideapad_laptop" ];

  boot.extraModulePackages = with config.boot.kernelPackages; [ lenovo-legion-module ];

  environment.systemPackages = with pkgs; [
    lenovo-legion
  ];
}
