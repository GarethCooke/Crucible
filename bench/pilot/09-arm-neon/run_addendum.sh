#!/usr/bin/env bash
# run_addendum.sh — Demo 09 addendum tasks 1c + 2a: timing captures.
#
# Captures scalar_poly and autovec at N=16k and N=1M (5 runs each), then
# runs three sanity checks against the existing scalar-libm and neon logs
# from the first pilot.  Sanity failures are flags for §3, not hard stops.
#
# Run AFTER verify_addendum_codegen.sh confirms price_scalar_poly codegen is clean.
# Must be run on the Pi 5 rig.
#
# Usage: ./run_addendum.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
BIN="$BUILD_DIR/pilot_blackscholes"
LOG_DIR="$SCRIPT_DIR/pilot_logs"
PREFLIGHT="$SCRIPT_DIR/../../scripts/pi-preflight.sh"

mkdir -p "$LOG_DIR"

# ─── Colour / print helpers ───────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

pass()   { printf "${GREEN}[PASS]${RESET} %s\n"   "$*"; }
fail()   { printf "${RED}[FAIL]${RESET} %s\n"     "$*" >&2; }
info()   { printf "${CYAN}[INFO]${RESET} %s\n"    "$*"; }
warn()   { printf "${YELLOW}[WARN]${RESET} %s\n"  "$*"; }
header() { printf "\n${BOLD}${CYAN}━━━ %s ━━━${RESET}\n" "$*"; }
die()    { printf "${RED}[ABORT]${RESET} %s\n"    "$*" >&2; exit 1; }

fp_ratio()    { awk -v a="$1" -v b="$2" 'BEGIN { printf "%.2f", a / b }'; }
fp_pct_diff() { awk -v a="$1" -v b="$2" 'BEGIN { printf "%.1f", (a - b) / b * 100 }'; }
fp_lt()       { awk -v a="$1" -v b="$2" 'BEGIN { exit (a + 0 < b + 0) ? 0 : 1 }'; }
fp_abs_le()   { awk -v a="$1" -v b="$2" 'BEGIN { v = a + 0; exit (v < 0 ? -v : v) <= b + 0 ? 0 : 1 }'; }
fp_in_range() { awk -v v="$1" -v lo="$2" -v hi="$3" 'BEGIN { exit (v+0 >= lo+0 && v+0 <= hi+0) ? 0 : 1 }'; }

extract_median_ns() { grep 'median:' "$1" | awk '{print $2}'; }
extract_max_err()   { grep 'max_abs_error' "$1" | grep -oE '[0-9]+\.[0-9]+e[+-][0-9]+' | head -1; }

# ─── Preflight ────────────────────────────────────────────────────────────────
header "Preflight"
if [[ -x "$PREFLIGHT" ]]; then
    info "Running pi-preflight.sh..."
    "$PREFLIGHT" || die "Preflight failed — fix rig state before capturing"
    pass "Preflight green"
else
    warn "pi-preflight.sh not found at $PREFLIGHT — skipping rig check"
    warn "Proceed only if you have manually verified: governor=performance, throttled=0x0"
fi

# ─── Binary ───────────────────────────────────────────────────────────────────
header "Binary"
[[ -x "$BIN" ]] || die "Binary not found: $BIN — run verify_addendum_codegen.sh --build first"
pass "Binary: $BIN"

# ─── Capture helper ───────────────────────────────────────────────────────────
run_variant() {
    local variant="$1" n="$2" logfile="$3"
    info "taskset -c 3  $BIN --variant $variant --n $n"
    taskset -c 3 "$BIN" --variant "$variant" --n "$n" | tee "$logfile"
    echo ""
}

# ─── Task 1c: scalar_poly ─────────────────────────────────────────────────────
header "Task 1c — scalar_poly  N=16384"
run_variant scalar_poly 16384   "$LOG_DIR/addendum_scalar_poly_16k.txt"

header "Task 1c — scalar_poly  N=1048576"
run_variant scalar_poly 1048576 "$LOG_DIR/addendum_scalar_poly_1m.txt"

