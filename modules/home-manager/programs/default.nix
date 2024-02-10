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
    ./vscode.nix
  ];
}
