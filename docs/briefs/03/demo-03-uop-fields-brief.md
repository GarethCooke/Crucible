# Crucible — demo 03 per-variant counter fields (M-5 forward half)

Implementation brief for CC. Source: finding M-5 in `crucible-live-site-hostile-cross-read-findings.md` (v2). The provenance half of M-5 is closed: `bench/scripts/03/uop_diag.sh` is the pinned `perf stat -e instructions,ex_ret_cops` run behind the post's ≈17/≈50 and 0.99/1.00 figures, so the note merged in PR #10 is repo-verified. This brief does the forward half: wire per-variant `instructions_per_op` and `uops_per_instruction` into the demo 03 harness and assembler so the next recapture emits them into the JSON automatically — fulfilling the note's "planned for the next recapture" clause with zero extra capture-day work. **No capture in this brief; no committed JSON changes; no prose changes.** One branch (`feat/demo-03-uop-fields`), one PR.

## Context

Demo 03 (and 09, which shares the harness) measures counters via `PerfCounters` in `bench/common/perf_wrapper.h` — four fixed `perf_event_open` counters (branches, misses, instructions, cycles), exposed through `bs_run_bm` in `bench/common/bs_bench_harness.h` as the GB counter `ipc`, which `bench/scripts/assemble_results_03.py` medians into the site JSON's `instructions_per_cycle`. `perf_wrapper.h` contains **two** `PerfCounters` class definitions (~lines 19 and 117 — a real Linux one and a fallback stub); both must stay API-identical. Retired µops on Zen 2 is the raw PMU event `0xC1` (ExRetCops — the same event `uop_diag.sh` names symbolically). The raw event is x86/AMD-specific: demo 09 builds this harness on aarch64, and dev machines may refuse the event, so the design is opt-in at the harness and fail-soft at runtime.

## Preconditions — verify before any edit; if any fail, stop and report

1. Repo clean, on `master`, up to date.
2. `grep -c "class PerfCounters" bench/common/perf_wrapper.h` → exactly 2.
3. `grep -ci "uops\|PERF_TYPE_RAW" bench/common/perf_wrapper.h` → 0.
4. `grep -c 'counters\["ipc"\]' bench/common/bs_bench_harness.h` → exactly 1.
5. `grep -c '"instructions_per_cycle"' bench/scripts/assemble_results_03.py` → ≥1; file `bench/scripts/assemble_results_09.py` exists.
6. `bench/scripts/03/uop_diag.sh` exists.

## Tasks

### 1. `perf_wrapper.h` — optional fifth counter (both class definitions)

- Constructor becomes `explicit PerfCounters(std::optional<uint64_t> raw_config = std::nullopt)`. Default-constructed behaviour is byte-for-byte what it is today — demo 01 constructs it directly and must be unaffected.
- `Counts` gains `uint64_t raw = 0;` and `bool raw_ok = false;` (accumulated in `operator+=`, `raw_ok` OR-ed).
- Real class: when `raw_config` is set, open a fifth fd with `type = PERF_TYPE_RAW`, `config = *raw_config`, same `exclude_kernel`/flags as the existing counters. **On open failure, set `raw_ok = false` and continue silently — do not throw.** The four core counters keep their existing throw-on-failure behaviour. `read()` populates `raw`/`raw_ok`.
- Stub class: mirror the API; `raw_ok` always false.
- The wrapper stays event-agnostic — the `0xC1` constant does **not** live here.

### 2. `bs_bench_harness.h` — request the event and expose the counters

In `bs_run_bm`:

- Construct the counter with the raw event only on x86-64:
  `#if defined(__x86_64__)` → `PerfCounters perf{std::optional<uint64_t>{0xC1}}; // Zen 2 ExRetCops (retired µops), same event uop_diag.sh uses` — `#else` → default-construct.
- After the loop, alongside the existing counters:
  - always: `state.counters["instructions_per_op"] = static_cast<double>(total.instructions) / ops;`
  - only if `total.raw_ok && total.instructions > 0`: `state.counters["uops_per_instruction"] = static_cast<double>(total.raw) / total.instructions;`
