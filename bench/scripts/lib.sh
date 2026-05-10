#!/usr/bin/env bash
# Shared shell utilities sourced by run_one.sh and tools/perf_capture.sh.
# Source this file after set -euo pipefail is active in the calling script.

set_governor_performance() {
    echo "==> Setting CPU governor to performance..."
    for c in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance | sudo tee "$c" >/dev/null
    done
    local actual
    actual=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo unknown)
    [[ "$actual" == "performance" ]] || { echo "ERROR: governor not performance: $actual" >&2; exit 1; }
}
