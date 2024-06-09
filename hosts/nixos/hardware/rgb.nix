{ pkgs, ... }:

{
  boot.kernelModules = [ "i2c-core" "i2c-dev" "i2c-piix4" ];

  environment.systemPackages = with pkgs; [
    i2c-tools
  ];

  nixpkgs.overlays = [
    (final: prev: {
      openrgb = prev.openrgb.overrideAttrs (old: {
        src = prev.fetchFromGitHub {
          owner = "Prn-Ice";
          repo = "OpenRGB";
          rev = "52b92bb4c6f566251fd4d03648e98697d1e280b6";
          hash = "sha256-xYVJ3yCJURgIhnfuQBUF/XOon/mKzYnZ7uvmkLQEmH8=";
        };
      });
      openrgb-plugin-effects = prev.openrgb-plugin-effects.overrideAttrs (old: {
        src = prev.fetchFromGitLab {
          owner = "OpenRGBDevelopers";
          repo = "OpenRGBEffectsPlugin";
          rev = "33cdbba21dff1eccd63fd8fff31a71a7519602e0";
          hash = "sha256-z/J9U3LqzfY3xTuvmMfbYGn1L5tNvaUCfTRkE6Il4GE=";
          fetchSubmodules = true;
        };
        # Dont make any post patch updates
        postPatch = "";
      });
      openrgb-plugin-hardwaresync = prev.openrgb-plugin-hardwaresync.overrideAttrs (old: {
        src = prev.fetchFromGitLab {
          owner = "OpenRGBDevelopers";
          repo = "OpenRGBHardwareSyncPlugin";
          rev = "04e396ab3db8f80e1fd681c6d7ba9dbcc946c148";
          hash = "sha256-dRDIp+pJbpp2Upt4RQJvE9hQDR17IGkcfeOKq8gTxos=";
        };
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
