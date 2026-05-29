"""Parse Google Benchmark JSON for demo 08 (Sorting Shootout) and emit a
schema-conformant site data file.

Benchmark naming scheme (parsed here):
    BM_Sort_u32/<variant>/<distribution>/<n>
    BM_Sort_u64/<variant>/<distribution>/<n>

  parts[0]  key_type embedded: "BM_Sort_u32" -> "u32", "BM_Sort_u64" -> "u64"
  parts[1]  variant:      std_sort | pdqsort | radix_lsd
  parts[2]  distribution: random | sorted | reverse | few_unique | sawtooth
  parts[3]  n:            integer (from ->Range() / ->Arg())

ns_per_op is nanoseconds per element sorted (real_time / n).
This matches the unit consumed by the site's <TimeVsN> component.

Usage (called by run_one.sh):
    python3 bench/scripts/assemble_results_08.py \\
        <bench_json> <captured_at> <machine_json> <out_path>
"""

import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from stats_utils import bench_stats, percentile

VARIANTS      = ["std_sort", "pdqsort", "radix_lsd"]
DISTRIBUTIONS = ["random", "sorted", "reverse", "few_unique", "sawtooth"]
KEY_TYPES     = ["u32", "u64"]

REQUIRED_RUN_FIELDS = [
    "variant", "n", "distribution", "key_type",
    "ns_per_op", "ops_per_sec", "iterations", "compile_flags",
]
REQUIRED_NS_PER_OP = ["median", "min", "p99", "iqr"]


def parse_name(name: str) -> dict | None:
    """Parse a GB benchmark name into (key_type, variant, distribution, n).

    Handles optional trailing repetition suffix '_0', '_1', etc. added by GB
    when ReportAggregatesOnly(false) is set with Repetitions > 1.
    Also skips aggregate entries whose run_type is not 'iteration'.
    """
    # Strip any trailing '_<digits>' repetition suffix before parsing.
    # GB names iteration reps as "<name>_0", "<name>_1", etc.
    import re
    base = re.sub(r"_\d+$", "", name)

    parts = base.split("/")
    if len(parts) < 4:
        return None

    func_part = parts[0]  # e.g. "BM_Sort_u32"
    variant   = parts[1]  # e.g. "std_sort"
    dist      = parts[2]  # e.g. "random"
    try:
        n = int(parts[3])
    except ValueError:
        return None

    if func_part == "BM_Sort_u32":
        key_type = "u32"
    elif func_part == "BM_Sort_u64":
        key_type = "u64"
    else:
        return None

    if variant not in VARIANTS:
        return None
    if dist not in DISTRIBUTIONS:
        return None

    return {"key_type": key_type, "variant": variant, "distribution": dist, "n": n}


def build_groups(benchmarks: list) -> dict:
    """Group iteration records by (key_type, variant, distribution, n)."""
    groups: dict = {}
    for b in benchmarks:
        if b.get("run_type") != "iteration":
            continue
        parsed = parse_name(b["name"])
        if parsed is None:
            continue
        key = (parsed["key_type"], parsed["variant"], parsed["distribution"], parsed["n"])
        groups.setdefault(key, []).append(b)
    return groups


def validate_run(run: dict) -> list[str]:
    tag = (
        f"[{run.get('key_type','?')} {run.get('variant','?')} "
        f"{run.get('distribution','?')} n={run.get('n','?')}]"
    )
    problems = []
    for field in REQUIRED_RUN_FIELDS:
        if field not in run:
            problems.append(f"MISS {tag}: required field '{field}' absent")
    ns = run.get("ns_per_op", {})
    for sub in REQUIRED_NS_PER_OP:
        if sub not in ns:
            problems.append(f"MISS {tag}: ns_per_op.{sub} absent")
    med = ns.get("median", 0)
    if med <= 0:
        problems.append(f"WARN {tag}: ns_per_op.median <= 0")
    # Consistency check: ops_per_sec × ns_per_op.median / 1e9 ≈ 1.0 (per element).
    n = run.get("n", 0)
    ops = run.get("ops_per_sec", 0)
    if med > 0 and ops > 0 and n > 0:
        ratio = ops * med / 1e9
        if not (0.90 < ratio < 1.10):
            problems.append(
                f"WARN {tag}: ops_per_sec × ns_per_op.median / 1e9 = {ratio:.3f} (expected ≈1.0)"
            )
    return problems


