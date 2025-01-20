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
    spectacle
    upscayl

    # music
    spotify
    tidal-hifi
    tidal-dl

    # video
    stremio
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
