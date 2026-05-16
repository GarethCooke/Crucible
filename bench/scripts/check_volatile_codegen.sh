#!/usr/bin/env bash
# CI: assert >=2 movsd instructions appear in the worker_fn inner block.
# Fails the build if the volatile double store was elided by the compiler.
# Called as a CMake POST_BUILD step for bench_02_false_sharing_pnl.
#
# Usage: check_volatile_codegen.sh <binary>
set -euo pipefail

BINARY="${1:?Usage: $0 <binary>}"

COUNT=$(objdump -d "$BINARY" \
    | grep -A 40 '<_ZL9worker_fn' \
    | grep -c 'movsd' || true)

if [[ -z "$COUNT" || "$COUNT" -lt 2 ]]; then
    echo "CODEGEN FAIL: found ${COUNT:-0} movsd in worker_fn (expected >=2)." >&2
    echo "  The volatile double pnl store may have been elided." >&2
    echo "  Without it, the false-sharing effect does not manifest cleanly." >&2
    echo "  See the comment at the top of false_sharing_pnl.cpp for debug guidance." >&2
    exit 1
fi

echo "CODEGEN OK: ${COUNT} movsd found in worker_fn (volatile load+store confirmed)"
