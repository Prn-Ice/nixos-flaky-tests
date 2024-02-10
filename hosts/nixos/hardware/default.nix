{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  imports = [
    ./cpu.nix
    ./gpu_passthrough.nix
    ./gpu.nix
  ];

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  # hardware.bluetooth.powerOnBoot = true;
}
