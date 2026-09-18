# Prince's NixOS Configuration

> **Note:** This README was generated with AI assistance to provide comprehensive documentation of the repository structure.

This repository contains a NixOS configuration using flakes for managing both system-level and user-level configurations. It's specifically tailored for a gaming laptop setup with advanced hardware support.

## Repository Structure

### Root Level Files

- **`flake.nix`** - Main flake configuration file that defines inputs (dependencies) and outputs (system configurations)
- **`flake.lock`** - Lock file that pins exact versions of all dependencies
- **`.vscode/`** - Visual Studio Code workspace configuration

### Main Directories

#### `hosts/`
Contains host-specific configurations for different machines.

- **`hosts/nixos/`** - Main NixOS system configuration
  - **`default.nix`** - Entry point that imports hardware and system configurations
  - **`hardware-configuration.nix`** - Auto-generated hardware configuration (filesystems, boot, etc.)
  - **`hardware/`** - Hardware-specific configurations and drivers
  - **`system/`** - System-level configurations and services

#### `modules/`
Contains reusable configuration modules.

- **`modules/home-manager/`** - User-level configurations managed by Home Manager
  - **`default.nix`** - Entry point for user configuration
  - **`programs/`** - Application and program configurations
  - **`shell/`** - Shell environments and terminal configurations

#### `scripts/`
Utility scripts for system management and automation.

- **`detect-connectors.sh`** - Detects display connectors for multi-GPU setups
- **`ac_mode.sh`** - Configures system for AC power mode
- **`battery_mode.sh`** - Configures system for battery power mode
- **`iommu_groups.sh`** - Lists IOMMU groups for GPU passthrough

#### `generated/`
Auto-generated configuration files.

- **`connectors.nix`** - Generated display connector configuration

## Detailed Directory Breakdown

### `hosts/nixos/hardware/`
Hardware-specific configurations and drivers:

- **`legion_slim.nix`** - Lenovo Legion laptop-specific configurations
- **`nvidia.nix`** - NVIDIA graphics driver configuration
- **`rgb.nix`** - RGB lighting control (OpenRGB)
- **`sunshine.nix`** - Game streaming server configuration
- **`hibernate.nix`** - Hibernation and power management
- **`obs_webcam.nix`** - OBS virtual camera configuration
- **`connector-detection.nix`** - Display connector detection system

### `hosts/nixos/system/`
System-level configurations:

- **`core.nix`** - Core system packages and basic configuration
- **`boot/`** - Boot loader and kernel configurations
- **`desktop/`** - Desktop environment configurations (KDE/GNOME)
- **`services/`** - System services and daemons
- **`theme/`** - System theming and appearance
- **`audio.nix`** - Audio system configuration
- **`networking.nix`** - Network configuration
- **`users.nix`** - User account definitions
- **`virtualisation.nix`** - Virtualization and containers
- **`steam.nix`** - Gaming platform configuration

### `modules/home-manager/programs/`
User application configurations:

- **`browsers.nix`** - Web browser configurations
- **`development.nix`** - Development tools and IDEs
- **`git.nix`** - Git configuration
- **`media.nix`** - Media applications
- **`vscode.nix`** - Visual Studio Code configuration
- **`pkgs/`** - Custom package definitions

### `modules/home-manager/shell/`
Shell and terminal configurations:

- **`fish/`** - Fish shell configuration
- **`nushell/`** - Nushell configuration
- **`starship.nix`** - Starship prompt configuration
- **`terminals.nix`** - Terminal emulator configurations
- **`common.nix`** - Common shell utilities and aliases

## Key Features

This configuration includes:

- **Multi-GPU Support** - NVIDIA and AMD graphics with proper switching
- **Gaming Setup** - Steam, game streaming, RGB lighting
- **Development Environment** - Complete development toolchain
- **Power Management** - Laptop-specific power profiles
- **Hardware Acceleration** - Video encoding/decoding support
- **Virtualization** - Docker, QEMU/KVM support

## Usage

1. **System Rebuild** - Apply system configuration changes:
   ```bash
   sudo nixos-rebuild switch --flake .
   ```

2. **User Configuration** - Apply user-level changes:
   ```bash
   home-manager switch --flake .
   ```

3. **Update Dependencies** - Update flake inputs:
   ```bash
   nix flake update
   ```

## Configuration Philosophy

This setup follows NixOS best practices:

- **Declarative** - Everything is defined in configuration files
- **Reproducible** - Exact same system can be built from these files
- **Modular** - Separated into logical, reusable components
- **Hardware-Specific** - Tailored for specific laptop hardware
- **User-Centric** - Comprehensive user environment configuration

The configuration is split between system-level (`hosts/`) and user-level (`modules/home-manager/`) to maintain clear separation of concerns and enable easier maintenance.