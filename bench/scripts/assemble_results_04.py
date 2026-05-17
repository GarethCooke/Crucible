"""Assemble per-variant JSON files from the SPSC queue benchmark into site data.

Usage (called by run_one.sh):
    python3 bench/scripts/assemble_results_04.py \\
        <variant_dir> <captured_at> <machine_json> <out_path>

<variant_dir> must contain files named:
    lockfree-handrolled-paced.json
    lockfree-handrolled-saturated.json
    lockfree-handrolled-sweep.json
    lockfree-boost-paced.json
    ... (same for each variant)

Each file is the stdout of 'bench_04_spsc_queue <variant> --mode <mode>',
which emits a JSON array of run objects.
"""

import json
import os
import sys
from pathlib import Path


VARIANTS = ["lockfree-handrolled", "lockfree-boost", "mutex-condvar"]
MODES    = ["paced", "saturated", "sweep"]


def load_runs(vpath: Path, tag: str) -> list:
    """Load a JSON array from a file, emitting warnings on sanity failures."""
    if not vpath.exists():
        print(f"WARN: missing file: {vpath} (skipping)", file=sys.stderr)
        return []

    with open(vpath) as f:
        data = json.load(f)

    # Normalise: binary now always emits an array; guard against old single-object format
    if isinstance(data, dict):
        data = [data]

    for run in data:
        variant = run.get("variant", "?")
        mode    = run.get("mode", "?")

        # top-bucket contamination
        if run.get("top_bucket_count", 0) > 0:
            print(
                f"FLAG [{variant}/{mode}]: {run['top_bucket_count']} top-bucket sample(s) "
                "— likely kernel preemption or page fault contamination.",
                file=sys.stderr,
            )

        # TSC drift
        drift = run.get("calibration_drift_pct", 0.0)
        if drift > 0.1:
            print(
                f"FLAG [{variant}/{mode}]: TSC calibration drift {drift:.4f}% "
                "exceeds 0.1% threshold.",
                file=sys.stderr,
            )

        # max >= p99_9 guarantee
        stats = run.get("latency_ns", {}).get("stats", {})
        if stats:
            mx    = stats.get("max", 0)
            p99_9 = stats.get("p99_9", 0)
            if mx < p99_9:
                print(
                    f"FLAG [{variant}/{mode}]: max ({mx}) < p99_9 ({p99_9}) in stats — "
                    "histogram percentile convention bug?",
                    file=sys.stderr,
                )

    return data


def main() -> None:
    if len(sys.argv) != 5:
        print(__doc__, file=sys.stderr)
        sys.exit(1)

    variant_dir  = Path(sys.argv[1])
    captured_at  = sys.argv[2]
    machine_json = sys.argv[3]
    out_path     = Path(sys.argv[4])

    machine = json.loads(machine_json)

    runs = []
    for variant in VARIANTS:
        for mode in MODES:
            vpath = variant_dir / f"{variant}-{mode}.json"
            runs.extend(load_runs(vpath, f"{variant}/{mode}"))

    if not runs:
        print("ERROR: no run data found in variant_dir", file=sys.stderr)
        sys.exit(1)

    output = {
        "demo":        "04-spsc-queue",
        "title":       "Lock-free SPSC vs mutex queue: end-to-end tail latency",
        "machine":     machine,
        "captured_at": captured_at,
        "runs":        runs,
        "notes":       (
            "Producer pinned to core 4, consumer to core 5 (both CCX1 on Zen 2 3800X). "
            "Same-CCX only — cross-CCX deferred. "
            "Latency definition: rdtscp immediately before push → rdtscp immediately "
            "after pop returns true, both outside synchronisation primitive. "
            "5 × 1M items per run; histograms merged. "
            "Paced mode: 1 MHz offered load. Sweep: 8 log-spaced steps 100 kHz→25 MHz."
        ),
    }

    os.makedirs(out_path.parent, exist_ok=True)
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2)

    paced_count  = sum(1 for r in runs if r.get("mode") == "paced")
    sat_count    = sum(1 for r in runs if r.get("mode") == "saturated")
    sweep_count  = sum(1 for r in runs if r.get("mode") == "sweep")
    print(f"Written: {out_path} ({paced_count} paced, {sat_count} saturated, {sweep_count} sweep runs)")


if __name__ == "__main__":
    main()
