# view-beads npm dependency hash

## Problem

The locked `view-beads` 0.3.0 flake declares an outdated `npmDepsHash`, causing
the NixOS rebuild to fail before Home Manager can assemble the user profile.
Nix reported the corrected hash as:

```text
sha256-u5QON0kbf94Z8ryLc0lyIiuBCjzBMEN+KAmNgsNRcX4=
```

## Solution

`modules/home-manager/programs/development.nix` overrides the input package's
already-created `npmDeps` fixed-output derivation and updates its `outputHash`.
Overriding only `npmDepsHash` is insufficient because `buildNpmPackage` has
already used it to construct `npmDeps` by the time `overrideAttrs` runs.

This override can be removed after the same hash correction is released by the
`beads-viewer` input and `flake.lock` is updated to that revision.

