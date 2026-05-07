#!/usr/bin/env bash
# run_all.sh — runs every demo in order, emitting JSON for each.
# Run from the repo root.

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEMOS=(
    01-branch-prediction
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
