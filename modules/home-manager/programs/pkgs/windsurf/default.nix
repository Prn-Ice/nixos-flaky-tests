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
  sha256 = "137sbcrg3gjsjcqzngvc9cb975d592kl3l2xn8878n6671h6ikvd";

in
callPackage ./generic.nix rec {
  inherit commandLineArgs useVSCodeRipgrep;

  version = "1.3.4";
  pname = "windsurf";

  executableName = "windsurf";
  longName = "Windsurf";
  shortName = "windsurf";

  src = fetchurl {
    url = "https://windsurf-stable.codeiumdata.com/${plat}/stable/ff5014a12e72ceb812f9e7f61876befac66725e5/Windsurf-${plat}-${version}.${archive_fmt}";
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
