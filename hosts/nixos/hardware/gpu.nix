{ config, lib, pkgs, ... }:

let
  buildNvidiaConfigs = if config.vfio.enable then false else true;

  # Define configurations to disable if VFIO is enabled
  nvidiaConfigs = {
    boot.initrd.kernelModules = [ "nvidia" ];
    boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

    # Enable OpenGL
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {

      # Modesetting is needed most of the time
      modesetting.enable = true;

      # Enable power management (do not disable this unless you have a reason to).
      # Likely to cause problems on laptops and with screen tearing if disabled.
      # Note: commented out cause of issues with sleep
      powerManagement = {
        enable = true;
        finegrained = true;
      };

      # Fix wake from sleep issues
      # nvidiaPersistenced = true;

      # Use the open source version of the kernel module ("nouveau")
      # Note that this offers much lower performance and does not
      # support all the latest Nvidia GPU features.
      # You most likely don't want this.
      # Only available on driver 515.43.04+
      open = false;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      prime = {
        reverseSync.enable = true;

        amdgpuBusId = "PCI:6:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
in
{
  # Apply the nvidiaConfigs configurations if VFIO is not enabled
  config = lib.mkIf buildNvidiaConfigs nvidiaConfigs;
}
