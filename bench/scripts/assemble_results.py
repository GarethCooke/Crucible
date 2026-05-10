"""Parse Google Benchmark JSON and emit a schema-conformant site data file.

Usage (called by run_one.sh):
    python3 bench/scripts/assemble_results.py \\
        <bench_file> <slug> <captured_at> <machine_json> <out_path>
"""

import argparse
import json
import os
import sys
from pathlib import Path

from stats_utils import bench_stats


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("bench_file",   type=Path, help="Google Benchmark JSON output")
    ap.add_argument("slug",                    help="Demo slug, e.g. 01-branch-prediction")
    ap.add_argument("captured_at",             help="ISO-8601 capture timestamp")
    ap.add_argument("machine_json",            help="JSON string from --machine-info")
    ap.add_argument("out_path",     type=Path, help="Destination site data JSON file")
    args = ap.parse_args()

    with open(args.bench_file) as f:
        raw = json.load(f)

    machine = json.loads(args.machine_json)

    groups: dict = {}
    for b in raw.get("benchmarks", []):
        if b.get("run_type") != "iteration":
            continue
        name = b["name"]
        parts = name.split("/")
        variant_raw = parts[0].removeprefix("BM_").lower()
        n = int(parts[1]) if len(parts) > 1 else 0
        key = (variant_raw, n)
        groups.setdefault(key, []).append(b)

    runs = []
    for (variant, n), reps in sorted(groups.items(), key=lambda x: (x[0][0], x[0][1])):
        times = [r["real_time"] for r in reps]
        ops_s = [r.get("items_per_second", 0) for r in reps]
        bm    = [r.get("branch_misses_per_op", 0) for r in reps]
        ipc   = [r.get("ipc", 0) for r in reps]

        runs.append({
            "variant":                variant,
            "n":                      n,
            "iterations":             reps[0].get("iterations", 0),
            "ns_per_op":              bench_stats(times),
            "ops_per_sec":            round(sorted(ops_s)[len(ops_s) // 2]),
            "branch_misses_per_op":   round(sorted(bm)[len(bm) // 2], 4),
            "instructions_per_cycle": round(sorted(ipc)[len(ipc) // 2], 3),
        })

    output = {
        "demo":        args.slug,
        "title":       "Sorted vs unsorted branch prediction",
        "machine":     machine,
        "captured_at": args.captured_at,
        "runs":        runs,
        "notes":       "Branch predictor learns sorted patterns; unsorted forces ~50% mispredicts.",
    }

    os.makedirs(os.path.dirname(args.out_path), exist_ok=True)
    with open(args.out_path, "w") as f:
        json.dump(output, f, indent=2)

    print(f"Written: {args.out_path}")


if __name__ == "__main__":
    main()
