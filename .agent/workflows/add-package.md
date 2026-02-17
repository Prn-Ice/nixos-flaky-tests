---
description: How to add a new package to the system
---

1. Determine where the package belongs:
   - **KDE/Plasma packages** (`kdePackages.*`) → `hosts/nixos/system/desktop/kde.nix`
   - **System-level services/packages** → appropriate file in `hosts/nixos/system/`
   - **Hardware-specific** → `hosts/nixos/hardware/`
   - **User CLI tools, utilities, communication** → `modules/home-manager/programs/common.nix`
   - **Audio/video/media apps** → `modules/home-manager/programs/media.nix`
   - **Development tools** → `modules/home-manager/programs/development.nix`
   - **Browsers** → `modules/home-manager/programs/browsers.nix`

2. Add the package to the appropriate `home.packages` or `environment.systemPackages` list.

3. Add an inline `#` comment if the package name isn't self-explanatory.

4. If the package is a custom derivation, create a new directory under `modules/home-manager/programs/pkgs/<package-name>/default.nix`.

5. Rebuild and test:
```sh
sudo nixos-rebuild switch --flake .#nixos
```

6. Commit:
```sh
git add -A
git commit -m "feat: add <package-name>"
```
