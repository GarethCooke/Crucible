"""Assemble per-variant JSON files from the SPSC queue benchmark into site data.

Usage (called by run_one.sh):
    python3 bench/scripts/assemble_results_04.py \\
        <variant_dir> <captured_at> <machine_json> <out_path>

<variant_dir> must contain:
    lockfree-handrolled.json
    lockfree-boost.json
    mutex-condvar.json
Each file is the stdout of '04-spsc-queue <variant>'.
"""

import json
import os
import sys
from pathlib import Path


VARIANTS = ["lockfree-handrolled", "lockfree-boost", "mutex-condvar"]


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
        vpath = variant_dir / f"{variant}.json"
        if not vpath.exists():
            print(f"ERROR: missing variant file: {vpath}", file=sys.stderr)
            sys.exit(1)
        with open(vpath) as f:
            run = json.load(f)
        # Sanity: top-bucket flag
        if run.get("top_bucket_count", 0) > 0:
            print(
                f"FLAG [{variant}]: {run['top_bucket_count']} top-bucket sample(s) "
                "— likely kernel preemption or page fault contamination.",
                file=sys.stderr,
            )
        # Sanity: drift flag
        drift = run.get("calibration_drift_pct", 0.0)
        if drift > 0.1:
            print(
                f"FLAG [{variant}]: TSC calibration drift {drift:.4f}% exceeds 0.1% threshold.",
                file=sys.stderr,
            )
        runs.append(run)

    output = {
        "demo":        "04-spsc-queue",
        "title":       "Lock-free SPSC vs mutex queue: end-to-end tail latency",
        "machine":     machine,
        "captured_at": captured_at,
        "runs":        runs,
        "notes":       (
            "Producer pinned to core 4, consumer to core 5 (both CCX1 on Zen 2 3800X). "
            "Same-CCX only — cross-CCX deferred. "
            "Latency definition: rdtscp immediately before try_push → rdtscp immediately "
            "after try_pop returns true. 5 × 1M items per variant; histograms merged."
        ),
    }

    os.makedirs(out_path.parent, exist_ok=True)
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2)

    print(f"Written: {out_path}")


if __name__ == "__main__":
    main()
