{
  lib,
  config,
  pkgs,
  ...
}:
{
  # Pin upstream LenovoLegionLinux with the Kernel 7 fixes (PRs #423 and #434).
  # Drops the fork's read_file_fix branch: it was based on pre-Kernel-7 upstream
  # and its EC fan-curve access for M1CN can be re-added later if WMI3 fails.
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
          owner = "johnfanv2";
          repo = "LenovoLegionLinux";
          rev = "3893e203332d60effea688a3043abd86046997ad";
          hash = "sha256-e/h/n4cYw/T+6iroF0SD564MNbi6aX+usVp0+e5LNak=";
        };
      in
      rec {
        lenovo-legion = prev.lenovo-legion.overrideAttrs (old: {
          src = lenovo-legion-src;

          propagatedBuildInputs = with pkgs; [
            python3Packages.qt6.qtbase
            python3Packages.pyqt6
            python3Packages.argcomplete
            python3Packages.pyyaml
            python3Packages.darkdetect
            libxcb
            python3Packages.pillow
          ];

          postPatch = ''
            substituteInPlace legion_linux/legion.py \
              --replace-fail "/etc/legion_linux" "$out/share/legion_linux"
            substituteInPlace legion_linux/legion_gui.desktop \
              --replace-fail "Icon=/usr/share/pixmaps/legion_logo.png" "Icon=legion_logo"
          '';
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

  # Serialize access to the CS35L41 I2C bus with the AMD PSP on this model only.
  boot.kernelPatches = [
    {
      name = "legion-slim-amdpsp-i2c";
      patch = ./legion-slim-amdpsp-i2c.patch;
      structuredExtraConfig = {
        CRYPTO_DEV_CCP_DD = lib.kernel.yes;
        I2C_DESIGNWARE_AMDPSP = lib.kernel.yes;
      };
    }
  ];

  # zenpower experiment
  boot.kernelModules = [ "zenpower" ];

  boot.blacklistedKernelModules = [
    "k10temp"
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

# TODO:
# - Fix hybrid mode activation script
# - Alternative to disabled amp

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
