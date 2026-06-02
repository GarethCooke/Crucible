#!/usr/bin/env bash
# run_pilot.sh — Demo 09 ARM NEON pilot: A1–A5 go/no-go runner
#
# Runs all five pilot tasks in sequence with per-step validation.
# Execution order: A5 (codegen) → A1 (PMU) → A2/A3 (ratios) → A4 (soak).
# A5 comes first because a codegen failure makes ratio measurements meaningless.
#
# Must be run on the Pi 5 rig (BCM2712 / Cortex-A76 / AArch64).
# Usage:
#   ./run_pilot.sh          # expects pre-built binary
#   ./run_pilot.sh --build  # cmake build first

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
BIN="$BUILD_DIR/pilot_blackscholes"
ASM_DIR="$SCRIPT_DIR/asm"
LOG_DIR="$SCRIPT_DIR/pilot_logs"
SOAK_SECONDS=480   # 8 minutes

mkdir -p "$LOG_DIR"

# ─── Colour / print helpers ────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

pass() { printf "${GREEN}[PASS]${RESET} %s\n" "$*"; }
fail() { printf "${RED}[FAIL]${RESET} %s\n" "$*"; }
info() { printf "${CYAN}[INFO]${RESET} %s\n" "$*"; }
warn() { printf "${YELLOW}[WARN]${RESET} %s\n" "$*"; }
header() { printf "\n${BOLD}${CYAN}━━━ %s ━━━${RESET}\n" "$*"; }
die()  { printf "${RED}[ABORT]${RESET} %s\n" "$*" >&2; print_summary; exit 1; }

# ─── Result tracking ───────────────────────────────────────────────────────────
declare -A RESULTS=(
    [A1]="SKIP" [A2]="SKIP" [A3]="SKIP" [A4]="SKIP" [A5]="SKIP"
)

# ─── Cleanup on exit ──────────────────────────────────────────────────────────
BENCH_PID=""
SOAK_SENTINEL=""
cleanup() {
    if [[ -n "$SOAK_SENTINEL" && -f "$SOAK_SENTINEL" ]]; then
        rm -f "$SOAK_SENTINEL"
    fi
    if [[ -n "$BENCH_PID" ]] && kill -0 "$BENCH_PID" 2>/dev/null; then
        kill "$BENCH_PID" 2>/dev/null || true
        wait "$BENCH_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT

# ─── Summary ──────────────────────────────────────────────────────────────────
print_summary() {
    header "Go/No-Go Summary"
    printf "\n  %-4s  %-12s\n" "Task" "Result"
    printf "  %-4s  %-12s\n"   "────" "────────────"
    local overall=0
    for task in A1 A2 A3 A4 A5; do
        local r="${RESULTS[$task]}"
        local colour="$RESET"
        case "$r" in
            GO)                           colour="$GREEN"  ;;
            STOP|FAIL)                    colour="$RED";   overall=1 ;;
            WARN|REFRAME|COLLAPSE|SKIP)   colour="$YELLOW" ;;
        esac
        printf "  ${colour}%-4s  %-12s${RESET}\n" "$task" "$r"
    done
    echo ""
    if [[ $overall -eq 0 ]]; then
        pass "All hard-stop gates cleared — proceed to implementation brief."
    else
        fail "One or more hard-stop conditions hit — resolve before writing the brief."
    fi
}

# ─── Floating-point comparison via awk ────────────────────────────────────────
# Usage: fp_ge <a> <b>   → exit 0 if a >= b, exit 1 otherwise
fp_ge() { awk -v a="$1" -v b="$2" 'BEGIN { exit (a >= b) ? 0 : 1 }'; }
fp_gt() { awk -v a="$1" -v b="$2" 'BEGIN { exit (a >  b) ? 0 : 1 }'; }
fp_pct_diff() {
    # Prints percentage by which $1 exceeds $2  (($1 - $2) / $2 * 100)
    awk -v a="$1" -v b="$2" 'BEGIN { printf "%.1f", (a - b) / b * 100 }'
}
fp_ratio() {
    awk -v a="$1" -v b="$2" 'BEGIN { printf "%.2f", a / b }'
}

# ─── Build ────────────────────────────────────────────────────────────────────
header "Build"
if [[ "${1:-}" == "--build" ]] || [[ ! -x "$BIN" ]]; then
    info "Running cmake build..."
    cmake -S "$SCRIPT_DIR" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release
    cmake --build "$BUILD_DIR"
fi
if [[ ! -x "$BIN" ]]; then
    die "Binary not found: $BIN — run with --build or cmake manually"
