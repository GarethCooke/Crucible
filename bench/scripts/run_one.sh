#!/usr/bin/env bash
# run_one.sh <demo-slug>
# Builds the demo, runs it inside a cset shield on cores 4-7, and emits
# a schema-conformant JSON file to site/src/data/perf/<slug>.json.
#
# Prerequisites:
#   - One-time machine setup complete (see README.md)
#   - jq and cpuset (provides cset) installed
#   - Sudo cached: run `sudo -v` before invocation to avoid mid-script prompts
#   - Run from the repo root

set -euo pipefail

SLUG="${1:?Usage: run_one.sh <demo-slug>}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BENCH_ROOT="${REPO_ROOT}/bench"
OUT_JSON="${REPO_ROOT}/site/src/data/perf/${SLUG}.json"

BINARY_NAME="bench_${SLUG//-/_}"
BINARY="${BENCH_ROOT}/build/demos/${SLUG}/${BINARY_NAME}"

# Cleanup runs on any exit path (success, error, or interrupt)
TMPFILE=""
SHIELD_ACTIVE=0
cleanup() {
    [[ -n "${TMPFILE}" ]] && rm -f "${TMPFILE}"
    if [[ "${SHIELD_ACTIVE}" -eq 1 ]]; then
        sudo cset shield --reset > /dev/null 2>&1 || true
    fi
}
trap cleanup EXIT

echo "==> Building ${SLUG}..."
cmake -B "${BENCH_ROOT}/build" -S "${BENCH_ROOT}" -DCMAKE_BUILD_TYPE=Release -Wno-dev --log-level=ERROR
cmake --build "${BENCH_ROOT}/build" --parallel > /dev/null

if [[ ! -x "${BINARY}" ]]; then
    echo "ERROR: binary not found at ${BINARY}" >&2
    exit 1
fi

echo "==> Activating cset shield on cores 4-7..."
sudo cset shield --cpu=4-7 > /dev/null
SHIELD_ACTIVE=1

echo "==> Collecting machine info..."
MACHINE_JSON=$(sudo cset shield --exec -- "${BINARY}" --machine-info)

TMPFILE=$(mktemp /tmp/crucible_bench_XXXXXX.json)

echo "==> Running benchmarks (20 repetitions per variant×size)..."
sudo cset shield --exec -- "${BINARY}" \
    --benchmark_format=json \
    --benchmark_repetitions=20 \
    --benchmark_report_aggregates_only=false \
    --benchmark_out="${TMPFILE}" \
    --benchmark_out_format=json

echo "==> Releasing cset shield..."
sudo cset shield --reset > /dev/null
SHIELD_ACTIVE=0

echo "==> Assembling output JSON..."
CAPTURED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

python3 "${BENCH_ROOT}/scripts/assemble_results.py" \
    "${TMPFILE}" "${SLUG}" "${CAPTURED_AT}" "${MACHINE_JSON}" "${OUT_JSON}"

echo "==> Done: ${OUT_JSON}"