{
  lib,
  fetchFromGitHub,
  python3,
  makeWrapper,
  system ? builtins.currentSystem,
}: let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {
    inherit system;
    config = {};
  };
  
  pythonWithPackages = python3.withPackages (ps: with ps; [
    # Core dependencies
    requests
    pycryptodome
    mutagen
    toml
    typer
    
    # Additional dependencies from pyproject.toml
    dataclasses-json
    pathvalidate
    m3u8
    coloredlogs
    mpegdash
    rich
    tidalapi
    python-ffmpeg
    
    # GUI dependencies
    pyside6
    pyqtdarktheme
    
    # Dependencies we added earlier that might still be needed
    aigpy
    prettytable
    pydub
    colorama
    pyyaml
    psutil
  ]);
in
pkgs.stdenv.mkDerivation rec {
  pname = "tidal-dl-ng";
  version = "0.25.0";

  src = fetchFromGitHub {
    owner = "exislow";
    repo = "tidal-dl-ng";
    rev = "v${version}";
    hash = "sha256-G6FAoVMWjcmbxj0grZVorZZxG78ERhSkunMd9Rbomek=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/lib $out/bin
    cp -r $src/* $out/lib/
    
    # Create a symlink for the config module at the root level
    ln -s $out/lib/tidal_dl_ng/config.py $out/lib/config.py
    
    # Create a simple entry script for CLI
    cat > $out/bin/tidal-dl-ng << EOF
    #!/bin/sh
    export PYTHONPATH="$out/lib:\$PYTHONPATH"
    cd $out/lib
    exec ${pythonWithPackages}/bin/python -m tidal_dl_ng.cli "\$@"
    EOF
    chmod +x $out/bin/tidal-dl-ng
    
    # Create alias for CLI
    ln -s $out/bin/tidal-dl-ng $out/bin/tdn
    
    # Create a simple entry script for GUI
    cat > $out/bin/tidal-dl-ng-gui << EOF
    #!/bin/sh
    export PYTHONPATH="$out/lib:\$PYTHONPATH"
    cd $out/lib
    exec ${pythonWithPackages}/bin/python -m tidal_dl_ng.gui "\$@"
    EOF
    chmod +x $out/bin/tidal-dl-ng-gui
    
    # Create alias for GUI
    ln -s $out/bin/tidal-dl-ng-gui $out/bin/tdng
  '';

  meta = with lib; {
    homepage = "https://github.com/exislow/tidal-dl-ng";
    description = "Multithreaded TIDAL Media Downloader Next Generation! Up to HiRes Lossless / TIDAL MAX 24-bit, 192 kHz.";
    license = licenses.asl20;
    maintainers = ["Prn-Ice"];
    platforms = platforms.all;
    mainProgram = "tidal-dl-ng";
  };
}
