---
description: How to update flake inputs and rebuild
---

// turbo-all

1. Update all flake inputs:
```sh
nix flake update
```

2. Or update a specific input:
```sh
nix flake update <input-name>
```

3. Rebuild and switch:
```sh
sudo nixos-rebuild switch --flake .#nixos
```

4. Commit the changes:
```sh
git add flake.lock
git commit -m "chore: update flake inputs"
```
