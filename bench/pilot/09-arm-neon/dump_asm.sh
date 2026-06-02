#!/usr/bin/env bash
# dump_asm.sh — extract price_scalar and price_neon disassembly from binary.
# Called as a CMake POST_BUILD step; can also be run manually.
# Usage: dump_asm.sh <binary_path> <asm_dir>

set -euo pipefail

BINARY="${1:?Usage: dump_asm.sh <binary> <asm_dir>}"
ASM_DIR="${2:?}"

if ! command -v objdump &>/dev/null; then
    echo "WARNING: objdump not found — skipping asm dump" >&2
    exit 0
fi

mkdir -p "${ASM_DIR}"

FULL="${ASM_DIR}/pilot_full.s"
objdump -d --demangle --no-show-raw-insn "${BINARY}" > "${FULL}"
echo "  wrote ${FULL}"

# extract_fn: pull one function out of the full dump.
# Starts at the function-header line whose demangled name contains PATTERN.
# Ends at the blank line that follows the last instruction (objdump convention).
# A new function-header line also resets the state, so back-to-back functions
# without an intervening blank line are handled correctly.
extract_fn() {
    local pattern="$1" out="$2"
    awk -v pat="${pattern}" '
        /^[0-9a-f]+ <.*>:/ {
            in_fn = index($0, pat) ? 1 : 0
        }
        /^[[:space:]]*$/ {
            if (in_fn) { in_fn = 0 }
        }
        in_fn { print }
    ' "${FULL}" > "${out}"
    echo "  wrote ${out}"
}

echo "==> Extracting asm sections..."
extract_fn "price_neon"             "${ASM_DIR}/price_neon.s"
extract_fn "price_scalar_poly("     "${ASM_DIR}/price_scalar_poly.s"      # "(" avoids price_scalar_fullpoly
extract_fn "price_scalar_fullpoly"  "${ASM_DIR}/price_scalar_fullpoly.s"
extract_fn "price_scalar("          "${ASM_DIR}/price_scalar.s"           # "(" avoids poly variants
extract_fn "price_autovec"          "${ASM_DIR}/price_autovec.s"
echo "==> Done.  Acceptance checks:"
echo "    grep -cE 'fmla|v[0-9]+\\.4s' ${ASM_DIR}/price_neon.s                  (expect > 0)"
echo "    grep -cE 'fmla|v[0-9]+\\.4s' ${ASM_DIR}/price_scalar.s                (expect = 0)"
echo "    grep -cE 'fmla|v[0-9]+\\.4s' ${ASM_DIR}/price_autovec.s               (expect > 0 — GCC autovec)"
echo "    grep -cE 'bl.*(logf|sqrtf)' ${ASM_DIR}/price_scalar_poly.s            (expect > 0 — libm log retained)"
echo "    grep -cE 'bl.*(expf|erff)' ${ASM_DIR}/price_scalar_poly.s             (expect = 0 — poly exp/N(x))"
echo "    grep -cE '\\.4s' ${ASM_DIR}/price_scalar_poly.s                        (expect = 0)"
echo "    grep -cE 'bl.*(logf|expf|sqrtf)' ${ASM_DIR}/price_scalar_fullpoly.s   (expect = 0 — all poly)"
