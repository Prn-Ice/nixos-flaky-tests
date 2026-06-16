{ ... }:
{
  programs = {
    google-chrome = {
      enable = true;
    };

    firefox = {
      enable = true;
      # Legacy path pinned to silence warning (home.stateVersion < 26.05).
      # To migrate: move ~/.mozilla/firefox to $XDG_CONFIG_HOME/mozilla/firefox,
      # then change this to "${config.xdg.configHome}/mozilla/firefox".
      # Note: native messaging hosts are not moved automatically.
      configPath = ".mozilla/firefox";
    };

    zen-browser = {
      enable = true;
    };
  };
}
