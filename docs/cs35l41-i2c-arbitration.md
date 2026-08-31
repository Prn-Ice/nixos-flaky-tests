# CS35L41 I2C Arbitration Experiment

## Problem

The internal speakers on the Lenovo Legion Slim 7 16APH8 (`82Y4`) can fail
because both CS35L41 amplifiers abort their initial I2C transactions. The
failing controller is `AMDI0010:03` (`\_SB_.I2CD`, ACPI UID 3), and the kernel
reports repeated `i2c_dw_handle_tx_abort: lost arbitration` errors.

The audio stack, ALSA routing, firmware, calibration files, and the upstream
`17AA38B7` CS35L41 quirk have been verified. The failure occurs across multiple
kernel versions. Disabling OpenRGB and performing a full cold reset did not
restore amplifier binding, so OpenRGB is not the source of the boot-time
contention.

## Upstream Finding

WangYuli proposed enabling AMD PSP semaphore arbitration for every
`AMDI0010` controller:

- <https://marc.info/?l=linux-i2c&m=177029472317067&w=2>

The proposal was not accepted. Applying it unchanged is unsafe here because
the machine exposes multiple `AMDI0010` controllers while the Linux AMD PSP
helper permits only one controller to register. AMD review also noted that
the PSP semaphore is required only on specific designs.

## Related Discussions

No public report was found with the complete combination of Lenovo `82Y4`,
`17AA38B7`, `CSC3551`, `AMDI0010:03`, and lost-arbitration probe failures as of
2026-08-30. These are the closest reports:

