{ inputs, pkgs, ... }: {
  imports = [
    # ./cloudflare-warp.nix
    ./ssh.nix
    (inputs.legion-frontend + "/packaging/nixos/legion-telemetry.nix")
  ];

  services.legionTelemetry = {
    enable = true;
    users = [ "prnice" ];
  };

  services.legionControl = {
    enable = true;
    backendPackage = pkgs.lenovo-legion;
  };
}
