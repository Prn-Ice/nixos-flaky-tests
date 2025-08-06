{
  pkgs,
  config,
  lib,
  ...
}:
let
  # Check if nvidia-sunshine tag is present
  isSunshineEnabled = builtins.elem "nvidia-sunshine" config.system.nixos.tags;
in
{
  # Only apply the configuration if the nvidia-sunshine tag is present
  config = lib.mkIf isSunshineEnabled {
    # Create the connector detection service
    systemd.services.connector-detection = {
      description = "Detect GPU connectors for Sunshine";
      wantedBy = [ "multi-user.target" ];
      after = [ "graphical-session.target" ];
      path = with pkgs; [ pciutils gawk bash ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.bash}/bin/bash ${../../../scripts/detect-connectors.sh}";
        User = "root";
        Group = "root";
      };
    };

    # Create the output directory with proper permissions
    systemd.tmpfiles.rules = [
      "d /home/prnice/Dotfiles/nixos-flaky-tests/generated 0755 prnice users -"
    ];

    # Timer to run the detection periodically (in case hardware changes)
    systemd.timers.connector-detection = {
      description = "Run connector detection periodically";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "30s";
        OnUnitActiveSec = "5m";
        Unit = "connector-detection.service";
      };
    };
  };
}
