# stremio-linux-shell — NixOS Package Notes

## Background

The stock `stremio` package in nixpkgs depends on `qtwebengine-5.15.19`, which is marked insecure. This blocks NixOS builds unless you add it to `permittedInsecurePackages`. As an alternative, Stremio has a new Rust/CEF-based shell (`stremio-linux-shell`) that replaces the Qt5 dependency entirely.

A Qt6 port of the old `stremio-shell` was also investigated but found to be incomplete upstream — not viable.

## Package Creation

### Source

- Repo: https://github.com/Stremio/stremio-linux-shell
- Version: `v1.0.0-beta.11`
- Build system: `rustPlatform.buildRustPackage` with `offline-build` feature flag

### CEF (Chromium Embedded Framework)

The package bundles pre-built CEF binaries (`v138.0.21`). During `preBuild`:

1. CEF tarball is fetched from `cef-builds.spotifycdn.com`
2. Extracted to a temp directory
3. Required files copied: `libcef.so`, `libEGL.so`, `libGLESv2.so`, `libvk_swiftshader.so`, `v8_context_snapshot.bin`, `icudtl.dat`, `*.pak`, `locales/`
4. All `.so` files are patched with `patchelf --set-rpath` to resolve transitive native dependencies

### Native Dependencies

CEF requires a large set of native libraries. These are specified in three places:

- **`buildInputs`** — for the Rust build/link step
- **`runtimeDependencies`** — for `autoPatchelfHook` to set RPATH on the final binary
- **`CEF_RPATH`** — passed to `patchelf` for CEF's own `.so` files

Key libraries: `libGL`, `libxkbcommon`, `wayland`, `vulkan-loader`, X11 libs, `alsa-lib`, `nss`, `nspr`, `dbus`, `at-spi2-atk`, `cups`, `libdrm`, `mesa`, `pango`, `cairo`, `expat`, `glib`, `gdk-pixbuf`, `gtk3`, `systemd` (libudev), `libgbm`.

## Fixes Applied

### 1. Missing `node` binary (server crash)

**Symptom:** `Failed to start server: No such file or directory (os error 2)`

**Cause:** The Rust binary spawns `Command::new("node")` to run a `server.js` file (downloaded at runtime to `~/.local/share/stremio/server.js`). On NixOS, `node` isn't in PATH by default.

**Fix:** Added `makeWrapper` and wrapped the binary with `--prefix PATH : ${nodejs}/bin`.

### 2. Missing `.desktop` file

**Symptom:** No launcher entry in the desktop environment.

**Fix:** Installed the upstream `.desktop` file and SVG icon from the source tree's `data/` directory during `postInstall`. Used `sed` to rewrite the `Exec=` line to point to `stremio-linux-shell`.

### 3. Missing `libayatana-appindicator3` (tray icon crash)

**Symptom:** `Failed to load ayatana-appindicator3 or appindicator3 dynamic library` — thread panic on the tray icon thread. First run appeared to work (main app survived the panic), second run crashed.

**Fix:** Added `libayatana-appindicator` to `buildInputs`, `runtimeDependencies`, and the wrapper's `LD_LIBRARY_PATH`.

### 4. `libGL.so.1` not found by CEF subprocesses

**Symptom:** `Could not dlopen libGL.so.1` — CEF GPU process exits, repeated on every launch.

**Cause:** CEF spawns child processes (GPU, renderer) that `dlopen` system libraries. The wrapper's `LD_LIBRARY_PATH` only had `$out/lib/stremio`. On NixOS, the actual GPU driver lives at `/run/opengl-driver/lib`.

**Fix:** Expanded the wrapper's `LD_LIBRARY_PATH` to include `libGL`, `libxkbcommon`, `wayland`, `vulkan-loader`, `libayatana-appindicator`, `libgbm`, and `/run/opengl-driver/lib`.

### 5. `EPIPE` crash on second launch

**Symptom:** `Error: write EPIPE` from the node server process.

**Cause:** Not a new bug — the orphaned node server from a previous crashed run was still alive. When the Rust binary crashed (due to issues #3/#4 above), the node server kept running. On the next launch, the stale server tried to write to a broken pipe.

**Fix:** Resolved by fixing issues #3 and #4. The stale process just needed to be killed (`pkill -f server.js`).

### 6. `nix-prefetch-git` not found during cargo vendor (build failure)

**Symptom:** `FileNotFoundError: [Errno 2] No such file or directory: 'nix-prefetch-git'` during the `vendor-staging` derivation.

**Cause:** The `Cargo.lock` contains git dependencies (forked `winit`, `glutin`, `libmpv2-rs` from the Stremio org). When using `cargoHash` or `useFetchCargoVendor`, nixpkgs runs `fetch-cargo-vendor-util` inside a fixed-output derivation (FOD) to vendor crates. That utility calls `nix-prefetch-git` to fetch git deps, but `nix-prefetch-git` is not available inside the FOD sandbox — adding it to `nativeBuildInputs` doesn't help because the vendor staging is a separate derivation.

**Fix:** Switched from `cargoHash` to `cargoLock` with explicit `outputHashes` for the three git dependencies. This tells nixpkgs to fetch each git repo as a standalone FOD (using `builtins.fetchGit`), bypassing `nix-prefetch-git` entirely:

```nix
cargoLock = {
  lockFile = src + "/Cargo.lock";
  outputHashes = {
    "winit-0.30.11" = "sha256-...";
    "glutin-0.32.3" = "sha256-...";
    "libmpv2-4.1.0" = "sha256-...";
  };
};
```

To update hashes when bumping versions, run:
```sh
nix run nixpkgs#nix-prefetch-git -- --quiet <repo-url> <commit-sha>
```

## File Layout (in Nix store)

```
$out/
├── bin/
│   ├── stremio-linux-shell          # wrapper script (sets PATH, LD_LIBRARY_PATH)
│   └── .stremio-linux-shell-wrapped # actual binary
├── lib/stremio/
│   ├── libcef.so
│   ├── libEGL.so
│   ├── libGLESv2.so
│   ├── libvk_swiftshader.so
│   ├── v8_context_snapshot.bin
│   ├── icudtl.dat
│   ├── *.pak
│   └── locales/
└── share/
    ├── applications/com.stremio.Stremio.desktop
    └── icons/hicolor/scalable/apps/com.stremio.Stremio.svg
```

## Runtime Data

The app downloads `server.js` on first launch to `~/.local/share/stremio/server.js` and runs it with `node`. This is upstream behavior and not patched.

## Status

Experimental / beta. The stock `stremio` package (Qt5) is commented out in `media.nix` with a "Currently broken" note. This package is wired in via `pkgs/default.nix`.
