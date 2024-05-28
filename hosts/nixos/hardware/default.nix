{ config, pkgs, ... }:

# let
#   lenovo-speaker-fix = pkgs.callPackage ./audio/lenovo-16ARHA7_speaker-fix.nix {
#     # Make sure the module targets the same kernel as your system is using.
#     inherit (config.boot.kernelPackages) kernel;
#   };
# in
{
  imports = [
    ./nvidia.nix
    ./no_nvidia.nix
    ./legion_slim.nix
  ];

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # √(3200² + 2000²) px / 16 in ≃ 236 dpi
  # services.xserver.dpi = 236;

  # boot.extraModulePackages = [ lenovo-speaker-fix ];
}
