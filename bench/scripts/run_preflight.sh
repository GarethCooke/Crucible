#!/usr/bin/env bash
# run_preflight.sh <demo-slug>
# Smoke-checks a demo with a sparse parameter grid before committing a full run.
#
# For 06-aos-vs-soa:
#   3 variants × N ∈ {4096, 131072, 1048576} × K ∈ {1, 2, 4, 8, 16} × 3 iters
#   Output: /tmp/preflight-06-aos-vs-soa.json
#
# Same shield/taskset pattern as run_one.sh.
# Prerequisites: binary already built; cset, jq, sudo available; run from repo root.

set -euo pipefail

SLUG="${1:?Usage: run_preflight.sh <demo-slug>}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BENCH_ROOT="${REPO_ROOT}/bench"

# shellcheck source=bench/scripts/lib.sh
source "${BENCH_ROOT}/scripts/lib.sh"

SHIELD_ACTIVE=0
WDIR=""
cleanup() {
    [[ -n "${WDIR}" ]] && rm -rf "${WDIR}"
    if [[ "${SHIELD_ACTIVE}" -eq 1 ]]; then
        sudo -E cset shield --reset > /dev/null 2>&1 || true
    fi
}
trap cleanup EXIT

sudo -v

assert_boost_off

assert_smt_off
assert_isolated_cores
set_governor_performance

# ─── Demo 06: AoS vs SoA — sparse preflight grid ─────────────────────────────
if [[ "${SLUG}" == "06-aos-vs-soa" ]]; then
    AOS_BINARY="${BENCH_ROOT}/build/demos/06-aos-vs-soa/bench_06_aos_vs_soa"

    if [[ ! -x "${AOS_BINARY}" ]]; then
        echo "ERROR: binary not found: ${AOS_BINARY}" >&2
        echo "       Run: cmake --build bench/build --parallel" >&2
        exit 1
    fi

    echo "==> Resetting cset shield (clears stale state from prior session)..."
    sudo cset shield --reset > /dev/null 2>&1 || true

    echo "==> Running codegen verification..."
    sudo -E cset shield --cpu=4-7 --kthread=on > /dev/null
    SHIELD_ACTIVE=1
    sudo -E cset shield --exec -- "${AOS_BINARY}" aos-scalar --verify-codegen \
        | grep -v '^cset:'
    sudo -E cset shield --reset > /dev/null
    SHIELD_ACTIVE=0

    echo "==> Collecting machine info..."
    sudo -E cset shield --cpu=4-7 --kthread=on > /dev/null
    SHIELD_ACTIVE=1
    MACHINE_JSON=$(sudo -E cset shield --exec -- "${AOS_BINARY}" --machine-info \
        | grep -v '^cset:' | tr -d '\000-\010\013-\037\177')
    sudo -E cset shield --reset > /dev/null
    SHIELD_ACTIVE=0

    WDIR=$(mktemp -d /tmp/crucible_preflight_XXXXXX)

    # Sparse grid — descending N avoids stale-data shortcuts in the warmup phase.
    NS_DESC=(1048576 131072 4096)
    KS=(1 2 4 8 16)
    VARIANTS_06=(aos-scalar soa-scalar soa-autovec)

    TOTAL_CELLS=$(( ${#VARIANTS_06[@]} * ${#NS_DESC[@]} * ${#KS[@]} ))
    CELL=0

    for VARIANT in "${VARIANTS_06[@]}"; do
        for N in "${NS_DESC[@]}"; do
            for K in "${KS[@]}"; do
                CELL=$(( CELL + 1 ))
                OUTFILE="${WDIR}/${VARIANT}-n${N}-k${K}.json"
                echo "==> Cell ${CELL}/${TOTAL_CELLS}: ${VARIANT} N=${N} K=${K}..."

                sudo -E cset shield --cpu=4-7 --kthread=on > /dev/null
                SHIELD_ACTIVE=1
                sudo -E cset shield --exec -- taskset -c 4 "${AOS_BINARY}" \
                    "${VARIANT}" --n "${N}" --k "${K}" --iterations 3 \
                    | grep -v '^cset:' > "${OUTFILE}"
                sudo -E cset shield --reset > /dev/null
                SHIELD_ACTIVE=0
            done
        done
    done

    echo "==> Assembling preflight JSON..."
    CAPTURED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    OUT_JSON="/tmp/preflight-06-aos-vs-soa.json"
    python3 "${BENCH_ROOT}/scripts/assemble_results_06.py" \
        "${WDIR}" "${CAPTURED_AT}" "${MACHINE_JSON}" "${OUT_JSON}"

    echo "==> Done: ${OUT_JSON}"
    exit 0
fi
# ─────────────────────────────────────────────────────────────────────────────

echo "ERROR: no preflight defined for slug '${SLUG}'" >&2
exit 1
