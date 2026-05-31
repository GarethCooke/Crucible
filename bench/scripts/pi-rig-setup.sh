#!/usr/bin/env bash
# pi-rig-setup.sh
# Puts a Raspberry Pi 5 (AArch64) into capture-ready state.
# Must be run as root. Idempotent — safe to re-run.
#
# Mandatory steps (script exits nonzero if these fail):
#   governor → performance, clock pinned, perf_event_paranoid=1
# Best-effort steps (logged but never fail the run):
#   IRQ affinity, quiet services, swap off

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

if [[ "${EUID}" -ne 0 ]]; then
    echo "ERROR: must be run as root (sudo ./pi-rig-setup.sh)." >&2
    exit 1
fi

ok()   { printf "  [ok]   %s\n" "$*"; }
skip() { printf "  [skip] %s\n" "$*"; }
info() { printf "  [info] %s\n" "$*"; }

echo "==> Raspberry Pi 5 bench-rig setup"

# ─── 1. Governor → performance ───────────────────────────────────────────────
echo "--- Governor"
gov_failed=0
for gov_path in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [[ -w "$gov_path" ]] || { skip "not writable: $gov_path"; continue; }
    echo performance > "$gov_path" || { gov_failed=1; skip "write failed: $gov_path"; continue; }
done
# Verify at least cpu0
actual_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo unknown)
if [[ "$actual_gov" != "performance" ]]; then
    echo "ERROR: governor on cpu0 is '$actual_gov', not 'performance'." >&2
    exit 1
fi
if [[ "$gov_failed" -eq 1 ]]; then
    echo "ERROR: one or more governor writes failed." >&2
    exit 1
fi
ok "governor = performance (all CPUs)"

# ─── 2. Pin clock: scaling_min = scaling_max = cpuinfo_max_freq ──────────────
echo "--- Clock pin"
clock_failed=0
pinned_khz=""
for cpu_dir in /sys/devices/system/cpu/cpu[0-9]*; do
    max_path="${cpu_dir}/cpufreq/cpuinfo_max_freq"
    min_w="${cpu_dir}/cpufreq/scaling_min_freq"
    max_w="${cpu_dir}/cpufreq/scaling_max_freq"
    [[ -r "$max_path" ]] || continue
    freq=$(cat "$max_path")
    [[ -z "$pinned_khz" ]] && pinned_khz="$freq"
    if [[ -w "$max_w" ]]; then
        echo "$freq" > "$max_w" || { clock_failed=1; skip "scaling_max_freq write failed: $cpu_dir"; }
    fi
    if [[ -w "$min_w" ]]; then
        echo "$freq" > "$min_w" || { clock_failed=1; skip "scaling_min_freq write failed: $cpu_dir"; }
    fi
done
if [[ "$clock_failed" -eq 1 ]]; then
    echo "ERROR: clock pin failed on one or more CPUs." >&2
    exit 1
fi
pinned_mhz=$(( ${pinned_khz:-0} / 1000 ))
ok "clock pinned to ${pinned_mhz} MHz (all CPUs)"

# ─── 3. irqbalance: stop and disable, then pin IRQ affinity off isolated cores ─
echo "--- IRQ affinity"
if systemctl is-active --quiet irqbalance 2>/dev/null; then
    systemctl stop irqbalance 2>/dev/null && ok "irqbalance stopped" || skip "irqbalance stop failed"
else
    skip "irqbalance not active"
fi
systemctl disable irqbalance 2>/dev/null && ok "irqbalance disabled" || skip "irqbalance disable failed (unit may not exist)"

repinned=0
skipped_irq=0
for aff in /proc/irq/*/smp_affinity_list; do
    [[ -w "$aff" ]] || { skipped_irq=$(( skipped_irq + 1 )); continue; }
    if echo "0-1" > "$aff" 2>/dev/null; then
        repinned=$(( repinned + 1 ))
    else
        skipped_irq=$(( skipped_irq + 1 ))
    fi
done
ok "IRQ affinity: ${repinned} re-pinned to 0-1, ${skipped_irq} skipped (per-CPU/unmovable)"

# ─── 4. Quiet jitter services ─────────────────────────────────────────────────
echo "--- Jitter services"
for svc in avahi-daemon triggerhappy ModemManager bluetooth; do
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
        systemctl stop "$svc" 2>/dev/null    && ok "$svc stopped"    || skip "$svc stop failed"
        systemctl disable "$svc" 2>/dev/null && ok "$svc disabled"   || skip "$svc disable failed"
    else
        skip "$svc not active"
    fi
done

# ─── 5. Swap off ─────────────────────────────────────────────────────────────
echo "--- Swap"
if command -v dphys-swapfile >/dev/null 2>&1; then
    dphys-swapfile swapoff 2>/dev/null && ok "dphys-swapfile off" || skip "dphys-swapfile swapoff failed"
else
    swapoff -a 2>/dev/null && ok "swapoff -a" || skip "swapoff -a failed (no swap?)"
fi

# ─── 6. perf access ──────────────────────────────────────────────────────────
echo "--- perf"
if sysctl -w kernel.perf_event_paranoid=1 >/dev/null 2>&1; then
    ok "kernel.perf_event_paranoid=1"
else
    echo "ERROR: sysctl -w kernel.perf_event_paranoid=1 failed." >&2
    exit 1
fi

echo ""
echo "==> Setup complete. Pinned clock: ${pinned_mhz} MHz."
echo "    Run ./bench/scripts/pi-preflight.sh to verify capture-ready state."
