#!/usr/bin/env bash
# Set the performance governor on every CPU and verify it took.
# Run before any capture/diagnostic. Idempotent. Exits non-zero if any CPU
# is not 'performance' afterwards.  Usage: sudo ./set_performance.sh  (or it self-sudos the writes)
set -uo pipefail

DRV="$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver 2>/dev/null || echo '?')"
AVAIL="$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null || echo '?')"
echo "scaling_driver: $DRV"
echo "available governors: $AVAIL"

if [[ "$AVAIL" != "?" && "$AVAIL" != *performance* ]]; then
  echo "ERROR: 'performance' is not an available governor under driver '$DRV'." >&2
  echo "       (amd_pstate in 'active' mode exposes performance/powersave only — that's fine;" >&2
  echo "        but if you see only 'schedutil' here, the driver config is unexpected.)" >&2
  exit 2
fi

# write every CPU's policy
for g in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_governor; do
  echo performance | sudo tee "$g" >/dev/null 2>&1 || echo "WARN: write failed for $g" >&2
done

# verify
FAIL=0
echo "--- verify ---"
for g in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_governor; do
  cpu="$(echo "$g" | grep -oE 'cpu[0-9]+' | head -1)"
  val="$(cat "$g" 2>/dev/null || echo '?')"
  printf "  %-6s %s\n" "$cpu" "$val"
  [[ "$val" == "performance" ]] || FAIL=$((FAIL+1))
done

echo
if [[ "$FAIL" -eq 0 ]]; then
  echo "OK: all CPUs on performance."
else
  echo "FAIL: $FAIL CPU(s) not on performance — do not capture until resolved." >&2
fi
exit $FAIL
