#!/usr/bin/env bash
# verify_boost_off.sh — Task 5 acceptance check for recaptured Machine 1 JSONs.
#
# For every supplied JSON (or all perf/*.json when called with no args), verifies:
#   1. machine.turbo == false
#   2. machine.freq_max_mhz < 4000  (no 4560 boost ceiling)
#   3. machine.lscpu_extended contains no MAXMHZ column value >= 4500
#   4. The JSON is well-formed (jq parse succeeds)
#
# Usage:
#   bench/scripts/verify_boost_off.sh                        # all Machine 1 JSONs
#   bench/scripts/verify_boost_off.sh site/src/data/perf/06-aos-vs-soa.json ...
#
# Exit 0: all checks pass.  Exit 1: one or more failures.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PERF_DIR="${REPO_ROOT}/site/src/data/perf"

# Machine 1 (Ryzen 7 3800X) demos — demo 09 is the Pi rig, skip it.
MACHINE1_SLUGS=(
    01-branch-prediction
    02-false-sharing-pnl
    03-simd-blackscholes
    04-spsc-queue
    05-allocators
    05-allocators-cross-ccx
    06-aos-vs-soa
    07-no-crossover
    08-sorting-shootout
)

if [[ "$#" -gt 0 ]]; then
    FILES=("$@")
else
    FILES=()
    for slug in "${MACHINE1_SLUGS[@]}"; do
        f="${PERF_DIR}/${slug}.json"
        [[ -f "$f" ]] && FILES+=("$f")
    done
fi

if [[ "${#FILES[@]}" -eq 0 ]]; then
    echo "ERROR: no JSON files found to verify." >&2
    exit 1
fi

PASS=0
FAIL=0

for f in "${FILES[@]}"; do
    label="$(basename "$f")"
    ok=1

    # 1. Well-formed JSON
    if ! jq empty "$f" 2>/dev/null; then
        echo "FAIL [$label]: invalid JSON" >&2
        FAIL=$(( FAIL + 1 ))
        continue
    fi

    # 2. machine.turbo == false
    turbo=$(jq -r '.machine.turbo // "MISSING"' "$f")
    if [[ "$turbo" != "false" ]]; then
        echo "FAIL [$label]: machine.turbo=${turbo} (expected false)" >&2
        ok=0
    fi

    # 3. machine.freq_max_mhz < 4000 (present and plausible base-clock value)
    freq_max=$(jq -r '.machine.freq_max_mhz // "null"' "$f")
    if [[ "$freq_max" == "null" ]]; then
        echo "WARN [$label]: machine.freq_max_mhz absent (pre-fix capture?)" >&2
    elif [[ "$freq_max" -ge 4000 ]]; then
        echo "FAIL [$label]: machine.freq_max_mhz=${freq_max} >= 4000 — boost may be active" >&2
        ok=0
    fi

    # 4. lscpu_extended MAXMHZ column: no value >= 4500 (the 4560 boost ceiling)
    lscpu_ext=$(jq -r '.machine.lscpu_extended // ""' "$f")
    if echo "$lscpu_ext" | grep -qE '[0-9]{4}\.[0-9]+' ; then
        # Extract all numeric values that look like MHz (4+ digits)
        boosted_mhz=$(echo "$lscpu_ext" \
            | grep -oE '[0-9]{4}\.[0-9]+' \
            | awk -F. '$1 >= 4500 {print $1"."$2}' || true)
        if [[ -n "$boosted_mhz" ]]; then
            echo "FAIL [$label]: lscpu_extended contains MAXMHZ >= 4500: ${boosted_mhz}" >&2
            ok=0
        fi
    fi

    if [[ "$ok" -eq 1 ]]; then
        echo "PASS [$label]: turbo=false, freq_max_mhz=${freq_max}"
        PASS=$(( PASS + 1 ))
    else
        FAIL=$(( FAIL + 1 ))
    fi
done

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed (${#FILES[@]} total)"
[[ "$FAIL" -eq 0 ]]