def build_notes(runs: list[dict]) -> str:
    n_u32 = sum(1 for r in runs if r.get("key_type") == "u32")
    n_u64 = sum(1 for r in runs if r.get("key_type") == "u64")
    variants_seen = sorted({r.get("variant", "?") for r in runs})
    dists_seen    = sorted({r.get("distribution", "?") for r in runs})
    reps          = runs[0].get("iterations", "?") if runs else "?"
    return (
        f"{len(runs)} cells total: {n_u32} u32 + {n_u64} u64. "
        f"Variants: {', '.join(variants_seen)}. "
        f"Distributions: {', '.join(dists_seen)}. "
        f"Approximately {reps} inner iterations per outer rep (Google Benchmark auto-scaled). "
        "ns_per_op is nanoseconds per element sorted; input restored from a master copy "
        "outside the timed region each iteration (PauseTiming/ResumeTiming). "
        "Fixed seeds: u32 master = 0xC0FFEE42, u64 master = 0xDEADBEEF1234. "
        "pdqsort vendored from github.com/orlp/pdqsort (zlib licence)."
    )


def main() -> None:
    if len(sys.argv) != 5:
        print(__doc__, file=sys.stderr)
        sys.exit(1)

    bench_file   = Path(sys.argv[1])
    captured_at  = sys.argv[2]
    machine_json = sys.argv[3]
    out_path     = Path(sys.argv[4])

    with open(bench_file) as f:
        raw = json.load(f)

    machine = json.loads(machine_json)
    groups  = build_groups(raw.get("benchmarks", []))

    if not groups:
        print("ERROR: no iteration records parsed from benchmark JSON.", file=sys.stderr)
        print("       Check that the benchmark ran with --benchmark_report_aggregates_only=false",
              file=sys.stderr)
        sys.exit(1)

    runs: list[dict] = []
    all_problems: list[str] = []

    for (key_type, variant, distribution, n), reps_list in sorted(
        groups.items(), key=lambda x: (x[0][0], x[0][2], x[0][1], x[0][3])
    ):
        times = [r["real_time"] for r in reps_list]   # ns per benchmark iteration
        ops_s = [r.get("items_per_second", 0.0) for r in reps_list]

        # ns_per_op = ns per element = real_time / n
        ns_vals     = [t / n for t in times] if n > 0 else times
        ns_per_op   = bench_stats(ns_vals)

        med_ops     = sorted(ops_s)[len(ops_s) // 2]
        inner_iters = reps_list[0].get("iterations", 0)

        run = {
            "variant":      variant,
            "n":            n,
            "distribution": distribution,
            "key_type":     key_type,
            "iterations":   inner_iters,
            "ns_per_op":    ns_per_op,
            "ops_per_sec":  round(med_ops),
            "compile_flags": "-O3 -march=native -std=c++20",
            "notes": (
                "ns_per_op is nanoseconds per element sorted; "
                "input restored from a master copy outside the timed region each iteration."
            ),
        }

        problems = validate_run(run)
        all_problems.extend(problems)
        runs.append(run)

    miss_problems = [p for p in all_problems if p.startswith("MISS")]
    for p in all_problems:
        print(p, file=sys.stderr)
    if all_problems:
        print(f"\n{len(all_problems)} validation issue(s) above.", file=sys.stderr)
    if miss_problems:
        print(f"ERROR: {len(miss_problems)} MISS error(s) — refusing to write output.",
              file=sys.stderr)
        sys.exit(1)

    # Coverage summary
    u32_random_ns = sorted({r["n"] for r in runs if r["key_type"] == "u32" and r["distribution"] == "random"})
    u32_dists_at_4m = sorted({r["distribution"] for r in runs if r["key_type"] == "u32" and r["n"] == 4194304})
    u64_at_4m = [r for r in runs if r["key_type"] == "u64" and r["n"] == 4194304]

    print(f"Set A (u32 random N-sweep): {len(u32_random_ns)} N values × 3 variants", file=sys.stderr)
    print(f"Set B (u32 dist sweep N=2^22): {len(u32_dists_at_4m)} distributions × 3 variants", file=sys.stderr)
    print(f"Set C (u64 N=2^22): {len(u64_at_4m)} cells", file=sys.stderr)

    output = {
        "demo":        "08-sorting-shootout",
        "title":       "The sorting shootout: going around the comparison wall",
        "machine":     machine,
        "captured_at": captured_at,
        "runs":        runs,
        "notes":       build_notes(runs),
    }

    os.makedirs(out_path.parent, exist_ok=True)
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2)

    print(
        f"Written: {out_path}  ({len(runs)} cells, "
        f"{len(all_problems)} validation issue(s))",
        file=sys.stderr,
    )


if __name__ == "__main__":
    main()
