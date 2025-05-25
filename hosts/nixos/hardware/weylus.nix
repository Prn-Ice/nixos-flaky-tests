{
  pkgs,
  inputs,
  ...
}: let
  weylus-new = pkgs.callPackage (inputs.self + "/modules/home-manager/programs/pkgs/weylus") {
    ApplicationServices = null;
    Carbon = null;
    Cocoa = null;
    VideoToolbox = null;
  };
in {
  programs.weylus = {
    enable = true;
    # package = weylus-new;
    users = ["prnice"];
    openFirewall = true;
  };
}
