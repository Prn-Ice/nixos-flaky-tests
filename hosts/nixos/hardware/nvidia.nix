{
  config,
  lib,
  pkgs,
  ...
}: let
  # Detect whether we are in the no-nvidia specialisation
  isNoNvidia = builtins.elem "no-nvidia" config.system.nixos.tags;

  # Common NVIDIA configuration
  nvidiaConfig = {
    # Load kernel modules early
    boot.initrd.kernelModules = ["nvidia"];

    # Load NVIDIA driver for Xorg and Wayland
    services.xserver.videoDrivers = ["nvidia"];

    hardware = {
      # Enable OpenGL
      graphics = {
        enable = true;
        enable32Bit = true;
      };

      nvidia = {
        # Driver package (change if you need a specific version)
        package = config.boot.kernelPackages.nvidiaPackages.beta;

        # Enable KMS
        modesetting.enable = true;

        # Power-management (recommended on laptops)
        powerManagement.enable = true;

        # Do NOT use the open-source variant (nouveau)
        open = false;

        # Expose nvidia-settings GUI
        nvidiaSettings = true;

        # Default to PRIME sync
        prime = {
          sync.enable = true;
          amdgpuBusId = "PCI:65:0:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };

      # Container toolkit (used by Docker, Podman, etc.)
      nvidia-container-toolkit.enable = true;
    };

    # NVIDIA-related userland packages
    environment.systemPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      nvidia-system-monitor-qt

      # Benchmarks
      glmark2
      unigine-heaven
      phoronix-test-suite
    ];
  };

  # Configuration that *disables* NVIDIA entirely
  noNvidiaConfig = {
    # Tag this configuration so other modules can detect the disabled profile
    system.nixos.tags = ["no-nvidia"];

    # Black-list NVIDIA & nouveau modules
    boot.extraModprobeConfig = ''
      blacklist nouveau
      options nouveau modeset=0
    '';

    boot.blacklistedKernelModules = ["nouveau" "nvidia" "nvidia_drm" "nvidia_modeset"];

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
        # 1. Disable NVIDIA completely
        no-nvidia.configuration = noNvidiaConfig;

        # 2. PRIME Offload (dGPU off until explicitly used)
        nvidia-offload.configuration = lib.mkMerge [
          nvidiaConfig
          {
            system.nixos.tags = ["nvidia-offload"];
            hardware.nvidia = {
              prime.offload.enable = lib.mkForce true;
              prime.offload.enableOffloadCmd = lib.mkForce true;
              prime.sync.enable = lib.mkForce false;
            };
          }
        ];
      };
    }
  ]
