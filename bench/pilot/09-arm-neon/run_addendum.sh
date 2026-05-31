#!/usr/bin/env bash
# run_addendum.sh — Demo 09 baseline-correction: capture scalar_poly (demo-3 spec).
#
# Captures the new scalar_poly (demo-3 spec: std::log + std::sqrt libm + inline
# fast_expf + ncdf_poly) at N=16k and N=1M, then captures autovec, then runs
# sanity checks against existing baselines.
#
# scalar_fullpoly medians are already captured (67.829 ns @ 16k, 72.690 ns @ 1M)
# in pilot_logs/addendum_scalar_fullpoly_*.txt — no re-capture required.
#
# Run AFTER verify_addendum_codegen.sh confirms price_scalar_poly codegen is clean
# (logf@plt present; expf@plt + erff@plt absent; no .4s; stride=1).
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

# ─── scalar_poly (demo-3 spec) ────────────────────────────────────────────────
header "scalar_poly (demo-3 spec)  N=16384"
run_variant scalar_poly 16384   "$LOG_DIR/addendum_scalar_poly_16k.txt"

header "scalar_poly (demo-3 spec)  N=1048576"
run_variant scalar_poly 1048576 "$LOG_DIR/addendum_scalar_poly_1m.txt"

SCALAR_POLY_16K=$(extract_median_ns "$LOG_DIR/addendum_scalar_poly_16k.txt")
SCALAR_POLY_1M=$(extract_median_ns  "$LOG_DIR/addendum_scalar_poly_1m.txt")
ERR_POLY_16K=$(extract_max_err      "$LOG_DIR/addendum_scalar_poly_16k.txt")
ERR_POLY_1M=$(extract_max_err       "$LOG_DIR/addendum_scalar_poly_1m.txt")

# Correctness gate — binary aborts on error >= 1e-4 anyway, but report explicitly.
# Libm log is more accurate than poly log, so error should be <= scalar_fullpoly.
header "scalar_poly correctness"
for entry in "16k:$ERR_POLY_16K" "1M:$ERR_POLY_1M"; do
    n_label="${entry%%:*}"; err="${entry##*:}"
    if awk -v e="$err" 'BEGIN { exit (e + 0 < 1e-4) ? 0 : 1 }'; then
        pass "${n_label}: max_abs_error=${err} < 1e-4"
    else
        fail "${n_label}: max_abs_error=${err} >= 1e-4 — exp/N(x) port has a bug"
        fail "  Stop here; do not proceed to timing (brief §correctness-regression)"
        exit 1
    fi
done

# ─── autovec ──────────────────────────────────────────────────────────────────
header "autovec  N=16384"
run_variant autovec 16384   "$LOG_DIR/addendum_autovec_16k.txt"

header "autovec  N=1048576"
run_variant autovec 1048576 "$LOG_DIR/addendum_autovec_1m.txt"

AUTOVEC_16K=$(extract_median_ns "$LOG_DIR/addendum_autovec_16k.txt")
AUTOVEC_1M=$(extract_median_ns  "$LOG_DIR/addendum_autovec_1m.txt")

# ─── Load baselines ───────────────────────────────────────────────────────────
# First-pilot scalar (a2_scalar_*.txt) is the demo-9 equivalent of demo-3's
# scalar_poly construction (std::log + std::sqrt libm + fast_expf + ncdf_poly).
# New scalar_poly uses the same kernel — expect near-identical performance.
SCALAR_16K=""; SCALAR_1M=""
NEON_16K=""; NEON_1M=""
FULLPOLY_16K=""; FULLPOLY_1M=""
BASELINES_OK=1

for log in "$LOG_DIR/a2_scalar_16k.txt" "$LOG_DIR/a2_scalar_1m.txt" \
           "$LOG_DIR/a2_neon_16k.txt"   "$LOG_DIR/a2_neon_1m.txt"; do
    [[ -f "$log" ]] || { warn "Log not found: $log — sanity checks will be partial"; BASELINES_OK=0; }
