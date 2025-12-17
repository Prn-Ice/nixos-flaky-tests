{ pkgs, ... }:
{
  boot.kernelModules = [
    "i2c-core"
    "i2c-dev"
    "i2c-piix4"
  ];

  environment.systemPackages = with pkgs; [
    i2c-tools
  ];

  nixpkgs.overlays = [
    (final: prev: {
      openrgb = prev.openrgb.overrideAttrs (old: {
        src = prev.fetchFromGitLab {
          owner = "CalcProgrammer1";
          repo = "OpenRGB";
          rev = "6e3271fe95178cebb6c0389aef61d9c9fa66eb0a";
          hash = "sha256-brEt1DLAEn9qfFpw9SR40TocKPG6ku5u57wwEZpyHHo=";
        };
        postPatch = ''
          patchShebangs scripts/build-udev-rules.sh
          substituteInPlace scripts/build-udev-rules.sh \
            --replace-warn '/usr/bin/env chmod' '${prev.coreutils}/bin/chmod'
        '';
        patches = [ ];
      });
      openrgb-plugin-effects = prev.openrgb-plugin-effects.overrideAttrs (old: {

        src = prev.fetchFromGitLab {
          owner = "OpenRGBDevelopers";
          repo = "OpenRGBEffectsPlugin";
          rev = "04fac6b3a568c55712f07a198d47882afe666b9a";
          hash = "sha256-q/W+BK2Z7n3quyXpg7CgYFpMM0+GUqnWer/qzcyKArI=";
          fetchSubmodules = true;
        };
        nativeBuildInputs = old.nativeBuildInputs ++ [
          prev.pkg-config
          prev.qt6.qttools
        ];
        buildInputs = old.buildInputs ++ [
          prev.pipewire.dev
          prev.glib
        ];
        postPatch = ''
          substituteInPlace OpenRGBEffectsPlugin.pro \
            --replace "/usr/include/pipewire-0.3" "" \
            --replace "/usr/include/spa-0.2" "" \
            --replace "LIBS += -lopenal -lGL -lpipewire-0.3" "LIBS += -lopenal -lGL"
          echo "CONFIG += link_pkgconfig" >> OpenRGBEffectsPlugin.pro
          echo "PKGCONFIG += libpipewire-0.3" >> OpenRGBEffectsPlugin.pro
        '';
        postConfigure = ''
          sed -i 's|/nix/store/.*/bin/lrelease|lrelease|g' Makefile
        '';
        patches = [ ];
      });
      openrgb-plugin-hardwaresync = prev.openrgb-plugin-hardwaresync.overrideAttrs (old: {
        src = prev.fetchFromGitLab {
          owner = "OpenRGBDevelopers";
          repo = "OpenRGBHardwareSyncPlugin";
          rev = "ba7c5d80b7d60fc313486f45bd11009965ae5cb4";
          hash = "sha256-PbJXRovQJxqTw4lGbVk/icdXVKnjgHmuiO2Ggn0KfHI=";
          fetchSubmodules = true;
        };
        # Dont make any post patch updates
        postPatch = "";
        patches = [ ];
      });

      # Create wrapper by overriding qmakeFlags (requires compilation)
      # This sets OPENRGB_SYSTEM_PLUGIN_DIRECTORY which is the ONLY way upstream handles system plugins
      openrgb-with-all-plugins =
        let
          pluginsDir = prev.symlinkJoin {
            name = "openrgb-plugins";
            paths = [
              final.openrgb-plugin-effects
              final.openrgb-plugin-hardwaresync
            ];
          };
        in
        final.openrgb.overrideAttrs (old: {
          qmakeFlags = old.qmakeFlags or [ ] ++ [
            "OPENRGB_SYSTEM_PLUGIN_DIRECTORY=${pluginsDir}/lib/openrgb/plugins"
          ];
        });
    })
  ];

  hardware.i2c.enable = true;

  users.extraUsers.prnice = {
    extraGroups = [ "i2c" ];
  };

  services.udev.packages = [ pkgs.openrgb-with-all-plugins ];

  services = {
    hardware.openrgb = {
      enable = true;
      motherboard = "amd";
      package = pkgs.openrgb-with-all-plugins;
    };
  };
}
