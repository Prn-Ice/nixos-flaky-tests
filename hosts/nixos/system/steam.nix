# Sources:
# https://nixos.wiki/wiki/Nvidia
# https://wiki.nixos.org/wiki/Steam
{
  lib,
  config,
  pkgs,
  ...
}:
with pkgs; let
  # Detect whether we are in the nvidia-offload specialisation
  # NOTE: Gamescope is broken when this is enabled
  isNvidiaOffload = builtins.elem "nvidia-offload" config.system.nixos.tags;

  # A generic function to patch the .desktop file of a given package.
  # It uses `sed` to find and replace a string in the application's .desktop file,
  # creating a new, high-priority derivation for the patched file.
  patchDesktop = pkg: appName: from: to:
    lib.hiPrio (
      pkgs.runCommand "$patched-desktop-entry-for-${appName}" {} ''
        ${coreutils}/bin/mkdir -p $out/share/applications
        ${gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
      ''
    );

  # Wraps a package to automatically use nvidia-offload if PRIME offload is enabled.
  # If `config.hardware.nvidia.prime.offload.enable` is true, it patches the
  # .desktop file to prepend "Exec=nvidia-offload ". Otherwise, it returns the
  # original package.
  GPUOffloadApp = pkg: desktopName:
    if config.hardware.nvidia.prime.offload.enable
    then (patchDesktop pkg desktopName "^Exec=" "Exec=nvidia-offload ")
    else pkg;

  steamPkg = pkgs.steam.override {
    extraEnv = {
      MANGOHUD = true;
      OBS_VKCAPTURE = true;

      # https://www.reddit.com/r/linux_gaming/comments/k6lgrl/is_there_a_way_to_enable_anisotrophic_filtering/
      # For anisotropic filtering with AMD add this to your launch script for the game or to $HOME/.profile
      # Vulkan
      RADV_TEX_ANISO = 16;
      # OpenGL
      AMD_TEX_ANISO = 16;
    };
  };
in {
  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
      # for Prime render offload on Nvidia laptops.
      # Also requires `hardware.nvidia.prime.offload.enable`.
      env = lib.mkIf isNvidiaOffload {
        __NV_PRIME_RENDER_OFFLOAD = "1";
        __VK_LAYER_NV_optimus = "NVIDIA_only";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };
    };
    steam = {
      enable = true;
      extest.enable = true;
      package = steamPkg;
      extraPackages = with pkgs; [
        mangohud
        gamescope
        libnma
      ];
      gamescopeSession = {
        enable = true;
        # Args to pass to gamescope
        args = [
          "--adaptive-sync" # VRR support
          "--hdr-enabled"
          "--mangoapp" # performance overlay
          "--rt"
          "--steam"
        ];
        # Args to pass to steam
        steamArgs = [
          "-tenfoot"
          "-pipewire-dmabuf"
        ];
      };
    };
  };

  # Not sure what this does, maybe remove
  services.getty.autologinUser = "prnice";

  # If nvidia offload is enabled, install our patched .desktop file.
  # This will be found by the desktop environment and override the default one,
  # effectively launching Steam with nvidia-offload.
  environment.systemPackages = lib.mkIf config.hardware.nvidia.prime.offload.enable [
    (GPUOffloadApp steamPkg "steam")
  ];
}
