{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchurl,
  pkg-config,
  mpv,
  gtk3,
  libGL,
  libxkbcommon,
  wayland,
  vulkan-loader,
  nodejs,
  bzip2,
  openssl,
  autoPatchelfHook,
  patchelf,
  makeWrapper,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxrender,
  libxtst,
  libxcursor,
  libxi,
  libxcb,
  libxscrnsaver,
  alsa-lib,
  nss,
  nspr,
  dbus,
  at-spi2-atk,
  cups,
  libdrm,
  mesa,
  pango,
  cairo,
  expat,
  glib,
  gdk-pixbuf,
  atk,
  systemd,
  libgbm,
  libayatana-appindicator,
}:
let
  cefVersion = "138.0.21";
  cefFullVersion = "138.0.21+g54811fe+chromium-138.0.7204.101";
  cef = fetchurl {
    url = "https://cef-builds.spotifycdn.com/cef_binary_${cefFullVersion}_linux64_minimal.tar.bz2";
    hash = "sha256-Kob/5lPdZc9JIPxzqiJXNSMaxLuAvNQKdd/AZDiXvNI=";
  };
in
rustPlatform.buildRustPackage rec {
  pname = "stremio-linux-shell";
  version = "1.0.0-beta.11";

  src = fetchFromGitHub {
    owner = "Stremio";
    repo = "stremio-linux-shell";
    tag = "v${version}";
    hash = "sha256-kl2+X/9cRzSTa5UT0STfKNcbUL4fuSlQ5l6l14qiRxA=";
    fetchSubmodules = true;
  };

  cargoLock = {
    lockFile = src + "/Cargo.lock";
    outputHashes = {
      "winit-0.30.11" = "sha256-5nc8cGFl4jUsJXfEtfOxFBQFRoBrM6/5xfA2c1qhmoQ=";
      "glutin-0.32.3" = "sha256-5IX+03mQmWxlCdVC0g1q2J+ulW+nPTAhYAd25wyaHx8=";
      "libmpv2-4.1.0" = "sha256-zXMFuajnkY8RnVGlvXlZfoMpfifzqzJnt28a+yPZmcQ=";
    };
  };

  buildFeatures = [ "offline-build" ];

  nativeBuildInputs = [
    pkg-config
    autoPatchelfHook
    patchelf
    makeWrapper
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    mpv
    gtk3
    libGL
    libxkbcommon
    wayland
    vulkan-loader
    bzip2
    openssl
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxrender
    libxtst
    libxcursor
    libxi
    libxcb
    libxscrnsaver
    alsa-lib
    nss
    nspr
    dbus
    at-spi2-atk
    atk
    cups
    libdrm
    mesa
    pango
    cairo
    expat
    glib
    gdk-pixbuf
    libayatana-appindicator
  ];

  runtimeDependencies = [
    libGL
    libxkbcommon
    wayland
    vulkan-loader
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxrender
    libxtst
    libxcursor
    libxi
    libxcb
    alsa-lib
    nss
    nspr
    dbus.lib
    at-spi2-atk
    cups
    libdrm
    mesa
    pango
    cairo
    expat
    glib
    gdk-pixbuf
    libayatana-appindicator
  ];

  CEF_RPATH = lib.makeLibraryPath [
    libGL
    libxkbcommon
    wayland
    vulkan-loader
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxrender
    libxtst
    libxcursor
    libxi
    libxcb
    libxscrnsaver
    alsa-lib
    nss
    nspr
    dbus.lib
    at-spi2-atk
    atk
    cups.lib
    libdrm
    mesa
    pango
    cairo
    expat
    glib
    gdk-pixbuf
    gtk3
    systemd
    libgbm
  ];

  preBuild = ''
    # Prepare CEF directory for offline build
    export CEF_PATH="$TMPDIR/cef"
    mkdir -p "$CEF_PATH" "$TMPDIR/cef-extract"

    # Extract required files from CEF archive
    tar xjf ${cef} -C "$TMPDIR/cef-extract"
    cp "$TMPDIR/cef-extract"/*/Release/libcef.so "$CEF_PATH/"
    cp "$TMPDIR/cef-extract"/*/Release/libEGL.so "$CEF_PATH/"
    cp "$TMPDIR/cef-extract"/*/Release/libGLESv2.so "$CEF_PATH/"
    cp "$TMPDIR/cef-extract"/*/Release/libvk_swiftshader.so "$CEF_PATH/"
    cp "$TMPDIR/cef-extract"/*/Release/v8_context_snapshot.bin "$CEF_PATH/"
    cp "$TMPDIR/cef-extract"/*/Resources/icudtl.dat "$CEF_PATH/"
    cp "$TMPDIR/cef-extract"/*/Resources/*.pak "$CEF_PATH/"
    mkdir -p "$CEF_PATH/locales"
    cp "$TMPDIR/cef-extract"/*/Resources/locales/* "$CEF_PATH/locales/"

    # Patch CEF shared libraries so the linker can resolve their transitive dependencies
    for lib in "$CEF_PATH"/*.so; do
      patchelf --set-rpath "$CEF_RPATH:$CEF_PATH" "$lib" || true
    done
  '';

  postInstall = ''
    # Install CEF libraries and resources alongside the binary
    mkdir -p $out/lib/stremio
    cp -r "$CEF_PATH"/* $out/lib/stremio/

    # Wrap the binary with node in PATH and all runtime libs in LD_LIBRARY_PATH
    # CEF spawns subprocesses that dlopen libGL.so.1, libvulkan, etc.
    # /run/opengl-driver/lib provides the actual GPU driver on NixOS
    wrapProgram $out/bin/stremio-linux-shell \
      --prefix PATH : ${nodejs}/bin \
      --prefix LD_LIBRARY_PATH : $out/lib/stremio:${
        lib.makeLibraryPath [
          libGL
          libxkbcommon
          wayland
          vulkan-loader
          libayatana-appindicator
          libgbm
        ]
      }:/run/opengl-driver/lib

    # Install desktop file
    install -Dm644 $src/data/com.stremio.Stremio.desktop \
      $out/share/applications/com.stremio.Stremio.desktop
    sed -i 's|Exec=.*|Exec=stremio-linux-shell -o %u|' \
      $out/share/applications/com.stremio.Stremio.desktop

    # Install icon
    install -Dm644 $src/data/icons/com.stremio.Stremio.svg \
      $out/share/icons/hicolor/scalable/apps/com.stremio.Stremio.svg
  '';

  meta = {
    mainProgram = "stremio-linux-shell";
    description = "Stremio on Linux (new Rust/CEF shell) - beta";
    homepage = "https://github.com/Stremio/stremio-linux-shell";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}
