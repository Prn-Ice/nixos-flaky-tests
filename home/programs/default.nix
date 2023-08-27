{ config
, pkgs
, ...
}: {
  imports = [
    ./browsers.nix
    ./common.nix
    ./development.nix
    ./git.nix
    ./media.nix
    ./virtualisation.nix
    ./vscode.nix
    ./xdg.nix
  ];
}
