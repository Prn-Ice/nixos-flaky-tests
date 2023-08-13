{ pkgs
, ...
}: {
  home.packages = [ pkgs.gh ];

  programs.git = {
    enable = true;

    userName = "Prn-Ice";
    userEmail = "stormprince77@gmail.com";
  };
}
