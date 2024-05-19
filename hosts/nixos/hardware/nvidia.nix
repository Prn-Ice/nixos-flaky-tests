{ config, lib, pkgs, ... }:

let
  nvidiaConfig = {
    boot.initrd.kernelModules = [ "nvidia" ];

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware = {

      # Enable OpenGL
      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };

      nvidia = {
        # Modesetting is needed most of the time
        modesetting.enable = true;

        # Enable power management (do not disable this unless you have a reason to).
        # Likely to cause problems on laptops and with screen tearing if disabled.
        # Note: commented out cause of issues with sleep
        powerManagement = {
          enable = true;
        };

        # Fix wake from sleep issues
        # nvidiaPersistenced = false;

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
        package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;

        prime = {
          sync.enable = true;

          amdgpuBusId = "PCI:65:0:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };
    };

    # Packages related to NVIDIA graphics
    environment.systemPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      nvidia-system-monitor-qt

      # benchmark
      glmark2
      unigine-heaven
      phoronix-test-suite
    ];
  };
in
{
  # Nvidia dGPU is asleep by default but can be turned on with command
  specialisation = {
    nvidia-on-call.configuration = lib.mkMerge [
      nvidiaConfig
      {
        system.nixos.tags = [ "nvidia-on-call" ];
        hardware.nvidia = {
          prime.offload.enable = lib.mkForce true;
          prime.offload.enableOffloadCmd = lib.mkForce true;
          prime.sync.enable = lib.mkForce false;
        };
      }
    ];
  };

  # Nvidia dGPU is always on with this specialisation
  specialisation = {
    nvidia-always-on.configuration = nvidiaConfig;
  };
}
