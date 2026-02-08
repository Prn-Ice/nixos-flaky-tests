# Custom packages specific to my home-manager configuration
{ pkgs, ... }:
let
  windsurf = pkgs.callPackage ./windsurf { };
  tidal-dl-ng = pkgs.callPackage ./tidal-dl-ng {
    inherit (pkgs) fetchFromGitHub lib system;
  };
  plasmavantage = pkgs.callPackage ./plasmavantage { };
  stremio-linux-shell = pkgs.callPackage ./stremio-linux-shell { };
in
{
  home.packages = [
    # Will remove soon, leaving for reference
    # windsurf
    # tidal-dl-ng
    plasmavantage
    stremio-linux-shell # Experimental: new Rust/CEF-based Stremio shell (beta)
  ];
}