fi
pass "Binary: $BIN"

# ─────────────────────────────────────────────────────────────────────────────
# A5 — Codegen sanity  (runs first: invalid codegen poisons A2/A3 ratios)
# ─────────────────────────────────────────────────────────────────────────────
header "A5 — Codegen + denormals sanity"
A5_OK=1

if [[ ! -f "$ASM_DIR/price_neon.s" || ! -f "$ASM_DIR/price_scalar.s" ]]; then
    fail "ASM dump files missing from $ASM_DIR/"
    fail "The post-build dump_asm.sh step may not have run."
    info "Hint: rebuild with --build, or run: $SCRIPT_DIR/dump_asm.sh $BIN $ASM_DIR"
    A5_OK=0
else
    # Hand-NEON must contain vector ops
    NEON_HITS=$(grep -cE 'fmla|v[0-9]+\.4s' "$ASM_DIR/price_neon.s" || true)
    if [[ "$NEON_HITS" -gt 0 ]]; then
        pass "price_neon.s: $NEON_HITS NEON instruction(s) found (fmla / v*.4s)"
    else
        fail "price_neon.s: no NEON instructions found — codegen has not vectorised"
        A5_OK=0
    fi

    # Scalar baseline must have zero vector ops (autovec guard check)
    SCALAR_HITS=$(grep -cE 'fmla|v[0-9]+\.4s' "$ASM_DIR/price_scalar.s" || true)
    if [[ "$SCALAR_HITS" -eq 0 ]]; then
        pass "price_scalar.s: no NEON ops — -fno-tree-vectorize guard is working"
    else
        fail "price_scalar.s: $SCALAR_HITS NEON instruction(s) found"
        fail "  The -fno-tree-vectorize guard failed; A2 would measure autovec-vs-autovec."
        fail "  Check the __attribute__((optimize(\"no-tree-vectorize\"))) on price_scalar()."
        A5_OK=0
    fi

    # Autovec variant must contain vector ops (confirms GCC autovectorised at -O3)
    if [[ -f "$ASM_DIR/price_autovec.s" ]]; then
        AUTOVEC_HITS=$(grep -cE 'fmla|v[0-9]+\.4s' "$ASM_DIR/price_autovec.s" || true)
        if [[ "$AUTOVEC_HITS" -gt 0 ]]; then
            pass "price_autovec.s: $AUTOVEC_HITS NEON instruction(s) — GCC autovectorised at -O3"
        else
            warn "price_autovec.s: no NEON ops — GCC did not autovectorise; A3 will show no gap (fine outcome)"
        fi
    else
        warn "price_autovec.s not found — rebuild to generate it (cmake --build build)"
    fi
fi

if [[ $A5_OK -eq 1 ]]; then
    RESULTS[A5]="GO"
    pass "A5: GO"
else
    RESULTS[A5]="FAIL"
    fail "A5: FAIL"
    die "Codegen failure — A2/A3 measurements would be untrustworthy; aborting."
fi

# ─────────────────────────────────────────────────────────────────────────────
# A1 — Full PMU counter set
# ─────────────────────────────────────────────────────────────────────────────
header "A1 — PMU counter availability"

if ! command -v perf &>/dev/null; then
    warn "perf not found — skipping A1 (install linux-perf or linux-tools)"
    RESULTS[A1]="SKIP"
else
    A1_LOG="$LOG_DIR/a1_perf_stat.txt"
    info "Running perf stat (variant=neon, N=1M)..."
    info "Log: $A1_LOG"

    # perf stat writes its output to stderr; capture both streams
    perf stat \
        -e cycles,instructions,branch-misses,cache-misses,cache-references \
        taskset -c 3 "$BIN" --variant neon --n 1048576 \
        > >(tee "$A1_LOG") 2>&1

    A1_FAIL=0
    for counter in cycles instructions branch-misses cache-misses cache-references; do
        if grep -q "${counter}.*<not supported>" "$A1_LOG"; then
            fail "  $counter: <not supported>"
            A1_FAIL=1
        elif grep -q "${counter}.*<not counted>" "$A1_LOG"; then
            fail "  $counter: <not counted>"
            A1_FAIL=1
        else
            pass "  $counter: available"
        fi
    done

    if [[ $A1_FAIL -eq 0 ]]; then
        RESULTS[A1]="GO"
        pass "A1: All PMU counters available — counter-overlay charts are in — GO"
    else
        RESULTS[A1]="REFRAME"
        warn "A1: Some counters unavailable."
        warn "  → REFRAME (not a hard stop): drop counter-overlay panel, lean on ratio charts."
        warn "  Hint: try A76 raw event e.g. 'r0017' for L2D refills if generic alias misfires."
    fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# A2 / A3 — NEON-over-scalar ratio (two N)
