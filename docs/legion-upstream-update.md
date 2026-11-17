# Legion backend update

The `legion-driver` input supplies both the kernel module and the CLI/GUI.
It pins the fork's merge commit `baafe12ccb4bea628aecccfb0e53309fa9c6be00`,
which includes upstream `98531565555d43c2e34c2c487ffcbba273c5e803` and the
seven local M1CN power and graphics fixes. See
[the driver PR](https://github.com/Prn-Ice/LenovoLegionLinux/pull/3).

The input now fetches that commit from GitHub rather than requiring a local
checkout. Builds remain pinned; updating other inputs does not advance the
driver. Update the explicit revision in `flake.nix`, then run
`nix flake update legion-driver` to regenerate its lock entry.

The overlay sets `0.1.8-unstable-2026-11-17` for both packages. Previously,
overriding only the source left the unrelated Nixpkgs version in their names.
Update this version alongside future source changes.

## Preserved behavior and new safeguards

- M1CN power limits use WMI3 and reject writes outside Custom mode.
- Graphics changes retain readback checks, rollback, active-client checks,
  and separate selected-policy and actual-device status.
- Upstream's M1CN fan-write restrictions remain enabled. This update does
  not opt into unvalidated fan writes or widen the hardware allowlist.
- Existing Polkit rules and kernel-module installation remain unchanged.

## Verification

The merged backend passed 161 unit tests, a C harness for M1CN writes,
505 capability-fixture cases, pylint, kernel checkpatch, formatting, and
the `legiond` build. Its Nix CLI/GUI package and Linux 7.3.4 module built.
The packaged CLI help command and offscreen GUI automatic-close check passed;
the GUI reported the existing permission error for an unprivileged fan read.

The full system build also passed for this computer's working configuration,
including its existing unrelated local edits. An initial optional-cache outage
was resolved with Nix's `--fallback` option; the standard command then passed
without it. All seven checks on the driver PR passed.

Build the system without activating it:

```sh
cd ~/Dotfiles/nixos-flaky-tests
nixos-rebuild build --flake .#nixos
```

Expected result: the command succeeds and creates `result` without changing
the running system or boot default. Use the repository path: `/etc/nixos`
contains absolute symlinks, which fail when Nix copies that directory as a
flake source.

No new module has been loaded. GPU transitions, power writes, fan behavior,
and resume still need verification after a separately approved activation.
