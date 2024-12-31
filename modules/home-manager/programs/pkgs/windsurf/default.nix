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
  sha256 = "1vynn9c5lk1ghba926gg6a3xrafm8r4p1nszc1ypl2msfbbsl1s0";

in
callPackage ./generic.nix rec {
  inherit commandLineArgs useVSCodeRipgrep;

  version = "1.1.2";
  pname = "windsurf";

  executableName = "windsurf";
  longName = "Windsurf";
  shortName = "windsurf";

  src = fetchurl {
    url = "https://windsurf-stable.codeiumdata.com/${plat}/stable/599ce698a84d43160da884347f22f6b77d0c8415/Windsurf-${plat}-${version}.${archive_fmt}";
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
