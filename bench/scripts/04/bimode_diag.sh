#!/usr/bin/env bash
# Demo 04 Phase 1 — overload bimodality diagnostic.
# Repeats saturated + 3 high sweep points x 3 variants under shield, captures
# every per-iteration ITER line, then bins each into deep / shallow / indeterminate.
# Run from repo root.  Usage: ./bimode_diag.sh
set -uo pipefail

INVOCATIONS="${INVOCATIONS:-10}"   # invocations per cell
ITERS="${ITERS:-5}"                # internal iterations per invocation
ISOL_CPUS="${ISOL_CPUS:-1-7}"
VARIANTS=(mutex-condvar lockfree-boost lockfree-handrolled)
# point spec: "mode|rate_hz"  (rate ignored for saturated)
POINTS=("saturated|" "paced|16152813" "paced|28419019" "paced|50000000")
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="bimode_diag_${STAMP}.txt"
RAW="bimode_raw_${STAMP}.log"

BIN="$(find . -type f -executable -name 'bench_04*' 2>/dev/null | head -n1)"
[[ -z "$BIN" ]] && BIN="$(find . -type f -executable -iname '*04*spsc*' 2>/dev/null | head -n1)"
if [[ -z "$BIN" || ! -x "$BIN" ]]; then echo "ERROR: bench_04 not found; build first." >&2; exit 1; fi

# --- preconditions --------------------------------------------------------
{
  echo "=== Demo 04 bimodality diagnostic  ${STAMP} ==="
  echo "host: $(hostname)   binary: $BIN"
  echo "invocations/cell: $INVOCATIONS   iters/invocation: $ITERS   isolcpus: $ISOL_CPUS"
  echo "governor: $(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor 2>/dev/null || echo '?')"
  echo "boost(0=off): $(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo '?')   paranoid: $(cat /proc/sys/kernel/perf_event_paranoid 2>/dev/null || echo '?')"
  echo "kernel: $(uname -r)"
  echo
} | tee "$OUT"

# --- shield (mirror run_one.sh); fall back to taskset --------------------
ERRF="$(mktemp)"
SHIELD=1
sudo cset shield --reset >/dev/null 2>&1 || true
if sudo cset shield --cpu="$ISOL_CPUS" --kthread=on >/dev/null 2>&1; then
  echo "shield: active on $ISOL_CPUS" | tee -a "$OUT"
  PREFIX=(sudo -E cset shield --exec --)
else
  SHIELD=0
  echo "shield: UNAVAILABLE — falling back to taskset -c 4-7 (binary self-pins anyway)" | tee -a "$OUT"
  PREFIX=(taskset -c 4-7)
fi
cleanup(){ [[ "$SHIELD" == "1" ]] && sudo cset shield --reset >/dev/null 2>&1 || true; rm -f "$ERRF"; }
trap cleanup EXIT

: > "$RAW"

# --- run ------------------------------------------------------------------
for v in "${VARIANTS[@]}"; do
  for pt in "${POINTS[@]}"; do
    mode="${pt%%|*}"; rate="${pt##*|}"
    if [[ "$mode" == "saturated" ]]; then args=(--mode saturated); label="saturated"
    else args=(--mode paced --rate-hz "$rate"); label="paced@$((rate/1000000))M"; fi
    echo "--- $v  $label  ($INVOCATIONS x $ITERS) ---" | tee -a "$OUT"
    for ((inv=1; inv<=INVOCATIONS; inv++)); do
      ts="$(date -u +%H:%M:%S)"
      "${PREFIX[@]}" "$BIN" "$v" "${args[@]}" --iterations "$ITERS" >/dev/null 2>"$ERRF"
      grep -E 'ITER|DIAG' "$ERRF" | sed "s/^/[$label inv=$inv $ts] /" >> "$RAW"
      # fail fast: if the very first invocation captured nothing, the harness is wrong
      if [[ "$v" == "${VARIANTS[0]}" && "$pt" == "${POINTS[0]}" && "$inv" -eq 1 && ! -s "$RAW" ]]; then
        echo "ABORT: first invocation produced no ITER/DIAG lines." | tee -a "$OUT"
        echo "  stderr sample from the run:" | tee -a "$OUT"
        head -5 "$ERRF" | sed 's/^/    /' | tee -a "$OUT"
        exit 1
      fi
    done
    echo "    $(grep -c "\[$label inv=" "$RAW" 2>/dev/null || echo 0) tagged lines so far" | tee -a "$OUT"
  done
done

# --- classify -------------------------------------------------------------
{
  echo
  echo "=== classification: depth_mean > 100 = DEEP, < 10 = SHALLOW, else INDET ==="
  printf "%-20s %-12s %6s %8s %8s %7s\n" "variant" "point" "deep" "shallow" "indet" "n"
  for v in "${VARIANTS[@]}"; do
    for pt in "${POINTS[@]}"; do
      mode="${pt%%|*}"; rate="${pt##*|}"
      [[ "$mode" == "saturated" ]] && label="saturated" || label="paced@$((rate/1000000))M"
      awk -v v="$v" -v lab="$label" '
        $0 ~ ("\\["lab" ") && $0 ~ ("ITER "v" ") {
          d=""; for(i=1;i<=NF;i++) if($i~/depth_mean=/){d=$i; gsub(/[^0-9.]/,"",d)}
          if(d=="") next
          n++; if(d+0>100) deep++; else if(d+0<10) shal++; else ind++
        }
        END{ printf "%-20s %-12s %6d %8d %8d %7d\n", v, lab, deep, shal, ind, n }
      ' "$RAW"
    done
  done
  echo
  echo "Raw tagged ITER/DIAG lines: $RAW"
  echo "Send both $OUT and $RAW back."
} | tee -a "$OUT"
