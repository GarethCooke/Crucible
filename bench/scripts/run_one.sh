#!/usr/bin/env bash
# run_one.sh <demo-slug>
# Builds the demo, runs it under taskset on isolated cores, and emits
# a schema-conformant JSON file to site/src/data/perf/<slug>.json.
#
# Prerequisites:
#   - One-time machine setup complete (see README.md)
#   - jq installed
#   - Run from the repo root

set -euo pipefail

SLUG="${1:?Usage: run_one.sh <demo-slug>}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BENCH_ROOT="${REPO_ROOT}/bench"
OUT_JSON="${REPO_ROOT}/site/src/data/perf/${SLUG}.json"
BINARY="${BENCH_ROOT}/build/demos/${SLUG//[-]/_}/bench_${SLUG//[-]/_}"

# Map slug → binary name (CMake target names use underscores)
BINARY_NAME="bench_$(echo "${SLUG}" | tr '-' '_' | sed 's/^0*//')"
# Handle leading zeros: 01-branch-prediction → bench_01_branch_prediction
BINARY_NAME="bench_$(echo "${SLUG}" | tr '-' '_')"
BINARY="${BENCH_ROOT}/build/demos/${SLUG}/${BINARY_NAME}"

echo "==> Building ${SLUG}..."
cmake -B "${BENCH_ROOT}/build" -S "${BENCH_ROOT}" -DCMAKE_BUILD_TYPE=Release -Wno-dev --log-level=ERROR
cmake --build "${BENCH_ROOT}/build" --parallel --log-level=ERROR

if [[ ! -x "${BINARY}" ]]; then
    echo "ERROR: binary not found at ${BINARY}" >&2
    exit 1
fi

echo "==> Collecting machine info..."
MACHINE_JSON=$(taskset -c 4-7 "${BINARY}" --machine-info)

TMPFILE=$(mktemp /tmp/crucible_bench_XXXXXX.json)
trap 'rm -f "${TMPFILE}"' EXIT

echo "==> Running benchmarks (20 repetitions per variant×size)..."
taskset -c 4-7 "${BINARY}" \
    --benchmark_format=json \
    --benchmark_repetitions=20 \
    --benchmark_report_aggregates_only=false \
    --benchmark_out="${TMPFILE}" \
    --benchmark_out_format=json

echo "==> Assembling output JSON..."

CAPTURED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

python3 "${BENCH_ROOT}/scripts/assemble_results.py" \
    "${TMPFILE}" "${SLUG}" "${CAPTURED_AT}" "${MACHINE_JSON}" "${OUT_JSON}"

echo "==> Done: ${OUT_JSON}"
