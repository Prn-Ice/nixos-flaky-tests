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
  sha256 = "sha256-7lpKw4+aJRilRCnLI1uudtdLP/8PWUfb/ClzjXjyhUI=";

in
callPackage ./generic.nix rec {
  inherit commandLineArgs useVSCodeRipgrep;

  version = "1.9.2";
  pname = "windsurf";

  executableName = "windsurf";
  longName = "Windsurf";
  shortName = "windsurf";

  src = fetchurl {
    url = "https://windsurf-stable.codeiumdata.com/${plat}/stable/8cb7f313303c8b35844a56b6fe0f76e508261569/Windsurf-${plat}-${version}.${archive_fmt}";
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
