#!/usr/bin/env bash
# dump_asm.sh — regenerate asm/*.s from the compiled OBJECT library .o files.
# Called as a CMake POST_BUILD step; can also be run manually.
#
# Usage: ./dump_asm.sh <cmake_binary_dir>
# e.g.:  ./dump_asm.sh /path/to/bench/build

set -euo pipefail

BUILD_DIR="${1:?Usage: dump_asm.sh <cmake_binary_dir>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OBJ_BASE="${BUILD_DIR}/demos/03-simd-blackscholes/CMakeFiles"
ASM_DIR="${SCRIPT_DIR}/asm"

if ! command -v objdump &>/dev/null; then
    echo "WARNING: objdump not found — skipping asm dump" >&2
    exit 0
fi

dump_variant() {
    local target="$1"   # CMake OBJECT library name, e.g. bs_scalar_libm
    local src="$2"      # Source file stem, e.g. scalar_libm
    local out="${ASM_DIR}/${src}.s"
    local obj="${OBJ_BASE}/${target}.dir/${src}.cpp.o"

    if [[ ! -f "${obj}" ]]; then
        echo "  WARNING: ${obj} not found — skipping" >&2
        return
    fi

    # -d:           disassemble text sections
    # -M intel:     Intel syntax (more readable for this audience)
    # --demangle:   unmangle C++ names
    # --no-show-raw-insn: omit hex bytes — focus on mnemonics
    objdump -d -M intel --demangle --no-show-raw-insn "${obj}" > "${out}"
    echo "  wrote ${out}"
}

echo "==> Dumping disassembly to asm/..."
dump_variant bs_scalar_libm    scalar_libm
dump_variant bs_scalar_poly    scalar_poly
dump_variant bs_sse2           sse2_intrinsics
dump_variant bs_avx2_fma       avx2_fma_intrinsics
