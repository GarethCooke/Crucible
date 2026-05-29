# Crucible — Demo 02 capture-pipeline alignment brief

Companion to `BRIEF.md`, `crucible-handover.md`, `03-harness-patch-brief.md`, and `crucible-demo-04-fixup-brief.md`. Brings demo 02's capture pipeline into alignment with demos 01/03/04. Precondition for closing out the JSON machine-block audit (task 1 of the pre-demo-5 review). After CC ships this, the user re-runs capture on the reference machine, then `pre-demo-5-audit-closeout-brief.md` handles the remaining cleanup.

## Why this change

Demo 02's JSON pipeline diverged from the others. Demos 01/03/04 emit their JSON directly from `bench/common/machine_info.h` via the patched harness (turbo via `CRUCIBLE_TURBO`, no machine-level `compiler_flags`, `isolated_cpus_requested`/`_effective`/`_source`/`cpu_affinity`/`lscpu_extended` sub-fields). Demo 02 routes through `bench/tools/parse_perf.py`, which initializes `"machine": {}` and `"captured_at": "PLACEHOLDER"` on file create and never populates either. The existing machine block and `captured_at` value in `site/src/data/perf/02-false-sharing-pnl.json` are curated state hand-supplied per `02b-false-sharing-prose-rewrite-brief.md` Task 1 — they survive every re-run because the load-existing-and-merge pattern preserves them.

Two consequences:

1. `captured_at` never updates on re-run. The audit caught this — the value is `"2026-05-16T16:58:01+00:00"`, pre-dating the harness patch commit (`8e35e3c`, 2026-05-16T20:42:00Z), and stays there across capture re-runs.
2. The machine block carries the pre-patch schema — `compiler_flags` present at machine level, `isolated_cores` and `smt_active` legacy fields, missing the patched-harness sub-fields. Same survival mechanism.

The format split is the smoking gun: demo 02's `captured_at` uses Python `datetime.isoformat()` style (`+00:00`), demos 01/03/04 use C-style `strftime` (`Z`). Different code paths producing the same field.

This brief aligns demo 02's pipeline so machine-info comes from the same shared `machine_info.h` the others use, and `captured_at` is stamped at every write.

## Scope

### 1. `bench/demos/02-false-sharing/false_sharing_pnl.cpp` — add `--machine-info` CLI mode

Match the pattern from `crucible-demo-04-fixup-brief.md` (which added the same mode to demo 04). At the top of `main`, before Google Benchmark initialization:

```cpp
#include "common/machine_info.h"   // if not already included
// ...

int main(int argc, char** argv) {
    if (argc > 1 && std::string(argv[1]) == "--machine-info") {
        std::cout << machine_info_json() << std::endl;
        return 0;
    }
    // ... existing Google Benchmark setup and run
}
```

If `machine_info_json()` already returns a complete JSON object (open brace to close brace), no wrapping needed. If it returns only the body (without enclosing braces), wrap it: `std::cout << "{" << machine_info_json() << "}"`. Match exactly what `bench_04_spsc_queue --machine-info` does — verify by inspecting the demo 04 binary's source for the same mode and replicating, so the two outputs are byte-identical apart from machine state.

`--machine-info` exits 0 after writing. The mode does **not** run benchmarks, does **not** require `CRUCIBLE_TURBO` to be set (machine_info.h will emit `"turbo": null` if unset, which is correct for an info-only invocation — but see §3, run_one.sh exports `CRUCIBLE_TURBO` before this call anyway).

### 2. `bench/tools/parse_perf.py` — accept machine-info, always update captured_at

Add a required argument and three behavioural changes. Don't touch the existing argument parsing, perf/bench parsing, or upsert logic — only the file-init and write paths.

**Add argument:**

```python
ap.add_argument("--machine-info-json", required=True, type=Path,
                help="Path to JSON file produced by `<bench-binary> --machine-info`")
```

**Add import:**

```python
from datetime import datetime, timezone
```

**Replace the file load/init block.** Current:

