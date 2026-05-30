#!/usr/bin/env bash
# diag_04_spike_16mhz.sh
# Re-runs the 16 MHz lockfree-handrolled sweep point 10 times under cset shield
# and captures the DIAG (and any WARN) lines to spike_16mhz.log.
#
# Each DIAG line is self-contained: variant, offered rate, p99, p99.9, max
# producer/consumer gaps, item index, and queue backlog at the largest stall.
#
# Run from the repo root.  Requires: cset, sudo, a built bench_04_spsc_queue.
# Build first: cd bench && cmake -B build && cmake --build build

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BINARY="${REPO_ROOT}/bench/build/demos/04-spsc-queue/bench_04_spsc_queue"
LOG="${REPO_ROOT}/spike_16mhz.log"
RUNS="${1:-10}"       # override with first arg, e.g. ./diag_04_spike_16mhz.sh 5
RATE_HZ=16152813      # matches the JSON entry for the sweep point of interest

if [[ ! -x "${BINARY}" ]]; then
    echo "ERROR: binary not found: ${BINARY}" >&2
    echo "       Run: cd bench && cmake -B build && cmake --build build" >&2
    exit 1
fi

sudo -v  # refresh sudo cache upfront

> "${LOG}"

for i in $(seq 1 "${RUNS}"); do
    sudo -E cset shield --cpu=4-7 --kthread=on >/dev/null
    echo "=== run ${i} ===" | tee -a "${LOG}"
    sudo -E cset shield --exec -- "${BINARY}" \
        lockfree-handrolled --mode paced --rate-hz "${RATE_HZ}" \
        2>&1 >/dev/null | grep -v '^cset:' | tee -a "${LOG}"
    sudo cset shield --reset >/dev/null
done

echo
echo "=== summary ==="
grep '^DIAG' "${LOG}"
