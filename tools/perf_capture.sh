#!/usr/bin/env bash
# Wraps `perf stat -j` around the false-sharing benchmark binary.
# Handles cset shield setup/teardown and IRQ affinity steering.
#
# Usage:
#   ./tools/perf_capture.sh <binary> <placement> <threads> <padded>
#
# Arguments:
#   binary     path to bench_02_false_sharing_pnl
#   placement  intra-ccx | cross-ccx
#   threads    number of threads (1|2|4 for intra; 2|4|8 for cross)
#   padded     0 (unpadded) | 1 (padded)
#
# Output:
#   <placement>_<threads>t_<padded|unpadded>.perf.json   perf stat JSON
#   <placement>_<threads>t_<padded|unpadded>.bench.json  Google Benchmark JSON
#
# Prerequisites:
#   sudo apt install cpuset linux-tools-common linux-tools-$(uname -r)
#   sudo sysctl kernel.perf_event_paranoid=1

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bench/scripts/lib.sh
source "${SCRIPT_DIR}/../bench/scripts/lib.sh"

set_governor_performance

BINARY="${1:?Usage: $0 <binary> <placement> <threads> <padded>}"
PLACEMENT="${2:?}"
THREADS="${3:?}"
PADDED_FLAG="${4:?}"  # 0 or 1

# ─── Resolve variant name for benchmark filter ───────────────────────────────

PADDED_STR="unpadded"
[[ "$PADDED_FLAG" == "1" ]] && PADDED_STR="padded"

if [[ "$PLACEMENT" == "intra-ccx" ]]; then
    FILTER="IntraCCX/${THREADS}t/${PADDED_STR}"
elif [[ "$PLACEMENT" == "cross-ccx" ]]; then
    FILTER="CrossCCX/${THREADS}t/${PADDED_STR}"
else
    echo "ERROR: placement must be intra-ccx or cross-ccx" >&2
    exit 1
fi

# ─── Determine shield cores ──────────────────────────────────────────────────

case "$PLACEMENT/$THREADS" in
    intra-ccx/1|intra-ccx/2|intra-ccx/4)
        SHIELD_CPUS="4-7"
        ;;
    cross-ccx/2)
        SHIELD_CPUS="0,4"
        ;;
    cross-ccx/4)
        SHIELD_CPUS="0,1,4,5"
        ;;
    cross-ccx/8)
        SHIELD_CPUS="0-7"
        ;;
    *)
        echo "ERROR: unsupported placement/threads combination: $PLACEMENT/$THREADS" >&2
        exit 1
        ;;
esac

# ─── Output filenames ────────────────────────────────────────────────────────

SLUG="${PLACEMENT}_${THREADS}t_${PADDED_STR}"
PERF_OUT="${SLUG}.perf.json"
BENCH_OUT="${SLUG}.bench.json"

echo "==> cset shield --cpu=$SHIELD_CPUS"
sudo cset shield --cpu="$SHIELD_CPUS" --kthread=on 2>/dev/null || true

# Steer IRQs away from shielded cores
echo "==> steering IRQ affinity away from shielded cores"
IRQ_MASK="ff"  # all 8 CPUs by default
case "$SHIELD_CPUS" in
    4-7)          IRQ_MASK="0f" ;;   # only CPUs 0-3 handle IRQs
    0,4)          IRQ_MASK="ee" ;;
    0,1,4,5)      IRQ_MASK="cc" ;;
    0-7)          IRQ_MASK="ff" ;;   # all 8 CPUs shielded — leave mask unchanged to avoid routing IRQs into the workload
esac
for affinity_file in /proc/irq/*/smp_affinity; do
    echo "$IRQ_MASK" | sudo tee "$affinity_file" > /dev/null 2>&1 || true
done

echo "==> running benchmark: $FILTER"
echo "    perf JSON  → $PERF_OUT"
echo "    bench JSON → $BENCH_OUT"

sudo cset shield --exec -- \
    perf stat \
        --event=cache-misses,cache-references,instructions,cycles \
        --json \
        --output="$PERF_OUT" \
        -- \
        "$BINARY" \
            --benchmark_filter="$FILTER" \
            --benchmark_repetitions=11 \
            --benchmark_out="$BENCH_OUT" \
            --benchmark_out_format=json

echo "==> cset shield --reset"
sudo cset shield --reset 2>/dev/null || true

echo "==> done: $PERF_OUT  $BENCH_OUT"