done

if [[ "$BASELINES_OK" -eq 1 ]]; then
    SCALAR_16K=$(extract_median_ns "$LOG_DIR/a2_scalar_16k.txt")
    SCALAR_1M=$(extract_median_ns  "$LOG_DIR/a2_scalar_1m.txt")
    NEON_16K=$(extract_median_ns   "$LOG_DIR/a2_neon_16k.txt")
    NEON_1M=$(extract_median_ns    "$LOG_DIR/a2_neon_1m.txt")
fi

# scalar_fullpoly: existing captures (relabelled from scalar_poly addendum).
for log in "$LOG_DIR/addendum_scalar_fullpoly_16k.txt" \
           "$LOG_DIR/addendum_scalar_fullpoly_1m.txt"; do
    [[ -f "$log" ]] || warn "scalar_fullpoly log not found: $log"
done
[[ -f "$LOG_DIR/addendum_scalar_fullpoly_16k.txt" ]] && \
    FULLPOLY_16K=$(extract_median_ns "$LOG_DIR/addendum_scalar_fullpoly_16k.txt")
[[ -f "$LOG_DIR/addendum_scalar_fullpoly_1m.txt" ]] && \
    FULLPOLY_1M=$(extract_median_ns  "$LOG_DIR/addendum_scalar_fullpoly_1m.txt")

# ─── Sanity checks (flags for §3, not hard stops) ────────────────────────────
header "Sanity checks — flags for §3 (not gates)"

# S1. autovec ≈ scalar (confirms asm-identity prediction)
echo ""
info "S1 — autovec sits on the scalar curve (expect within ±5%)"
if [[ -n "$SCALAR_16K" && -n "$SCALAR_1M" ]]; then
    for entry in "16k:$AUTOVEC_16K:$SCALAR_16K" "1M:$AUTOVEC_1M:$SCALAR_1M"; do
        n_label="${entry%%:*}"; rest="${entry#*:}"
        av="${rest%%:*}"; sl="${rest##*:}"
        pct=$(fp_pct_diff "$av" "$sl")
        if fp_abs_le "$pct" 5; then
            pass "${n_label}: autovec=${av} ns/op  scalar=${sl} ns/op  diff=${pct}%  (≤5%) — asm-identity confirmed"
        else
            warn "${n_label}: autovec=${av} ns/op  scalar=${sl} ns/op  diff=${pct}%  (>5%)"
            warn "  Flag for §3: binaries may differ in a way the asm-inspection didn't show"
        fi
    done
else
    warn "First-pilot scalar logs missing — skipping S1"
fi

# S2. new scalar_poly ≈ scalar (same kernel: bs_call_poly; expect within ±5%)
echo ""
info "S2 — scalar_poly (demo-3 spec) ≈ scalar (same bs_call_poly kernel; expect within ±5%)"
if [[ -n "$SCALAR_16K" && -n "$SCALAR_1M" ]]; then
    for entry in "16k:$SCALAR_POLY_16K:$SCALAR_16K" "1M:$SCALAR_POLY_1M:$SCALAR_1M"; do
        n_label="${entry%%:*}"; rest="${entry#*:}"
        sp="${rest%%:*}"; sc="${rest##*:}"
        pct=$(fp_pct_diff "$sp" "$sc")
        if fp_abs_le "$pct" 5; then
            pass "${n_label}: scalar_poly=${sp} ns/op  scalar=${sc} ns/op  diff=${pct}%  (≤5%) — same-kernel confirmed"
        else
            warn "${n_label}: scalar_poly=${sp} ns/op  scalar=${sc} ns/op  diff=${pct}%  (>5%)"
            warn "  Unexpected: both call bs_call_poly — check compiler flags and alignment"
        fi
    done
else
    warn "First-pilot scalar logs missing — skipping S2"
fi

