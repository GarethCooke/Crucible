"""Parse Google Benchmark JSON for demo 03 (SIMD Black-Scholes) and emit an
extended schema-conformant site data file.

Extra fields vs v1 schema (additive — won't break demo 01 JSON reader):
  run.variant_isa         e.g. "sse4.2", "avx2+fma"
  run.compile_flags       per-variant ISA flags string
  run.max_abs_error_vs_scalar_libm   from benchmark counter
  run.gflops              derived: ops_per_sec × FLOPS_PER_OPTION / 1e9
  run.instructions_per_cycle  (already ipc in v1, kept for back-compat)

Usage (called by run_one.sh):
    python3 bench/scripts/assemble_results_03.py \\
        <bench_file> <slug> <captured_at> <machine_json> <out_path>
"""

import argparse
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from stats_utils import bench_stats, build_groups
from bs_utils import FLOPS_SCALAR, FLOPS_SIMD, normalise_variant

VARIANT_META = {
    "scalarlibm": {
        "variant_isa":   "sse4.2",
        "compile_flags": "-O3 -fno-tree-vectorize -mno-avx -mno-avx2 -mno-fma -msse4.2",
        "flops":         FLOPS_SCALAR,
    },
    "scalarpoly": {
        "variant_isa":   "sse4.2",
        "compile_flags": "-O3 -fno-tree-vectorize -mno-avx -mno-avx2 -mno-fma -msse4.2",
        "flops":         FLOPS_SCALAR,
    },
    "sse2": {
        "variant_isa":   "sse4.2",
        "compile_flags": "-O3 -msse4.2 -mno-avx -mno-avx2 -mno-fma",
        "flops":         FLOPS_SIMD,
    },
    "avx2fma": {
        "variant_isa":   "avx2+fma",
        "compile_flags": "-O3 -mavx -mavx2 -mfma",
        "flops":         FLOPS_SIMD,
    },
}

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
        times    = [r["real_time"] for r in reps]
        ops_s    = [r.get("items_per_second", 0) for r in reps]
        ipc      = [r.get("ipc", 0) for r in reps]
        max_err  = [r.get("max_abs_error", 0) for r in reps]

        med_ops = sorted(ops_s)[len(ops_s) // 2]
        meta    = VARIANT_META.get(variant, {"variant_isa": "unknown", "compile_flags": "", "flops": FLOPS_SCALAR})
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
        "title":       "Black-Scholes: scalar libm vs polynomial vs SSE vs AVX2+FMA",
        "machine":     machine,
        "captured_at": args.captured_at,
        "runs":        runs,
        "notes":       (
            "Four variants of European call option pricing under Black-Scholes. "
            "Speedup decomposed into algorithm win (poly vs libm) and SIMD width win "
            "(SSE 4-wide → AVX2+FMA 8-wide). Zen 2 executes 256-bit AVX2 as single μops (verified ex_ret_cops ≈1.0/instr); AVX2/SSE ≈2× = lane-width ratio."
        ),
    }

    os.makedirs(os.path.dirname(args.out_path), exist_ok=True)
    with open(args.out_path, "w") as f:
        json.dump(output, f, indent=2)

    print(f"Written: {args.out_path}")


if __name__ == "__main__":
    main()
