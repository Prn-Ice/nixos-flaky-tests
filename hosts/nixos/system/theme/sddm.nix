{ lib, pkgs, ... }:

let

  buildTheme = { name, version, src, themeIni ? [ ] }:
    pkgs.stdenv.mkDerivation rec {
      pname = "sddm-theme-${name}";
      inherit version src;

      buildCommand = ''
        dir=$out/share/sddm/themes/${name}
        doc=$out/share/doc/${pname}

        mkdir -p $dir $doc
        if [ -d $src/${name} ]; then
          srcDir=$src/${name}
        else
          srcDir=$src
        fi
        cp -r $srcDir/* $dir/
        for f in $dir/{AUTHORS,COPYING,LICENSE,README,*.md,*.txt}; do
          test -f $f && mv $f $doc/
        done
        chmod 777 $dir/theme.conf

        ${lib.concatMapStringsSep "\n" (e: ''
            ${pkgs.crudini}/bin/crudini --set --inplace $dir/theme.conf \
              "${e.section}" "${e.key}" "${e.value}"
          '')
          themeIni}
      '';
    };

  customTheme = builtins.isAttrs theme;

  # ------------------------------------------
  # SDDM theme selector
  # ------------------------------------------

  # theme = "breeze"; # <==== Default ssdm them for kde
  theme = themes.sddm-sugar-dark;


  themeName =
    if customTheme
    then theme.pkg.name
    else theme;

  packages =
    if customTheme
    then [ (buildTheme theme.pkg) ] ++ theme.deps
    else [ ];

  themes = {

    sddm-sugar-dark = {
      pkg = rec {
        name = "sugar-dark";
        version = "1.2";
        src = pkgs.fetchFromGitHub {
          owner = "MarianArlt";
          repo = "sddm-sugar-dark";
          rev = "v${version}";
          sha256 = "0gx0am7vq1ywaw2rm1p015x90b75ccqxnb1sz3wy8yjl27v82yhb";
        };
        themeIni = [
          {
            section = "General";
            key = "background";
            value = ./assets/Harmony.jpg;
          }
        ];
      };
      deps = [ pkgs.libsForQt5.qt5.qtgraphicaleffects ];
    };
  };

in
{
  environment.systemPackages = packages;

  services.displayManager.sddm.theme = themeName;
}
