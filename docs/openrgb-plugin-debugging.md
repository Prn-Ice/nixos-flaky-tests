# OpenRGB Plugin Debugging Guide

## Problem Overview

When building OpenRGB with custom overlays in NixOS, plugins may fail to load even though they build successfully. This document explains how to debug and fix this issue.

## Root Cause

When using `overrideAttrs` on the `openrgb` package, the `passthru.withPlugins` function gets destroyed. The `openrgb-with-all-plugins` wrapper relies on this function to:
1. Create a wrapper that includes plugin paths
2. Copy plugin `.so` files to `$out/lib/openrgb/plugins/`
3. Set up the `OPENRGB_PLUGIN_PATH` environment variable

Without the preserved `passthru`, the wrapper becomes just a plain openrgb build with no plugin integration.

## Debugging Steps

### 1. Verify Plugins Build Successfully

```bash
# Build the plugin package
nix build .#nixosConfigurations.nixos.pkgs.openrgb-plugin-effects --no-link --print-out-paths

# Check for .so files in the plugin package
PLUGIN_PATH=$(nix build .#nixosConfigurations.nixos.pkgs.openrgb-plugin-effects --no-link --print-out-paths)
find $PLUGIN_PATH -name "*.so"
```

**Expected output:**
```
/nix/store/xxx-openrgb-plugin-effects-0.9/lib/openrgb/plugins/libOpenRGBEffectsPlugin.so
```

### 2. Check Wrapper Package

```bash
# Build the wrapper package
nix build .#nixosConfigurations.nixos.config.services.hardware.openrgb.package --no-link --print-out-paths

# Store path for inspection
OPENRGB_PATH=$(nix build .#nixosConfigurations.nixos.config.services.hardware.openrgb.package --no-link --print-out-paths)

# Check for plugin .so files (should be present if wrapper works correctly)
find $OPENRGB_PATH -name "*.so"
```

**Expected output if working:**
```
/nix/store/xxx-openrgb-0.9/lib/openrgb/plugins/libOpenRGBEffectsPlugin.so
/nix/store/xxx-openrgb-0.9/lib/openrgb/plugins/libOpenRGBHardwareSyncPlugin.so
```

**Actual output when broken:**
```
(no output - no .so files found)
```

### 3. Inspect Dependency Tree

```bash
# List all runtime dependencies
nix-store --query --references $OPENRGB_PATH

# Search for plugin packages in dependency tree
nix-store --query --tree $OPENRGB_PATH | grep -i "effect\|hardware"
```

**Expected:** Should show plugin package paths like `openrgb-plugin-effects-0.9` and `openrgb-plugin-hardwaresync-0.x`

**Actual when broken:** No plugin references found

### 4. Runtime Debugging

```bash
# Check user plugin directory
ls -la ~/.local/share/OpenRGB/plugins/ 2>/dev/null

# Run OpenRGB and check for plugin loading messages
openrgb --list-devices

# Check environment
echo $OPENRGB_PLUGIN_PATH
```

### 5. Verify Passthru Attributes

```bash
# Check if your overridden openrgb has withPlugins
nix eval .#nixosConfigurations.nixos.pkgs.openrgb.passthru.withPlugins --json 2>&1

# Compare with upstream
nix eval nixpkgs#openrgb.passthru.withPlugins --json 2>&1
```

## Solution 1: Compile-Time Path Injection (Recommended for Git Builds)

When building from specific git commits (especially newer ones post-May 2024), the most reliable way to ensure plugins are found is to bake the path directly into the binary defined by `OPENRGB_SYSTEM_PLUGIN_DIRECTORY`.

### 1. Create a joined directory of plugins
Use `symlinkJoin` to create a single path containing all plugins.

### 2. Pass the path via `qmakeFlags`
**CRITICAL:** Pass `OPENRGB_SYSTEM_PLUGIN_DIRECTORY` as a direct variable in `qmakeFlags`, NOT as a `DEFINES`.

```nix
openrgb.overrideAttrs (old: {
  qmakeFlags = old.qmakeFlags or [ ] ++ [
    # Pass as a variable so qmake handles the string quoting and logic
    "OPENRGB_SYSTEM_PLUGIN_DIRECTORY=${pluginsDir}/lib/openrgb/plugins"
  ];
})
```

## Solution 2: Override openrgb-with-all-plugins (Standard Nixpkgs method)

**Context:** The `openrgb-with-all-plugins` wrapper relies on `passthru.withPlugins`. If using `overrideAttrs` on the base package, you must ensure `passthru` is preserved and that the wrapper itself is also overridden to use your *new* base package.

