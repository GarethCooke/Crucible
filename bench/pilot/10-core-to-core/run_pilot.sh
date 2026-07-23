#!/usr/bin/env bash
# run_pilot.sh — demo 10 §1 core-to-core pilot gate runner.
#
# Lays out the numbers for the §A calibration gates. It DECIDES NOTHING — the
# protocol, K, window count and core-0 include/exclude are decided from the
# data with Opus/the user. This script only produces and logs numbers.
#
# Gate groups (select one or more; default runs A1, A2, A3):
#   --a1   full RTT matrix, twice back to back (the CCX seam)
#   --a2   representative intra- and cross-CCX pair, both protocols (4 medians)
#   --a3   those two pairs swept over K in {100,1000,10000}, median + IQR per K
#   --a4   core 0's row only  (HEADLESS ONLY — see below)
#
# Round-2 gates — all analysis-grade, all HEADLESS ONLY (assert_headless):
#   --a3b  the real K-lock: --a3's K sweep with --repeat 20 at each K, so the
#          across-allocation IQR (not within-window IQR) is compared to the gap
#   --a6   offset sweep on the intra and cross pair — confirm/kill L3 slicing
#   --a7   baseline fixed cost X on cores 1,2,4,5
#   --a8   pair (1,2) and (4,5) each with the orchestrator on cores 0,3,4,7
#
# GUI-safety: A1-A3 touch only the isolated cores (1-7), which isolcpus keeps
# clear of the desktop, so they are safe to run with the GUI up. A4 measures
# core 0, which under a GUI also carries gdm / the compositor / the session, so
# a GUI-up A4 measures "core 0 plus your desktop" and the verdict comes out
# wrong. A3b/A6/A7/A8 are analysis-grade and must be quiet, so they too are
# headless-gated. --a4 (and the round-2 gates) call assert_headless and refuse
# to run under an active graphical.target; use the wrapper:
#   ./bench/scripts/headless-capture.sh ./bench/pilot/10-core-to-core/run_pilot.sh --a4
#
# The intra/cross pairs for A2/A3 are derived from the sysfs L3 (CCX) grouping,
# never hardcoded; the script prints which pairs it chose and why.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
BIN="$SCRIPT_DIR/build/pingpong"
LOG_DIR="$SCRIPT_DIR/pilot_logs"
mkdir -p "$LOG_DIR"

# lib.sh gives us assert_headless, assert_isolated_cores, assert_smt_off and
# EXPECTED_ISOLATED — the same canonical gates the capture harness uses.
# shellcheck source=bench/scripts/lib.sh
source "$REPO_ROOT/bench/scripts/lib.sh"

# ─── print helpers ────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
info()   { printf "${CYAN}[INFO]${RESET} %s\n" "$*"; }
warn()   { printf "${YELLOW}[WARN]${RESET} %s\n" "$*"; }
header() { printf "\n${BOLD}${CYAN}━━━ %s ━━━${RESET}\n" "$*"; }
die()    { printf "${RED}[ABORT]${RESET} %s\n" "$*" >&2; exit 1; }

# ─── arg parse ────────────────────────────────────────────────────────────────
DO_BUILD=0
GATES=()
for arg in "$@"; do
    case "$arg" in
        --a1)  GATES+=(a1) ;;
        --a2)  GATES+=(a2) ;;
        --a3)  GATES+=(a3) ;;
        --a4)  GATES+=(a4) ;;
        --a3b) GATES+=(a3b) ;;
        --a6)  GATES+=(a6) ;;
        --a7)  GATES+=(a7) ;;
        --a8)  GATES+=(a8) ;;
        --build) DO_BUILD=1 ;;
        -h|--help)
            sed -n '2,31p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *) die "unknown flag '$arg' (want --a1 --a2 --a3 --a4 --a3b --a6 --a7 --a8 [--build])" ;;
    esac
