#!/usr/bin/env bash
# calibrate.sh — fast pre-capture check for bench/demos/07-no-crossover
#
# Runs a reduced 1-rep sweep and verifies two anchor cells against pilot bounds:
#   absl_flat, lookup, N=4096      → expected [3.0, 5.0] ns
#   std_unord, lookup, N=4096      → expected [20.0, 35.0] ns
#
# Exit 0 = in bounds. Exit 1 = out of bounds or binary missing.
#
# Usage: ./bench/demos/07-no-crossover/calibrate.sh
#        (run from repo root, or any directory — uses $0 to locate binary)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
BINARY="${REPO_ROOT}/bench/build/demos/07-no-crossover/bench_07_no_crossover"

if [[ ! -x "${BINARY}" ]]; then
    echo "ERROR: binary not found at ${BINARY}" >&2
    echo "Build first: cmake --build bench/build --target bench_07_no_crossover" >&2
    exit 1
fi

# Reduced calibration sweep
LOOKUP_NS=(8 256 4096 65536)
MODIFYMIX_NS=(256 4096 65536)
MODIFYMIX_PCTS=(0 50 90)
VARIANTS=(std_map sorted_vec boost_flat std_unord absl_flat)

echo "=== Demo 07 calibration sweep (1 rep, reduced N) ==="
echo

# ─── Workload A: lookup-only ─────────────────────────────────────────────────
echo "Workload: lookup"
printf "%-12s %8s %10s\n" "variant" "N" "ns/op"
printf "%-12s %8s %10s\n" "-------" "---" "-----"

declare -A LOOKUP_RESULTS

for VARIANT in "${VARIANTS[@]}"; do
    for N in "${LOOKUP_NS[@]}"; do
        OUT=$("${BINARY}" "${VARIANT}" lookup --n "${N}" --reps 1 2>/dev/null) || {
            printf "%-12s %8d %10s\n" "${VARIANT}" "${N}" "SKIP"
            continue
        }
        NS=$(echo "${OUT}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['ns_per_op']['median'])" 2>/dev/null || echo "ERR")
        printf "%-12s %8d %10s\n" "${VARIANT}" "${N}" "${NS}"
        LOOKUP_RESULTS["${VARIANT}_${N}"]="${NS}"
    done
done

echo

# ─── Workload B: modify-mix ───────────────────────────────────────────────────
echo "Workload: modify_mix"
printf "%-12s %8s %4s %10s\n" "variant" "N" "pct" "ns/op"
printf "%-12s %8s %4s %10s\n" "-------" "---" "---" "-----"

for VARIANT in "${VARIANTS[@]}"; do
    for N in "${MODIFYMIX_NS[@]}"; do
        for PCT in "${MODIFYMIX_PCTS[@]}"; do
            OUT=$("${BINARY}" "${VARIANT}" modify_mix --n "${N}" --modify-pct "${PCT}" --reps 1 2>/dev/null) || {
                printf "%-12s %8d %4d %10s\n" "${VARIANT}" "${N}" "${PCT}" "SKIP"
                continue
            }
            NS=$(echo "${OUT}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['ns_per_op']['median'])" 2>/dev/null || echo "ERR")
            printf "%-12s %8d %4d %10s\n" "${VARIANT}" "${N}" "${PCT}" "${NS}"
        done
    done
done

echo
echo "=== Pilot bound checks ==="

PASS=1

# Check absl_flat lookup N=4096
ABSL_4K="${LOOKUP_RESULTS["absl_flat_4096"]:-}"
if [[ -z "${ABSL_4K}" || "${ABSL_4K}" == "ERR" || "${ABSL_4K}" == "SKIP" ]]; then
    echo "FAIL: absl_flat lookup N=4096 — no result"
    PASS=0
else
    python3 - <<EOF
import sys
v = float("${ABSL_4K}")
lo, hi = 3.0, 5.0
if lo <= v <= hi:
    print(f"PASS: absl_flat lookup N=4096 = {v:.2f} ns  (expected [{lo}, {hi}])")
else:
    print(f"FAIL: absl_flat lookup N=4096 = {v:.2f} ns  (expected [{lo}, {hi}])")
    sys.exit(1)
EOF
    [[ $? -eq 0 ]] || PASS=0
fi

# Check std_unord lookup N=4096
UNORD_4K="${LOOKUP_RESULTS["std_unord_4096"]:-}"
if [[ -z "${UNORD_4K}" || "${UNORD_4K}" == "ERR" || "${UNORD_4K}" == "SKIP" ]]; then
    echo "FAIL: std_unord lookup N=4096 — no result"
    PASS=0
else
    python3 - <<EOF
import sys
v = float("${UNORD_4K}")
lo, hi = 20.0, 35.0
if lo <= v <= hi:
    print(f"PASS: std_unord  lookup N=4096 = {v:.2f} ns  (expected [{lo}, {hi}])")
else:
    print(f"FAIL: std_unord  lookup N=4096 = {v:.2f} ns  (expected [{lo}, {hi}])")
    print("      Possible causes: DCE of accumulator, seed drift, toolchain change.")
    print("      See Open item 5 in docs/briefs/07-no-crossover-brief.md.")
    sys.exit(1)
EOF
    [[ $? -eq 0 ]] || PASS=0
fi

echo
if [[ "${PASS}" -eq 1 ]]; then
    echo "Calibration PASSED — safe to proceed with headline capture."
    exit 0
else
    echo "Calibration FAILED — do not run headline capture until bounds are met."
    exit 1
fi