```python
if args.out.exists():
    with open(args.out) as f:
        data = json.load(f)
else:
    data = {
        "demo": "02-false-sharing-pnl",
        "title": "False sharing: padded vs unpadded P&L accumulators",
        "machine": {},
        "captured_at": "PLACEHOLDER",
        "runs": [],
        "notes": "",
    }
```

Replace with:

```python
with open(args.machine_info_json) as f:
    machine_info = json.load(f)

if args.out.exists():
    with open(args.out) as f:
        data = json.load(f)
else:
    data = {
        "demo": "02-false-sharing-pnl",
        "title": "False sharing: padded vs unpadded P&L accumulators",
        "machine": {},
        "captured_at": "",
        "runs": [],
        "notes": (
            "Captured on AMD Ryzen 7 3800X, Zen 2, governor=performance, turbo off, "
            "SMT off, isolated cpus 1-7 (cpu0 cannot be kernel-isolated). "
            "Fill stream: 1024 doubles (8 KB), mt19937 seed 42, uniform [-1, 1]. "
            "Compiler: GCC 13, -O3 -march=native."
        ),
    }

# Always overwrite machine block and stamp captured_at — both come from the
# current capture session, not from preserved file state.
data["machine"] = machine_info
data["captured_at"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
```

Notes on the choice:

- `data["machine"]` is replaced every invocation. Idempotent — same machine across all 12 invocations of one capture session, so the value is identical on each write.
- `data["captured_at"]` is stamped every write. The final value reflects the last variant's write time; for a multi-minute capture, the difference between first and last is acceptable (the field's purpose is "when was this dataset produced", not microsecond accuracy).
- `Z` suffix format matches demos 01/03/04. No `+00:00`.
- The hardcoded methodology `notes` string is the canonical one from `02b-false-sharing-prose-rewrite-brief.md` Task 1. Preserve verbatim so the prose's footer reference still resolves.

### 3. `bench/scripts/run_one.sh` — invoke `--machine-info` once per capture session

Update the demo-02 branch. The existing 12-variant loop is unchanged in structure; add a one-time machine-info dump before it and pass the file through to parse_perf.py on every invocation.

```bash
# (existing setup: governor, CRUCIBLE_TURBO, isolation precondition checks)

# Dump machine info once per session. Use mktemp for the temp file so concurrent
# sessions don't collide; trap to clean up on any exit path.
MACHINE_INFO_JSON=$(mktemp --tmpdir crucible-machine-info-XXXX.json)
trap 'rm -f "$MACHINE_INFO_JSON"' EXIT

"$BENCH_BINARY" --machine-info > "$MACHINE_INFO_JSON"

# Sanity: refuse to proceed if the dump is empty or missing required fields.
if ! jq -e '.cpu and .turbo != null' "$MACHINE_INFO_JSON" > /dev/null; then
    echo "FATAL: machine-info dump invalid; check $BENCH_BINARY --machine-info" >&2
    exit 1
fi

# Existing loop over placement × threads × padded:
for placement in intra-ccx cross-ccx; do
    for threads in <existing list>; do
        for padded in 0 1; do
            "$BENCH_BINARY" --benchmark_filter=... > "$BENCH_JSON"
            perf stat ... 2> "$PERF_OUT"
            python3 "$PARSE_PERF" \
                --perf "$PERF_OUT" \
                --bench "$BENCH_JSON" \
                --out "$OUT_JSON" \
                --placement "$placement" \
                --threads "$threads" \
                --padded "$padded" \
                --machine-info-json "$MACHINE_INFO_JSON"
        done
    done
done
```

`jq` is already a build-time prerequisite or should be. If it isn't, swap the precondition check for a `grep`-based one and flag.

### 4. Delete the existing JSON before recapture (user step, documented)

`parse_perf.py` always overwrites `data["machine"]` from `machine_info_json`, so a re-run on top of the existing JSON would still produce a correct machine block. But the existing JSON also has the stale `"notes"` string and stale top-level state. Cleaner to delete and start fresh; the methodology notes string is now hardcoded in the parser's init template.

Document this step in the demo-02 README (`bench/demos/02-false-sharing/README.md`) under a "Re-capturing" section:

