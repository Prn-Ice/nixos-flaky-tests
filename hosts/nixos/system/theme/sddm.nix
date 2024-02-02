{ config, lib, pkgs, ... }:

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
        # chmod 777 $dir/theme.conf


        ${lib.concatMapStringsSep "\n" (e: ''
          ${pkgs.crudini}/bin/crudini --set --inplace $dir/theme.conf \
            "${e.section}" "${e.key}" "${e.value}"
        '') themeIni}
      '';
    };

  customTheme = builtins.isAttrs theme;

  # ------------------------------------------
  # SDDM theme selector
  # ------------------------------------------

  theme = "breeze"; # <==== Default ssdm them for kde
  # theme = themes.solarized;
  # theme = themes.nordic;

  themeName =
    if customTheme
    then theme.pkg.name
    else theme;

  packages =
    if customTheme
    then [ (buildTheme theme.pkg) ] ++ theme.deps
    else [ ];

  themes = {
    solarized = {
      pkg = rec {
        name = "solarized";
        version = "20190103";
        src = pkgs.fetchFromGitHub {
          owner = "MalditoBarbudo";
          repo = "${name}_sddm_theme";
          rev = "2b5bdf1045f2a5c8b880b482840be8983ca06191";
          sha256 = "1n36i4mr5vqfsv7n3jrvsxcxxxbx73yq0dbhmd2qznncjfd5hlxr";
        };
        themeIni = [
          {
            section = "General";
            key = "background";
            value = ./assets/Harmony.jpg;
          }
        ];
      };
      deps = with pkgs; [ font-awesome ];
    };

    nordic = {
      pkg = rec {
        name = "nordic";
        src = pkgs.nordic;
        version = "2.2.0-unstable-2024-01-20";
        themeIni = [
          {
            section = "General";
            key = "background";
            value = ./assets/Harmony.jpg;
          }
        ];
      };
      deps = with pkgs; [ ];
    };
  };

in
{
  environment.systemPackages = packages;

  services.xserver.displayManager.sddm.theme = themeName;
}
