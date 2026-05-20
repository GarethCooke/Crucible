#!/usr/bin/env bash
# Shared shell utilities sourced by run_one.sh and tools/perf_capture.sh.
# Source this file after set -euo pipefail is active in the calling script.

assert_smt_off() {
    local smt_path=/sys/devices/system/cpu/smt/active
    if [[ ! -r "$smt_path" ]]; then
        echo "WARNING: $smt_path not readable — SMT check skipped (kernel may lack CONFIG_SCHED_SMT)" >&2
        return 0
    fi
    local active
    active=$(<"$smt_path")
    if [[ "$active" != "0" ]]; then
        echo "ERROR: SMT is enabled (smt/active=$active). Disable in BIOS or run:" >&2
        echo "  echo off | sudo tee $smt_path" >&2
        exit 1
    fi
}

EXPECTED_ISOLATED="${EXPECTED_ISOLATED:-1-7}"

assert_isolated_cores() {
    local iso_path=/sys/devices/system/cpu/isolated
    local actual
    actual=$(cat "$iso_path" 2>/dev/null)
    if [[ "$actual" != "$EXPECTED_ISOLATED" ]]; then
        echo "ERROR: isolated cores mismatch — got '$actual', expected '$EXPECTED_ISOLATED'." >&2
        echo "Boot under the benchmark GRUB entry with isolcpus=$EXPECTED_ISOLATED nohz_full=$EXPECTED_ISOLATED rcu_nocbs=$EXPECTED_ISOLATED." >&2
        exit 1
    fi
}

set_governor_performance() {
    echo "==> Setting CPU governor to performance..."
    for c in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance | sudo tee "$c" >/dev/null
    done
    local actual
    actual=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo unknown)
    [[ "$actual" == "performance" ]] || { echo "ERROR: governor not performance: $actual" >&2; exit 1; }
}
