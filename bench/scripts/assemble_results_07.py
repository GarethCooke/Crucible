"""Assemble per-cell JSON outputs from the No Crossover benchmark into site data.

Usage (called by run_one.sh):
    python3 bench/scripts/assemble_results_07.py \\
        <cell_dir> <captured_at> <machine_json> <out_path>

<cell_dir> must contain files named:
    <variant>-<workload>-n<N>-pct<P>.json
    e.g.  absl_flat-lookup-n4096-pct0.json
          std_map-modify_mix-n65536-pct50.json

Each file is the stdout of one invocation of bench_07_no_crossover.

The assembler:
  1. Loads all cell files.
  2. Validates required fields per run.
  3. Assembles into a single JSON with top-level machine, notes, and runs[].
  4. Prints a summary to stderr.
"""

import json
import os
import sys
from pathlib import Path


VARIANTS = ["std_map", "sorted_vec", "boost_flat", "std_unord", "absl_flat"]

LOOKUP_NS    = [8, 16, 32, 64, 128, 256, 512, 1024, 4096, 16384, 65536,
                262144, 1048576, 4194304]
MODIFYMIX_NS  = [256, 4096, 65536]
MODIFY_PCTS  = [0, 10, 25, 50, 75, 90]

REQUIRED_RUN_FIELDS = [
    "variant", "n", "workload", "modify_pct",
    "ns_per_op", "compile_flags", "captured_at",
]
REQUIRED_NS_PER_OP = ["median", "min", "max", "p99", "iqr", "iqr_lo", "iqr_hi", "n_reps"]


def validate_run(run: dict) -> list[str]:
    tag = (
        f"[{run.get('variant','?')} {run.get('workload','?')} "
        f"n={run.get('n','?')} pct={run.get('modify_pct','?')}]"
    )
    problems = []
    for field in REQUIRED_RUN_FIELDS:
        if field not in run:
            problems.append(f"MISS {tag}: required field '{field}' absent")
    ns = run.get("ns_per_op", {})
    for sub in REQUIRED_NS_PER_OP:
        if sub not in ns:
            problems.append(f"MISS {tag}: ns_per_op.{sub} absent")
    if ns.get("median", 0) <= 0:
        problems.append(f"WARN {tag}: ns_per_op.median <= 0")
    return problems


def load_cell(path: Path) -> dict | None:
    if not path.exists():
        return None
    with open(path) as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            print(f"ERROR: JSON decode failed for {path}: {e}", file=sys.stderr)
            return None
    if isinstance(data, list):
        data = data[0] if data else None
    return data


def build_notes(runs: list[dict]) -> str:
    n_lookup   = sum(1 for r in runs if r.get("workload") == "lookup")
    n_modify   = sum(1 for r in runs if r.get("workload") == "modify_mix")
    variants   = sorted({r.get("variant", "?") for r in runs})
    n_reps     = runs[0].get("ns_per_op", {}).get("n_reps", "?") if runs else "?"
    return (
        f"{len(runs)} cells total: {n_lookup} lookup + {n_modify} modify_mix. "
        f"Variants: {', '.join(variants)}. "
        f"{n_reps} outer reps per cell; ns_per_op is median of reps. "
        "Key generation: mt19937_64(seed=42), distinctness via unordered_set. "
        "Op/lookup sequence: mt19937_64(seed=1337). "
        "Lookup: 4096-entry cyclic index, 100% hit rate. "
        "Modify-mix: steady-state erase+insert; modify_pct fraction of ops are modify."
    )


def main() -> None:
    if len(sys.argv) != 5:
        print(__doc__, file=sys.stderr)
        sys.exit(1)

    cell_dir     = Path(sys.argv[1])
    captured_at  = sys.argv[2]
    machine_json = sys.argv[3]
    out_path     = Path(sys.argv[4])

    machine = json.loads(machine_json)

    runs: list[dict] = []
    all_problems: list[str] = []
    skipped = 0

    # Workload A: lookup
    for variant in VARIANTS:
        for n in LOOKUP_NS:
            fname = f"{variant}-lookup-n{n}-pct0.json"
            cell = load_cell(cell_dir / fname)
            if cell is None:
                skipped += 1
                continue
            problems = validate_run(cell)
            all_problems.extend(problems)
            runs.append(cell)

    # Workload B: modify_mix
    for variant in VARIANTS:
        for n in MODIFYMIX_NS:
            for pct in MODIFY_PCTS:
                fname = f"{variant}-modify_mix-n{n}-pct{pct}.json"
                cell = load_cell(cell_dir / fname)
                if cell is None:
                    skipped += 1
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

    expected_lookup   = len(VARIANTS) * len(LOOKUP_NS)
    expected_modify   = len(VARIANTS) * len(MODIFYMIX_NS) * len(MODIFY_PCTS)
    expected_total    = expected_lookup + expected_modify

    if skipped > 0:
        print(
            f"INFO: {skipped} cell(s) skipped (over-budget or missing). "
            f"Got {len(runs)}/{expected_total}.",
            file=sys.stderr,
        )

    workloads = sorted({r.get("workload") for r in runs})
    variants_seen = sorted({r.get("variant") for r in runs})
    workloads_ok = sorted(workloads) == ["lookup", "modify_mix"]
    variants_ok  = sorted(variants_seen) == sorted(VARIANTS)

    if not workloads_ok:
        print(f"WARN: workloads in output = {workloads} (expected lookup+modify_mix)",
              file=sys.stderr)
    if not variants_ok:
        print(f"WARN: variants in output = {variants_seen}", file=sys.stderr)

    output = {
        "demo":        "07-no-crossover",
        "title":       "No crossover: absl::flat_hash_map wins at every N and workload mix",
        "machine":     machine,
        "captured_at": captured_at,
        "runs":        runs,
        "notes":       build_notes(runs),
    }

    os.makedirs(out_path.parent, exist_ok=True)
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2)

    print(
        f"Written: {out_path}  ({len(runs)}/{expected_total} cells, "
        f"{len(all_problems)} validation issue(s), {skipped} skipped)"
    )


if __name__ == "__main__":
    main()
