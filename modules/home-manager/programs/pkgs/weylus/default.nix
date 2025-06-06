{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  dbus,
  ffmpeg,
  x264,
  libva,
  gst_all_1,
  xorg,
  libdrm,
  pkg-config,
  pango,
  pipewire,
  cmake,
  git,
  autoconf,
  libtool,
  typescript,
  ApplicationServices,
  Carbon,
  Cocoa,
  VideoToolbox,
  wayland,
  wayland-protocols,
  libxkbcommon,
  wayland-scanner,
}:

rustPlatform.buildRustPackage rec {
  pname = "weylus";
  version = "unstable-2025-04-21";

  src = fetchFromGitHub {
    owner = "H-M-H";
    repo = pname;
    rev = "master";
    sha256 = "sha256-lx1ZVp5DkQiL9/vw6PAZ34Lge+K8dfEVh6vLnCUNf7M=";
  };

  buildInputs =
    [
      ffmpeg
      x264
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      ApplicationServices
      Carbon
      Cocoa
      VideoToolbox
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      dbus
      libva
      gst_all_1.gst-plugins-base
      xorg.libXext
      xorg.libXft
      xorg.libXinerama
      xorg.libXcursor
      xorg.libXrender
      xorg.libXfixes
      xorg.libXtst
      xorg.libXrandr
      xorg.libXcomposite
      xorg.libXi
      xorg.libXv
      pango
      libdrm
      # Add Wayland and XKB dependencies
      wayland
      wayland-protocols
      libxkbcommon
    ];

  nativeBuildInputs =
    [
      cmake
      git
      typescript
      makeWrapper
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      pkg-config
      autoconf
      libtool
      # Add wayland-scanner for generating Wayland protocol code
      wayland-scanner
    ];

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "autopilot-0.4.0" = "sha256-1DRuhAAXaIADUmXlDVr8UNbI/Ab2PYdrx9Qh0j9rTX8=";
    };
  };

  cargoBuildFlags = [ "--features=ffmpeg-system" ];
  cargoTestFlags = [ "--features=ffmpeg-system" ];

  # Ignore deprecation warnings in FLTK
  CXXFLAGS = "-Wno-deprecated-declarations";

  postFixup =
    let
      GST_PLUGIN_PATH = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
        gst_all_1.gst-plugins-base
        pipewire
      ];
    in
    lib.optionalString stdenv.hostPlatform.isLinux ''
      wrapProgram $out/bin/weylus --prefix GST_PLUGIN_PATH : ${GST_PLUGIN_PATH}
    '';

  postInstall = ''
    install -vDm755 weylus.desktop $out/share/applications/weylus.desktop
  '';

  # env = {
  #   NIX_CFLAGS_COMPILE = toString [
  #     "-Wno-incompatible-pointer-types"
  #   ];
  # };

  meta = with lib; {
    broken = stdenv.hostPlatform.isDarwin;
    description = "Use your tablet as graphic tablet/touch screen on your computer";
    mainProgram = "weylus";
    homepage = "https://github.com/H-M-H/Weylus";
    license = with licenses; [ agpl3Only ];
    maintainers = with maintainers; [ lom ];
  };
}