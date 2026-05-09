#!/usr/bin/env python3
"""Folds perf stat JSON + Google Benchmark JSON into false-sharing-pnl.json.

Usage:
    python3 tools/parse_perf.py \\
        --perf   <placement>_<N>t_<padded|unpadded>.perf.json \\
        --bench  <placement>_<N>t_<padded|unpadded>.bench.json \\
        --out    site/src/data/perf/false-sharing-pnl.json

Run once per variant. The script upserts the run entry into the JSON file
(matching on placement + threads + variant), preserving all other runs.
"""

import argparse
import json
import math
import re
import statistics
import sys
from pathlib import Path


# ─── perf stat JSON parsing ──────────────────────────────────────────────────

def parse_perf_json(path: Path) -> dict[str, int]:
    """Extract event counts from perf stat --json output."""
    counts: dict[str, int] = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue
            event = obj.get("event", "").strip()
            raw = obj.get("counter-value", "")
            try:
                val = int(float(str(raw).replace(",", "")))
                counts[event] = val
            except (ValueError, TypeError):
                pass
    return counts


# ─── Google Benchmark JSON parsing ───────────────────────────────────────────

def parse_bench_json(path: Path, filter_name: str) -> dict:
    """Extract timing stats for a specific benchmark from GB JSON output."""
    with open(path) as f:
        data = json.load(f)

    # Collect all individual repetitions (not aggregate rows)
    ns_per_iter_values = []
    items_per_iter = None
    iters_per_rep = None

    for bm in data.get("benchmarks", []):
        name = bm.get("name", "")
        # Skip aggregate rows (mean/median/stddev/cv)
        if any(name.endswith(sfx) for sfx in ("_mean", "_median", "_stddev", "_cv")):
            continue
        if filter_name not in name:
            continue

        ns = bm.get("real_time", None)
        if ns is None:
            continue
        ns_per_iter_values.append(ns)

        if items_per_iter is None:
            items_per_iter = bm.get("items_per_second", None)
            iters_per_rep = bm.get("iterations", None)

    if not ns_per_iter_values:
        raise ValueError(f"No benchmark rows matching '{filter_name}' found in {path}")

    # Extract threads/N_ITERS/N_FILLS from the first entry
    # ns_per_iter = wall_time for one GB outer iteration
    # items_per_outer_iter reported as items_per_second × real_time_ns×1e-9
    # ns_per_op = ns_per_iter / items_per_outer_iter
    # We back-compute items_per_iter from items_per_second × real_time
    ns_vals = sorted(ns_per_iter_values)
    n = len(ns_vals)
    median_ns_iter = statistics.median(ns_vals)
    min_ns_iter = ns_vals[0]
    q1 = ns_vals[n // 4]
    q3 = ns_vals[(3 * n) // 4]
    iqr_ns_iter = q3 - q1

    # items_per_second from GB is total_items / real_time_seconds for one repetition
    # We need items_per_outer_iter = items_per_second × real_time_seconds
    # = items_per_second × ns_per_iter × 1e-9
    if items_per_iter is None:
        raise ValueError("items_per_second not found in benchmark output")

    # compute ns_per_op for the median iteration
    items_per_outer = items_per_iter * (median_ns_iter * 1e-9)
    ns_per_op_median = median_ns_iter / items_per_outer if items_per_outer > 0 else 0.0
    ns_per_op_min    = min_ns_iter / (items_per_iter * (min_ns_iter * 1e-9)) if items_per_iter > 0 else 0.0
    iqr_ns_op        = iqr_ns_iter / items_per_outer if items_per_outer > 0 else 0.0
    ops_per_sec      = int(1e9 / ns_per_op_median) if ns_per_op_median > 0 else 0

    return {
        "ns_per_op": {
            "median": round(ns_per_op_median, 4),
            "min":    round(ns_per_op_min,    4),
            "iqr":    round(iqr_ns_op,        4),
        },
        "ops_per_sec": ops_per_sec,
    }


# ─── Derived counter fields ───────────────────────────────────────────────────

def derive_counters(perf: dict[str, int], ops: int) -> dict:
    cache_misses   = perf.get("cache-misses",     0)
    cache_refs     = perf.get("cache-references", 1)  # avoid /0
    instructions   = perf.get("instructions",     0)
    cycles         = perf.get("cycles",           1)

    return {
        "cache_misses_per_op":     round(cache_misses / ops, 6) if ops > 0 else 0,
        "cache_miss_ratio":        round(cache_misses / cache_refs, 6),
        "instructions_per_cycle":  round(instructions / cycles, 4),
    }


# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--perf",  required=True, type=Path)
    ap.add_argument("--bench", required=True, type=Path)
    ap.add_argument("--out",   required=True, type=Path)
    ap.add_argument("--placement", required=True,
                    choices=["intra-ccx", "cross-ccx"])
    ap.add_argument("--threads",   required=True, type=int)
    ap.add_argument("--padded",    required=True, type=int, choices=[0, 1])
    args = ap.parse_args()

    variant     = "padded" if args.padded else "unpadded"
    placement   = args.placement
    nthreads    = args.threads
    ccx_label   = "IntraCCX" if placement == "intra-ccx" else "CrossCCX"
    filter_name = f"{ccx_label}/{nthreads}t/{variant}"

    print(f"Parsing perf: {args.perf}")
    perf_counts = parse_perf_json(args.perf)

    print(f"Parsing bench: {args.bench} (filter: {filter_name})")
    timing = parse_bench_json(args.bench, filter_name)

    # total ops used to normalise perf counters: use ops_per_sec × ~100ms
    # (approximate; adjust if you have exact iteration counts)
    ops_approx = timing["ops_per_sec"] // 10  # ~100ms worth
    counters = derive_counters(perf_counts, ops_approx)

    # Determine cores_used
    if placement == "intra-ccx":
        cores_map = {1: [4], 2: [4, 5], 4: [4, 5, 6, 7]}
    else:
        cores_map = {2: [0, 4], 4: [0, 1, 4, 5], 8: [0, 1, 2, 3, 4, 5, 6, 7]}
    cores_used = cores_map.get(nthreads, [])

    new_run = {
        "variant":    variant,
        "threads":    nthreads,
        "padded":     bool(args.padded),
        "placement":  placement,
        "cores_used": cores_used,
        "ns_per_op":  timing["ns_per_op"],
        "ops_per_sec": timing["ops_per_sec"],
        "counters":   counters,
        "notes": (
            f"cores: {cores_used}; fill seed: 42; "
            f"AMD PMU generic counters (cache-misses, cache-references, instructions, cycles)"
        ),
    }

    # Load or initialise the output JSON
    if args.out.exists():
        with open(args.out) as f:
            data = json.load(f)
    else:
        data = {
            "demo": "false-sharing-pnl",
            "title": "False sharing: padded vs unpadded P&L accumulators",
            "machine": {},
            "captured_at": "PLACEHOLDER",
            "runs": [],
            "notes": "",
        }

    # Upsert: replace existing run matching placement+threads+variant
    runs = data.get("runs", [])
    key = (placement, nthreads, variant)
    updated = False
    for i, r in enumerate(runs):
        if (r.get("placement"), r.get("threads"), r.get("variant")) == key:
            runs[i] = new_run
            updated = True
            break
    if not updated:
        runs.append(new_run)
    data["runs"] = runs

    with open(args.out, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")

    status = "updated" if updated else "added"
    print(f"{status}: {placement}/{nthreads}t/{variant}")
    print(f"  ns/op median={new_run['ns_per_op']['median']:.4f}")
    print(f"  counters: {counters}")


if __name__ == "__main__":
    main()
