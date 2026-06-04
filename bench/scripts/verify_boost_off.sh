#!/usr/bin/env bash
# verify_boost_off.sh — standalone acceptance check for recaptured Machine 1 JSONs.
#
# One command, authoritative verdict — no manual jq/eyeballing needed. For every
# supplied JSON (or all Machine 1 perf/*.json when called with no args), a demo
# PASSES only if ALL of:
#   1. JSON is well-formed (jq parse succeeds)
#   2. machine.turbo == false
#   3. machine.turbo_source ∈ {cpb, scaling_avail_freq, cpufreq/boost}
#      (a real signal verified it; "unavailable"/missing => detection failed)
#   4. machine.freq_max_available_mhz present AND < 4000
#      (the P-state ceiling that tracks CPB state; ~3900 on this rig with CPB off)
#
# Note: freq_max_advertised_mhz (lscpu MAXMHZ, ~4560) is advisory only — it stays at
# the silicon boost ceiling on acpi-cpufreq regardless of CPB state; it is NOT gated on.
# freq_base_mhz may legitimately be null (acpi-cpufreq does not expose base_frequency).
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
    tsource=$(jq -r '.machine.turbo_source // "MISSING"' "$f")
    freq_max_available=$(jq -r '.machine.freq_max_available_mhz // "MISSING"' "$f")
    freq_max_advertised=$(jq -r '.machine.freq_max_advertised_mhz // "MISSING"' "$f")
    fbase=$(jq -r '.machine.freq_base_mhz // "null"' "$f")

    # 2. turbo == false
    if [[ "$turbo" != "false" ]]; then
        reasons+=("turbo=${turbo} (expected false)")
        ok=0
    fi

    # 3. turbo_source must be a trustworthy signal
    case "$tsource" in
        cpb|scaling_avail_freq|"cpufreq/boost") ;;
        *)
            reasons+=("turbo_source=${tsource} (expected cpb, scaling_avail_freq, or cpufreq/boost)")
            ok=0
            ;;
    esac

    # 4. freq_max_available_mhz present and < 4000 (P-state ceiling that tracks CPB state)
    if [[ "$freq_max_available" == "MISSING" || "$freq_max_available" == "null" ]]; then
        reasons+=("freq_max_available_mhz absent (not recaptured with fixed header)")
        ok=0
    elif [[ "$freq_max_available" -ge 4000 ]]; then
        reasons+=("freq_max_available_mhz=${freq_max_available} >= 4000 (boost-range P-state available)")
        ok=0
    fi

    if [[ "$ok" -eq 1 ]]; then
        echo "PASS [$label]: turbo=false  turbo_source=${tsource}  freq_max_available_mhz=${freq_max_available}  freq_max_advertised_mhz=${freq_max_advertised} (advisory)"
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
