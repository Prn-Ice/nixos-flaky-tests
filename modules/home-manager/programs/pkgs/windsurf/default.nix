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
  sha256 = "sha256-jgSSS5PiPtnKAOtvQyEiVS9osjYLoZPjl4xmJuKXKag=";
in
  callPackage ./generic.nix {
    inherit commandLineArgs useVSCodeRipgrep;

    version = "1.10.7";
    pname = "windsurf";

    executableName = "windsurf";
    longName = "Windsurf";
    shortName = "windsurf";

    src = fetchurl {
      url = "https://windsurf-stable.codeiumdata.com/linux-x64/stable/7c493d782a6cad0516e79f070d953687991df4ec/Windsurf-linux-x64-1.10.7.tar.gz";
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
