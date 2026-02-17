---
description: How to rebuild the NixOS system configuration
---

// turbo-all

1. Rebuild and switch to the new configuration:
```sh
sudo nixos-rebuild switch --flake .#nixos
```

2. If you only want to test without making it the boot default:
```sh
sudo nixos-rebuild test --flake .#nixos
```

3. To build without activating (dry run):
```sh
nixos-rebuild build --flake .#nixos
```
