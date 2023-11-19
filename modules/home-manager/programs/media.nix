{ pkgs
, config
, ...
}:
# media - control and enjoy audio/video
{
  home.packages = with pkgs; [
    # audio control
    pavucontrol
    playerctl
    pulsemixer
    # images
    imv
    ffmpeg
    spectacle
    upscayl

    # music
    spotify

    # video
    stremio
  ];

  programs = {
    mpv = {
      enable = true;
      defaultProfiles = [ "gpu-hq" ];
      scripts = [ pkgs.mpvScripts.mpris ];
    };

    obs-studio.enable = true;
  };

  services = {
    playerctld.enable = true;
  };
}
