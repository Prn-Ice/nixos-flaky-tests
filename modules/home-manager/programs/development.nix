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
  viewBeads =
    inputs.view-beads.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
      (old: {
        npmDeps = old.npmDeps.overrideAttrs {
          outputHash = "sha256-u5QON0kbf94Z8ryLc0lyIiuBCjzBMEN+KAmNgsNRcX4=";
        };
      });
in
{
  home.packages = with pkgs; [
    # MCP server for NixOS
    inputs.mcp-nixos.packages.${pkgs.stdenv.hostPlatform.system}.default

    # AI coding agent memory system
    beads

    # Local dashboard for beads (bd) issue trackers
    viewBeads

    # AI coding assistant
    claude-code
    opencode
    opencode-desktop

    # android
    (android-studio.withSdk androidSdk)
    android-tools

    # Broken build
    # jetbrains.idea-community
    devin-desktop

    # javascript runtime (provides node, npm, npx globally)
    nodejs

    # networking tools
    ngrok # a tunneling HTTP proxy
    httpie # a command-line HTTP client
    acli # Atlassian Command Line Interface

    # containers
    # docker
    # docker-compose
  ];
}
