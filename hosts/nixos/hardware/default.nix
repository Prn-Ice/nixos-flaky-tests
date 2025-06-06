{ ... }:

{
  imports = [
    ./nvidia.nix
    ./no_nvidia.nix
    ./obs_webcam.nix
    # ./legion_slim.nix
    ./rgb.nix
    ./weylus.nix
  ];

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # √(3200² + 2000²) px / 16 in ≃ 236 dpi
  # services.xserver.dpi = 236;
}