# ─────────────────────────────────────────────────────────────────────────────
header "A2 — NEON-over-scalar ratios"

run_variant() {
    local variant="$1" n="$2" logfile="$3"
    info "  taskset -c 3 $BIN --variant $variant --n $n"
    taskset -c 3 "$BIN" --variant "$variant" --n "$n" | tee "$logfile"
}

extract_median_ns() {
    # Parses "median:  X.XXX ns/op  ..." → X.XXX
    grep 'median:' "$1" | awk '{print $2}'
}

# N = 16 384 (cache-resident, isolates compute-bound case)
info "=== N=16384 (cache-resident ~320 KB) ==="
run_variant scalar 16384  "$LOG_DIR/a2_scalar_16k.txt"
run_variant neon   16384  "$LOG_DIR/a2_neon_16k.txt"

SCALAR_16K=$(extract_median_ns "$LOG_DIR/a2_scalar_16k.txt")
NEON_16K=$(extract_median_ns   "$LOG_DIR/a2_neon_16k.txt")
RATIO_16K=$(fp_ratio "$SCALAR_16K" "$NEON_16K")
info "16k compute-bound ratio: scalar=${SCALAR_16K} ns/op  neon=${NEON_16K} ns/op  ratio=${RATIO_16K}×"

# N = 1 048 576 (headline; spills cache)
info "=== N=1048576 (headline, spills cache) ==="
run_variant scalar 1048576 "$LOG_DIR/a2_scalar_1m.txt"
run_variant neon   1048576 "$LOG_DIR/a2_neon_1m.txt"

SCALAR_1M=$(extract_median_ns "$LOG_DIR/a2_scalar_1m.txt")
NEON_1M=$(extract_median_ns   "$LOG_DIR/a2_neon_1m.txt")
RATIO_1M=$(fp_ratio "$SCALAR_1M" "$NEON_1M")
info "1M headline ratio: scalar=${SCALAR_1M} ns/op  neon=${NEON_1M} ns/op  ratio=${RATIO_1M}×"

# ── A2 validation (decision on 16k compute-bound number) ──────────────────────
if fp_ge "$RATIO_16K" 3.5; then
    RESULTS[A2]="GO"
    pass "A2: 16k ratio ${RATIO_16K}× ≥ 3.5× — Framing B ceiling is real — GO"
elif fp_ge "$RATIO_16K" 2.5; then
    RESULTS[A2]="WARN"
    warn "A2: 16k ratio ${RATIO_16K}× is in the 2.5–3.5× grey zone."
    warn "  Investigate before committing the brief (FTZ set? scalar guard effective?)"
else
    RESULTS[A2]="STOP"
    fail "A2: 16k ratio ${RATIO_16K}× < 2.5× — STOP"
    fail "  Likely causes (scope §A2): FTZ not set, scalar baseline autovec'd (check A5), wrong N."
    fail "  Do not write the brief on a sub-ceiling number."
fi

# ── A3 — autovec vs hand-NEON at N=16k (decides Framing A) ───────────────────
# Runs the autovec variant (same polynomial, no guard — GCC autovectorises at
# -O3 -mcpu=cortex-a76) and compares its median against hand-NEON at 16k.
# This is the question the scope couldn't answer from A2's guarded-scalar data.
header "A3 — Autovec vs hand-NEON (Framing A)"
info "=== N=16384 (autovec vs hand-NEON) ==="
run_variant autovec 16384 "$LOG_DIR/a3_autovec_16k.txt"

AUTOVEC_16K=$(extract_median_ns "$LOG_DIR/a3_autovec_16k.txt")
MARGIN_16K=$(fp_pct_diff "$AUTOVEC_16K" "$NEON_16K")
RATIO_A3=$(fp_ratio "$AUTOVEC_16K" "$NEON_16K")
info "A3 autovec vs hand-NEON: autovec=${AUTOVEC_16K} ns/op  neon=${NEON_16K} ns/op  ratio=${RATIO_A3}×  hand-NEON advantage=${MARGIN_16K}%"

if fp_gt "$MARGIN_16K" 15; then
    RESULTS[A3]="GO"
    pass "A3: Hand-NEON beats autovec by ${MARGIN_16K}% > 15% — Framing A alive as secondary story — GO"
