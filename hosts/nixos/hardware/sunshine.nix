{
  pkgs,
  config,
  lib,
  ...
}:
let
  nvidiaConnector = "DP-1";
  amdConnector = "eDP-2"; # sometimes "eDP-1" for some reason
  monitorIndex = "1";
  waylandDisplayIndex = "2";
  edidFile = ./SAMTULT.bin;

  # Check if nvidia-sunshine tag is present
  isSunshineEnabled = builtins.elem "nvidia-sunshine" config.system.nixos.tags;
in
{
  # Only apply the configuration if the nvidia-sunshine tag is present
  config = lib.mkIf isSunshineEnabled {
    # Sunshine
    services.sunshine = {
      enable = true;
      capSysAdmin = true;
      openFirewall = true;
      settings = {
        # Try to use nvidia GPU for encoding
        # If this value is not set, Sunshine falls back to vaapi
        encoder = "nvenc";
        # Forces Sunshine to use the virtual display
        # If this value is not set, Sunshine will use the primary display (mirrored)
        # If this value is set and the display is not available, Sunshine will fail to start
        output_name = monitorIndex;
      };
      applications = {
        env = {
          PATH = "$(PATH):$(HOME)/.local/bin";
        };
        apps = [
          {
            name = "Desktop";
            image-path = "desktop.png";
            prep-cmd = [
              {
                # Extend built-in display
                do = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.${nvidiaConnector}.mirror.none output.${nvidiaConnector}.scale.2 output.${nvidiaConnector}.position.0,-700 output.${amdConnector}.position.1480,0";
                # Mirror built-in display
                undo = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.${nvidiaConnector}.mirror.${amdConnector} output.${nvidiaConnector}.scale.2 output.${amdConnector}.position.0,0";
              }
            ];
          }
          {
            name = "Steam Big Picture";
            image-path = "steam.png";
            detached = [ "steam steam://open/bigpicture" ];
            auto-detach = "true";
            wait-all = "true";
            exit-timeout = "5";
          }
        ];
      };
    };

    systemd.user.services.sunshine = {
      serviceConfig = {
        Environment = [
          "WAYLAND_DISPLAY=wayland-0"
          "DISPLAY=:${waylandDisplayIndex}"
          "__NV_PRIME_RENDER_OFFLOAD=1"
        ];
        # Enable virtual display and mirror built-in display
        ExecStartPre = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.${nvidiaConnector}.enable output.${nvidiaConnector}.mirror.${amdConnector} output.${nvidiaConnector}.scale.2 output.${amdConnector}.position.0,0";

        # Disable virtual display after Sunshine stops
        ExecStopPost = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.${nvidiaConnector}.disable output.${amdConnector}.position.0,0";
      };
    };

    # Virtual Display
    hardware.display = {
      edid.packages = [
        (pkgs.runCommand "edid.bin" { } ''
          mkdir -p $out/lib/firmware/edid
          cp ${edidFile} $out/lib/firmware/edid/virtual-display.bin
        '')
      ];

      outputs.${nvidiaConnector} = {
        edid = "virtual-display.bin";
        mode = "2960x1848@120e";
      };
    };

    environment.systemPackages = with pkgs; [
      eglexternalplatform
      egl-wayland
    ];
  };
}

# TODO
# - Test, sddm set default display
# - GPU accelerated VM
# - Per monitor virtual display control
# - Sunshine macos

# Sources:
# https://github.com/WoLeo-Z/nix-config/blob/b50854a9a073be081b8f550e9e0be91de037cc63/modules/services/sunshine.nix#L22
# https://github.com/c2vi/nixos/blob/60b70c23d2c6ab07cb4b8e2eb9efc62e2eaacd57/hosts/main.nix#L66
# https://github.com/powwu/nixos/blob/4711d3fcfe324e6773ad30c949aa943d30d1205e/extra/sunshine.nix#L9
# https://github.com/stevenpetryk/dotfiles/blob/7e878e892a2333be9cfcf05431b686d2365df990/nixos/gigante/configuration.nix#L94
# https://github.com/MichaelOwenDyer/dotfiles/blob/52d60586614e7c8a35429384c85aaa47f1b74cfc/system/modules/local-streaming-network.nix#L99
# https://www.azdanov.dev/articles/2025/how-to-create-a-virtual-display-for-sunshine-on-arch-linux
# https://discourse.nixos.org/t/copying-custom-edid/31593/25

# Commands:
# List available outputs: type "/sys/class/drm/card" then press tab
# Find a free GPU output: for p in /sys/class/drm/*/status; do con=${p%/status}; echo -n "${con#*/card?-}: "; cat $p; done
# Get monitors with ids: kscreen-console
