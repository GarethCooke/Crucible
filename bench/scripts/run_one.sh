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

# shellcheck source=bench/scripts/lib.sh
source "${BENCH_ROOT}/scripts/lib.sh"

# Cleanup runs on any exit path (success, error, or interrupt)
TMPFILE=""
WDIR=""
SHIELD_ACTIVE=0
cleanup() {
    [[ -n "${TMPFILE}" ]] && rm -f "${TMPFILE}"
    [[ -n "${WDIR}"    ]] && rm -rf "${WDIR}"
    if [[ "${SHIELD_ACTIVE}" -eq 1 ]]; then
        sudo cset shield --reset > /dev/null 2>&1 || true
    fi
}
trap cleanup EXIT

set_governor_performance

echo "==> Building ${SLUG}..."
cmake -B "${BENCH_ROOT}/build" -S "${BENCH_ROOT}" -DCMAKE_BUILD_TYPE=Release -Wno-dev --log-level=ERROR
cmake --build "${BENCH_ROOT}/build" --parallel > /dev/null

# ─── Demo 02: false-sharing — separate perf-stat pipeline ────────────────────
# Uses tools/perf_capture.sh (handles its own cset shield per variant) and
# tools/parse_perf.py to fold perf stat + Google Benchmark JSON into the site
# data file. Does not use the cset / assemble_results.py path below.
if [[ "${SLUG}" == "02-false-sharing" ]]; then
    FS_BINARY="${BENCH_ROOT}/build/demos/02-false-sharing/bench_02_false_sharing_pnl"
    OUT_JSON="${REPO_ROOT}/site/src/data/perf/false-sharing-pnl.json"

    if [[ ! -x "${FS_BINARY}" ]]; then
        echo "ERROR: binary not found: ${FS_BINARY}" >&2; exit 1
    fi

    echo "==> Verifying disassembly (movsd load+store pair in worker_fn)..."
    DISASM_OUT=$(objdump -d "${FS_BINARY}" | grep -A 40 '<_ZL9worker_fn' || true)
    MOVSD_COUNT=$(echo "${DISASM_OUT}" | grep -c 'movsd' || true)
    if [[ "${MOVSD_COUNT}" -lt 2 ]]; then
        echo "ERROR: expected ≥2 movsd in worker_fn (volatile load + store); found ${MOVSD_COUNT}." >&2
        echo "       See escalation options in false_sharing_pnl.cpp header." >&2
        exit 1
    fi
    echo "    OK — ${MOVSD_COUNT} movsd confirmed."

    WDIR=$(mktemp -d /tmp/crucible_fs_XXXXXX)

    run_variant() {
        local placement="$1" threads="$2" padded="$3"
        local padded_str="unpadded"; [[ "$padded" -eq 1 ]] && padded_str="padded"
        local slug_v="${placement}_${threads}t_${padded_str}"
        echo "==> ${placement}/${threads}t/${padded_str}"
        (cd "${WDIR}" && "${REPO_ROOT}/tools/perf_capture.sh" \
            "${FS_BINARY}" "${placement}" "${threads}" "${padded}")
        python3 "${REPO_ROOT}/tools/parse_perf.py" \
            --perf  "${WDIR}/${slug_v}.perf.json" \
            --bench "${WDIR}/${slug_v}.bench.json" \
            --out   "${OUT_JSON}" \
            --placement "${placement}" --threads "${threads}" --padded "${padded}"
    }

    for t in 1 2 4; do
        for p in 0 1; do run_variant "intra-ccx" "${t}" "${p}"; done
    done
    for t in 2 4 8; do
        for p in 0 1; do run_variant "cross-ccx" "${t}" "${p}"; done
    done

    echo "==> Running sanity checks..."
    python3 "${REPO_ROOT}/tools/sanity_check.py" "${OUT_JSON}"

    echo "==> Done: ${OUT_JSON}"
    exit 0
fi
# ─────────────────────────────────────────────────────────────────────────────

if [[ ! -x "${BINARY}" ]]; then
    echo "ERROR: binary not found at ${BINARY}" >&2
    exit 1
fi

# ─── Disassembly guard — fails loudly if the compiler defeats the experiment ──
if [[ "${SLUG}" == "01-branch-prediction" ]]; then
    DISASM_OUT="${REPO_ROOT}/site/src/data/perf/01-branch-prediction.disasm.txt"
    echo "==> Verifying disassembly of sum_threshold (must contain jl/jge, no cmov/SIMD)..."
    objdump -d "${BINARY}" \
        | awk '/<_?Z[NL]?13sum_threshold/,/^$/' \
        > "${DISASM_OUT}" 2>/dev/null || true
    if ! grep -qE '\b(jl|jge|jb|jae)\b' "${DISASM_OUT}"; then
        echo "ERROR: no jl/jge/jb/jae found in sum_threshold — branch may have been eliminated." >&2
        echo "       Check for cmov/SIMD ops:" >&2
        grep -E '\b(cmov|vpcmpgtd|vpand|vpaddd)\b' "${DISASM_OUT}" >&2 || true
        exit 1
    fi
    if grep -qE '\b(cmov[a-z]*|vpcmpgtd|vpand|vpaddd)\b' "${DISASM_OUT}"; then
        echo "ERROR: cmov or SIMD ops found in sum_threshold — compiler eliminated the branch." >&2
        grep -E '\b(cmov[a-z]*|vpcmpgtd|vpand|vpaddd)\b' "${DISASM_OUT}" >&2
        exit 1
    fi
    echo "    OK — branch instructions confirmed. Disassembly saved to ${DISASM_OUT}"
fi

echo "==> Activating cset shield on cores 4-7..."
sudo cset shield --cpu=4-7 --kthread=on > /dev/null
SHIELD_ACTIVE=1

echo "==> Collecting machine info..."
MACHINE_JSON=$(sudo cset shield --exec -- "${BINARY}" --machine-info \
    | grep -v '^cset:' \
    | tr -d '\000-\010\013-\037\177')

TMPFILE=$(mktemp /tmp/crucible_bench_XXXXXX.json)
sudo chmod 666 "${TMPFILE}"

echo "==> Running benchmarks (20 repetitions per variant×size)..."
sudo cset shield --exec -- "${BINARY}" \
    --benchmark_format=json \
    --benchmark_repetitions=20 \
    --benchmark_report_aggregates_only=false \
    | grep -v '^cset:' > "${TMPFILE}"

echo "==> Releasing cset shield..."
sudo cset shield --reset > /dev/null
SHIELD_ACTIVE=0

echo "==> Assembling output JSON..."
CAPTURED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

python3 "${BENCH_ROOT}/scripts/assemble_results.py" \
    "${TMPFILE}" "${SLUG}" "${CAPTURED_AT}" "${MACHINE_JSON}" "${OUT_JSON}"

echo "==> Done: ${OUT_JSON}"