#!/usr/bin/env bash
# dump_asm.sh — regenerate asm/*.s from compiled OBJECT library .o files.
# Called as a CMake POST_BUILD step; can also be run manually.
#
# Usage: ./dump_asm.sh <cmake_binary_dir>
# e.g.:  ./dump_asm.sh /path/to/bench/build
#
# Acceptance grep targets (run manually after build):
#   scalar_libm:  grep 'bl.*logf'      asm/scalar_libm.s   → present
#                 grep '\.4s'           asm/scalar_libm.s   → absent
#   scalar_poly:  grep 'bl.*logf'      asm/scalar_poly.s   → present
#                 grep 'bl.*expf\|erff' asm/scalar_poly.s   → absent
#                 grep '\.4s'           asm/scalar_poly.s   → absent
#   autovec:      grep 'bl.*logf'      asm/autovec.s       → present
#                 grep '\.4s'           asm/autovec.s       → absent (GCC cannot cross logf)
#   neon:         grep '\.4s'           asm/neon_intrinsics.s → present
#                 grep 'bl.*@plt'      asm/neon_intrinsics.s → absent in main loop

set -euo pipefail

BUILD_DIR="${1:?Usage: dump_asm.sh <cmake_binary_dir>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OBJ_BASE="${BUILD_DIR}/demos/09-arm-neon/CMakeFiles"
ASM_DIR="${SCRIPT_DIR}/asm"

if ! command -v objdump &>/dev/null; then
    echo "WARNING: objdump not found — skipping asm dump" >&2
    exit 0
fi

dump_variant() {
    local target="$1"   # CMake OBJECT library name, e.g. bs09_scalar_libm
    local src="$2"      # Source file stem, e.g. scalar_libm
    local out="${ASM_DIR}/${src}.s"
    local obj="${OBJ_BASE}/${target}.dir/${src}.cpp.o"

    if [[ ! -f "${obj}" ]]; then
        echo "  WARNING: ${obj} not found — skipping" >&2
        return
    fi

    objdump -d --demangle --no-show-raw-insn "${obj}" > "${out}"
    echo "  wrote ${out}"
}

echo "==> Dumping disassembly to asm/..."
dump_variant bs09_scalar_libm    scalar_libm
dump_variant bs09_scalar_poly    scalar_poly
dump_variant bs09_autovec        autovec
dump_variant bs09_neon           neon_intrinsics
