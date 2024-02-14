{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  imports = [
    ./gpu_passthrough.nix
    ./cpu.nix
    ./gpu.nix
  ];

  # Enable bluetooth
  hardware.bluetooth.enable = true;
}
