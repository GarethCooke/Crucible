#!/usr/bin/env bash
# verify_addendum_codegen.sh — Demo 09 baseline-correction: codegen checks for price_scalar_poly.
#
# Builds the pilot binary (pass --build, or auto-builds if the binary is missing),
# dumps the disassembly, then verifies three acceptance criteria from the
# baseline-correction brief (INVERTED from the prior addendum brief):
#
#   1. logf@plt IS PRESENT — libm log is retained, matching demo-3 spec.
#      expf@plt and erff@plt ABSENT — exp and N(x) are the inline polynomials.
#      (Prior addendum required ALL to be absent; that produced a different
#      denominator that diverges from demo 3.  This brief corrects that.)
#   2. Zero .4s float-vector ops  (no accidental autovectorisation).
#   3. Loop back-edge increments by 1 element (#0x1 stride, not #0x4).
#
# Prints the full price_scalar_poly disassembly at the end so you can post it
# to the thread before running run_addendum.sh for timing captures.
#
# Usage:
#   ./verify_addendum_codegen.sh          # expects pre-built binary in build/
#   ./verify_addendum_codegen.sh --build  # cmake build first

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
BIN="$BUILD_DIR/pilot_blackscholes"
ASM_DIR="$SCRIPT_DIR/asm"
ASM_FILE="$ASM_DIR/price_scalar_poly.s"

# ─── Colour / print helpers ───────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

pass()   { printf "${GREEN}[PASS]${RESET} %s\n"   "$*"; }
fail()   { printf "${RED}[FAIL]${RESET} %s\n"     "$*" >&2; }
info()   { printf "${CYAN}[INFO]${RESET} %s\n"    "$*"; }
warn()   { printf "${YELLOW}[WARN]${RESET} %s\n"  "$*"; }
header() { printf "\n${BOLD}${CYAN}━━━ %s ━━━${RESET}\n" "$*"; }
die()    { printf "${RED}[ABORT]${RESET} %s\n"    "$*" >&2; exit 1; }

# ─── Build ────────────────────────────────────────────────────────────────────
REBUILT=0
header "Build"
if [[ "${1:-}" == "--build" ]] || [[ ! -x "$BIN" ]]; then
    info "Running cmake build..."
    cmake -S "$SCRIPT_DIR" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release
    cmake --build "$BUILD_DIR"
    REBUILT=1
fi
[[ -x "$BIN" ]] || die "Binary not found: $BIN — run with --build or cmake manually"
pass "Binary: $BIN"

# ─── ASM dump ─────────────────────────────────────────────────────────────────
# Always re-dump after a rebuild so stale .s files don't mask a codegen change.
header "ASM dump"
if [[ "$REBUILT" -eq 1 || ! -f "$ASM_FILE" ]]; then
    info "Dumping asm (rebuilt=$REBUILT)..."
    bash "$SCRIPT_DIR/dump_asm.sh" "$BIN" "$ASM_DIR"
fi
[[ -f "$ASM_FILE" ]] || die "price_scalar_poly.s still missing after dump — check dump_asm.sh"
pass "ASM file: $ASM_FILE"

# ─── Codegen checks ───────────────────────────────────────────────────────────
header "Codegen checks — price_scalar_poly (demo-3 spec)"
info "Criteria: logf@plt PRESENT; expf@plt + erff@plt ABSENT; no .4s; stride=1"
ALL_PASS=1

# 1a. logf@plt MUST be present — libm log is retained (demo-3 spec)
LOGF_PLT=$(grep -cE 'bl[[:space:]]+.*(logf)(@plt)?' "$ASM_FILE" || true)
if [[ "$LOGF_PLT" -gt 0 ]]; then
    pass "logf@plt present ($LOGF_PLT call(s)) — libm log retained, matches demo-3 spec"
else
    fail "logf@plt ABSENT — price_scalar_poly must call libm log"
    fail "  Check: bs_call_poly uses std::log, not fast_logf."
    fail "  If the full-poly variant (scalar_fullpoly) is being checked instead, rebuild."
    ALL_PASS=0
