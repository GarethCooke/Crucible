#!/usr/bin/env bash
# topology.sh — capture ground-truth CPU topology for demo 10 (§A0/A1).
#
# On Zen 2, L3 cache sharing IS CCX membership: the CPUs that share an L3
# (index3) slice are exactly one CCX. This dumps that grouping straight from
# sysfs BEFORE any latency measurement, so A1 predicts the CCX seam from
# hardware and measurement then confirms or contradicts it — rather than
# inferring topology from latency alone.
#
# Writes plain text to stdout and to pilot_logs/topology.txt.
# Machine 1 (Ryzen 7 3800X, Matisse/Zen 2) only; throwaway calibration.
#
# REPORT WHAT IT ACTUALLY SAYS — do not assume 0-3 / 4-7.

set -uo pipefail   # not -e: a missing optional sysfs file must not abort the dump

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/pilot_logs"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/topology.txt"

# Read a sysfs file, or print 'n/a' if it is absent/unreadable.
cpu_field() {
    local p="$1"
    if [[ -r "$p" ]]; then
        cat "$p" 2>/dev/null || echo "n/a"
    else
        echo "n/a"
    fi
}

report() {
    echo "=============================================================="
    echo " Crucible demo 10 — CPU topology ground truth"
    echo " host: $(uname -n)   kernel: $(uname -r)   arch: $(uname -m)"
    echo "=============================================================="
    echo

    echo "--- lscpu -e (core / socket / node enumeration) ---"
    lscpu -e 2>/dev/null || echo "  lscpu unavailable"
    echo

    echo "--- L3 sharing per CPU (index3) — on Zen 2 this IS CCX membership ---"
    for c in /sys/devices/system/cpu/cpu[0-9]*; do
        [[ -e "$c/cache/index3/shared_cpu_list" ]] || continue
        printf "  %-7s L3 shared_cpu_list: %s\n" \
            "$(basename "$c"):" "$(cat "$c/cache/index3/shared_cpu_list" 2>/dev/null)"
    done
    echo
    echo "  Distinct L3 domains (each distinct line = one CCX):"
    for c in /sys/devices/system/cpu/cpu[0-9]*; do
        [[ -e "$c/cache/index3/shared_cpu_list" ]] \
            && cat "$c/cache/index3/shared_cpu_list" 2>/dev/null
    done | sort -u | sed 's/^/    /'
    echo

    echo "--- L1d (index0) and L2 (index2) sharing, for completeness ---"
    for c in /sys/devices/system/cpu/cpu[0-9]*; do
        local n l1 l2
        n="$(basename "$c")"
        l1="$(cpu_field "$c/cache/index0/shared_cpu_list")"
        l2="$(cpu_field "$c/cache/index2/shared_cpu_list")"
        printf "  %-7s L1d: %-10s L2: %-10s\n" "$n:" "$l1" "$l2"
    done
    echo

    echo "--- isolation / SMT state ---"
    echo "  isolated:   $(cpu_field /sys/devices/system/cpu/isolated)"
    echo "  nohz_full:  $(cpu_field /sys/devices/system/cpu/nohz_full)"
    echo "  smt/active: $(cpu_field /sys/devices/system/cpu/smt/active)  (0 = SMT off)"
    echo

    echo "--- hwloc lstopo (optional) ---"
    if command -v lstopo-no-graphics >/dev/null 2>&1; then
        lstopo-no-graphics --of console 2>/dev/null || echo "  lstopo present but failed to run"
    else
        echo "  lstopo-no-graphics not installed (hwloc absent) — skipped."
    fi
    echo

    echo "Expected on a 3800X with SMT off: two L3 domains, 0-3 and 4-7."
    echo "This grouping is A1's PREDICTION — measurement then confirms or contradicts it."
}

report | tee "$LOG"
