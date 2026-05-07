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
cmake -B "${BENCH_ROOT}/build" -S "${BENCH_ROOT}" -DCMAKE_BUILD_TYPE=Release -Wno-dev --quiet
cmake --build "${BENCH_ROOT}/build" --parallel --quiet

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

# Extract per-(name, n) groups and compute median/min/p99/iqr from repetitions.
# jq computes statistics inline using sort + index arithmetic.
python3 - "${TMPFILE}" "${SLUG}" "${CAPTURED_AT}" "${MACHINE_JSON}" "${OUT_JSON}" <<'PYEOF'
import json, sys, math, os

bench_file, slug, captured_at, machine_json, out_path = sys.argv[1:]

with open(bench_file) as f:
    raw = json.load(f)

machine = json.loads(machine_json)

def stats(values):
    s = sorted(values)
    n = len(s)
    if n == 0:
        return {"median": 0, "min": 0, "p99": 0, "iqr": 0}
    def pct(p):
        idx = p / 100 * (n - 1)
        lo  = int(idx)
        frac = idx - lo
        if lo + 1 >= n: return s[-1]
        return s[lo] * (1 - frac) + s[lo + 1] * frac
    return {
        "median": round(pct(50), 4),
        "min":    round(s[0],    4),
        "p99":    round(pct(99), 4),
        "iqr":    round(pct(75) - pct(25), 4),
    }

# Group iteration rows by (variant, n)
groups = {}
for b in raw.get("benchmarks", []):
    if b.get("run_type") != "iteration":
        continue
    name = b["name"]                    # e.g. "BM_Sorted/1024"
    parts = name.split("/")
    variant_raw = parts[0].removeprefix("BM_").lower()  # sorted / unsorted
    n = int(parts[1]) if len(parts) > 1 else 0
    key = (variant_raw, n)
    groups.setdefault(key, []).append(b)

runs = []
for (variant, n), reps in sorted(groups.items(), key=lambda x: (x[0][0], x[0][1])):
    times = [r["real_time"] for r in reps]          # ns/op
    ops_s = [r.get("items_per_second", 0) for r in reps]
    bm    = [r.get("branch_misses_per_op", 0) for r in reps]
    ipc   = [r.get("ipc", 0) for r in reps]

    runs.append({
        "variant":              variant,
        "n":                    n,
        "iterations":           reps[0].get("iterations", 0),
        "ns_per_op":            stats(times),
        "ops_per_sec":          round(sorted(ops_s)[len(ops_s) // 2]),
        "branch_misses_per_op": round(sorted(bm)[len(bm) // 2], 4),
        "instructions_per_cycle": round(sorted(ipc)[len(ipc) // 2], 3),
    })

output = {
    "demo":         slug,
    "title":        "Sorted vs unsorted branch prediction",
    "machine":      machine,
    "captured_at":  captured_at,
    "runs":         runs,
    "notes":        "Branch predictor learns sorted patterns; unsorted forces ~50% mispredicts.",
}

os.makedirs(os.path.dirname(out_path), exist_ok=True)
with open(out_path, "w") as f:
    json.dump(output, f, indent=2)

print(f"Written: {out_path}")
PYEOF

echo "==> Done: ${OUT_JSON}"
