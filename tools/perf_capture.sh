#!/usr/bin/env bash
# Wraps `perf stat -j` around the false-sharing benchmark binary.
#
# PRECONDITION: must be run from the benchmark GRUB entry with kernel params
#   isolcpus=1-7 nohz_full=1-7 rcu_nocbs=1-7
# The script aborts if /sys/devices/system/cpu/isolated does not read "0-7".
# See /methodology for the dual-GRUB-entry setup.
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
#   Boot into the benchmark GRUB entry (isolcpus=1-7 nohz_full=1-7 rcu_nocbs=1-7)
#   sudo sysctl kernel.perf_event_paranoid=1
#   linux-tools-$(uname -r) installed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bench/scripts/lib.sh
source "${SCRIPT_DIR}/../bench/scripts/lib.sh"

set_governor_performance

BINARY="${1:?Usage: $0 <binary> <placement> <threads> <padded>}"
PLACEMENT="${2:?}"
THREADS="${3:?}"
PADDED_FLAG="${4:?}"  # 0 or 1

# ─── Precondition: verify isolcpus kernel boot params ────────────────────────

ISOLATED="$(cat /sys/devices/system/cpu/isolated 2>/dev/null || echo '')"
# The kernel will not isolate cpu0 (the boot CPU) regardless of isolcpus= — so
# the effective isolation from isolcpus=0-7 is always "1-7". Accept that value.
if [[ "$ISOLATED" != "1-7" ]]; then
    echo "ERROR: cores 1-7 are not isolated as required." >&2
    echo "  /sys/devices/system/cpu/isolated = '${ISOLATED}'" >&2
    echo "  Boot into the benchmark GRUB entry:" >&2
    echo "    isolcpus=1-7 nohz_full=1-7 rcu_nocbs=1-7" >&2
    echo "  (kernel reports 1-7 because cpu0 is the boot CPU and cannot be isolated)" >&2
    echo "  See /methodology for the dual-GRUB-entry setup." >&2
    exit 1
fi

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

# Validate thread/placement combination
case "$PLACEMENT/$THREADS" in
    intra-ccx/1|intra-ccx/2|intra-ccx/4) ;;
    cross-ccx/2|cross-ccx/4|cross-ccx/8) ;;
    *)
        echo "ERROR: unsupported placement/threads combination: $PLACEMENT/$THREADS" >&2
        exit 1
        ;;
esac

# ─── Output filenames ────────────────────────────────────────────────────────

SLUG="${PLACEMENT}_${THREADS}t_${PADDED_STR}"
PERF_OUT="${SLUG}.perf.json"
BENCH_OUT="${SLUG}.bench.json"

echo "==> Isolation: cores 0-7 confirmed (isolcpus=1-7 nohz_full=1-7 rcu_nocbs=1-7)"
echo "==> Running benchmark: $FILTER"
echo "    perf JSON  → $PERF_OUT"
echo "    bench JSON → $BENCH_OUT"

perf stat \
    --event=cache-misses,cache-references,instructions,cycles,L1-dcache-load-misses \
    --json \
    --output="$PERF_OUT" \
    -- \
    "$BINARY" \
        --benchmark_filter="$FILTER" \
        --benchmark_repetitions=20 \
        --benchmark_out="$BENCH_OUT" \
        --benchmark_out_format=json

echo "==> Done: $PERF_OUT  $BENCH_OUT"
