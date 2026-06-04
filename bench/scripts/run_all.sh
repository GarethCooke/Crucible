#!/usr/bin/env bash
# run_all.sh — runs every demo in order, emitting JSON for each.
#
# Prerequisites:
#   - One-time machine setup complete (see README.md)
#   - jq and cpuset (provides cset) installed
#   - Run from the repo root
#   - Core Performance Boost disabled in BIOS (hard gate; see assert_boost_off in lib.sh)

# Cache sudo credentials up front so per-demo cset calls don't prompt mid-run
sudo -v

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=bench/scripts/lib.sh
source "${SCRIPTS_DIR}/lib.sh"

# Fail fast: check boost before any demo builds or runs.
# Each run_one.sh will re-check; this just surfaces the error immediately.
assert_boost_off

DEMOS=(
    01-branch-prediction
    02-false-sharing
    03-simd-blackscholes
    04-spsc-queue
    05-allocators
    06-aos-vs-soa
    07-no-crossover
)

for slug in "${DEMOS[@]}"; do
    echo ""
    echo "=========================================="
    echo " Demo: ${slug}"
    echo "=========================================="
    "${SCRIPTS_DIR}/run_one.sh" "${slug}"
done

echo ""
echo "All done."
