#!/usr/bin/env bash
# pi-preflight.sh
# Read-only guard: asserts Raspberry Pi 5 is capture-ready.
# Exits nonzero with a specific message on the first failure.
# Run after pi-rig-setup.sh and before any capture.
#
# Design note: vcgencmd get_throttled is checked strictly for 0x0.
# Any nonzero value (including "occurred since boot" high-bit flags) aborts.
# A cooled, well-powered rig reads 0x0; an earlier throttle is worth knowing.

set -euo pipefail

# ─── Guard: Pi 5 / AArch64 only ──────────────────────────────────────────────
if [[ "$(uname -m)" != "aarch64" ]]; then
    echo "ERROR: this script is for AArch64 only (got: $(uname -m)). Do not run on the x86 rig." >&2
    exit 1
fi
if ! grep -q "Raspberry Pi 5" /proc/device-tree/model 2>/dev/null; then
    echo "ERROR: /proc/device-tree/model does not identify this as a Raspberry Pi 5." >&2
    echo "       Found: $(cat /proc/device-tree/model 2>/dev/null || echo '<unreadable>')" >&2
    exit 1
fi

pass() { printf "  [pass] %s\n" "$*"; }
warn() { printf "  [warn] %s\n" "$*"; }
fail() { printf "  [FAIL] %s\n" "$*" >&2; }

warnings=0
pinned_mhz=""
throttled_val=""

# ─── 1. Core isolation ────────────────────────────────────────────────────────
iso_actual=$(cat /sys/devices/system/cpu/isolated 2>/dev/null || echo "")
if [[ "$iso_actual" != "2-3" ]]; then
    fail "core isolation not active (got '${iso_actual}', expected '2-3')."
    echo "      Apply cmdline.txt boot params and reboot — see README." >&2
    exit 1
fi
pass "core isolation = 2-3"

# ─── 2. Governor on isolated cores ───────────────────────────────────────────
for core in 2 3; do
    gov_path="/sys/devices/system/cpu/cpu${core}/cpufreq/scaling_governor"
    if [[ ! -r "$gov_path" ]]; then
        fail "cannot read governor for cpu${core}: $gov_path"
        exit 1
    fi
    gov=$(cat "$gov_path")
    if [[ "$gov" != "performance" ]]; then
        fail "cpu${core} governor is '${gov}', not 'performance'. Run: sudo ./bench/scripts/pi-rig-setup.sh"
        exit 1
    fi
    pass "cpu${core} governor = performance"
done

# ─── 3. Clock pinned on isolated cores ───────────────────────────────────────
for core in 2 3; do
    min_path="/sys/devices/system/cpu/cpu${core}/cpufreq/scaling_min_freq"
    max_path="/sys/devices/system/cpu/cpu${core}/cpufreq/scaling_max_freq"
    if [[ ! -r "$min_path" || ! -r "$max_path" ]]; then
        fail "cannot read scaling freq paths for cpu${core}."
        exit 1
    fi
    min_freq=$(cat "$min_path")
    max_freq=$(cat "$max_path")
    if [[ "$min_freq" != "$max_freq" ]]; then
        fail "cpu${core} clock not pinned: scaling_min_freq=${min_freq} kHz, scaling_max_freq=${max_freq} kHz."
        echo "      Run: sudo ./bench/scripts/pi-rig-setup.sh" >&2
        exit 1
    fi
    mhz=$(( max_freq / 1000 ))
    [[ -z "$pinned_mhz" ]] && pinned_mhz="${mhz}"
    pass "cpu${core} clock pinned = ${mhz} MHz"
done

# ─── 4. No throttling ────────────────────────────────────────────────────────
if ! command -v vcgencmd >/dev/null 2>&1; then
    fail "vcgencmd not found. Install: sudo apt install libraspberrypi-bin"
    echo "      The throttle check is the Pi rig's turbo-off guarantee and cannot be skipped." >&2
    exit 1
fi
throttled_val=$(vcgencmd get_throttled 2>/dev/null | sed 's/throttled=//')
if [[ "$throttled_val" != "0x0" ]]; then
    fail "throttle status is ${throttled_val} (expected 0x0)."
    # Decode bits to aid diagnosis
    val=$(( throttled_val ))
    msg=""
    (( val & 0x1     )) && msg+=" under-voltage-now"
    (( val & 0x2     )) && msg+=" arm-freq-capped-now"
    (( val & 0x4     )) && msg+=" throttled-now"
    (( val & 0x8     )) && msg+=" soft-temp-limit-now"
    (( val & 0x10000 )) && msg+=" under-voltage-occurred"
    (( val & 0x20000 )) && msg+=" arm-freq-capped-occurred"
    (( val & 0x40000 )) && msg+=" throttled-occurred"
    (( val & 0x80000 )) && msg+=" soft-temp-limit-occurred"
    echo "      Active/historical flags:${msg}" >&2
    echo "      Check active cooler, PSU (≥5A official supply), and ambient temperature." >&2
    exit 1
fi
pass "throttle = 0x0 (no throttling active or historical)"

# ─── 5. perf usable ──────────────────────────────────────────────────────────
paranoid=$(sysctl -n kernel.perf_event_paranoid 2>/dev/null || echo 99)
if [[ "$paranoid" -gt 1 ]]; then
    fail "kernel.perf_event_paranoid=${paranoid} (must be ≤ 1). Run: sudo ./bench/scripts/pi-rig-setup.sh"
    exit 1
fi
pass "kernel.perf_event_paranoid=${paranoid}"

if ! perf stat -e cycles true >/dev/null 2>&1; then
    fail "perf stat -e cycles true failed. Check perf installation and permissions."
    echo "      Try: sudo apt install linux-perf  (or linux-tools-\$(uname -r))" >&2
    exit 1
fi
pass "perf stat functional"

# ─── 6. Isolated cores idle (warning only) ───────────────────────────────────
pinned_pids=""
for pid in /proc/[0-9]*/status; do
    pid_dir=$(dirname "$pid")
    pid_num=$(basename "$pid_dir")
    # Skip kernel threads (no /proc/PID/exe)
    [[ -e "${pid_dir}/exe" ]] || continue
    aff_file="${pid_dir}/status"
    # Read allowed_list from /proc/PID/status
    aff=$(grep "^Cpus_allowed_list:" "${pid_dir}/status" 2>/dev/null | awk '{print $2}' || true)
    # Warn if affinity explicitly includes core 2 or 3
    # Simple check: if the list contains 2 or 3 as standalone tokens
    if echo "$aff" | grep -qE '(^|,|-)(2|3)(,|-|$)' 2>/dev/null; then
        comm=$(cat "${pid_dir}/comm" 2>/dev/null || echo "?")
        pinned_pids="${pinned_pids} ${pid_num}(${comm})"
    fi
done
if [[ -n "$pinned_pids" ]]; then
    warn "user tasks pinned to isolated cores 2-3:${pinned_pids}"
    warn "Consider unpinning before capture."
    warnings=$(( warnings + 1 ))
else
    pass "no user tasks pinned to isolated cores 2-3"
fi

# ─── Summary ──────────────────────────────────────────────────────────────────
echo ""
if [[ "$warnings" -eq 0 ]]; then
    printf "\033[32m[ALL PASS]\033[0m clock=%s MHz, throttled=%s — Pi 5 capture-ready.\n" \
        "${pinned_mhz}" "${throttled_val}"
else
    printf "\033[33m[PASS with %d warning(s)]\033[0m clock=%s MHz, throttled=%s — review warnings before capture.\n" \
        "$warnings" "${pinned_mhz}" "${throttled_val}"
fi
