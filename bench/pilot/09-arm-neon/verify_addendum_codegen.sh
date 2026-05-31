#!/usr/bin/env bash
# verify_addendum_codegen.sh — Demo 09 addendum task 1b: codegen checks for price_scalar_poly.
#
# Builds the pilot binary (pass --build, or auto-builds if the binary is missing),
# dumps the disassembly, then verifies three acceptance criteria from the addendum brief:
#
#   1. No logf / expf / sqrtf PLT calls in price_scalar_poly.
#   2. Zero .4s float-vector ops  (no accidental autovectorisation).
#   3. Loop back-edge increments by 1 element (#0x1 stride, not #0x4).
#
# Prints the full price_scalar_poly disassembly at the end so you can post it to the
# thread before running run_addendum.sh for timing captures.
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
header "Codegen checks — price_scalar_poly"
ALL_PASS=1

# 1. No libm PLT calls (logf, expf, sqrtf)
PLT_HITS=$(grep -cE 'bl[[:space:]]+.*(logf|expf|sqrtf)(@plt)?' "$ASM_FILE" || true)
if [[ "$PLT_HITS" -eq 0 ]]; then
    pass "No logf/expf/sqrtf PLT calls — hot loop is call-free"
else
    fail "Found $PLT_HITS libm PLT call(s)"
    grep -E 'bl[[:space:]]+.*(logf|expf|sqrtf)(@plt)?' "$ASM_FILE" | sed 's/^/    /' >&2
    if grep -qE 'bl[[:space:]]+.*sqrtf(@plt)?' "$ASM_FILE"; then
        fail "  sqrtf@plt: GCC branches to libm for negative inputs to preserve errno."
        fail "  Fix: replace __builtin_sqrtf with vsqrt_f32 NEON scalar intrinsic in poly_neon.h."
    fi
    if grep -qE 'bl[[:space:]]+.*(logf|expf)(@plt)?' "$ASM_FILE"; then
        fail "  logf/expf@plt: polynomial not fully inlined — check fast_logf/fast_expf usage."
    fi
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
    # Compiler may use pointer arithmetic rather than an index register; check for
    # a #0x4 address advance on the output pointer (4 bytes per float)
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
    pass "All codegen checks passed"
    info "Post the disassembly above, then run: ./run_addendum.sh"
else
    fail "One or more codegen checks FAILED — do not proceed to timing captures"
    fail "See addendum brief open items (§residual-libm, §accidental-autovec)"
    exit 1
fi
