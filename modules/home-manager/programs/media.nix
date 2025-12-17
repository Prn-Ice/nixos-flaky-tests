{ pkgs, ... }:
# media - control and enjoy audio/video
{
  home.packages = with pkgs; [
    # audio control
    pavucontrol
    playerctl
    pulsemixer 
    # easyeffects
    # jamesdsp

    # images
    imv
    ffmpeg
    upscayl

    # music
    spotify
    tidal-hifi
    tidal-dl

    # video
    # Note: Currently broken
    # stremio
  ];

  programs = {
    mpv = {
      enable = true;
    };
  };

  services = {
    playerctld.enable = true;
  };
}
