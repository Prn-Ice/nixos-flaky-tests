#!/usr/bin/env nix-shell
#! nix-shell update-shell.nix -i bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
WINDSURF_NIX="$SCRIPT_DIR/windsurf.nix"

# Fetch the latest version from the APT repository
latest_version=$(curl -sS "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt/dists/stable/main/binary-amd64/Packages" | grep -A1 "Package: windsurf" | grep "Version:" | cut -d' ' -f2)

# Extract the current version from windsurf.nix
current_version=$(sed -nE 's/.*version = "(.*)".*/\1/p' "$WINDSURF_NIX")

if [ "$latest_version" != "$current_version" ]; then
    echo "Updating Windsurf from $current_version to $latest_version"

    # Update the version in windsurf.nix
    sed -i "s/version = \".*\"/version = \"$latest_version\"/" "$WINDSURF_NIX"

    # Construct the new URL
    new_url="https://windsurf-stable.codeiumdata.com/linux-x64/stable/599ce698a84d43160da884347f22f6b77d0c8415/Windsurf-linux-x64-$latest_version.tar.gz"

    # Fetch the new tarball and get its hash
    new_hash=$(nix-prefetch-url --type sha256 "$new_url")

    # Update the SHA256 in windsurf.nix
    sed -i "s|sha256 = \".*\"|sha256 = \"$new_hash\"|" "$WINDSURF_NIX"

    echo "Updated Windsurf to version $latest_version"
else
    echo "Windsurf is already at the latest version ($current_version)"
fi