done
[[ ${#GATES[@]} -eq 0 ]] && GATES=(a1 a2 a3)   # default

MASTER_LOG="$LOG_DIR/run_pilot-$(date +%Y%m%dT%H%M%S).log"

# ─── build (optional convenience) ────────────────────────────────────────────
if [[ "$DO_BUILD" -eq 1 ]]; then
    header "build"
    cmake -S "$SCRIPT_DIR" -B "$SCRIPT_DIR/build"
    cmake --build "$SCRIPT_DIR/build"
fi
[[ -x "$BIN" ]] || die "harness not built: run 'cmake -S $SCRIPT_DIR -B $SCRIPT_DIR/build && cmake --build $SCRIPT_DIR/build' (or pass --build)"

# ─── isolation preflight (fail loudly on an unisolated box) ──────────────────
# A pilot run against an unisolated machine is worthless; it must fail rather
# than produce plausible numbers. We do NOT gate on boost — the invariant TSC
# makes ns trustworthy regardless of boost state (brief §Task 2).
preflight() {
    assert_isolated_cores
    assert_smt_off
    local nohz
    nohz="$(cat /sys/devices/system/cpu/nohz_full 2>/dev/null || echo '')"
    [[ "$nohz" == "${EXPECTED_ISOLATED:-1-7}" ]] \
        || die "nohz_full='$nohz', expected '${EXPECTED_ISOLATED:-1-7}' — boot the benchmark GRUB entry."

    # Governor gate — read sysfs scaling_governor DIRECTLY on all eight cores,
    # not by parsing a frequency tool's prose. Round 1's first attempt ran under
    # schedutil and produced a plausible-looking 1.40x that was pure artefact; a
    # standalone script that bypasses run_one.sh bypasses every guarantee it
    # provides, so it must assert its own. Collect the governor files FIRST and
    # fail closed if the glob matched none (cpufreq absent) — a gate that reads
    # zero governors and reports "performance" is the very fail-open this exists
    # to prevent. `grep -Lx` then lists any file whose sole line != "performance".
    local -a gov_files=()
    local gf
    for gf in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [[ -e "$gf" ]] && gov_files+=("$gf")
    done
    (( ${#gov_files[@]} >= 1 )) || die "no scaling_governor files under /sys/.../cpufreq — cannot verify the CPU governor; refusing to run on an unverifiable machine (round 1's schedutil artefact is exactly what this gate exists to catch)."
    local bad_gov
    bad_gov="$(grep -Lx performance "${gov_files[@]}" 2>/dev/null || true)"
    [[ -z "$bad_gov" ]] || die "CPU governor is not 'performance' on:
$bad_gov
  Set it: for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance | sudo tee \$g >/dev/null; done"

    info "isolation OK: isolated=$(cat /sys/devices/system/cpu/isolated) nohz_full=$nohz smt=off governor=performance"
}

# ─── derive the representative intra/cross-CCX pairs from sysfs L3 grouping ───
expand_cpulist() {   # "1-7,9" -> "1 2 3 4 5 6 7 9"
    local spec="$1" part lo hi c out=()
    local -a parts
    IFS=',' read -ra parts <<<"$spec"
    for part in "${parts[@]}"; do
        if [[ "$part" == *-* ]]; then
            lo=${part%-*}; hi=${part#*-}
            for ((c = lo; c <= hi; c++)); do out+=("$c"); done
        else
            out+=("$part")
        fi
    done
    echo "${out[@]}"
}
# `|| true` so a missing file yields "" (caught by the explicit die below) rather
# than aborting main under errexit before the friendly message can print.
l3_domain() { cat "/sys/devices/system/cpu/cpu$1/cache/index3/shared_cpu_list" 2>/dev/null || true; }

INTRA_A="" INTRA_B="" CROSS_A="" CROSS_B=""
derive_pairs() {
    local -a iso
    read -ra iso <<<"$(expand_cpulist "$(cat /sys/devices/system/cpu/isolated)")"
    (( ${#iso[@]} >= 2 )) || die "need >=2 isolated cores, got: ${iso[*]:-none}"

    declare -A DOM
    local c
    for c in "${iso[@]}"; do
        DOM[$c]="$(l3_domain "$c")"
        [[ -n "${DOM[$c]}" ]] || die "cpu$c has no L3 index3/shared_cpu_list — cannot read CCX membership."
    done

    local x y a b
    for ((x = 0; x < ${#iso[@]}; x++)); do
        for ((y = x + 1; y < ${#iso[@]}; y++)); do
            a=${iso[x]}; b=${iso[y]}
            if [[ "${DOM[$a]}" == "${DOM[$b]}" ]]; then
                [[ -z "$INTRA_A" ]] && { INTRA_A=$a; INTRA_B=$b; }
            else
                [[ -z "$CROSS_A" ]] && { CROSS_A=$a; CROSS_B=$b; }
            fi
        done
    done
    [[ -n "$INTRA_A" ]] || die "no intra-CCX isolated pair found in L3 grouping (all cores in distinct domains?)."
    [[ -n "$CROSS_A" ]] || die "no cross-CCX isolated pair found in L3 grouping (all cores in one domain?)."

    header "CCX grouping (from sysfs L3 shared_cpu_list — this is A1's prediction)"
    for c in "${iso[@]}"; do printf "    core %-2s -> L3 domain %s\n" "$c" "${DOM[$c]}"; done
    info "intra-CCX pair: ($INTRA_A,$INTRA_B) — both in L3 domain ${DOM[$INTRA_A]}"
    info "cross-CCX pair: ($CROSS_A,$CROSS_B) — $CROSS_A in ${DOM[$CROSS_A]}, $CROSS_B in ${DOM[$CROSS_B]}"
}

# ─── gates ───────────────────────────────────────────────────────────────────
run_a1() {
    header "A1 — full RTT matrix, twice back to back"
    info "run 1 of 2"
    "$BIN" --full-matrix
    info "run 2 of 2"
    "$BIN" --full-matrix
    info "A1 done — compare the two matrices for stability, and the block"
    info "structure against the CCX grouping above (they should agree)."
}

run_a2() {
    header "A2 — intra vs cross-CCX pair, both protocols (4 medians)"
    local proto
    for proto in exchange twoflag; do
        info "protocol=$proto  intra ($INTRA_A,$INTRA_B)"
        "$BIN" --pair "$INTRA_A,$INTRA_B" --protocol "$proto"
        info "protocol=$proto  cross ($CROSS_A,$CROSS_B)"
        "$BIN" --pair "$CROSS_A,$CROSS_B" --protocol "$proto"
    done
}

run_a3() {
    header "A3 — K sweep {100,1000,10000}, >=20 windows, median + IQR per K"
    local K
    for K in 100 1000 10000; do
        info "K=$K  intra ($INTRA_A,$INTRA_B)"
        "$BIN" --pair "$INTRA_A,$INTRA_B" --k "$K" --windows 20
        info "K=$K  cross ($CROSS_A,$CROSS_B)"
        "$BIN" --pair "$CROSS_A,$CROSS_B" --k "$K" --windows 20
    done
    info "Pick the smallest K whose IQR stays comfortably inside the intra/cross gap."
}

run_a4() {
    header "A4 — core 0's row (HEADLESS ONLY)"
    # Under a GUI, core 0 carries the desktop; this gate refuses to run there.
    assert_headless
    info "core 0 paired with each isolated core:"
    "$BIN" --include-core0
    info "A4 done — judge whether core 0's row is quiet enough to include, or"
    info "whether housekeeping noise argues for excluding it (data decides with user)."
}

# ─── round-2 gates (all HEADLESS ONLY) ───────────────────────────────────────
run_a3b() {
    header "A3b — K sweep {100,1000,10000} with --repeat 20 (the real K-lock)"
    # This is the analysis-grade version of A3: --repeat re-runs each measurement
    # at 20 fresh arena offsets, so the reported error bar is the across-ALLOCATION
    # IQR(medians) — the L3-slice spread — not the within-window IQR that A3 saw.
    assert_headless
    local K
    for K in 100 1000 10000; do
        info "K=$K  intra ($INTRA_A,$INTRA_B)  --repeat 20"
        "$BIN" --pair "$INTRA_A,$INTRA_B" --k "$K" --windows 20 --repeat 20
        info "K=$K  cross ($CROSS_A,$CROSS_B)  --repeat 20"
        "$BIN" --pair "$CROSS_A,$CROSS_B" --k "$K" --windows 20 --repeat 20
    done
    info "K-lock test: pick the smallest K whose across-allocation IQR(medians)"
    info "stays comfortably inside the intra/cross gap — compare that, not the"
    info "within-window IQR A3 reported."
}

run_a6() {
    header "A6 — offset sweep, intra and cross pair (confirm/kill L3 slicing)"
    assert_headless
    info "intra pair ($INTRA_A,$INTRA_B):"
    "$BIN" --offset-sweep --pair "$INTRA_A,$INTRA_B"
    info "cross pair ($CROSS_A,$CROSS_B):"
    "$BIN" --offset-sweep --pair "$CROSS_A,$CROSS_B"
    info "A repeating period or clustering into a few discrete levels confirms L3"
    info "slice placement; a flat line refutes it and sends us hunting elsewhere."
}

run_a7() {
    header "A7 — baseline fixed cost X on cores 1,2,4,5"
    assert_headless
    info "baseline cores 1,2:"
    "$BIN" --baseline --pair 1,2
    info "baseline cores 4,5:"
    "$BIN" --baseline --pair 4,5
    info "X is the fixed protocol cost (two atomic stores into L1 + loop + amortised"
    info "rdtscp). The transfer component is (RTT - X)/2 per direction — computed"
    info "OUTSIDE the harness. If X exceeds the intra-CCX RTT, STOP and report."
}

run_a8() {
    header "A8 — orchestrator placement: pair (1,2) & (4,5) over orchestrator cores 0,3,4,7"
    # Cores fixed by the confirmed 0-3 / 4-7 CCX grouping (preflight asserts
    # isolated=1-7). For pair (1,2) in CCX0: orch 3 is a same-CCX third party,
    # 0 is housekeeping in CCX0, 4/7 are in the other CCX. A flat row argues the
    # orchestrator (which sleeps in pthread_join during the timed region) does
    # not perturb the pair; a bump when orch shares the pair's CCX would explain
    # round 1's intra-CCX0 skew.
    assert_headless
    local orch_cores=(0 3 4 7)
    local pair o med
    printf "    %-7s" "pair"
    for o in "${orch_cores[@]}"; do printf "  orch=%-8s" "$o"; done
    printf "\n"
    for pair in "1,2" "4,5"; do
        printf "    %-7s" "($pair)"
        for o in "${orch_cores[@]}"; do
            # Parse the median from "pair (a,b) RTT: median X ns  ..." (field 5).
            # Guarded with `if`: a $BIN failure (exit != 0) must print ERR in the
            # cell and keep the table going, NOT abort the run via errexit+pipefail
            # on the bare assignment. An empty parse (ran OK, no match) is ERR too.
            if med="$("$BIN" --pair "$pair" --orchestrator-core "$o" 2>/dev/null | awk '/^pair \(/{print $5}')" \
               && [[ -n "$med" ]]; then
                printf "  %-13s" "$med"
            else
                printf "  %-13s" "ERR"
            fi
        done
        printf "\n"
    done
    info "orchestrator sleeps in pthread_join during the timed region (see PR notes);"
    info "a row that is flat across orch cores says its placement does not perturb the pair."
}

# ─── main ────────────────────────────────────────────────────────────────────
# Everything runs inside main() so it can be piped to tee as a single unit: the
# shell waits for the whole pipeline, so a failing gate's remediation message is
# fully flushed to the terminal before we exit (an `exec > >(tee)` redirect
# races on exit and can drop the last line).
main() {
    # main() runs in the left side of the `main | tee` pipe, a subshell that
    # inherits the outer `set +e` (below). Re-enable errexit HERE so a benchmark
    # abort — e.g. pingpong's affinity readback firing (exit 2) — stops the run
    # and surfaces as a non-zero ${PIPESTATUS[0]} instead of being swallowed
    # under a cheerful "done" banner. The `... || die` guards are errexit-safe.
    set -e
    info "logging to $MASTER_LOG"
    header "demo 10 §1 core-to-core pilot — gates: ${GATES[*]}"
    preflight
    derive_pairs

    for g in "${GATES[@]}"; do
        case "$g" in
            a1)  run_a1 ;;
            a2)  run_a2 ;;
            a3)  run_a3 ;;
            a4)  run_a4 ;;
            a3b) run_a3b ;;
            a6)  run_a6 ;;
            a7)  run_a7 ;;
            a8)  run_a8 ;;
        esac
    done

    header "done — full log: $MASTER_LOG"
    info "This script laid out numbers only; no gate was decided here."
}

set +e
main 2>&1 | tee -a "$MASTER_LOG"
rc=${PIPESTATUS[0]}
set -e
exit "$rc"
