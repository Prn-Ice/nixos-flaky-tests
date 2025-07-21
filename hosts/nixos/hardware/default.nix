{ ... }:

{
  imports = [
    ./nvidia.nix
    ./obs_webcam.nix
    ./legion_slim.nix
    ./rgb.nix
    ./weylus.nix
  ];

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # √(3200² + 2000²) px / 16 in ≃ 236 dpi
  # services.xserver.dpi = 236;

  # Set cursor size for GTK apps
  # On KDE cursor size is 24
  # At 175% scale, 42px is 24px * 1.75
  environment.sessionVariables = {
    XCURSOR_SIZE = "42";
  };
}
