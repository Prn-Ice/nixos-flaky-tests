{ pkgs, inputs, ... }:
let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = [
      "latest"
      "35.0.0"
      "34.0.0"
      "28.0.3"
      "27.0.1"
    ];
    platformVersions = [
      "34"
      "28"
      "27"
    ];
    abiVersions = [
      "armeabi-v7a"
      "arm64-v8a"
    ];
    ndkVersions = [
      "28.1.13356709"
      "27.0.12077973"
    ];
    includeNDK = true;
  };
  androidSdk = androidComposition.androidsdk;
in
{
  home.packages = with pkgs; [
    # MCP server for NixOS
    inputs.mcp-nixos.packages.${pkgs.stdenv.hostPlatform.system}.default

    # AI coding agent memory system
    beads

    # android
    (android-studio.withSdk androidSdk)
    android-tools

    # Broken build
    # jetbrains.idea-community
    windsurf

    # networking tools
    ngrok # a tunneling HTTP proxy
    httpie # a command-line HTTP client

    # containers
    # docker
    # docker-compose
  ];
}
