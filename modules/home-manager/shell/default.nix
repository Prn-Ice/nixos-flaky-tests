{ config, ... }:
let
  d = config.xdg.dataHome;
  c = config.xdg.configHome;
  cache = config.xdg.cacheHome;
in
{
  imports = [
    ./fish
    ./nushell
    ./common.nix
    ./starship.nix
    ./terminals.nix
  ];

  # add environment variables
  home.sessionVariables = {

    # set default applications
    EDITOR = "vim";
    BROWSER = "firefox";
    TERMINAL = "konsole";

    # enable scrolling in git diff
    DELTA_PAGER = "less -R";

    MANPAGER = "sh -c 'col -bx | bat -l man -p'";

    # Electron apps wayland fix
    NIXOS_OZONE_WL = "1";
  };

  home.shellAliases = {
    k = "kubectl";
  };
}
