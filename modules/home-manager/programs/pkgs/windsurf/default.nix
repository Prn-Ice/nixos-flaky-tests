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
  sha256 = "0b9r8137g4fjdblfyhvaslbrbrvjbic38mcma4ar65x16i1ijqbl";

in
callPackage ./generic.nix rec {
  inherit commandLineArgs useVSCodeRipgrep;

  version = "1.2.1";
  pname = "windsurf";

  executableName = "windsurf";
  longName = "Windsurf";
  shortName = "windsurf";

  src = fetchurl {
    url = "https://windsurf-stable.codeiumdata.com/${plat}/stable/aa53e9df956d9bc7cb1835f8eaa47768ce0e5b44/Windsurf-${plat}-${version}.${archive_fmt}";
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