```
Before re-capturing, delete the existing data file so the parser produces a clean
JSON from the patched pipeline:

    rm site/src/data/perf/02-false-sharing-pnl.json
    ./scripts/run_one.sh 02-false-sharing

The first invocation in the loop will initialise the file with the canonical
methodology notes; subsequent invocations append per-variant runs.
```

If `bench/demos/02-false-sharing/README.md` doesn't exist, create it with this section plus a one-paragraph header describing the demo.

## User steps after CC ships

1. Boot into the benchmark GRUB entry ("Ubuntu (benchmark — cores 0-7 isolated)").
2. `cpupower frequency-set -g performance` and verify `cpupower frequency-info | grep "Active: no"`.
3. `export CRUCIBLE_TURBO=off`.
4. Rebuild: `cd bench && cmake --build build --clean-first` (clean-first to be sure `--machine-info` linkage picks up).
5. Sanity check: `./build/demos/02-false-sharing/bench_02_false_sharing_pnl --machine-info | jq .` — output should be a JSON object with the same shape as the `machine` block in `site/src/data/perf/03-simd-blackscholes.json`. If `compiler_flags` appears at the top level of that output, stop and flag back.
6. `rm site/src/data/perf/02-false-sharing-pnl.json`.
7. `./scripts/run_one.sh 02-false-sharing`.
8. Verify the resulting JSON:
   - `captured_at` is fresh (today, `Z` suffix).
   - `machine` has no `compiler_flags`, has `isolated_cpus_requested`/`_effective`/`_source`/`cpu_affinity`/`lscpu_extended`.
   - `runs[]` has 12 entries (3 intra-CCX thread counts + 3 cross-CCX thread counts) × 2 padded variants.
   - Top-level `notes` matches the canonical methodology string.
9. Hand off `pre-demo-5-audit-closeout-brief.md` to CC to finish the closeout.

## Acceptance

- `bench_02_false_sharing_pnl --machine-info` emits a JSON object structurally identical to the `machine` block produced by demos 01/03/04's harness (turbo, no machine-level `compiler_flags`, `isolated_cpus_requested`/`_effective`/`_source`, `cpu_affinity`, `lscpu_extended`).
- `parse_perf.py --machine-info-json <path>` is a required argument; the script overwrites `data["machine"]` and stamps `data["captured_at"]` on every write.
- `data["captured_at"]` matches the `YYYY-MM-DDTHH:MM:SSZ` format (Z suffix, not `+00:00`).
- `run_one.sh` invokes `--machine-info` once per session, passes the dump to all 12 parse_perf.py invocations, cleans up the temp file on any exit path.
- `README.md` under `bench/demos/02-false-sharing/` documents the `rm + run_one.sh` re-capture sequence.
- Build succeeds: `cmake --build build --clean-first` on the reference machine.

## Out of scope

- Any change to the perf or bench parsing logic in `parse_perf.py`.
- Any change to `false_sharing_pnl.cpp` beyond the `--machine-info` early-exit mode.
- Notes / findings / tasks-file updates (handled by `pre-demo-5-audit-closeout-brief.md` after the user re-captures).
- Aligning the captured_at format across the C++ harness (demos 01/03/04 already use `Z`; this brief brings demo 02 to match).
- Other demos.
- Recapture (user step on reference machine).

## Open items for CC to flag

- If `machine_info_json()` in `bench/common/machine_info.h` returns a JSON string that's not parseable as a top-level object (e.g. returns just the key-value pairs without enclosing `{}`), flag and propose. Don't silently change the function signature — other demos depend on it.
- If `bench_04_spsc_queue --machine-info` and the newly-added `bench_02_false_sharing_pnl --machine-info` produce structurally different output (different keys, ordering, types), surface the diff. They should be identical apart from runtime-varying values (RAM speed reading, kernel version, etc.).
- If `parse_perf.py` is used by any demo other than 02 (search for `import parse_perf` and `parse_perf.py` references across `bench/`), stop — this brief assumes it's demo-02-specific. Confirm before adding the required argument.
- If `run_one.sh` lacks a demo-specific branching structure and the demo-02 capture path lives elsewhere (separate script, inline in another), flag the actual file you patched.
- If `jq` isn't already a dependency, propose the fallback sanity check inline.