| Discussion | Similarity and status |
| --- | --- |
| [WangYuli PSP semaphore v2](https://lore-kernel.gnuweeb.org/all/20260205114451.30445-1-wangyuli@aosc.io/T/) | Directly addresses `AMDI0010` lost arbitration using the AMD PSP helper, but on a Strix Point touchpad at UID 1. It is unmerged and marked changes-requested. AMD specifically requested hardware details, logs, and a kernel config. |
| [Arch HP Phoenix/CSC3551 report](https://bbs.archlinux.org/viewtopic.php?id=304624) | Phoenix `1022:15c7`, CSC3551 amplifiers, and sustained arbitration loss on `AMDI0010:01`. Both amplifiers eventually bind, so it is the closest hardware-class match rather than the same failure. |
| [Pop!_OS Lenovo 82Y4 no-audio report](https://www.reddit.com/r/pop_os/comments/18nzhva/lenovo_legion_slim_7i_no_sound_coming_from/) | Exact laptop model and unresolved internal-speaker failure, but the report has no I2C logs proving the same cause. |
| [Lenovo Yoga touchscreen issue](https://github.com/linuxwacom/input-wacom/issues/508) | Active `AMDI0010:02` lost-arbitration report on Strix/Gorgon Point. It affects a touchscreen and may involve different firmware or probe-order behavior. |
| [CS35L41 reset patch](https://lkml.rescloud.iu.edu/2603.0/01471.html) and [kernel bug 221161](https://bugzilla.kernel.org/show_bug.cgi?id=221161) | Similar `OTP_BOOT_DONE` symptom, but on SPI during resume. This is not the correct venue for the AMD I2C arbitration result. |

## Upstream Follow-Up

The best reporting path is a reply-all to WangYuli's v2 thread. The report
should be presented as an additional hardware data point, not as `Tested-by`,
because the global `AMDI0010` change was not tested unchanged.

Include this evidence:

- Lenovo `82Y4`, Phoenix PSP `1022:15c7`, and the ACPI UID-to-controller map.
- Stock failures with 46 to 241 arbitration losses and no amplifier binds.
- Six successful scoped-path boots with zero losses and two binds per boot.
- The failed early-`ccp` control, which initialized PSP at the same time but
  still produced 241 losses.
- The immediate `PSP communication error` and fail-open behavior on every
  successful boot.
- The multi-controller problem with enabling the semaphore globally.

Ask AMD whether Phoenix supports this doorbell command, how firmware identifies
the shared I2C controller, and which raw response data would explain the
communication error. A built-in-CCP-only control remains the next useful test
before claiming that the initial PSP request itself is the fix.

## First Experiment: Scoped PSP Path

`hosts/nixos/hardware/legion-slim-amdpsp-i2c.patch` enables
`ARBITRATION_SEMAPHORE` only when all of these conditions match:

- DMI system vendor is `LENOVO`.
- DMI product name is `82Y4`.
- The ACPI device is `AMDI0010` with UID 3.

`hosts/nixos/hardware/legion_slim.nix` also sets:

```text
CONFIG_CRYPTO_DEV_CCP_DD=y
CONFIG_I2C_DESIGNWARE_AMDPSP=y
```

Building the CCP/PSP driver into the kernel is required because the built-in
DesignWare platform driver cannot link its AMD PSP support to a module.
Controllers with UID 0 and 1 retain their existing behavior.

## Risks

The PSP protocol does not include a controller identifier. Phoenix firmware
might arbitrate a different physical bus, in which case this experiment will
not prevent UID 3 arbitration loss. A rejected PSP request can also delay the
first transaction for up to ten seconds before the helper fails open and lets
the host continue without arbitration.

The previous NixOS generation remains the rollback path if the patched kernel
loses the touchpad, delays boot, or fails to expose the amplifier bus.

## Validation Status

First experiment:

- The patch applies cleanly to Linux 7.2 with `patch --dry-run`.
- `nix flake check "path:$PWD" --no-build` passes.
- Nix generates `I2C_DESIGNWARE_PLATFORM=y`,
  `I2C_DESIGNWARE_AMDPSP=y`, and `CRYPTO_DEV_CCP_DD=y`.
- A direct kernel build was cancelled because it was taking too long. The
  subsequent `nixos-rebuild boot` completed and the custom kernel booted.

Second experiment:

- `boot.kernelPatches` evaluates to an empty list.
- The initrd module list contains `ccp`.
- Nix selects the stock Linux 7.2 derivation.
- `nix flake check --no-build` passes.
- A dry run requires initrd and module-wrapper builds, but no Linux kernel
  build.

## First Experiment Results

Five consecutive Linux boots on 2026-08-29 and 2026-08-30, including one
after booting Windows, produced the same sequence:

- The PSP initialized between 1.143 and 1.164 seconds, instead of 4.591 seconds
  on the prior unpatched boot.
- UID 3 reported `I2C bus managed by AMD PSP`.
- The first semaphore request immediately reported `PSP communication error`
  and `Assume i2c bus is for exclusive host usage`.
- No lost-arbitration errors occurred.
- Both amplifiers loaded firmware and reported `CS35L41 Bound`.
- Internal-speaker output was confirmed working.

The semaphore helper fails open after its communication error, so this result
does not show that continued PSP locking prevented contention. The later
early-`ccp` control ruled out initialization timing alone. The remaining
explanations are a side effect from the initial PSP request or a difference
between built-in and modular CCP linkage.

## Second Experiment: Early CCP Module

The second configuration used the unpatched kernel and forced the existing
`ccp` module into the initrd:

```nix
boot.initrd.kernelModules = [ "ccp" ];
```

This used the stock settings `CRYPTO_DEV_CCP_DD=m` and
`I2C_DESIGNWARE_AMDPSP=n`; the custom patch was not included in
`boot.kernelPatches` for this experiment.

The isolation failed. The module initialized PSP at 1.151 seconds, matching the
working custom kernel's timing, but the boot produced 241 lost-arbitration
errors. Neither amplifier bound and internal-speaker output was absent. This
rules out early PSP initialization as the sufficient fix.

Restoring the first configuration immediately returned to zero arbitration
errors, two amplifier binds, and working internal-speaker output. Its
meaningful differences are the UID-3 PSP semaphore path, including the initial
PSP request that reports a communication error, and built-in rather than
modular CCP linkage. A further built-in-CCP-only kernel test would be required
to distinguish those two changes.

## Runtime Test

Keep OpenRGB disabled. Build the restored working generation
without activating it immediately:

```sh
sudo nixos-rebuild boot --flake .#nixos
```

After a cold boot, verify PSP initialization and the amplifier result:

```sh
journalctl -b -k --no-pager -g 'psp enabled|I2C bus managed by AMD PSP|lost arbitration|CS35L41 Bound|cs35l41-hda|failed to probe lock support'
```

Expected success criteria:

- UID 3 reports `I2C bus managed by AMD PSP`.
- No `AMDI0010:03` lost-arbitration burst occurs during amplifier probing.
- Both amplifiers report `CS35L41 Bound` and internal-speaker output works.

If boot or input devices regress, select the previous NixOS generation from
GRUB.