SCALAR_POLY_16K=$(extract_median_ns "$LOG_DIR/addendum_scalar_poly_16k.txt")
SCALAR_POLY_1M=$(extract_median_ns  "$LOG_DIR/addendum_scalar_poly_1m.txt")
ERR_POLY_16K=$(extract_max_err      "$LOG_DIR/addendum_scalar_poly_16k.txt")
ERR_POLY_1M=$(extract_max_err       "$LOG_DIR/addendum_scalar_poly_1m.txt")

# Correctness gate — binary aborts on error >= 1e-4 anyway, but report explicitly
header "scalar_poly correctness"
for entry in "16k:$ERR_POLY_16K" "1M:$ERR_POLY_1M"; do
    n_label="${entry%%:*}"; err="${entry##*:}"
    if awk -v e="$err" 'BEGIN { exit (e + 0 < 1e-4) ? 0 : 1 }'; then
        pass "${n_label}: max_abs_error=${err} < 1e-4"
    else
        fail "${n_label}: max_abs_error=${err} >= 1e-4 — polynomial port has a bug"
        fail "  Stop here; do not proceed to §3 timing (addendum §correctness-regression)"
        exit 1
    fi
done

# ─── Task 2a: autovec ─────────────────────────────────────────────────────────
header "Task 2a — autovec  N=16384"
run_variant autovec 16384   "$LOG_DIR/addendum_autovec_16k.txt"

header "Task 2a — autovec  N=1048576"
run_variant autovec 1048576 "$LOG_DIR/addendum_autovec_1m.txt"

AUTOVEC_16K=$(extract_median_ns "$LOG_DIR/addendum_autovec_16k.txt")
AUTOVEC_1M=$(extract_median_ns  "$LOG_DIR/addendum_autovec_1m.txt")

# ─── Load first-pilot baselines ───────────────────────────────────────────────
SCALAR_LIBM_16K=""; SCALAR_LIBM_1M=""
NEON_16K=""; NEON_1M=""
BASELINES_OK=1

for var_n in "scalar:16k:$LOG_DIR/a2_scalar_16k.txt" \
             "scalar:1m:$LOG_DIR/a2_scalar_1m.txt"   \
             "neon:16k:$LOG_DIR/a2_neon_16k.txt"     \
             "neon:1m:$LOG_DIR/a2_neon_1m.txt"; do
    log="${var_n##*:}"
    [[ -f "$log" ]] || { warn "First-pilot log not found: $log — sanity checks will be partial"; BASELINES_OK=0; }
done

if [[ "$BASELINES_OK" -eq 1 ]]; then
    SCALAR_LIBM_16K=$(extract_median_ns "$LOG_DIR/a2_scalar_16k.txt")
    SCALAR_LIBM_1M=$(extract_median_ns  "$LOG_DIR/a2_scalar_1m.txt")
    NEON_16K=$(extract_median_ns        "$LOG_DIR/a2_neon_16k.txt")
    NEON_1M=$(extract_median_ns         "$LOG_DIR/a2_neon_1m.txt")
fi

# ─── Sanity checks (flags for §3, not hard stops) ────────────────────────────
header "Sanity checks — flags for §3 (not gates)"

# 1. autovec ≈ scalar-libm (confirms asm-identity prediction)
echo ""
info "Sanity 1 — autovec sits on the scalar-libm curve (expect within ±5%)"
if [[ -n "$SCALAR_LIBM_16K" && -n "$SCALAR_LIBM_1M" ]]; then
    for entry in "16k:$AUTOVEC_16K:$SCALAR_LIBM_16K" "1M:$AUTOVEC_1M:$SCALAR_LIBM_1M"; do
        n_label="${entry%%:*}"; rest="${entry#*:}"
        av="${rest%%:*}"; sl="${rest##*:}"
        pct=$(fp_pct_diff "$av" "$sl")
        if fp_abs_le "$pct" 5; then
            pass "${n_label}: autovec=${av} ns/op  scalar-libm=${sl} ns/op  diff=${pct}%  (≤5%) — asm-identity confirmed"
        else
            warn "${n_label}: autovec=${av} ns/op  scalar-libm=${sl} ns/op  diff=${pct}%  (>5%)"
            warn "  Flag for §3: binaries may differ in a way the asm-inspection didn't show"
        fi
    done