**The real issue:** Even though `passthru.withPlugins` is preserved, `openrgb-with-all-plugins` is defined in `all-packages.nix` as:
```nix
openrgb-with-all-plugins = openrgb.withPlugins [ ... ];
```

This gets evaluated with the original (non-overridden) plugin packages unless you override it in the overlay.

**Implementation:**

```nix
nixpkgs.overlays = [
  (final: prev: {
    openrgb = prev.openrgb.overrideAttrs (old: {
      # ... source and patch overrides ...
      
      # Preserve the passthru attributes including withPlugins
      passthru = old.passthru or {};
    });
    
    # ... your plugin overrides here ...
    
    # CRITICAL: Re-create the wrapper with overridden packages
    openrgb-with-all-plugins = final.openrgb.withPlugins [
      final.openrgb-plugin-effects
      final.openrgb-plugin-hardwaresync
    ];
  })
];
```

**Key points:**
1. Preserve `passthru` in the openrgb override
2. Override each plugin package
3. **Override `openrgb-with-all-plugins` to call `final.openrgb.withPlugins` with `final` plugin packages**

Using `final.` ensures you're using the overridden versions from your overlay, not the upstream ones.

## Understanding OpenRGB Plugin Path Resolution

OpenRGB searches for plugins in the following order:

1. **Environment variable:** `$OPENRGB_PLUGIN_PATH`
2. **User directory:** `$XDG_CONFIG_HOME/OpenRGB/plugins` or `~/.config/OpenRGB/plugins`
3. **System directory:** `/usr/share/OpenRGB/plugins` (not used on NixOS)
4. **Compile-time path:** Set during build via wrapper

The `withPlugins` wrapper:
- Creates a new derivation that wraps the base openrgb
- Copies all plugin `.so` files to `$out/lib/openrgb/plugins/`
- May set up environment variables to point to this directory

## Alternative Solutions

### Option 2: Custom Wrapper with symlinkJoin

```nix
openrgb-with-custom-plugins = prev.symlinkJoin {
  name = "openrgb-with-plugins";
  paths = [
    final.openrgb
    final.openrgb-plugin-effects
    final.openrgb-plugin-hardwaresync
  ];
  buildInputs = [ prev.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/openrgb \
      --set OPENRGB_PLUGIN_PATH "$out/lib/openrgb/plugins"
  '';
};
```

### Option 3: Environment Variable

```nix
environment.sessionVariables = {
  OPENRGB_PLUGIN_PATH = "${pkgs.openrgb-plugin-effects}/lib/openrgb/plugins:${pkgs.openrgb-plugin-hardwaresync}/lib/openrgb/plugins";
};
```

## Common Startup Issues
    
### I2C / SMBus Errors
**Symptom:** OpenRGB starts but shows:
> "Some internal devices may not be detected... One or more I2C or SMBus interfaces failed to initialize."
    
**Fix:**
1. Ensure kernel modules are loaded: `i2c-dev`, `i2c-piix4` (AMD) or `i2c-i801` (Intel).
2. **Check User Groups:** The user must be in the `i2c` group.
   - Run `groups` to check the **current session**.
   - If missing (even if added to `/etc/group`), you must **log out and log back in**.
   - Temporary fix: `newgrp i2c`.

## Verification After Fix

After applying the fix and rebuilding:

```bash
# Rebuild your system
sudo nixos-rebuild switch

# Verify wrapper now includes plugins
OPENRGB_PATH=$(readlink -f $(which openrgb))
find $(dirname $(dirname $OPENRGB_PATH)) -name "*.so" | grep plugin

# Launch OpenRGB
openrgb
```

In the OpenRGB UI:
- Go to **Settings** → **Plugins** tab
- You should see:
  - OpenRGB Effects Plugin
  - OpenRGB Hardware Sync Plugin
- Both should show as "Loaded" or "Enabled"

## Common Pitfalls

1. **Not preserving passthru** - Most common issue, breaks the wrapper mechanism
2. **Overriding plugins without overriding openrgb** - Version mismatches can cause issues
3. **Plugin ABI compatibility** - Ensure plugin versions match OpenRGB version
4. **Missing dependencies** - Plugins may need additional runtime dependencies

## See Also

- [OpenRGB NixOS Wiki](https://nixos.wiki/wiki/OpenRGB)
- [Nixpkgs OpenRGB Package](https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/op/openrgb/package.nix)
- [OpenRGB Plugin Development](https://gitlab.com/CalcProgrammer1/OpenRGB/-/wikis/Plugin-Development)
