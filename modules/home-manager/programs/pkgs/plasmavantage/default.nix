{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
}:
stdenvNoCC.mkDerivation {
  pname = "plasmavantage";
  version = "latest";

  src = fetchFromGitLab {
    owner = "Scias";
    repo = "plasmavantage";
    rev = "master";
    hash = "sha256-ix26p2Oo64WFI5AF8D+HdlfwVz2wuJ+NfA5th489jPU=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/plasma/plasmoids/
    cp -r package $out/share/plasma/plasmoids/com.gitlab.scias.plasmavantage
  '';

  meta = {
    description = "KDE Plasma plasmoid for Lenovo Vantage-like features";
    longDescription = ''
      KDE Plasma plasmoid (Plasma Vantage) for Lenovo laptops.
      Built as a C++/QML Plasmoid.
    '';
    license = lib.licenses.gpl3Plus;
    homepage = "https://gitlab.com/Scias/plasmavantage";
    maintainers = [];
  };
}
