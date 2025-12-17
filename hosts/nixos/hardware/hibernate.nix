# Source:
# https://nixos.wiki/wiki/Hibernation
# https://discourse.nixos.org/t/is-it-possible-to-hibernate-with-swap-file/2852/5
{...}: {
  boot.initrd.systemd.enable = true;

  # Suspend first then hibernate when closing the lid
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";

  # suspend to RAM (deep) rather than `s2idle`
  boot.kernelParams = ["mem_sleep_default=s2idle"];

  # Define time delay for hibernation
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024; # 32GB in MB
    }
  ];
}
