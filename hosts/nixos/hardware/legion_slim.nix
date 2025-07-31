{
  lib,
  config,
  pkgs,
  ...
}:
{
  # NOTE: Experiments start

  # With the kernel module loaded, power-profiles change in response to FN+Q
  # Needs a restart if you make changes to the module

  # Systemd service test
  #systemd.services.yoga-bass-speaker-fix = {
  #  after = ["systemd-suspend.service" "systemd-hibernate.service"];
  #  requiredBy = ["systemd-suspend.service" "systemd-hibernate.service"];
  #  wantedBy = ["multi-user.target"];
  #  description = "Triggers the yoga7 bass-speaker toggle with i2c on boot and resume.";
  #  serviceConfig = {
  #    Type = "oneshot";
  #    User = "root";
  #    ExecStart = pkgs.writeShellScript "yoga-bass-speaker-fix" ''
  #      ${pkgs.i2c-tools}/bin/i2cset -y 3 0x48 0x2 0 && echo "Successfully applied speaker fix!"
  #    '';
  #  };
  #};

  # Other options experiment
  # modinfo snd_hda_scodec_cs35l41
  # options snd_hda_scodec_cs35l41 firmware_autostart=0

  # Sources:
  # https://gist.github.com/felipelalli/6179aac72735fd35ea3a9854beb490e5
  # https://github.com/NixOS/nixos-hardware/blob/master/system76/darp6/default.nix
  # hardware.firmware = [
  #   (pkgs.writeTextFile {
  #     name = "legion-alc287-patch";
  #     destination = "/lib/firmware/legion-alc287-patch";
  #     text = ''
  #       [codec]
  #       0x10ec0287 0x17aa38b6 0

  #       [model]
  #       auto

  #       [verb]
  #       0x20 0x500 0x24
  #       0x20 0x400 0x41
  #       0x20 0x500 0x26
  #       0x20 0x400 0x2
  #       0x20 0x400 0x0
  #       0x20 0x400 0x0
  #       0x20 0x4b0 0x20
  #       0x20 0x500 0x24
  #       0x20 0x400 0x42
  #       0x20 0x500 0x26
  #       0x20 0x400 0xc
  #       0x20 0x400 0x0
  #       0x20 0x400 0x2a
  #       0x20 0x4b0 0x20
  #       0x20 0x500 0x26
  #       0x20 0x400 0x2
  #       0x20 0x400 0x0
  #       0x20 0x400 0x0
  #       0x20 0x4b0 0x20

  #       [hint]
  #       auto_mute = no
  #     '';
  #   })
  # ];

  # boot.extraModprobeConfig = ''
  #   options snd_hda_intel model=auto patch=legion-alc287-patch
  # '';

  # NOTE: Experiments end

  # Override package to use my branch, test fan read fix
  nixpkgs.overlays = [
    (
      final: prev:
      let
        # For local development
        # lenovo-legion-src = lib.fileset.toSource {
        #   root = /home/prnice/Projects/personal/LenovoLegionLinux;
        #   fileset = lib.fileset.fromSource /home/prnice/Projects/personal/LenovoLegionLinux;
        # };
        lenovo-legion-src = prev.fetchFromGitHub {
          owner = "Prn-Ice";
          repo = "LenovoLegionLinux";
          rev = "read_file_fix";
          hash = "sha256-Wp/Kha5Wa+XJnQYZt8uzaWwkf9uPllp2TIXIVz60eqQ=";
        };
      in
      rec {
        lenovo-legion = prev.lenovo-legion.overrideAttrs (old: {
          src = lenovo-legion-src;

          propagatedBuildInputs = with pkgs; [
            python3Packages.pyqt6
            python3Packages.argcomplete
            python3Packages.pyyaml
            python3Packages.darkdetect
            xorg.libxcb
            python3Packages.pillow
          ];
        });

        lenovo-legion-module = prev.lenovo-legion-module.overrideAttrs (old: {
          src = lenovo-legion-src;

          sourceRoot = "${lenovo-legion.src.name}/kernel_module";
        });
      }
    )
  ];

  boot.extraModulePackages = with config.boot.kernelPackages; [
    lenovo-legion-module
    zenpower
  ];

  # zenpower experiment
  boot.kernelModules = [ "zenpower" ];

  # Blacklisting this stops the annoying i2c error messages
  # Also stops sound from working
  boot.blacklistedKernelModules = [
    "k10temp"
    "snd_hda_scodec_cs35l41_i2c"
  ];

  environment.systemPackages = with pkgs; [
    lenovo-legion
  ];

  system.activationScripts.disableHybridMode =
    lib.mkIf (lib.elem "nvidia-only" config.system.nixos.tags)
      {
        text = ''
          echo "nvidia-only tag detected, disabling hybrid graphics mode..."
          ${pkgs.lenovo-legion}/bin/legion_cli hybrid-mode-disable
        '';
        deps = [ "users" ];
      };

  system.activationScripts.enableHybridMode =
    lib.mkIf (lib.elem "no-nvidia" config.system.nixos.tags)
      {
        text = ''
          echo "no-nvidia tag detected, enabling hybrid graphics mode..."
          ${pkgs.lenovo-legion}/bin/legion_cli hybrid-mode-enable
        '';
        deps = [ "users" ];
      };
}
