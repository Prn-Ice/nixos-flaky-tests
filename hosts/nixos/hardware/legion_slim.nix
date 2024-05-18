{ config, pkgs, ... }:
{
  # Tools for managing legion laptop hardware

  boot.extraModulePackages = with config.boot.kernelPackages; [ lenovo-legion-module ];

  environment.systemPackages = with pkgs; [
    lenovo-legion
  ];
}
