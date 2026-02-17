# AGENTS.md

This is a NixOS flake-based dotfiles repository for a Lenovo Legion Slim laptop running KDE Plasma 6 on Wayland.

## Architecture

```
.agent/                            # AI agent configuration (shared across machines)
├── workflows/                     # Step-by-step workflows (/rebuild, /update-flake, /add-package)
├── skills/                        # Reusable knowledge (nixos-packages, nixos-debugging)
└── memories/                      # Persistent context and learnings
flake.nix                          # Entry point. Single host "nixos" (x86_64-linux)
├── hosts/nixos/                   # System-level NixOS configuration
│   ├── hardware/                  # Hardware-specific: nvidia, rgb, sunshine, hibernate, etc.
│   └── system/                    # System services and packages
│       ├── desktop/kde.nix        # KDE Plasma 6 + KDE-specific packages only
│       ├── audio.nix              # PipeWire / audio daemon config
│       ├── fonts.nix
│       ├── networking.nix
│       ├── services/              # SSH, Cloudflare WARP, etc.
│       └── ...
└── modules/home-manager/          # User-level configuration (home-manager)
    ├── programs/
    │   ├── common.nix             # General CLI tools, utilities, communication apps
    │   ├── media.nix              # Audio/video apps (mpv, spotify, audacity, etc.)
    │   ├── development.nix        # Dev tools (Android SDK, IDEs, MCP servers)
    │   ├── browsers.nix
    │   ├── vscode.nix
    │   └── pkgs/                  # Custom package definitions (overlays)
    └── shell/                     # Fish, Nushell, Starship config
```

## Key Conventions

- **Nix formatting**: Use `{pkgs, ...}: {` style (opening brace on same line as args).
- **Package placement**: System packages (`environment.systemPackages`) go in `hosts/nixos/`. User packages (`home.packages`) go in `modules/home-manager/programs/`.
- **Desktop-specific packages** (KDE/kdePackages) go in `hosts/nixos/system/desktop/kde.nix`. Non-KDE applications do **not** belong there.
- **Categorization matters**: Place packages in the correct file by purpose — `media.nix` for audio/video, `development.nix` for dev tools, `common.nix` for general CLI utilities.
- **Custom packages** are defined under `modules/home-manager/programs/pkgs/` with their own `default.nix`.
- **Comments**: Use inline `#` comments to describe non-obvious packages.

## Flake Inputs

| Input | Purpose |
|---|---|
| `nixpkgs` | nixos-unstable channel |
| `home-manager` | User environment management (follows nixpkgs) |
| `zen-browser` | Firefox fork (home-manager module) |
| `nix-alien` | Running unpatched binaries |
| `batmon` | Battery monitoring |
| `mcp-nixos` | MCP NixOS server for AI assistants |

## Building & Deploying

```sh
# Rebuild and switch
sudo nixos-rebuild switch --flake .#nixos

# Test without switching (dry activation)
sudo nixos-rebuild test --flake .#nixos
```

## Commits

Use **conventional commits**. Examples from this repo:

```
feat: add android-tools, re-enable windsurf
fix: wire nvidia suspend services into suspend-then-hibernate
fix(hibernate): correct misleading comment about sleep mode
docs: document cargo vendor fix for stremio-linux-shell
chore: update flake inputs
```

Common prefixes: `feat`, `fix`, `docs`, `chore`, `refactor`. Use a scope in parentheses when the change targets a specific module (e.g. `fix(hibernate):`, `feat(media):`).

## Important Notes

- The system uses **nixos-unstable** — packages may occasionally have broken builds. Comment out broken packages with a `# Broken build` note.
- NVIDIA GPU is configured in `hosts/nixos/hardware/nvidia.nix`.
- The `generated/` directory contains auto-generated Nix files (e.g., connector detection) — do not manually edit.
- Shell scripts in `scripts/` are helper utilities for power management and hardware detection.

## Learnings & Documentation

After resolving difficult problems or completing non-trivial projects, **document the learnings** in `docs/`. Each document should capture the problem, what was tried, and the solution — so the same issues aren't debugged from scratch again. See existing examples:

- `docs/nvidia-suspend-fix.md`
- `docs/openrgb-plugin-debugging.md`
