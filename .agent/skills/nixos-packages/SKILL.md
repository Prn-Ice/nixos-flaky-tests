---
name: NixOS Package Management
description: How to find, evaluate, and manage NixOS packages using nix CLI and the nixos MCP
---

# NixOS Package Management

## Finding Packages

Use the NixOS MCP server to search for packages:
- Search by name or description
- Check available versions with `nix_versions`
- View package info including license and homepage

## Evaluating Package Options

```sh
# Search for a package
nix search nixpkgs#<package-name>

# Show package metadata
nix eval nixpkgs#<package-name>.meta --json | jq

# Check if a package has overridable attributes
nix eval nixpkgs#<package-name>.override --json 2>&1
```

## Building Custom Packages

When a package needs customization or isn't in nixpkgs:

1. Create a directory: `modules/home-manager/programs/pkgs/<name>/`
2. Write a `default.nix` with `mkDerivation` or appropriate builder
3. Import it via an overlay or directly in the consuming module

## Common Patterns

### Package with overrides
```nix
(pkgs.somePackage.override {
  feature = true;
})
```

### Package from flake input
```nix
inputs.some-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
```

### Broken packages
Comment out with a note:
```nix
# Broken build
# somePackage
```
