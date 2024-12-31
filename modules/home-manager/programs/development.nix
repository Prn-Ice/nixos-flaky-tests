{ pkgs, ... }:

let
  windsurf = pkgs.callPackage ./pkgs/windsurf { };
in {
  home.packages = with pkgs; [
    # development environments
    windsurf

    # android
    android-studio
    # jetbrains.idea-community-

    # networking tools
    ngrok # a tunneling HTTP proxy
    httpie # a command-line HTTP client

    # containers
    # docker
    # docker-compose
  ];
}