fi

# 1b. sqrtf@plt — note presence (std::sqrt; acceptable per spec)
SQRTF_PLT=$(grep -cE 'bl[[:space:]]+.*sqrtf(@plt)?' "$ASM_FILE" || true)
if [[ "$SQRTF_PLT" -gt 0 ]]; then
    info "sqrtf@plt present ($SQRTF_PLT call(s)) — std::sqrt backed by libm (expected)"
else
    info "sqrtf@plt absent — std::sqrt inlined to fsqrt by this toolchain (acceptable)"
fi

# 1c. expf@plt MUST be absent — exp is inline fast_expf polynomial
if ! grep -qE 'bl[[:space:]]+.*expf(@plt)?' "$ASM_FILE"; then
    pass "expf@plt absent — exp is the inline fast_expf polynomial"
else
    fail "expf@plt PRESENT — exp must be inline fast_expf, not libm"
    grep -E 'bl[[:space:]]+.*expf(@plt)?' "$ASM_FILE" | sed 's/^/    /' >&2
    ALL_PASS=0
fi

# 1d. erff@plt MUST be absent — N(x) is inline ncdf_poly polynomial
if ! grep -qE 'bl[[:space:]]+.*erff?(@plt)?' "$ASM_FILE"; then
    pass "erff@plt absent — N(x) is the inline ncdf_poly polynomial"
else
    fail "erff@plt PRESENT — N(x) must be inline ncdf_poly, not libm erfc"
    grep -E 'bl[[:space:]]+.*erff?(@plt)?' "$ASM_FILE" | sed 's/^/    /' >&2
    ALL_PASS=0
fi

# 2. No .4s float-vector ops (would mean GCC widened the loop despite no-tree-vectorize)
VEC4S_HITS=$(grep -cE '\.4s' "$ASM_FILE" || true)
if [[ "$VEC4S_HITS" -eq 0 ]]; then
    pass "No .4s ops — loop is scalar, no-tree-vectorize guard effective"
else
    fail "Found $VEC4S_HITS .4s vector op(s) — loop was accidentally widened"
    grep -E '\.4s' "$ASM_FILE" | head -10 | sed 's/^/    /' >&2
    ALL_PASS=0
fi

# 3. Loop stride check: back-edge must increment by 1 element (#0x1), not 4 (#0x4)
STRIDE1_HITS=$(grep -cE 'add[[:space:]]+x[0-9]+,[[:space:]]*x[0-9]+,[[:space:]]*#0x1' "$ASM_FILE" || true)
STRIDE4_HITS=$(grep -cE 'add[[:space:]]+x[0-9]+,[[:space:]]*x[0-9]+,[[:space:]]*#0x4' "$ASM_FILE" || true)
if [[ "$STRIDE4_HITS" -gt 0 ]]; then
    fail "Loop has #0x4 stride increment — 4-wide vectorised loop may have leaked in"
    grep -E 'add[[:space:]]+x[0-9]+,[[:space:]]*x[0-9]+,[[:space:]]*#0x4' "$ASM_FILE" | sed 's/^/    /' >&2
    ALL_PASS=0
elif [[ "$STRIDE1_HITS" -gt 0 ]]; then
    pass "Loop back-edge increments by #0x1 — stride is one element"
else
    warn "No explicit #0x1 index increment found — compiler may use pointer arithmetic"
    warn "  Verify loop structure manually in the disassembly below"
    warn "  Expected: ldr / str at successive addresses, no v*.4s loads"
fi

# ─── Print disassembly for thread post ────────────────────────────────────────
header "price_scalar_poly disassembly — post this to the thread before running captures"
echo ""
cat "$ASM_FILE"

# ─── Summary ──────────────────────────────────────────────────────────────────
header "Summary"
if [[ $ALL_PASS -eq 1 ]]; then
    pass "All codegen checks passed — price_scalar_poly matches demo-3 spec"
    info "Post the disassembly above, then run: ./run_addendum.sh"
else
    fail "One or more codegen checks FAILED — do not proceed to timing captures"
    exit 1
fi