- No other harness changes; demo 01's direct `PerfCounters` usage untouched.

### 3. Assemblers — pass the fields through

- `assemble_results_03.py`: for each run, median the new GB counters across reps exactly as `ipc` is medianed today. Emit `"instructions_per_op"` (2 dp) and `"uops_per_instruction"` (3 dp) per run; when the counter is absent from the reps (raw event didn't open), emit `null` for `uops_per_instruction` — `instructions_per_op` is always present. If the script filters GB counters through an allowlist, extend it.
- `assemble_results_09.py`: same treatment for `instructions_per_op` only. Do **not** add `uops_per_instruction` on the ARM path.

### 4. `bench/demos/03-simd-blackscholes/README.md` — provenance + capture gate

Append a short section stating: (a) the published instruction/µop figures (≈17 vs ≈50 per option; 0.99/1.00 µops per instruction) currently derive from `bench/scripts/03/uop_diag.sh`, a pinned `perf stat` pass over the same binaries; (b) from the next capture onward the JSON fields `instructions_per_op` / `uops_per_instruction` are authoritative; (c) **validation gate for that first capture**: the new fields must land within a few percent of the published figures for `sse2` and `avx2fma` at N=1M — a mismatch means the raw event `0xC1` mis-resolved on this kernel/PMU and the capture must stop before committing.

## Acceptance

- `cmake` build of `bench/` succeeds on the CC machine.
- Short local run of the demo 03 binary (any small `--benchmark_min_time`, one N): exits 0 whether or not the raw event opens; GB JSON contains `instructions_per_op` in counters; `uops_per_instruction` present iff the event opened. Include the command and the counters block in the PR description.
- Assembler demonstration in the PR: run `assemble_results_03.py` against a minimal synthetic GB input twice — reps with the `uops_per_instruction` counter and reps without — showing the output carries the value in the first case and `null` in the second, with `instructions_per_op` in both.
- Greps: `grep -c "0xC1" bench/common/bs_bench_harness.h` → 1; `grep -c "0xC1" bench/common/perf_wrapper.h` → 0; `grep -c "raw_ok" bench/common/perf_wrapper.h` → ≥2 (both classes); `grep -c "__x86_64__" bench/common/bs_bench_harness.h` → 1; `grep -c "instructions_per_op" bench/scripts/assemble_results_09.py` → ≥1; `grep -c "uops_per_instruction" bench/scripts/assemble_results_09.py` → 0.
- `git diff --stat master...HEAD` touches exactly five files: `bench/common/perf_wrapper.h`, `bench/common/bs_bench_harness.h`, `bench/scripts/assemble_results_03.py`, `bench/scripts/assemble_results_09.py`, `bench/demos/03-simd-blackscholes/README.md`.
- No committed capture JSON, no `site/`, no demo 01 file shows a diff.

## Out of scope

- Any capture. The committed `03-simd-blackscholes.json` and `09-arm-neon.json` are untouched; the new fields appear only when the user next captures.
- Demo 03/09 post MDX — the merged provenance note already says the fields land "at the next recapture"; retiring that clause happens after the capture, not now.
- `uop_diag.sh` itself, demo 01/02/04–08 code, `tsc_utils.h`, the site.

## Open items for CC to flag

- If the two `PerfCounters` definitions differ structurally from the four-fd pattern described (e.g. the stub lacks `Counts`), adapt while keeping the public API identical between them — and say so in the PR.
- If the assemblers drop unknown GB counters via an allowlist or schema check, extend it minimally; if their reps structure doesn't mirror the `ipc` handling shown at lines ~75–88 of `assemble_results_03.py`, stop and report rather than restructuring.
- aarch64 compile-cleanliness is by preprocessor guard only — it cannot be verified on the CC machine. Note in the PR that the Pi build gets verified at the next demo 09 touchpoint.

## Stop condition

Acceptance green, PR open referencing M-5 and this brief. User merges. M-5 closes permanently at the next demo 03 recapture, when the README's validation gate passes and the fields are committed.
