#!/usr/bin/env bash

set -euo pipefail  # Enable strict error handling

# Detect NVIDIA and AMD PCI addresses
nvidia_pci=$(lspci | grep -i 'VGA' | grep -i nvidia | awk '{print $1}')
amd_pci=$(lspci | grep -i 'VGA' | grep -i amd | awk '{print $1}')

# Function to map PCI address to DRM card index
get_drm_card() {
  local pci_address=$1
  for card in /sys/class/drm/card*; do
    if readlink -f "$card/device" | grep -q "$pci_address"; then
      basename "$card"
      return
    fi
  done
}

# Map PCI addresses to DRM card indices
nvidia_card=$(get_drm_card "0000:$(echo "$nvidia_pci" | head -n 1)")  # Use the first NVIDIA PCI address
amd_card=$(get_drm_card "0000:$(echo "$amd_pci" | head -n 1)")  # Use the first AMD PCI address

# Detect outputs for AMD (eDP prefix)
get_amd_edp_output() {
  local card=$1
  for status in /sys/class/drm/${card}-eDP-*/status; do
    echo "${status%/status}" | awk -F'-' '{print $2"-"$3}'
    return
  done
}

# Detect outputs for NVIDIA (DP prefix)
get_nvidia_dp_output() {
  local card=$1
  for status in /sys/class/drm/${card}-DP-*/status; do
    echo "${status%/status}" | awk -F'-' '{print $2"-"$3}'
    return
  done
}

# Get the connectors
nvidia_connector=$(get_nvidia_dp_output "$nvidia_card")
amd_connector=$(get_amd_edp_output "$amd_card")

# Output directory for connector information (within repo for pure builds)
REPO_ROOT="${HOME}/Dotfiles/nixos-flaky-tests"
OUTPUT_DIR="$REPO_ROOT/generated"
NIX_FILE="$OUTPUT_DIR/connectors.nix"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Write connector values to Nix file
cat > "$NIX_FILE" << EOF
{
  nvidiaConnector = "$nvidia_connector";
  amdConnector = "$amd_connector";
}
EOF

# Also output to stdout for debugging
echo "Detected connectors written to: $NIX_FILE"
echo "Values:"
echo "  nvidiaConnector=$nvidia_connector"
echo "  amdConnector=$amd_connector"