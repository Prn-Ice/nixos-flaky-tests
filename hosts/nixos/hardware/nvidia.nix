# Sources:
# https://nixos.wiki/wiki/Nvidia
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Detect whether we are in the no-nvidia specialisation
  isNoNvidia = builtins.elem "no-nvidia" config.system.nixos.tags;

  # Common NVIDIA configuration
  nvidiaConfig = {
    # Load kernel modules early
    boot.initrd.kernelModules = [ "nvidia" ];

    # May help, remove if something is off
    boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

    # Load NVIDIA driver for Xorg and Wayland
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware = {
      # Enable OpenGL
      graphics = {
        enable = true;
        enable32Bit = true;
      };

      nvidia = {
        # Driver package (change if you need a specific version)
        package = config.boot.kernelPackages.nvidiaPackages.beta;
        # package = config.boot.kernelPackages.nvidiaPackages.stable;

        # Enable KMS
        modesetting.enable = true;

        # Power-management (recommended on laptops)
        powerManagement.enable = true;

        # Use the NVidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of
        # supported GPUs is at:
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
        # Only available from driver 515.43.04+
        open = true;

        # Expose nvidia-settings GUI
        nvidiaSettings = true;

        # This makes things worse.
        # The GPU is always in the D0 state, power draw reported by batmon is ~20w.
        # Without this, the GPU can go into lower states(eg D3cold) and the power draw is ~13w.
        # powerManagement.finegrained = lib.mkForce true;

        # Default to PRIME offload
        prime = {
          # sync.enable = true;
          offload.enable = true;
          offload.enableOffloadCmd = true;
          amdgpuBusId = "PCI:65:0:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };

      # Container toolkit (used by Docker, Podman, etc.)
      nvidia-container-toolkit.enable = true;
    };

    # NVIDIA-related userland packages
    environment.systemPackages = with pkgs; [
      nvidia-system-monitor-qt

      # Benchmarks
      glmark2
      # Currently broken
      # unigine-heaven
      phoronix-test-suite
    ];
  };

  # Configuration that *disables* NVIDIA entirely
  noNvidiaConfig = {
    # Tag this configuration so other modules can detect the disabled profile
    system.nixos.tags = [ "no-nvidia" ];

    # Black-list NVIDIA & nouveau modules
    boot.extraModprobeConfig = ''
      blacklist nouveau
      options nouveau modeset=0
    '';

    boot.blacklistedKernelModules = [
      "nouveau"
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
    ];

    services.udev.extraRules = ''
      # Remove NVIDIA USB xHCI Host Controller devices, if present
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
      # Remove NVIDIA USB Type-C UCSI devices, if present
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
      # Remove NVIDIA Audio devices, if present
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
      # Remove NVIDIA VGA/3D controller devices
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
    '';
  };
in
lib.mkMerge [
  # Base NVIDIA config (conditionally enabled)
  (lib.mkIf (!isNoNvidia) nvidiaConfig)

  # Specialisations (always defined regardless of base config)
  {
    specialisation = {
      # NVIDIA Only (dGPU always on). Use legion_cli hybrid-mode-disable to disable hybrid mode
      nvidia-only.configuration = lib.mkMerge [
        nvidiaConfig
        {
          system.nixos.tags = [ "nvidia-only" ];
        }
      ];

      # NVIDIA with sunshine server
      nvidia-sunshine.configuration = lib.mkMerge [
        nvidiaConfig
        {
          system.nixos.tags = [ "nvidia-sunshine" ];
        }
      ];

      # Disable NVIDIA completely
      no-nvidia.configuration = noNvidiaConfig;
    };
  }
]
