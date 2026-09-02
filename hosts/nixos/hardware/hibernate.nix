# Source:
# https://nixos.wiki/wiki/Hibernation
# https://discourse.nixos.org/t/is-it-possible-to-hibernate-with-swap-file/2852/5
{ pkgs, ... }:
let
  legionHibernateDiagnostics = pkgs.writeShellApplication {
    name = "legion-hibernate-diagnostics";
    runtimeInputs = with pkgs; [
      coreutils
      pciutils
      procps
      systemd
    ];
    text = builtins.readFile ../../../scripts/legion-hibernate-diagnostics.sh;
  };
in
{
  boot.initrd.systemd.enable = true;

  # Suspend first then hibernate when closing the lid
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";

  # Use s2idle (platform-level idle) for suspend
  boot.kernelParams = [ "mem_sleep_default=s2idle" ];

  # Define time delay for hibernation
  systemd.sleep.settings = {
    "Sleep" = {
      HibernateDelaySec = "30m";
      # Avoid firmware _PTS(4), which powers the detached NVIDIA device back on.
      HibernateMode = "shutdown";
      SuspendState = "mem";
    };
  };

  # Capture only hibernate transitions while user sessions are still frozen.
  environment.etc."systemd/system-sleep/legion-hibernate-diagnostics" = {
    source = "${legionHibernateDiagnostics}/bin/legion-hibernate-diagnostics";
    mode = "0755";
  };

  # Wire NVIDIA power management services into suspend-then-hibernate
  systemd.services.nvidia-suspend = {
    before = [ "systemd-suspend-then-hibernate.service" ];
    requiredBy = [ "systemd-suspend-then-hibernate.service" ];
  };
  systemd.services.nvidia-resume = {
    after = [ "systemd-suspend-then-hibernate.service" ];
    wantedBy = [ "systemd-suspend-then-hibernate.service" ];
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024; # 32GB in MB
    }
  ];
}
