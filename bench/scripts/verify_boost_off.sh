#!/usr/bin/env bash
# verify_boost_off.sh — standalone acceptance check for recaptured Machine 1 JSONs.
#
# One command, authoritative verdict — no manual jq/eyeballing needed. For every
# supplied JSON (or all Machine 1 perf/*.json when called with no args), a demo
# PASSES only if ALL of:
#   1. JSON is well-formed (jq parse succeeds)
#   2. machine.turbo == false                       (not true / null / missing)
#   3. machine.freq_max_mhz present AND < 4000       (missing => FAIL: not recaptured
#                                                      with the fixed header)
#   4. machine.turbo_source present and != "unavailable"
#                                                    (a real signal verified it;
#                                                     "unavailable" => detection failed)
#   5. machine.lscpu_extended contains no MAXMHZ column value >= 4500 (the 4560 ceiling)
#
# freq_base_mhz is informational only and may legitimately be null (acpi-cpufreq does
# not expose base_frequency); it is NOT gated on. turbo_source is printed for each demo
# so you can see which signal verified it: "freq_compare*" = MAXMHZ ground-truth active
# (amd_pstate); "cpufreq/boost" = software-toggle fallback (acpi-cpufreq).
#
# Usage:
#   bench/scripts/verify_boost_off.sh                       # all Machine 1 JSONs
#   bench/scripts/verify_boost_off.sh path/to/one.json ...  # a single just-captured demo
#
# Exit 0: all checks pass.  Exit 1: any failure (including missing file / missing field).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PERF_DIR="${REPO_ROOT}/site/src/data/perf"

# Machine 1 (Ryzen 7 3800X) demos — demo 09 is the Pi rig (no boost), skip it.
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

if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required but not installed." >&2
    exit 1
fi

if [[ "$#" -gt 0 ]]; then
    FILES=("$@")
else
    FILES=()
    MISSING=()
    for slug in "${MACHINE1_SLUGS[@]}"; do
        f="${PERF_DIR}/${slug}.json"
        if [[ -f "$f" ]]; then
            FILES+=("$f")
        else
            MISSING+=("$slug")
        fi
    done
    # A Machine 1 demo whose JSON is absent is a failure, not a silent skip.
    if [[ "${#MISSING[@]}" -gt 0 ]]; then
        for slug in "${MISSING[@]}"; do
            echo "FAIL [$slug]: expected JSON not found at ${PERF_DIR}/${slug}.json" >&2
        done
    fi
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
    reasons=()

    # 1. Well-formed JSON
    if ! jq empty "$f" 2>/dev/null; then
        echo "FAIL [$label]: invalid JSON" >&2
        FAIL=$(( FAIL + 1 ))
        continue
    fi

    # NB: jq's // treats false as empty, so a plain `.machine.turbo // "MISSING"`
    # would report a genuine `false` as MISSING. Use has() + tostring instead.
    turbo=$(jq -r 'if (.machine|has("turbo")) and (.machine.turbo != null)
                   then (.machine.turbo|tostring) else "MISSING" end' "$f")
    freq_max=$(jq -r '.machine.freq_max_mhz // "MISSING"' "$f")
    tsource=$(jq -r '.machine.turbo_source // "MISSING"' "$f")
    fbase=$(jq -r '.machine.freq_base_mhz // "null"' "$f")

    # 2. turbo == false
    if [[ "$turbo" != "false" ]]; then
        reasons+=("turbo=${turbo} (expected false)")
        ok=0
    fi

    # 3. freq_max_mhz present and < 4000
    if [[ "$freq_max" == "MISSING" || "$freq_max" == "null" ]]; then
        reasons+=("freq_max_mhz absent (not recaptured with fixed header)")
        ok=0
    elif [[ "$freq_max" -ge 4000 ]]; then
        reasons+=("freq_max_mhz=${freq_max} >= 4000 (boost active)")
        ok=0
    fi

    # 4. turbo_source present and a real signal
    if [[ "$tsource" == "MISSING" || "$tsource" == "unavailable" ]]; then
        reasons+=("turbo_source=${tsource} (no real signal verified boost state)")
        ok=0
    fi

    # 5. lscpu_extended: no MAXMHZ column value >= 4500
    lscpu_ext=$(jq -r '.machine.lscpu_extended // ""' "$f")
    if [[ -n "$lscpu_ext" ]]; then
        boosted_mhz=$(echo "$lscpu_ext" \
            | grep -oE '[0-9]{4}\.[0-9]+' \
            | awk -F. '$1 >= 4500 {print $1"."$2}' || true)
        if [[ -n "$boosted_mhz" ]]; then
            reasons+=("lscpu_extended MAXMHZ >= 4500: ${boosted_mhz}")
            ok=0
        fi
    fi

    if [[ "$ok" -eq 1 ]]; then
        echo "PASS [$label]: turbo=false  freq_max_mhz=${freq_max}  freq_base_mhz=${fbase}  via ${tsource}"
        PASS=$(( PASS + 1 ))
    else
        for r in "${reasons[@]}"; do
            echo "FAIL [$label]: $r" >&2
        done
        FAIL=$(( FAIL + 1 ))
    fi
done

# Count any missing-file failures recorded above (no-arg mode only).
if [[ "$#" -eq 0 && "${#MISSING[@]:-0}" -gt 0 ]]; then
    FAIL=$(( FAIL + ${#MISSING[@]} ))
fi

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
[[ "$FAIL" -eq 0 ]]
