# Custom packages specific to my home-manager configuration
{pkgs, ...}: let
  # windsurf = pkgs.callPackage ./windsurf {};
  tidal-dl-ng = pkgs.callPackage ./tidal-dl-ng {
    inherit (pkgs) fetchFromGitHub lib system;
  };
in {
  home.packages = [
    # Will remove soon, leaving for reference
    # windsurf
    tidal-dl-ng
  ];
}
