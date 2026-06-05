#!/usr/bin/env bash
# Demo 03 µop diagnostic — Zen 2 256-bit split vs native.
# Runs perf stat (instructions, ex_ret_cops) for three kernels at N=1M,
# computes µops/instruction per kernel, writes raw + summary to a file.
#
# Usage:  ./uop_diag.sh [path-to-bench-binary] [core]
#   bench binary : optional; auto-detected under build/ if omitted
#   core         : optional isolated core to pin to (default 4)
set -uo pipefail

CORE="${2:-4}"
N=1048576
REPS=20
EVENTS="instructions,ex_ret_cops"
VARIANTS=(avx2fma sse2 scalarpoly)
FILTERS=("BM_AVX2FMA/${N}" "BM_SSE2/${N}" "BM_ScalarPoly/${N}")
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="uop_diag_${STAMP}.txt"

# --- locate bench binary --------------------------------------------------
BIN="${1:-}"
if [[ -z "$BIN" ]]; then
  BIN="$(find . -type f -executable -name 'bench_03*' 2>/dev/null | head -n1)"
  [[ -z "$BIN" ]] && BIN="$(find . -type f -executable -iname '*03*blackscholes*' 2>/dev/null | head -n1)"
fi
if [[ -z "$BIN" || ! -x "$BIN" ]]; then
  echo "ERROR: bench binary not found. Pass it explicitly:  ./uop_diag.sh path/to/bench_03" >&2
  exit 1
fi

# --- preconditions --------------------------------------------------------
{
  echo "=== µop diagnostic  ${STAMP} ==="
  echo "host:    $(hostname)"
  echo "binary:  $BIN"
  echo "core:    $CORE   N=$N   reps=$REPS   events=$EVENTS"
  echo

  # turbo / cpb state (advisory)
  if [[ -r /sys/devices/system/cpu/cpufreq/boost ]]; then
    echo "cpufreq boost sysfs: $(cat /sys/devices/system/cpu/cpufreq/boost) (0=off)"
  fi
  echo "governor: $(cat /sys/devices/system/cpu/cpu${CORE}/cpufreq/scaling_governor 2>/dev/null || echo '?')"
  echo "paranoid: $(cat /proc/sys/kernel/perf_event_paranoid 2>/dev/null || echo '?')"
  echo

  # verify the event resolves before doing real work
  if ! perf stat -e ex_ret_cops -- true 2>/dev/null; then
    echo "NOTE: 'ex_ret_cops' did not resolve under this kernel/perf; check 'perf list | grep -i cops'." 
    echo "      If the name differs, edit EVENTS at the top of this script."
    echo
  fi
} | tee "$OUT"

# reset any prior shield (capture precondition); ignore if cset absent
sudo cset shield --reset >/dev/null 2>&1 || true

# --- run ------------------------------------------------------------------
declare -A INSTR UOPS
for idx in "${!VARIANTS[@]}"; do
  v="${VARIANTS[$idx]}"; f="${FILTERS[$idx]}"
  echo "--- $v  (filter: $f) ---" | tee -a "$OUT"
  # -x, => CSV: value,unit,event,...   2>&1 because perf prints stat to stderr
  RAW="$(taskset -c "$CORE" perf stat -x, -e "$EVENTS" \
        "$BIN" --benchmark_filter="$f" --benchmark_repetitions="$REPS" 2>&1)"
  echo "$RAW" | tee -a "$OUT"
  INSTR[$v]="$(echo "$RAW" | awk -F, '$3=="instructions"{gsub(/[^0-9]/,"",$1); print $1; exit}')"
  UOPS[$v]="$(echo  "$RAW" | awk -F, '$3=="ex_ret_cops"{gsub(/[^0-9]/,"",$1); print $1; exit}')"
  echo | tee -a "$OUT"
done

# --- summary --------------------------------------------------------------
{
  echo "=== summary: µops / instruction ==="
  printf "%-12s %16s %16s %10s\n" "kernel" "instructions" "ex_ret_cops" "uops/inst"
  for v in "${VARIANTS[@]}"; do
    i="${INSTR[$v]:-}"; u="${UOPS[$v]:-}"
    if [[ -n "$i" && -n "$u" && "$i" -gt 0 ]]; then
      r="$(awk -v u="$u" -v i="$i" 'BEGIN{printf "%.4f", u/i}')"
    else
      r="n/a"
    fi
    printf "%-12s %16s %16s %10s\n" "$v" "${i:-?}" "${u:-?}" "$r"
  done
  echo
  echo "DECISION RULE:"
  echo "  avx2fma uops/inst  ≈  sse2 uops/inst  -> Zen 2 native 256-bit (no split). C-1 rewrite proceeds."
  echo "  avx2fma uops/inst  ≈  2× sse2         -> split story stands. C-1 downgraded."
} | tee -a "$OUT"

echo
echo "Written: $OUT  —  paste this file back."