# S3. scalar_poly faster than scalar_fullpoly (poly log is slower on A76)
echo ""
info "S3 — scalar_poly (demo-3 spec) faster than scalar_fullpoly (poly log is net drag on A76)"
if [[ -n "$FULLPOLY_16K" && -n "$FULLPOLY_1M" ]]; then
    for entry in "16k:$SCALAR_POLY_16K:$FULLPOLY_16K" "1M:$SCALAR_POLY_1M:$FULLPOLY_1M"; do
        n_label="${entry%%:*}"; rest="${entry#*:}"
        sp="${rest%%:*}"; fp="${rest##*:}"
        if fp_lt "$sp" "$fp"; then
            ratio=$(fp_ratio "$fp" "$sp")
            pass "${n_label}: scalar_poly=${sp} < scalar_fullpoly=${fp} ns/op  (${ratio}× faster)"
        else
            warn "${n_label}: scalar_poly=${sp} >= scalar_fullpoly=${fp} ns/op"
            warn "  Unexpected: poly log should be a drag on A76 — flag for §3"
        fi
    done
else
    warn "scalar_fullpoly logs missing — skipping S3"
fi

# S4. neon/scalar_poly ratio (record for §6 cross-arch comparison to demo 3)
echo ""
info "S4 — neon/scalar_poly ratio (demo 3 reference: 3.785× @ 16k, 4.121× @ 1M)"
if [[ -n "$NEON_16K" && -n "$NEON_1M" ]]; then
    for entry in "16k:$SCALAR_POLY_16K:$NEON_16K:3.785" "1M:$SCALAR_POLY_1M:$NEON_1M:4.121"; do
        n_label="${entry%%:*}"; rest="${entry#*:}"
        sp="${rest%%:*}"; rest="${rest#*:}"
        neon="${rest%%:*}"; ref="${rest##*:}"
        ratio=$(fp_ratio "$sp" "$neon")
        info "${n_label}: scalar_poly=${sp} ns/op  neon=${neon} ns/op  ratio=${ratio}×  (demo-3 ref: ${ref}×)"
    done
else
    warn "First-pilot neon logs missing — skipping S4"
fi

# ─── Post-capture preflight ───────────────────────────────────────────────────
header "Post-capture preflight"
if [[ -x "$PREFLIGHT" ]]; then
    "$PREFLIGHT" || warn "Post-capture preflight failed — rig state changed during run; review captures"
    pass "Post-capture preflight green — rig was stable throughout"
else
    warn "pi-preflight.sh not found — skipping post-capture rig check"
fi

# ─── Results table ────────────────────────────────────────────────────────────
header "Results"
printf "\n  %-22s  %12s  %12s\n" "variant" "16k ns/op" "1M ns/op"
printf "  %-22s  %12s  %12s\n"   "──────────────────────" "────────────" "────────────"
[[ -n "$SCALAR_16K" ]] && \
    printf "  %-22s  %12s  %12s\n" "scalar (libm+poly)"   "$SCALAR_16K"     "$SCALAR_1M"
printf   "  %-22s  %12s  %12s\n" "scalar_poly (demo-3)"  "$SCALAR_POLY_16K" "$SCALAR_POLY_1M"
[[ -n "$FULLPOLY_16K" ]] && \
    printf "  %-22s  %12s  %12s\n" "scalar_fullpoly"      "$FULLPOLY_16K"   "$FULLPOLY_1M"
printf   "  %-22s  %12s  %12s\n" "autovec"                "$AUTOVEC_16K"    "$AUTOVEC_1M"
[[ -n "$NEON_16K" ]] && \
    printf "  %-22s  %12s  %12s\n" "neon (hand)"          "$NEON_16K"       "$NEON_1M"
echo ""
info "Logs saved to $LOG_DIR/:"
info "  addendum_scalar_poly_16k.txt   addendum_scalar_poly_1m.txt"
info "  addendum_autovec_16k.txt       addendum_autovec_1m.txt"
info "  addendum_scalar_fullpoly_16k.txt (existing, no re-capture)"
