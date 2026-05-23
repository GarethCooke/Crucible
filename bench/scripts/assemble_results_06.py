"""Assemble per-cell JSON outputs from the AoS vs SoA benchmark into site data.

Usage (called by run_one.sh):
    python3 bench/scripts/assemble_results_06.py \\
        <cell_dir> <captured_at> <machine_json> <out_path>

<cell_dir> must contain files named:
    <variant>-n<N>-k<K>.json
    e.g.  aos-scalar-n1048576-k1.json

Each file is the stdout of one invocation of bench_06_aos_vs_soa, which emits
a single JSON object per cell.

The assembler:
  1. Loads all cell files.
  2. Validates schema (round-trip identity, required fields).
  3. Assembles into a single JSON with top-level machine, notes, and runs array.
  4. Prints a summary to stderr.
"""

import json
import math
import os
import sys
from pathlib import Path


VARIANTS = ["aos-scalar", "soa-scalar", "soa-autovec"]
NS       = [4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576]
KS       = [1, 2, 4, 8, 16]

REQUIRED_FIELDS = [
    "variant", "n", "k",
    "struct_size_bytes", "struct_field_count", "field_type_bytes",
    "access_pattern", "kernel",
    "iterations", "items_measured", "items_warmup", "warmup_ms",
    "ns_per_op", "ops_per_sec",
    "calibration_drift_pct", "captured_at",
]


def validate_run(run: dict) -> list[str]:
    """Return list of problem strings; empty = clean."""
    problems = []
    tag = f"[{run.get('variant', '?')} n={run.get('n', '?')} k={run.get('k', '?')}]"

    for field in REQUIRED_FIELDS:
        if field not in run:
            problems.append(f"MISS {tag}: required field '{field}' absent")

    # Round-trip identity: ops_per_sec × ns_per_op.median / 1e9 ∈ [0.999, 1.001]
    ns_obj = run.get("ns_per_op", {})
    med = ns_obj.get("median")
    ops = run.get("ops_per_sec")
    if med is not None and ops is not None and med > 0:
        product = ops * med / 1e9
        if not (0.999 <= product <= 1.001):
            problems.append(
                f"ROUNDTRIP {tag}: ops_per_sec × ns_per_op.median / 1e9 = {product:.6f} "
                f"(expected 0.999–1.001)"
            )

    # Drift warning
    drift = run.get("calibration_drift_pct", 0.0)
    if drift > 0.1:
        problems.append(f"DRIFT {tag}: calibration drift {drift:.4f}% > 0.1%")

    return problems


def load_cell(path: Path) -> dict | None:
    if not path.exists():
        print(f"WARN: missing cell file: {path} (skipping)", file=sys.stderr)
        return None
    with open(path) as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            print(f"ERROR: JSON decode failed for {path}: {e}", file=sys.stderr)
            return None
    if isinstance(data, list):
        if not data:
            return None
        data = data[0]
    return data


def build_notes(runs: list[dict]) -> str:
    n_cells = len(runs)
    variants = sorted({r.get("variant", "?") for r in runs})
    ns_seen  = sorted({r.get("n", 0) for r in runs})
    ks_seen  = sorted({r.get("k", 0) for r in runs})

    thp = runs[0].get("transparent_hugepage", "unknown") if runs else "unknown"

    return (
        f"{n_cells} cells: {len(variants)} variants × "
        f"{len(ns_seen)} N values × {len(ks_seen)} K values. "
        f"Variants: {', '.join(variants)}. "
        f"N: {min(ns_seen)}–{max(ns_seen)} elements. "
        f"K: {', '.join(str(k) for k in ks_seen)}. "
        "Single thread pinned to core 4 (CCX1, Zen 2 3800X). "
        "Warmup: 500 ms wall-clock per cell. "
        "Measurement: 5 iterations per cell; ns_per_op is per Record element scanned. "
        f"transparent_hugepage={thp}. "
        "Access pattern: sequential contiguous-prefix (fields 0..K-1 per element). "
        "K=12 excluded: pilot showed no discontinuity at the cache-line-fill boundary — "
        "sits on a smooth ramp between K=8 and K=16. See pilot README §8.2."
    )


def main() -> None:
    if len(sys.argv) not in (5,):
        print(__doc__, file=sys.stderr)
        sys.exit(1)

    cell_dir     = Path(sys.argv[1])
    captured_at  = sys.argv[2]
    machine_json = sys.argv[3]
    out_path     = Path(sys.argv[4])

    machine = json.loads(machine_json)

    runs: list[dict] = []
    all_problems: list[str] = []

    for variant in VARIANTS:
        for n in NS:
            for k in KS:
                fname = f"{variant}-n{n}-k{k}.json"
                cell = load_cell(cell_dir / fname)
                if cell is None:
                    continue
                problems = validate_run(cell)
                all_problems.extend(problems)
                runs.append(cell)

    if not runs:
        print("ERROR: no run data found in cell_dir", file=sys.stderr)
        sys.exit(1)

    for p in all_problems:
        print(p, file=sys.stderr)
    if all_problems:
        print(f"\n{len(all_problems)} validation issue(s) above.", file=sys.stderr)

    # Check grid density.
    expected = len(VARIANTS) * len(NS) * len(KS)
    if len(runs) != expected:
        print(
            f"WARN: expected {expected} cells, got {len(runs)} — "
            "grid may be incomplete.",
            file=sys.stderr,
        )

    output = {
        "demo":        "06-aos-vs-soa",
        "title":       "AoS vs SoA: bandwidth amplification across the cache hierarchy",
        "machine":     machine,
        "captured_at": captured_at,
        "runs":        runs,
        "notes":       build_notes(runs),
    }

    os.makedirs(out_path.parent, exist_ok=True)
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2)

    print(
        f"Written: {out_path} ({len(runs)}/{expected} cells, "
        f"{len(all_problems)} validation issue(s))"
    )


if __name__ == "__main__":
    main()
