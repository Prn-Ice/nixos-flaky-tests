# Project Context

## Hardware
- **Laptop**: Lenovo Legion Slim
- **GPU**: NVIDIA (hybrid graphics, open kernel driver)
- **Architecture**: x86_64-linux

## Software
- **OS**: NixOS (unstable channel)
- **Desktop**: KDE Plasma 6 on Wayland
- **Display Manager**: SDDM (Wayland mode, catppuccin-mocha theme)
- **Shell**: Fish (primary), Nushell (secondary)
- **Prompt**: Starship
- **Audio**: PipeWire
- **Browser**: Zen Browser (Firefox fork via flake input)

## Known Quirks
- NVIDIA suspend-then-hibernate requires manual systemd service wiring — see `docs/nvidia-suspend-fix.md`
- OpenRGB plugins need special handling with `overrideAttrs` — see `docs/openrgb-plugin-debugging.md`
- Some packages are periodically broken on unstable — comment out with `# Broken build`
- Use `stdenv.hostPlatform.system` instead of deprecated `system`
