# Custom packages specific to my home-manager configuration
{ pkgs ? import <nixpkgs> { } }: {
  windsurf = pkgs.callPackage ./windsurf { };
}
