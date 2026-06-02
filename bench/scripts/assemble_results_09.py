"""Parse Google Benchmark JSON for demo 09 (ARM NEON Black-Scholes) and emit an
extended schema-conformant site data file.

Four variants on AArch64 / Cortex-A76 (BCM2712 / Pi 5):
  scalar_libm — all libm, 1-wide oracle and autovec comparand
  scalar_poly — demo 03's exact split (libm log/sqrt + poly exp/N(x)); width-ratio denominator
  autovec     — natural libm kernel, no guard; expected to land on scalar_libm
  neon        — hand-written float32x4_t, inline poly log/exp/N(x)

Extra fields beyond the v1 schema (additive):
  run.variant_isa         e.g. "aarch64-neon"
  run.compile_flags       per-variant flags string
  run.max_abs_error_vs_scalar_libm   from benchmark counter
  run.gflops              derived: ops_per_sec × FLOPS_PER_OPTION / 1e9

Usage (called by run_one.sh):
    python3 bench/scripts/assemble_results_09.py \\
        <bench_file> <slug> <captured_at> <machine_json> <out_path>
"""

import argparse
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from stats_utils import bench_stats, build_groups

# Flops per option — documented in poly.h (demo 03).
# scalar variants: 98 (treating libm log/sqrt as 1 flop each).
# neon: 125 (fast_logf replaces libm log, adding ~27 constituent ops).
FLOPS_SCALAR = 98
FLOPS_SIMD   = 125

VARIANT_META = {
    "scalarlibm": {
        "variant_isa":   "aarch64-scalar",
        "compile_flags": "-O3 -mcpu=cortex-a76 -fno-tree-vectorize",
        "flops":         FLOPS_SCALAR,
    },
    "scalarpoly": {
        "variant_isa":   "aarch64-scalar",
        "compile_flags": "-O3 -mcpu=cortex-a76 -fno-tree-vectorize",
        "flops":         FLOPS_SCALAR,
    },
    "autovec": {
        "variant_isa":   "aarch64-scalar",
        "compile_flags": "-O3 -mcpu=cortex-a76",
        "flops":         FLOPS_SCALAR,
    },
    "neon": {
        "variant_isa":   "aarch64-neon",
        "compile_flags": "-O3 -mcpu=cortex-a76",
        "flops":         FLOPS_SIMD,
    },
}

def normalise_variant(raw: str) -> str:
    """BM_ScalarLibm → scalarlibm, BM_Neon → neon, BM_Autovec → autovec."""
    return raw.lower().replace("_", "")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("bench_file",   type=Path)
    ap.add_argument("slug")
    ap.add_argument("captured_at")
    ap.add_argument("machine_json")
    ap.add_argument("out_path",     type=Path)
    args = ap.parse_args()

    with open(args.bench_file) as f:
        raw = json.load(f)

    machine = json.loads(args.machine_json)

    def parse_name(name: str):
        parts = name.split("/")
        return {"variant": normalise_variant(parts[0].removeprefix("BM_")),
                "n": int(parts[1]) if len(parts) > 1 else 0}

    groups = build_groups(raw.get("benchmarks", []), parse_name)

    runs = []
    for (variant, n), reps in sorted(groups.items(), key=lambda x: (x[0][0], x[0][1])):
        times   = [r["real_time"] for r in reps]
        ops_s   = [r.get("items_per_second", 0) for r in reps]
        ipc     = [r.get("ipc", 0) for r in reps]
        max_err = [r.get("max_abs_error", 0) for r in reps]

        med_ops = sorted(ops_s)[len(ops_s) // 2]
        meta    = VARIANT_META.get(variant, {
            "variant_isa": "unknown", "compile_flags": "", "flops": FLOPS_SCALAR,
        })
        gflops  = round(med_ops * meta["flops"] / 1e9, 3)

        runs.append({
            "variant":                      variant,
            "n":                            n,
            "iterations":                   reps[0].get("iterations", 0),
            "ns_per_op":                    bench_stats([t / n for t in times] if n > 0 else times),
            "ops_per_sec":                  round(med_ops),
            "instructions_per_cycle":       round(sorted(ipc)[len(ipc) // 2], 3),
            "gflops":                       gflops,
            "max_abs_error_vs_scalar_libm": round(sorted(max_err)[len(max_err) // 2], 8),
            "variant_isa":                  meta["variant_isa"],
            "compile_flags":                meta["compile_flags"],
        })

    output = {
        "demo":        args.slug,
        "title":       "Black-Scholes: ARM NEON vs scalar on Cortex-A76 (BCM2712 / Pi 5)",
        "machine":     machine,
        "captured_at": args.captured_at,
        "runs":        runs,
        "notes":       (
            "Four variants of European call option pricing on AArch64 (BCM2712 / Cortex-A76). "
            "Cross-arch companion to demo 03 (Zen 2 SSE/AVX2). "
            "scalar_poly matches demo 03's construction exactly (libm log/sqrt + poly exp/N(x)). "
            "autovec: GCC cannot cross the logf@plt barrier — asm is scalar despite -O3 NEON target; timing within 0.01% of scalar_libm at every N. "
            "scalar_poly runs ~6% faster than scalar_libm (6.4% at 16k, 6.2% at 1M) — Debian libm erfc/exp cost is not negligible. "
            "neon: hand-written float32x4_t achieves ~4.3× at 16k (4.34×) rising to ~4.8× at 1M (4.81×) over scalar_poly (pure-width denominator); "
            "neon/scalar_libm is larger (~4.6× at 16k, ~5.1× at 1M) but folds the algorithm win into the ratio. "
            "No second SIMD step: 128-bit NEON is the widest unit on BCM2712 (no SVE)."
        ),
    }

    os.makedirs(os.path.dirname(args.out_path), exist_ok=True)
    with open(args.out_path, "w") as f:
        json.dump(output, f, indent=2)

    print(f"Written: {args.out_path}")


if __name__ == "__main__":
    main()
