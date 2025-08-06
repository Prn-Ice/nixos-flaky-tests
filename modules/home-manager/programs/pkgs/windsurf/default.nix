{
  lib,
  stdenv,
  callPackage,
  fetchurl,
  commandLineArgs ? "",
  useVSCodeRipgrep ? stdenv.hostPlatform.isDarwin,
  writeScript,
  bash,
}: let
  sha256 = "sha256-sLVDkkXKnAWsSmANooNXV2QYIABcIZyXGilKy5Hz8RQ=";
in
  callPackage ./generic.nix {
    inherit commandLineArgs useVSCodeRipgrep;

    version = "1.11.2";
    pname = "windsurf";

    executableName = "windsurf";
    longName = "Windsurf";
    shortName = "windsurf";

    src = fetchurl {
      url = "https://windsurf-stable.codeiumdata.com/linux-x64/stable/a2714d538be16de1c91a0bc6fa1f52acdb0a07d2/Windsurf-linux-x64-1.11.2.tar.gz";
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
      maintainers = with maintainers; [Prn-Ice];
      platforms = ["x86_64-linux"];
      sourceProvenance = with sourceTypes; [binaryNativeCode];
    };
  }
