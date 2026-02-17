---
name: NixOS Debugging
description: How to debug NixOS build failures, service issues, and driver problems
---

# NixOS Debugging

## Build Failures

### Check the build log
```sh
# Rebuild with verbose output
sudo nixos-rebuild switch --flake .#nixos --show-trace 2>&1 | tee /tmp/rebuild.log
```

### Common causes
- **Broken upstream package**: Comment it out with `# Broken build` and document in a commit
- **Hash mismatch**: Update the hash (use `lib.fakeHash` to get the correct one)
- **Deprecated options**: Check the NixOS release notes for migration paths
- **Kernel incompatibility**: Pin the kernel or the problematic driver version

## Service Debugging

```sh
# Check service status
systemctl status <service-name>

# View service logs
journalctl -u <service-name> -b

# List failed services
systemctl --failed
```

## Driver Issues (especially NVIDIA)

- Config is in `hosts/nixos/hardware/nvidia.nix`
- Suspend/hibernate issues often involve systemd service ordering — see `docs/nvidia-suspend-fix.md`
- Check kernel compatibility when updating flake inputs

## After Fixing

1. Rebuild and verify: `sudo nixos-rebuild switch --flake .#nixos`
2. Document the fix in `docs/` if the problem was non-trivial
3. Commit with a descriptive message: `fix(<scope>): <description>`