elif fp_gt "$MARGIN_16K" 10; then
    RESULTS[A3]="WARN"
    warn "A3: Margin ${MARGIN_16K}% (10–15%) — borderline; Framing A questionable."
else
    RESULTS[A3]="COLLAPSE"
    info "A3: Margin ${MARGIN_16K}% ≤ 10% — Framing A collapses."
    info "  Demo rests on Framing B alone: 'free autovec NEON still hits the same 4-wide wall.'"
    info "  This is a fine outcome — scope §A3 says so explicitly."
fi

# ─────────────────────────────────────────────────────────────────────────────
# A4 — Sustained-load thermal soak (~8 min)
# ─────────────────────────────────────────────────────────────────────────────
header "A4 — Thermal soak (${SOAK_SECONDS}s)"

if ! command -v vcgencmd &>/dev/null; then
    warn "vcgencmd not found — skipping A4 (Pi-specific tool not available)"
    RESULTS[A4]="SKIP"
else
    SOAK_LOG="$LOG_DIR/a4_soak.txt"
    SOAK_SENTINEL="$(mktemp /tmp/pilot_soak.XXXXXX)"

    info "Launching bench loop on core 3 (background)..."
    (
        while [[ -f "$SOAK_SENTINEL" ]]; do
            taskset -c 3 "$BIN" --variant neon --n 1048576 >/dev/null 2>&1
        done
    ) &
    BENCH_PID=$!

    THROTTLE_FIRED=0
    MAX_TEMP_INT=0   # integer °C (no bc needed)
    POLL_END=$(( SECONDS + SOAK_SECONDS ))

    info "Polling temp + throttle every 2s for ${SOAK_SECONDS}s..."
    info "Log: $SOAK_LOG"
    : > "$SOAK_LOG"

    while [[ $SECONDS -lt $POLL_END ]] && kill -0 "$BENCH_PID" 2>/dev/null; do
        TEMP_RAW=$(vcgencmd measure_temp 2>/dev/null || echo "temp=N/A")
        THROTTLE_RAW=$(vcgencmd get_throttled 2>/dev/null || echo "throttled=N/A")
        TIMESTAMP=$(date +%H:%M:%S)

        LINE="$TIMESTAMP  $TEMP_RAW  $THROTTLE_RAW"
        echo "$LINE" | tee -a "$SOAK_LOG"

        # Throttle check
        THROTTLE_VAL=$(echo "$THROTTLE_RAW" | grep -oE '0x[0-9a-fA-F]+' || echo "")
        if [[ -n "$THROTTLE_VAL" && "$THROTTLE_VAL" != "0x0" ]]; then
            THROTTLE_FIRED=1
            fail "  Throttle bit(s) set: $THROTTLE_RAW at $TEMP_RAW"
        fi

        # Track max temperature (integer; vcgencmd gives X.X'C)
        TEMP_INT=$(echo "$TEMP_RAW" | grep -oE '[0-9]+\.[0-9]+' | awk -F. '{print $1}' || echo "0")
        if [[ -n "$TEMP_INT" && "$TEMP_INT" -gt "$MAX_TEMP_INT" ]]; then
            MAX_TEMP_INT=$TEMP_INT
        fi

        sleep 2
    done

    # Stop the bench loop
    rm -f "$SOAK_SENTINEL"; SOAK_SENTINEL=""
    if [[ -n "$BENCH_PID" ]] && kill -0 "$BENCH_PID" 2>/dev/null; then
        kill "$BENCH_PID" 2>/dev/null || true
        wait "$BENCH_PID" 2>/dev/null || true
        BENCH_PID=""
    fi

    info "Soak complete. Max temperature: ~${MAX_TEMP_INT}°C"
    info "Full poll log: $SOAK_LOG"

    if [[ $THROTTLE_FIRED -ne 0 ]]; then
        RESULTS[A4]="STOP"
        fail "A4: Throttle detected during soak — STOP"
        fail "  Every number captured under throttle is contaminated."
        fail "  Sort cooling (active cooler, case airflow) before any authoritative capture."
    elif [[ $MAX_TEMP_INT -ge 80 ]]; then
        RESULTS[A4]="WARN"
        warn "A4: No throttle but max temp ${MAX_TEMP_INT}°C approaches threshold (~80–85°C)."
        warn "  Monitor closely during actual captures; margin is thin."
    else
        RESULTS[A4]="GO"
        pass "A4: No throttle, max temp ${MAX_TEMP_INT}°C — cooler is adequate — GO"
    fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
print_summary
echo ""
info "Run logs saved to: $LOG_DIR/"
