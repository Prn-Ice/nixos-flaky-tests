{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # android
    android-studio

    # networking tools
    ngrok # a tunneling HTTP proxy
    httpie # a command-line HTTP client

    # containers
    # docker
    # docker-compose
  ];
}
