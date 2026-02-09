# Fix NVIDIA Suspend-then-Hibernate Failure

The NVIDIA driver fails to suspend because `nvidia-suspend.service` is not triggered before `systemd-suspend-then-hibernate.service`, causing every lid-close suspend to fail with error -5.

## Root Cause

- `hardware.nvidia.powerManagement.enable = true;` is already set in `hosts/nixos/hardware/nvidia.nix:40`, which adds `nvidia.NVreg_PreserveVideoMemoryAllocations=1` to the kernel command line.
- This parameter requires the NVIDIA systemd services (`nvidia-suspend`, `nvidia-resume`, `nvidia-hibernate`) to write to `/proc/driver/nvidia/suspend` **before** the kernel suspends the GPU.
- The NVIDIA-provided systemd units hook into `systemd-suspend.service` and `systemd-hibernate.service`, but **not** `systemd-suspend-then-hibernate.service`.
- `hibernate.nix:8` sets `HandleLidSwitch = "suspend-then-hibernate"`, so every lid close triggers the unhooked path → NVIDIA suspend fails → system immediately wakes.
- Evidence: the boot log shows plain `suspend` (with `nvidia-suspend.service`) succeeds at 13:16:37, but all three `suspend-then-hibernate` attempts fail.

## Fix

**File**: `hosts/nixos/hardware/hibernate.nix`

Add systemd service overrides to make the NVIDIA suspend/resume/hibernate services also activate for `suspend-then-hibernate`:

```nix
# Wire NVIDIA power management services into suspend-then-hibernate
systemd.services.nvidia-suspend.serviceConfig = {
  # Already has Before=systemd-suspend.service, add suspend-then-hibernate
};
systemd.services.nvidia-suspend = {
  before = [ "systemd-suspend-then-hibernate.service" ];
  requiredBy = [ "systemd-suspend-then-hibernate.service" ];
};
systemd.services.nvidia-resume = {
  after = [ "systemd-suspend-then-hibernate.service" ];
  wantedBy = [ "systemd-suspend-then-hibernate.service" ];
};
```

This is a minimal 3-line addition to `hibernate.nix` that wires the existing NVIDIA services into the `suspend-then-hibernate` target.

## Verification

After `nixos-rebuild switch`, close the laptop lid. The system should:

1. Successfully suspend (no immediate wake)
2. Show `nvidia-suspend.service` completing before suspend in `journalctl -b`
3. Resume cleanly without KWin "Atomic modeset test failed" errors
