# Legion iGPU-only hibernate investigation

## Problem

Two direct hibernate attempts on 2026-09-02 failed while Lenovo graphics policy
was `hybrid-igpu-only` and the NVIDIA PCI functions were detached. Both attempts
used the kernel's platform hibernation mode. Firmware ACPI `_PTS(4)` called
`DGHP(One)`, powered the NVIDIA root port back on, and caused a wakeup-pending
rollback before the kernel created a hibernation image. NVIDIA then
re-enumerated into the thawed AMD-only Plasma Wayland session, leaving the
display unusable and requiring forced shutdown.

The detailed boot IDs, timing, ACPI methods, and kernel control flow are recorded
in the LenovoLegionLinuxFrontend repository at
`docs/architecture/igpu-only-driver-handoff.md` and in Beads issue
`lllf-j9t.6.1`.

## Prepared workaround

`hosts/nixos/hardware/hibernate.nix` now configures the single systemd
`HibernateMode` value `shutdown`. Linux shutdown-mode hibernation skips the ACPI
platform pre-snapshot callback, so it should avoid `_PTS(4)` while still writing
the image before using the normal shutdown path.

This setting is fail-closed in systemd 261: `systemd-sleep` replaces its parsed
mode list with the configured value, writes that value to `/sys/power/disk`, and
returns without writing `disk` to `/sys/power/state` if mode selection fails.
There is no `platform` fallback when the configured list contains only
`shutdown`.

No lid-switch or ordinary suspend setting was changed. The existing
`HandleLidSwitch=suspend-then-hibernate`, `mem_sleep_default=s2idle`, and
`SuspendState=mem` settings remain as they were.

## Diagnostics

`scripts/legion-hibernate-diagnostics.sh` is installed as
`/etc/systemd/system-sleep/legion-hibernate-diagnostics`. It exits immediately
unless systemd invokes a direct `hibernate` action. For a controlled run it
captures these root-visible states in
`/var/log/legion-hibernate-diagnostics/<timestamp>-<boot-id>`:

- boot ID, uptime, kernel version, selected `/sys/power/disk` mode, and PM debug
  controls;
- authoritative graphics-mode JSON and NVIDIA PCI presence;
- root-port power, wake, and PCIe link state;
- ACPI wake configuration, kernel wakeup sources, wake IRQ, and suspend failure
  counters;
- processes, systemd jobs and failures, and the relevant kernel/systemd journal.

The `initial-preflight` snapshot is taken before graphical quiescing. The
`pre-hibernate` and `post-hibernate` snapshots run from systemd's sleep-hook
window while `user.slice` is frozen. An `UNSAFE-HIBERNATION-MODE` marker records
any unexpected mode observed after systemd performs its own mode write.

## Controlled test

The guarded runner is
`LenovoLegionLinuxFrontend/tool/test_igpu_only_hibernate_tty.sh`. It must be run
from a Linux virtual console. It refuses to continue unless:

- the effective final systemd configuration is exactly
  `HibernateMode=shutdown`;
- the kernel advertises shutdown mode;
- no external display is connected;
- policy is `hybrid-igpu-only` with detached, settled topology;
- final root client inspection is complete and reports no active dGPU clients.

The runner enables and verifies `pm_debug_messages` and `pm_print_times`, creates
a fresh persistent evidence run, stops graphical and audio clients, explicitly
selects and verifies `[shutdown]`, and then requires the literal confirmation
`HIBERNATE-SHUTDOWN`. Diagnostics are restored after the command returns. The
display manager is restarted only when hibernate returned successfully and the
dGPU remains detached and settled; otherwise it remains stopped for controlled
Hybrid recovery.

## Validation status

The configuration and scripts passed Bash syntax, `shfmt`, ShellCheck, Nix
format/evaluation, and a complete NixOS host build on 2026-09-02. Activation and
the hardware hibernate/resume test are still pending. Platform mode must not be
retried.
