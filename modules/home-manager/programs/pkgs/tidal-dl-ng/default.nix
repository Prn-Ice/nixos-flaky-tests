{
  lib,
  fetchFromGitHub,
  # Build inputs
  python312Packages,
  system ? builtins.currentSystem,
}:

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {
    inherit system;
    config = {};
  };
  # Let all API attributes like "poetry2nix.mkPoetryApplication"
  # use the packages and versions (python3, poetry etc.) from our pinned nixpkgs above
  poetry2nix = import sources.poetry2nix { inherit pkgs; };
  mkPoetryApplication = poetry2nix.mkPoetryApplication;
in
mkPoetryApplication {
  projectDir = fetchFromGitHub {
    owner = "exislow";
    repo = "tidal-dl-ng";
    rev = "v0.23.0";
    hash = "sha256-JrR58NoGxChhj8i7sWezPOzgnYP5w9AZ0u/CK/Mlu08=";
  };
  python = pkgs.python312;
  preferWheels = true;
  extras = []; # Don't include GUI extras since we're using system packages

  buildInputs = with python312Packages; [
    pyside6
    pyqtdarktheme
  ];

  meta = with lib; {
    homepage = "https://github.com/exislow/tidal-dl-ng";
    description = "TIDAL Media Downloader Next Generation!";
    license = licenses.asl20;
    maintainers = ["Prn-Ice"];
    platforms = platforms.all;
    mainProgram = "tidal-dl-ng";
  };
}
