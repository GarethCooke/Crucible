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

# assert_boost_off: gate on real sysfs boost signals, not MAXMHZ.
# Priority: (1) per-CPU cpb, (2) global cpufreq/boost, (3) scaling_available_frequencies vs base.
# Degrades safely — if no signal is present (Pi/ARM) the gate passes rather than fails closed.
# Override (boost-on captures only): export CRUCIBLE_ALLOW_BOOST=1 before calling.
assert_boost_off() {
    if [[ "${CRUCIBLE_ALLOW_BOOST:-}" == "1" ]]; then
        echo "WARNING: boost gate bypassed (CRUCIBLE_ALLOW_BOOST=1)" >&2
        return 0
    fi

    local max_mhz
    max_mhz=$(lscpu 2>/dev/null | awk '/CPU max MHz/{gsub(/\..*/, "", $NF); print $NF+0}') || true

    # 1. Per-CPU cpb (acpi-cpufreq, Ryzen). Most reliable signal on this rig.
    local cpb_found=0 cpb_on=0 cpb_off=0 cpb_path val
    for cpb_path in /sys/devices/system/cpu/cpu*/cpufreq/cpb; do
        [[ -r "$cpb_path" ]] || continue
        cpb_found=1
        val=$(<"$cpb_path")
        if [[ "$val" == "1" ]]; then
            cpb_on=$(( cpb_on + 1 ))
        else
            cpb_off=$(( cpb_off + 1 ))
        fi
    done

    if [[ "$cpb_found" -eq 1 ]]; then
        if [[ "$cpb_on" -gt 0 ]]; then
            echo "FATAL: Core Performance Boost is enabled (cpb=1 on ${cpb_on} CPU(s))." >&2
            echo "  Disable in BIOS: Core Performance Boost → Disabled." >&2
            echo "  Verify: cat /sys/devices/system/cpu/cpu0/cpufreq/cpb  (expect 0)" >&2
            echo "  Override (boost-on captures only): export CRUCIBLE_ALLOW_BOOST=1" >&2
            exit 1
        fi
        echo "CRUCIBLE_TURBO=off  (cpb=0 on ${cpb_off} CPU(s); MAXMHZ=${max_mhz:-?} MHz — advisory)" >&2
        return 0
    fi

    # 2. Global cpufreq/boost (absent on this rig; present on some acpi-cpufreq boards).
    local boost_sysfs
    boost_sysfs=$(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo "")
    if [[ "$boost_sysfs" == "1" ]]; then
        echo "FATAL: Core Performance Boost is enabled (cpufreq/boost=1)." >&2
        echo "  Disable in BIOS: Core Performance Boost → Disabled." >&2
        echo "  Override (boost-on captures only): export CRUCIBLE_ALLOW_BOOST=1" >&2
        exit 1
    elif [[ "$boost_sysfs" == "0" ]]; then
        echo "CRUCIBLE_TURBO=off  (cpufreq/boost=0)" >&2
        return 0
    fi

    # 3. scaling_available_frequencies top vs amd_pstate base (where both are present).
    local avail_raw avail_top_khz base_khz
    avail_raw=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies 2>/dev/null || echo "")
    base_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/base_frequency 2>/dev/null || echo "0")
    avail_top_khz=0
    if [[ -n "$avail_raw" ]]; then
        avail_top_khz=$(echo "$avail_raw" | awk '{m=0; for(i=1;i<=NF;i++) if($i+0>m) m=$i+0; print m}')
        avail_top_khz=${avail_top_khz:-0}
    fi
    if [[ "${avail_top_khz:-0}" -gt 0 && "${base_khz:-0}" -gt 0 ]]; then
        if [[ "$avail_top_khz" -gt $(( base_khz * 105 / 100 )) ]]; then
            local avail_top_mhz base_mhz
            avail_top_mhz=$(( avail_top_khz / 1000 ))
            base_mhz=$(( base_khz / 1000 ))
            echo "FATAL: scaling_available top=${avail_top_mhz} MHz exceeds base ${base_mhz} MHz by >5%." >&2
            echo "  Core Performance Boost appears active." >&2
            echo "  Override (boost-on captures only): export CRUCIBLE_ALLOW_BOOST=1" >&2
            exit 1
        fi
        local avail_top_mhz base_mhz
        avail_top_mhz=$(( avail_top_khz / 1000 ))
        base_mhz=$(( base_khz / 1000 ))
        echo "CRUCIBLE_TURBO=off  (scaling_avail_top=${avail_top_mhz} MHz ≤ base=${base_mhz} MHz)" >&2
        return 0
    fi

    # No signal found: pass safely (Pi/ARM, unknown driver — no fail-closed).
    echo "CRUCIBLE_TURBO=unknown  (no boost signal detected; MAXMHZ=${max_mhz:-?} MHz — passing)" >&2
}
