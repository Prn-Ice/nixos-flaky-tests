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

## Shutdown-mode workaround

`hosts/nixos/hardware/hibernate.nix` now configures the single systemd
`HibernateMode` value `shutdown`. Linux shutdown-mode hibernation skips the ACPI
platform pre-snapshot callback, avoiding `_PTS(4)`, writes the image, and uses
the normal shutdown path.

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
- authoritative graphics-mode JSON in the initial capture;
- fixed NVIDIA/root-port presence, driver binding, and runtime-power state in
  the frozen captures, without PCI configuration-space probes;
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

## Validation result

The first shutdown-mode attempt in boot `76d2cb91` on 2026-09-02 successfully
created and restored a hibernation image. The pre-hook snapshot confirmed
`[shutdown]`, so the kernel bypassed ACPI platform preparation and `_PTS(4)`.
It preallocated snapshot memory, froze devices, disabled secondary CPUs, passed
the `pm_wakeup_pending()` check, and entered `swsusp_save()`.

Systemd's `/sys/power/state` write returned successfully and the same kernel boot
ID resumed. Wall clock advanced about 93 seconds while kernel monotonic time
advanced 11.212 seconds, leaving roughly 82 seconds in the powered-off state.
The absent image-write/restore messages were PM-debug messages suppressed by the
runner race below, not evidence that image creation was skipped.

NVIDIA reappeared during kernel device restoration, before systemd's post hook
and before `user.slice` thaw. A MediaTek `mt7921e` restore timeout on
`0000:03:00.0` was a separate device-resume error. The remaining iGPU-only defect
is therefore post-resume NVIDIA topology, not failed hibernation.

The first runner also exposed two instrumentation bugs: `systemctl hibernate`
returned as soon as the job was queued, causing PM diagnostics to be restored
too early, and the frozen hook lacked `bash` in `PATH` for the graphics CLI.
The code now requires an initially inactive `systemd-hibernate.service`, observes
a new nonzero service start timestamp, and tracks that invocation until it
finishes; `--wait` does not make the normal logind request synchronous. It also
supplies Bash, skips the graphics CLI while sessions are frozen, and avoids
`lspci`, broad PCI sysfs scans, power-state reads, and PCI link attributes because
the initial capture runtime-resumed the NVIDIA root port and perturbed the
baseline. Graphical recovery additionally requires complete evidence and a
successful, complete root graphics inspection with zero clients and detached,
settled topology. These fixes passed formatting, syntax, ShellCheck, diff checks,
and a full host build but have not been hardware-retested.

The frontend NixOS module now provides
`services.legionControl.reconcileGraphicsAfterHibernate`, defaulting to the
already-enabled boot reconciliation option. Its post hook checks
`SYSTEMD_SLEEP_ACTION=hibernate` and runs before systemd thaws user sessions.
This covers direct hibernate and the final hibernate stage of
suspend-then-hibernate without running after ordinary suspend.

The first deployed hook validation ran in boot
`fafd892b-38b4-4062-98ee-ffe47e352e62` on 2026-09-03. The kernel explicitly
reported `Hibernation image restored successfully`. About 180 ms after
hibernation exit, the original one-shot hook observed partial NVIDIA topology,
incomplete client inspection, blocked reconciliation, and zero reconciliation
attempts. It exited 2 rather than bypassing the client preflight. NVIDIA DRM and
audio completed attached initialization roughly 1.3 seconds later. The guarded
runner kept the display manager stopped, and the restored system remained
running with no failed units. This proved `udevadm settle` did not establish
driver and device-node readiness.

Frontend revision `4248cf8` replaces the one-shot attempt with authoritative
root reconciliation retries every two seconds under one 60-second deadline. It
rejects confirmed clients, malformed or unsupported JSON, and inconsistent
success immediately. It succeeds only with schema version 1, complete client
inspection, no clients, settled reconciliation, and effective topology matching
the expected attached or detached state. Enabling either boot or hibernate
reconciliation now also loads `legion_laptop`.

The user manually powered off after the failed return. New boot `eb9dea5f`
reconciled to detached/settled topology with no failed units. Full evidence is
stored at
`/var/log/legion-hibernate-diagnostics/2026-09-02T12-40-01+01-00-76d2cb91`.
The bounded-retry hook passes focused shell tests, ShellCheck, Nix formatting,
generated no-op dispatch tests, and a full host build. The revision is pinned but
still requires activation and controlled resume validation; platform-mode
hibernation must not be used.
