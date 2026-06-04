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

# detect_turbo_state: sets/exports CRUCIBLE_TURBO (on|off) unless already set.
# Primary: /sys/.../cpufreq/boost sysfs. Fallback: cpupower frequency-info.
detect_turbo_state() {
    if [ -n "${CRUCIBLE_TURBO:-}" ]; then return; fi
    local boost_sysfs
    boost_sysfs=$(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo "")
    case "$boost_sysfs" in
        "0") export CRUCIBLE_TURBO=off ;;
        "1") export CRUCIBLE_TURBO=on  ;;
        *)
            local boost
            boost=$(cpupower frequency-info 2>/dev/null \
                | awk '/boost state support/{flag=1; next} flag && /Active/{print tolower($2); exit}')
            case "$boost" in
                no)  export CRUCIBLE_TURBO=off ;;
                yes) export CRUCIBLE_TURBO=on  ;;
                *)
                    echo "FATAL: cannot determine boost state from sysfs or cpupower." >&2
                    echo "  Set CRUCIBLE_TURBO=on|off manually, or check driver:" >&2
                    echo "  lsmod | grep cpufreq; cpupower frequency-info" >&2
                    exit 1 ;;
            esac ;;
    esac
}

# assert_boost_off: detect turbo state, cross-check via amd_pstate MAXMHZ,
# then abort if boost is on. Not bypassable via --skipchecks.
# Override (boost-on captures only): export CRUCIBLE_ALLOW_BOOST=1 before calling.
assert_boost_off() {
    if [[ "${CRUCIBLE_ALLOW_BOOST:-}" == "1" ]]; then
        echo "WARNING: boost gate bypassed (CRUCIBLE_ALLOW_BOOST=1)" >&2
        return 0
    fi

    detect_turbo_state
    echo "CRUCIBLE_TURBO=$CRUCIBLE_TURBO (verified)" >&2

    # Cross-check via amd_pstate base_frequency: if MAXMHZ > base*1.05, BIOS CPB is active.
    local max_mhz base_khz base_mhz
    max_mhz=$(lscpu 2>/dev/null | awk '/CPU max MHz/{gsub(/\..*/, "", $NF); print $NF+0}')
    base_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/base_frequency 2>/dev/null || echo "0")
    if [[ "${max_mhz:-0}" -gt 0 && "${base_khz:-0}" -gt 0 ]]; then
        base_mhz=$(( base_khz / 1000 ))
        if [[ "${max_mhz}" -gt $(( base_mhz * 105 / 100 )) ]]; then
            echo "FATAL: MAXMHZ=${max_mhz} MHz exceeds base ${base_mhz} MHz by >5%." >&2
            echo "  BIOS Core Performance Boost appears active despite software toggle off." >&2
            echo "  Disable in BIOS: Ai Tweaker → Core Performance Boost → Disabled." >&2
            echo "  Verify: lscpu | grep 'max MHz'  (expect ~${base_mhz}, not ${max_mhz})" >&2
            exit 1
        fi
    fi

    if [[ "${CRUCIBLE_TURBO}" == "on" ]]; then
        echo "FATAL: Core Performance Boost is enabled (CRUCIBLE_TURBO=on)." >&2
        echo "  Disable in BIOS: Ai Tweaker → Core Performance Boost → Disabled (master switch)." >&2
        echo "  PBO-off alone is insufficient — use the CPB master switch." >&2
        echo "  Verify: lscpu | grep 'max MHz'  (expect ~3900, not 4560)" >&2
        echo "  Override (boost-on captures only): export CRUCIBLE_ALLOW_BOOST=1" >&2
        exit 1
    fi
}
