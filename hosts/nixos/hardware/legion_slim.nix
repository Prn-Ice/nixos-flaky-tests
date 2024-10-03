{ config, lib, pkgs, ... }:

{
  # Tools for managing legion laptop hardware

  # Default package fails to build
  # Override package to use my branch and remove broken postPatch step
  nixpkgs.overlays = [
    (final: prev: {
      lenovo-legion = prev.lenovo-legion.overrideAttrs (old: {
        src = prev.fetchFromGitHub {
          owner = "Prn-Ice";
          repo = "LenovoLegionLinux";
          rev = "18c88217c13829df78ad135b6582207fcb2757ea";
          hash = "sha256-mGYm5SPnji4SntZiOE2RxuaV0Qex+Wuhrs+kME4hfyQ=";
        };

        postPatch = ''
          substituteInPlace ./setup.cfg \
            --replace-fail "_VERSION" "0.0.12"
          substituteInPlace ./legion_linux/legion.py \
            --replace-fail "/etc/legion_linux" "$out/share/legion_linux"
          substituteInPlace ./legion_linux/legion_gui.desktop \
            --replace-fail "Icon=/usr/share/pixmaps/legion_logo.png" "Icon=legion_logo"
        '';
      });
    })
  ];

  # Fix sleep issue
  boot.blacklistedKernelModules = [ "ideapad_laptop" ];

  # Ignore sleep fix. For testing purposes only
  specialisation = {
    with-ideapad-laptop.configuration = {
      boot.blacklistedKernelModules = lib.mkForce (lib.filter (module: module != "ideapad_laptop") config.boot.blacklistedKernelModules);
    };
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [ lenovo-legion-module ];

  environment.systemPackages = with pkgs; [
    lenovo-legion
  ];
}
