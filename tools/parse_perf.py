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
import sys
import os
from pathlib import Path

# Shared statistics module (bench/scripts/stats_utils.py)
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', 'bench', 'scripts'))
from stats_utils import percentile


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
    items_per_sec = None

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

        if items_per_sec is None:
            items_per_sec = bm.get("items_per_second", None)

    if not ns_per_iter_values:
        raise ValueError(f"No benchmark rows matching '{filter_name}' found in {path}")

    # ns_per_iter = wall_time for one GB outer iteration.
    # Since SetItemsProcessed is constant across reps,
    # items_per_sec × real_time_s = total_items is invariant —
    # so using items_per_sec from any rep is correct.
    if items_per_sec is None:
        raise ValueError("items_per_second not found in benchmark output")

    ns_vals = sorted(ns_per_iter_values)
    median_ns_iter = percentile(ns_vals, 50)
    min_ns_iter    = ns_vals[0]
    iqr_ns_iter    = percentile(ns_vals, 75) - percentile(ns_vals, 25)

    items_per_outer  = items_per_sec * (median_ns_iter * 1e-9)
    ns_per_op_median = median_ns_iter / items_per_outer if items_per_outer > 0 else 0.0
    ns_per_op_min    = min_ns_iter    / (items_per_sec * (min_ns_iter * 1e-9)) if items_per_sec > 0 else 0.0
    iqr_ns_op        = iqr_ns_iter    / items_per_outer if items_per_outer > 0 else 0.0
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

    # L1D replacement event — AMD Zen 2 name confirmed by:
    #   perf list | grep -i l1d   (look for l1d.replacement or l1-dcache-load-misses)
    l1d_raw = perf.get("l1d.replacement", perf.get("L1-dcache-load-misses", None))
    l1d_misses_per_op = (
        round(l1d_raw / ops, 6) if (l1d_raw is not None and ops > 0) else None
    )

    return {
        "cache_misses_per_op":     round(cache_misses / ops, 6) if ops > 0 else 0,
        "cache_miss_ratio":        round(cache_misses / cache_refs, 6),
        "instructions_per_cycle":  round(instructions / cycles, 4),
        "l1d_misses_per_op":       l1d_misses_per_op,
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

    # Approximate total ops for one GB outer iteration (≈ N_ITERS × N_FILLS × nthreads).
    # Using ops_per_sec / 10 gives roughly one iteration's worth at current N_ITERS=1000.
    ops_approx = timing["ops_per_sec"] // 10
    counters = derive_counters(perf_counts, ops_approx)

    # Core assignments — SYNC: must match intra_ccx_cores/cross_ccx_cores in
    # bench/demos/02-false-sharing/false_sharing_pnl.cpp
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
            f"AMD PMU generic counters (cache-misses, cache-references, instructions, cycles); "
            f"l1d event: l1d.replacement (verify with perf list | grep -i l1d on reference machine)"
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
