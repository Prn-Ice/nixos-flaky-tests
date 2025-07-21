# Source:
# https://nixos.wiki/wiki/Hibernation
# https://discourse.nixos.org/t/is-it-possible-to-hibernate-with-swap-file/2852/5
{...}: {
  boot.initrd.systemd.enable = true;

  # Suspend first then hibernate when closing the lid
  services.logind.lidSwitch = "suspend-then-hibernate";

  # Define time delay for hibernation
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
  '';

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024; # 32GB in MB
    }
  ];
}