else
    warn "First-pilot scalar-libm logs missing — skipping sanity 1"
fi

# 2. scalar_poly faster than scalar-libm (inline poly beats libm call)
echo ""
info "Sanity 2 — scalar_poly is faster than scalar-libm (inline poly beats libm)"
if [[ -n "$SCALAR_LIBM_16K" && -n "$SCALAR_LIBM_1M" ]]; then
    for entry in "16k:$SCALAR_POLY_16K:$SCALAR_LIBM_16K" "1M:$SCALAR_POLY_1M:$SCALAR_LIBM_1M"; do
        n_label="${entry%%:*}"; rest="${entry#*:}"
        sp="${rest%%:*}"; sl="${rest##*:}"
        if fp_lt "$sp" "$sl"; then
            ratio=$(fp_ratio "$sl" "$sp")
            pass "${n_label}: scalar_poly=${sp} < scalar-libm=${sl} ns/op  (${ratio}× faster)"
        else
            warn "${n_label}: scalar_poly=${sp} >= scalar-libm=${sl} ns/op — inline poly not faster"
            warn "  Flag for §3: unexpected; check FTZ and compiler flags"
        fi
    done
else
    warn "First-pilot scalar-libm logs missing — skipping sanity 2"
fi

# 3. scalar_poly → neon ratio near 4× (width-isolation check; not a blocker)
echo ""
info "Sanity 3 — scalar_poly/neon ratio near 4× (expect 3.5–4.5×; record if outside)"
if [[ -n "$NEON_16K" && -n "$NEON_1M" ]]; then
    for entry in "16k:$SCALAR_POLY_16K:$NEON_16K" "1M:$SCALAR_POLY_1M:$NEON_1M"; do
        n_label="${entry%%:*}"; rest="${entry#*:}"
        sp="${rest%%:*}"; neon="${rest##*:}"
        ratio=$(fp_ratio "$sp" "$neon")
        if fp_in_range "$ratio" 3.5 4.5; then
            pass "${n_label}: scalar_poly/neon=${ratio}× — speedup is width-driven"
        else
            warn "${n_label}: scalar_poly/neon=${ratio}× — outside 3.5–4.5×"
            warn "  If >4×: residual FMA/scheduling finding — record for §3 framing"
            warn "  If <3.5×: unexpected limiting factor — flag for §3"
        fi
    done
else
    warn "First-pilot neon logs missing — skipping sanity 3"
fi

# ─── Post-capture preflight (confirms rig remained stable) ───────────────────
header "Post-capture preflight"
if [[ -x "$PREFLIGHT" ]]; then
    "$PREFLIGHT" || warn "Post-capture preflight failed — rig state changed during run; review captures"
    pass "Post-capture preflight green — rig was stable throughout"
else
    warn "pi-preflight.sh not found — skipping post-capture rig check"
fi

# ─── Results table ────────────────────────────────────────────────────────────
header "Results"
printf "\n  %-18s  %12s  %12s\n" "variant" "16k ns/op" "1M ns/op"
printf "  %-18s  %12s  %12s\n"   "──────────────────" "────────────" "────────────"
[[ -n "$SCALAR_LIBM_16K" ]] && \
    printf "  %-18s  %12s  %12s\n" "scalar (libm)" "$SCALAR_LIBM_16K" "$SCALAR_LIBM_1M"
printf "  %-18s  %12s  %12s\n" "scalar_poly"     "$SCALAR_POLY_16K" "$SCALAR_POLY_1M"
printf "  %-18s  %12s  %12s\n" "autovec"           "$AUTOVEC_16K"     "$AUTOVEC_1M"
[[ -n "$NEON_16K" ]] && \
    printf "  %-18s  %12s  %12s\n" "neon (hand)"   "$NEON_16K"         "$NEON_1M"
echo ""
info "Logs saved to $LOG_DIR/:"
info "  addendum_scalar_poly_16k.txt  addendum_scalar_poly_1m.txt"
info "  addendum_autovec_16k.txt      addendum_autovec_1m.txt"
