# External kernel module certificates

## Problem

After updating nixpkgs to Linux 7.3.1, the combined kernel module tree failed
with:

```text
cat: kernel/drivers/platform/x86/legion-laptop.ko.cer: No such file or directory
```

The Lenovo Legion module itself compiled successfully. The failure happened
later, while nixpkgs aggregated the in-tree and external modules.

## Cause

Nixpkgs passes a `cmd_sign` implementation backed by `kmodigest` to external
module builds. Its module aggregator expects every external module to provide a
matching `.ko.cer` certificate sidecar.

LenovoLegionLinux's custom `install` target copied only `legion-laptop.ko`, so
the certificate produced by the kernel build system was omitted from the
package output.

## Solution

`hosts/nixos/hardware/legion_slim.nix` overrides only the module's installation
settings and uses Kbuild's standard `modules_install` target. Kbuild now strips,
signs, compresses, and installs the module together with
`legion-laptop.ko.cer`.

Verify the package and aggregate module tree with:

```sh
nix build --impure --expr \
  'builtins.head (builtins.getFlake (toString ./.)).nixosConfigurations.nixos.config.boot.extraModulePackages' \
  --no-link --print-build-logs

nix build .#nixosConfigurations.nixos.config.system.modulesTree \
  --no-link --print-build-logs
```

