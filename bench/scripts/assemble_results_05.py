"""Assemble per-variant JSON files from the allocators benchmark into site data.

Usage (called by run_one.sh):
    python3 bench/scripts/assemble_results_05.py \\
        <variant_dir> <captured_at> <machine_json> <out_path> [--cross-ccx]

<variant_dir> must contain files named:
    cross-thread-malloc-paced.json
    cross-thread-malloc-pressure_sweep.json
    freelist-return-queue-paced.json
    freelist-return-queue-pressure_sweep.json
    arena-batch-handoff-paced.json
    arena-batch-handoff-pressure_sweep.json

With --cross-ccx, the expected files are:
    cross-thread-malloc-cross-ccx.json
    freelist-return-queue-cross-ccx.json
    arena-batch-handoff-cross-ccx.json

Each file is the stdout of 'bench_05_allocators <variant> --mode <mode>',
which emits a JSON array of run objects.
"""

import json
import os
import sys
from pathlib import Path


VARIANTS = ["cross-thread-malloc", "freelist-return-queue", "arena-batch-handoff"]


def load_runs(vpath: Path) -> list:
    """Load a JSON array from a file, emitting warnings on sanity failures."""
    if not vpath.exists():
        print(f"WARN: missing file: {vpath} (skipping)", file=sys.stderr)
        return []

    with open(vpath) as f:
        data = json.load(f)

    # Normalise: binary emits an array; guard against single-object format.
    if isinstance(data, dict):
        data = [data]

    for run in data:
        variant = run.get("variant", "?")
        mode    = run.get("mode", "?")

        # Top-bucket contamination flag.
        if run.get("top_bucket_count", 0) > 0:
            print(
                f"FLAG [{variant}/{mode}]: {run['top_bucket_count']} top-bucket "
                "sample(s) — likely kernel preemption or page fault.",
                file=sys.stderr,
            )

        # TSC drift flag.
        drift = run.get("calibration_drift_pct", 0.0)
        if drift > 0.1:
            print(
                f"FLAG [{variant}/{mode}]: TSC drift {drift:.4f}% > 0.1% threshold.",
                file=sys.stderr,
            )

        # max >= p99_9 guarantee (the demo-04 bug must not recur).
        stats = run.get("latency_ns", {}).get("stats", {})
        if stats:
            mx    = stats.get("max", 0)
            p99_9 = stats.get("p99_9", 0)
            if mx < p99_9:
                print(
                    f"FLAG [{variant}/{mode}]: max ({mx}) < p99_9 ({p99_9}) — "
                    "histogram bug?",
                    file=sys.stderr,
                )

        # Pressure sweep sanity: background_pressure_hz must be present.
        if mode == "pressure_sweep" and "background_pressure_hz" not in run:
            print(
                f"FLAG [{variant}/{mode}]: missing background_pressure_hz field.",
                file=sys.stderr,
            )

        # pressure_config must be present on every demo-05 run.
        pc = run.get("pressure_config")
        if pc is None:
            print(
                f"FLAG [{variant}/{mode}]: missing pressure_config block.",
                file=sys.stderr,
            )
        else:
            for field in ("malloc_tuning", "bg_live_allocs", "bg_size_classes", "bg_threads"):
                if field not in pc:
                    print(
                        f"FLAG [{variant}/{mode}]: pressure_config missing field '{field}'.",
                        file=sys.stderr,
                    )

    return data


def _build_notes(runs: list, cross_ccx: bool) -> str:
    paced_runs = [r for r in runs if r.get("mode") == "paced"]
    sweep_runs = [r for r in runs if r.get("mode") == "pressure_sweep"]

    paced_suffix = ""
    if paced_runs:
        rate = paced_runs[0].get("offered_rate_hz", 0)
        bg   = paced_runs[0].get("background_pressure_hz", None)
        paced_suffix = (
            f" Paced: {rate/1e6:.0f} MHz offered load"
            + (f", {bg/1e6:.0f} M/s background pressure." if bg else ", no background pressure.")
        )

    sweep_suffix = ""
    if sweep_runs:
        bgs = [r.get("background_pressure_hz") for r in sweep_runs
               if r.get("background_pressure_hz") is not None]
        if bgs:
            variants = {r.get("variant") for r in sweep_runs}
            pts = len(sweep_runs) // len(variants) if variants else len(sweep_runs)
            sweep_suffix = (
                f" Pressure sweep: {pts} points "
                f"(zero baseline + {pts-1} log-spaced "
                f"{min(bgs)/1000:.0f}k–{max(bgs)/1e6:.0f}M Hz)."
            )

    ccx_note = " Cross-CCX side experiment included." if cross_ccx else ""
    return (
        "Producer pinned to core 4, consumer to core 5 (same CCX1 on Zen 2 3800X). "
        "Background pressure thread (T_bg) pinned to core 6 (same CCX1). "
        "Order struct: 64 B, alignas(64). "
        "End-to-end latency: rdtscp after allocate() → rdtscp after simulated risk check. "
        "Warmup: 100k items pre-roll per iteration."
        + paced_suffix
        + sweep_suffix
        + ccx_note
    )


def main() -> None:
    if len(sys.argv) < 5:
        print(__doc__, file=sys.stderr)
        sys.exit(1)

    variant_dir  = Path(sys.argv[1])
    captured_at  = sys.argv[2]
    machine_json = sys.argv[3]
    out_path     = Path(sys.argv[4])
    cross_ccx    = "--cross-ccx" in sys.argv[5:]

    machine = json.loads(machine_json)

    runs = []
    if cross_ccx:
        for variant in VARIANTS:
            vpath = variant_dir / f"{variant}-cross-ccx.json"
            runs.extend(load_runs(vpath))
    else:
        for variant in VARIANTS:
            for mode in ("paced", "pressure_sweep"):
                vpath = variant_dir / f"{variant}-{mode}.json"
                runs.extend(load_runs(vpath))

    if not runs:
        print("ERROR: no run data found in variant_dir", file=sys.stderr)
        sys.exit(1)

    demo_id = "05-allocators"
    title   = "Allocators: cross-thread order pipeline"

    output = {
        "demo":        demo_id,
        "title":       title,
        "machine":     machine,
        "captured_at": captured_at,
        "runs":        runs,
        "notes":       _build_notes(runs, cross_ccx),
    }

    os.makedirs(out_path.parent, exist_ok=True)
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2)

    paced_count = sum(1 for r in runs if r.get("mode") == "paced")
    sweep_count = sum(1 for r in runs if r.get("mode") == "pressure_sweep")
    xccx_count  = sum(1 for r in runs if r.get("mode") not in ("paced", "pressure_sweep"))
    print(
        f"Written: {out_path} "
        f"({paced_count} paced, {sweep_count} pressure_sweep"
        + (f", {xccx_count} cross-ccx" if cross_ccx else "")
        + " runs)"
    )


if __name__ == "__main__":
    main()
