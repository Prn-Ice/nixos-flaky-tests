{pkgs, ...}: let
  buildToolsVersion = "34.0.0";
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = [buildToolsVersion "28.0.3"];
    platformVersions = ["34" "28"];
    abiVersions = ["armeabi-v7a" "arm64-v8a"];
    includeNDK = true;
  };
  androidSdk = androidComposition.androidsdk;
in {
  home.packages = with pkgs; [
    # android
    (android-studio.withSdk androidSdk)

    jetbrains.idea-community
    windsurf

    # networking tools
    ngrok # a tunneling HTTP proxy
    httpie # a command-line HTTP client

    # containers
    # docker
    # docker-compose
  ];
}
