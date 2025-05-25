{ lib
, stdenv
, callPackage
, fetchurl
, commandLineArgs ? ""
, useVSCodeRipgrep ? stdenv.hostPlatform.isDarwin
, writeScript
, bash
}:

let
  plat = "linux-x64";  # Assuming it's only for x86_64 Linux, adjust if needed
  archive_fmt = "tar.gz";
  sha256 = "sha256-z4J8r/GTzQjEX0D+2HoMPu1vBWObXmAp6noGDaD+0gU=";

in
callPackage ./generic.nix rec {
  inherit commandLineArgs useVSCodeRipgrep;

  version = "1.9.2";
  pname = "windsurf";

  executableName = "windsurf";
  longName = "Windsurf";
  shortName = "windsurf";

  src = fetchurl {
    url = "https://windsurf-stable.codeiumdata.com/${plat}/stable/71eeb18eeed7897bea630fcaba7d37c49c78b05e/Windsurf-${plat}-${version}.${archive_fmt}";
    inherit sha256;
  };

  sourceRoot = "";

  updateScript = writeScript "update-windsurf.sh" ''
    #!${bash}/bin/bash
    exec ${bash}/bin/bash ${./update-windsurf.sh}
  '';

  meta = with lib; {
    description = "Windsurf application";
    homepage = "https://codeium.com/windsurf/";
    license = licenses.unfree;
    maintainers = with maintainers; [ Prn-Ice ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
