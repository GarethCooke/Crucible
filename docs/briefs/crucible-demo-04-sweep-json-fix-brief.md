# Crucible — Demo 04 sweep-mode JSON emission fix

Hot-fix brief. Companion to `crucible-demo-04-fixup-brief.md`. The fix-up brief has been implemented; the benchmark binary runs cleanly end-to-end; raw measurement data has been collected. The only failure is in the JSON emission contract between the C++ binary and the Python assembler.

This brief is small in scope: one C++ emitter bug, plus a data-recovery path so the existing run doesn't have to be repeated.

## Why this revision

`bench/scripts/assemble_results_04.py` aborts with:

```
File ".../assemble_results_04.py", line 35, in load_runs
    data = json.load(f)
json.decoder.JSONDecodeError: Expecting value: line 3 column 1 (char 1026)
```

The assembler's contract (documented in its own docstring) is that each `<variant>-<mode>.json` file contains either a single JSON object or a JSON array of run objects. It normalises with `if isinstance(data, dict): data = [data]`. The current binary, in `--mode sweep`, emits N top-level JSON objects concatenated on stdout — neither a single object nor a valid array. `json.load()` parses the first object and then chokes on the second.

The benchmark itself completed correctly. All sweep steps for all three variants produced data. Only the file format is wrong.

## C++ changes

### `bench/demos/04-spsc-queue/benchmark.cpp`

In the main sweep code path, wrap the per-step run output in a JSON array. The fix pattern:

```cpp
if (mode == Mode::Sweep) {
    std::printf("[\n");
    for (size_t step = 0; step < num_steps; ++step) {
        const double rate_hz = sweep_rates[step];
        RunResult r = run_variant(variant, ns_per_cycle, Mode::Paced, rate_hz);

        emit_run_json(variant, "sweep", rate_hz, r, ns_per_cycle, drift_pct);

        if (step + 1 < num_steps) std::printf(",\n");
    }
    std::printf("]\n");
} else {
    // paced / saturated: single run, single object — assembler handles via
    // its isinstance(data, dict) fallback.
    emit_run_json(variant, mode_name, rate_hz, result, ns_per_cycle, drift_pct);
}
```

Constraints on `emit_run_json`:

- Must emit _only_ the JSON object — no surrounding array brackets, no trailing comma, no extraneous newline that would break array syntax. If it currently ends with `}\n`, that's fine; the wrapper adds the inter-element comma.
- The function does not need a mode-aware variant. Same emitter for paced, saturated, and each sweep step.
- The `offered_rate_hz` field must be present and correct for every emitted object (including paced and saturated — saturated should report the empirically achieved rate, or 0 if not applicable, but the field must exist for schema uniformity).

Belt-and-braces: at the end of `main()` after the sweep loop, validate the emitted output by piping it through a minimal parser. If running in a debug build, optionally re-parse stdout into a JSON object before exit. This is cheap and catches future emitter regressions immediately.

### What not to change

- The paced and saturated emission paths. They emit a single object today and the assembler handles that via `isinstance(data, dict)`. Leave them alone.
- The assembler script (`assemble_results_04.py`). Its contract is correct; the C++ side was the violator. Modifying the assembler to accept concatenated objects would mask future emitter bugs.

## Data recovery (avoid re-running the rig)

The existing `*-sweep.json` files contain valid per-step JSON objects, just concatenated. They can be salvaged in place. Add a script `bench/scripts/repair_sweep_json.py` that takes a file path, reads its contents, splits on top-level `}{` boundaries, and rewrites it as a proper array.

Minimal Python (use Python's own decoder rather than regex to avoid false splits inside histogram strings):

```python
import json, sys
from pathlib import Path

def repair(path: Path) -> None:
    text = path.read_text()
    decoder = json.JSONDecoder()
    objs = []
    idx = 0
    while idx < len(text):
        # skip whitespace
        while idx < len(text) and text[idx].isspace():
            idx += 1
        if idx >= len(text):
            break
        obj, end = decoder.raw_decode(text, idx)
        objs.append(obj)
        idx = end
    path.write_text(json.dumps(objs, indent=2))
    print(f"Repaired {path}: {len(objs)} objects")

if __name__ == "__main__":
    for p in sys.argv[1:]:
        repair(Path(p))
```

Usage:

```bash
python3 bench/scripts/repair_sweep_json.py <variant_dir>/*-sweep.json
python3 bench/scripts/assemble_results_04.py <variant_dir> <captured_at> "$machine_json" <out_path>
```

After this, the merged `04-spsc-queue.json` should fall out without re-running the C++ binary. The repair script is one-shot; once the C++ emitter is fixed, future runs won't need it. Keep it in `scripts/` anyway — useful diagnostic tool.

## Acceptance criteria

- `bench_04_spsc_queue lockfree-handrolled --mode sweep --rate-from 100000 --rate-to 25000000 --steps 8` produces stdout that parses cleanly with `python3 -c "import json,sys; json.load(sys.stdin)"` and yields a list of length 8.
- `bench_04_spsc_queue lockfree-handrolled --mode paced --rate-hz 1000000` continues to produce stdout that parses as either a JSON object or a single-element array. Both shapes accepted.
- `./bench/scripts/run_one.sh 04-spsc-queue` completes without Python tracebacks and writes `site/src/data/perf/04-spsc-queue.json`.
- The merged JSON contains exactly 3 paced runs, 3 saturated runs, and 24 sweep runs (3 variants × 8 steps), for 30 entries total in `runs[]`.
- Every entry in `runs[]` has non-empty `variant`, `mode`, and `offered_rate_hz` fields.
- `python3 bench/scripts/repair_sweep_json.py <existing_sweep_file>` round-trips cleanly (parses, rewrites, re-parses).

## Out of scope

- Schema changes. The contract documented in `assemble_results_04.py` is correct; only the emitter needed to honour it.
- Re-running the benchmark on the rig. The existing measurement data is intact and can be recovered via the repair script.
- The `repair_sweep_json.py` script is a one-time recovery aid; it does not need to be wired into `run_one.sh` once the emitter is fixed.

## Note to CC

The fix-up brief specified that sweep mode should emit "per-step results into a single `runs[]` array; one JSON file covers all sweep points." That instruction was followed in spirit but not in JSON syntax — the file contained per-step results, just not wrapped in array brackets. The acceptance criteria here are explicit about the wrapping so the same ambiguity doesn't recur.
