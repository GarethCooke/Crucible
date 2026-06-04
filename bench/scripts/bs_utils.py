"""Shared constants and utilities for Black-Scholes benchmark assemblers (demos 03 and 09)."""

# Flops per option — documented in poly.h.
FLOPS_SCALAR = 98   # scalar variants: treating libm log/sqrt as 1 flop each
FLOPS_SIMD   = 125  # SIMD variants: fast_logf replaces libm log, adding ~27 constituent ops


def normalise_variant(raw: str) -> str:
    """BM_ScalarLibm → scalarlibm, BM_SSE2 → sse2, BM_Neon → neon, etc."""
    return raw.lower().replace("_", "")
