#!/usr/bin/env bash
# Post-build guard: assert worker_fn contains >=2 movsd instructions.
# Failing this means volatile double was optimised away and the false-sharing
# effect will not manifest — every number in the benchmark becomes meaningless.
# See bench/demos/02-false-sharing/false_sharing_pnl.cpp header for diagnosis steps.
set -euo pipefail

binary="${1:?usage: check_codegen.sh <path-to-bench_02_false_sharing_pnl>}"

if ! command -v objdump &>/dev/null; then
    echo "WARNING: objdump not found — skipping volatile codegen check." >&2
    exit 0
fi

count=$(objdump -d "$binary" \
    | grep -A 40 '<_ZL9worker_fn' \
    | grep -c 'movsd' || true)

if [ "$count" -lt 2 ]; then
    echo "FATAL: worker_fn movsd count is $count (expect >=2)." >&2
    echo "  volatile double may have been optimised away." >&2
    echo "  Diagnosis options (in order):" >&2
    echo "    1. Verify volatile is still on both Strategy members" >&2
    echo "    2. Drop to -O1" >&2
    echo "    3. Use std::atomic_ref<double> relaxed" >&2
    echo "  See bench/demos/02-false-sharing/false_sharing_pnl.cpp header." >&2
    exit 1
fi

echo "OK: worker_fn movsd check passed ($count movsd instructions found)."
