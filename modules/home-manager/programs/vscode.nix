{ config
, pkgs
, ...
}:

{

  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhsWithPackages (
      additionalPkgs: with additionalPkgs; [ ]
    );
    extensions = [ ];
  };
}
