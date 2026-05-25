#!/usr/bin/env bash
# Pre-run environment check: stops background noise and verifies CPU state.
# Run from a TTY before any benchmark session, especially after GNOME login,
# which can reset the governor and SMT state.
set -euo pipefail

echo "==> Stopping background indexing and update services..."
tracker3 daemon --terminate
sudo systemctl stop unattended-upgrades.service

echo "==> Verifying CPU governor is still 'performance'..."
if ! cpupower frequency-info | grep -q "performance"; then
    echo "ERROR: CPU governor is not 'performance'. Re-apply with:" >&2
    echo "  sudo cpupower frequency-set -g performance" >&2
    exit 1
fi

echo "==> Verifying SMT is disabled..."
smt=$(cat /sys/devices/system/cpu/smt/active)
if [[ "$smt" != "0" ]]; then
    echo "ERROR: SMT is active (value=${smt}). Disable before benchmarking:" >&2
    echo "  echo off | sudo tee /sys/devices/system/cpu/smt/control" >&2
    exit 1
fi

echo "==> Migrating all running tasks back to the default root cpuset..."
sudo cset shield --reset > /dev/null 2>&1 || true

echo "==> Environment OK."
