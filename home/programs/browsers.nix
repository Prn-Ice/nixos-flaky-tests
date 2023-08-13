{ config
, pkgs
, ...
}: {
  programs = {
    google-chrome = {
      enable = true;
    };

    firefox = {
      enable = true;
    };
  };
}
