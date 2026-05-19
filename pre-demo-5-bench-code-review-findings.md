# Crucible bench/ code review — findings

Generated 2026-05-19. Covers all files under `bench/` (excluding `build/`) and `tools/`. No fixes implemented; findings only.

---

## Critical

### C1 — `assemble_results.py`: `sort_cost_32m.ns_per_op` and `runs[*].ns_per_op` have different units

**Location:** `bench/scripts/assemble_results.py`, lines 65–70 (`sort_cost_32m`) vs lines 74–88 (`runs`).

**Observation:** `sort_cost_32m["ns_per_op"] = round(median_ns / sort_n, 4)` divides `real_time` by 33,554,432 elements — giving per-element nanoseconds. `runs[i]["ns_per_op"] = bench_stats(times)` emits `real_time` directly — giving per-outer-call nanoseconds (one pass over N elements). The same JSON key name is used for both.

**Problem:** If the site renderer applies the same display logic to both occurrences (e.g., labels both as "ns/op"), one set of values is wrong by ≈33.5 M×. The demo 01 post's sort-cost claim is directly at risk: a reader comparing `sort_cost_32m.ns_per_op` against `runs[*].ns_per_op` would see figures that differ by eight orders of magnitude rather than the expected factor of ≈N.

**Suggested fix:** Either normalise all `ns_per_op` fields to per-element (divide `bench_stats(times)` by `n` for each run), or rename `sort_cost_32m["ns_per_op"]` to `ns_per_element` to signal the different unit.

**Severity:** Critical


### C2 — Demo 04 sweep mode reports `calibration_drift_pct: 0.0` always; drift not monitored

**Location:** `bench/demos/04-spsc-queue/benchmark.cpp`, line 758: `const double drift = 0.0;  // per-step drift omitted`.

**Observation:** In paced and saturated modes a second `calibrate_tsc()` call is made after the run and drift is computed and checked against a 0.1% threshold. In sweep mode a single calibration is done at startup; every JSON run object emitted by the sweep loop carries `"calibration_drift_pct":0.0000`.

**Problem:** The latency-vs-load sweep chart is the primary deliverable of demo 04. Each sweep step runs 5 × 1 M items across 12 rate points — a substantial wall-clock window. If TSC frequency drifted during the sweep, all latency values for affected steps are silently wrong. The `assemble_results_04.py` drift flag (`if drift > 0.1: FLAG`) will never fire for sweep data, meaning the post's sweep-derived claims have no drift guard.

**Suggested fix:** Perform a second `calibrate_tsc()` call after each sweep step (or after the entire sweep) and report the actual drift. At minimum, change the hard-coded `0.0` to `calibrate_tsc()`-derived drift so the assembler flag fires when warranted.

**Severity:** Critical


---

## Material

### M1 — Demo 01: `BM_Branchless` duplicates `BM_impl` body (DRY violation)

**Location:** `bench/demos/01-branch-prediction/benchmark.cpp`, lines 75–94 (`BM_impl`) and 101–120 (`BM_Branchless`).

**Observation:** `BM_Branchless` reimplements the full perf-counter loop, the `ops` calculation, both `state.counters[...]` assignments, and `SetItemsProcessed` — identical to `BM_impl` except it calls `sum_threshold_branchless` instead of `sum_threshold` and uses `make_shuffled` unconditionally.

**Problem:** Demo 01 was the v1 demo. Any future refinement to the measurement framing (new counter, changed ops denominator, added `--verify-warmup` flag) must be applied to two places. An earlier patch could already have drifted silently — `BM_Branchless` is not guarded by the `BM_impl` code path and would not automatically pick up changes made there.

**Suggested fix:** Add a `PriceFn`-style function pointer parameter to `BM_impl`, or add a `bool branchless` flag that dispatches inside. `BM_Branchless` then becomes a one-liner.

**Severity:** Material


### M2 — Two redundant volatile codegen check scripts (DRY violation)

**Locations:**
- `bench/scripts/check_volatile_codegen.sh` — invoked by CMake POST_BUILD (canonical)
- `bench/demos/02-false-sharing/check_codegen.sh` — not invoked by any build target or capture script
- `bench/scripts/run_one.sh` lines 188–195 — inline re-implementation for demo 02 capture path

**Observation:** All three check `>=2 movsd` in `worker_fn`. The CMake version is the canonical build-time guard. The demo-local `check_codegen.sh` is never invoked by anything automated; it appears to be an abandoned earlier version. `run_one.sh` re-implements the same check inline as a pre-capture flight check.

**Problem:** `check_codegen.sh` is dead code that will diverge from the canonical script. If the movsd threshold or function-name mangling changes, the change must be made in three places. More importantly, `check_codegen.sh` being present gives the impression it is wired up somewhere.

**Suggested fix:** Delete `bench/demos/02-false-sharing/check_codegen.sh`. Optionally have the run_one.sh inline block call `bench/scripts/check_volatile_codegen.sh` directly instead of duplicating the logic.

**Severity:** Material


### M3 — `run_one.sh` does not check SMT state for demos 01, 03, 04

**Location:** `bench/scripts/run_one.sh`; cf. `bench/demos/02-false-sharing/false_sharing_pnl.cpp` lines 79–93 and `tools/prepare_bench.sh`.

**Observation:** SMT is enforced only for demo 02 — via `check_smt_off()` called from inside the binary. `run_one.sh` calls `set_governor_performance()` for all demos but has no SMT check. `prepare_bench.sh` checks SMT but is a separate manual step, not called from `run_one.sh`.

**Problem:** If SMT is enabled at capture time for demos 01, 03, 04, the benchmarks proceed silently. For demo 01, the sibling thread shares decode and execution units, contaminating IPC and branch-miss counter readings — both of which underpin the post's claims. For demo 03, GFLOPS numbers can be deflated by SMT resource contention. No script-level guard catches this.

**Suggested fix:** Add an `assert_smt_off()` function to `bench/scripts/lib.sh` (parallel to `set_governor_performance`) and call it at the top of `run_one.sh` before any demo-specific code.

**Severity:** Material


### M4 — `run_one.sh` does not check `/sys/devices/system/cpu/isolated` for demos 01, 03, 04

**Location:** `bench/scripts/run_one.sh`; `tools/perf_capture.sh` lines 42–53.

**Observation:** `perf_capture.sh` (demo 02 path) aborts if `/sys/devices/system/cpu/isolated` ≠ "1-7". For demos 01, 03, 04 the check is absent entirely — `run_one.sh` relies on `cset shield` at runtime.

**Problem:** `cset shield` migrates existing tasks away from the shielded cores at runtime but cannot prevent scheduler interrupts from the kernel's core-0 interrupt handler or timer ticks on non-isolated cores. If the machine was not booted with `isolcpus=4-7` (or equivalent), the cset shield provides weaker isolation than the post's methodology section claims. There is no warning when this is the case.

**Suggested fix:** Add a soft check (print warning, do not abort) in `run_one.sh` that reads `/sys/devices/system/cpu/isolated` and warns if cores 4-7 are absent, while still proceeding since cset is sufficient for most purposes. Make it a hard abort for demo 01 where perf counter readings matter.

**Severity:** Material


### M5 — `l1d.replacement` not captured in `perf_capture.sh`; `l1d_misses_per_op` always null

**Location:** `tools/perf_capture.sh` lines 90–99; `tools/parse_perf.py` lines 126–130.

**Observation:** `perf_capture.sh` captures `cache-misses,cache-references,instructions,cycles`. It does not include `l1d.replacement` or `L1-dcache-load-misses`. `parse_perf.py` tries to read `l1d.replacement` (fallback to `L1-dcache-load-misses`) and silently emits `null` when neither is present. All shipped demo 02 data therefore has `"l1d_misses_per_op": null`. `sanity_check.py` acknowledges this but uses `cache_miss_ratio` as a proxy.

**Problem:** If the demo 02 post cites per-op L1D miss rates, those numbers are absent from the captured data. The `cache_miss_ratio` proxy is an approximation (LLC misses / total cache references) and has different semantics from L1D replacement rate. Future authors adding new asserts or derived metrics against `l1d_misses_per_op` would always receive null.

**Suggested fix:** Add `-e l1d.replacement` to the `perf stat` event list in `perf_capture.sh` (verify the event name with `perf list | grep -i l1d` on the reference machine). Fall back to `L1-dcache-load-misses` if the AMD-specific event is unavailable.

**Severity:** Material


### M6 — `assemble_results_04.py` notes field hardcodes stale sweep parameters

**Location:** `bench/scripts/assemble_results_04.py` lines 109–110.

**Observation:** The `notes` field says `"Sweep: 8 log-spaced steps 100 kHz→25 MHz."` The actual capture in `run_one.sh` uses `--steps 12 --rate-to 50000000` (12 steps, 50 MHz ceiling). The shipped `04-spsc-queue.json` will contain the wrong step count and wrong upper-rate limit.

**Problem:** If the demo 04 post cites sweep parameters from the JSON notes field, it states 8 steps / 25 MHz when the actual data contains 12 steps / 50 MHz. This is a shipped factual error in the data file regardless of what the post prose says.

**Suggested fix:** Remove the hardcoded sweep parameters from the notes string. Instead derive them from the actual run data: `min/max offered_rate_hz` and `sum(1 for r in runs if r.get("mode") == "sweep")` per variant.

**Severity:** Material


### M7 — Demo 03: `gen_inputs()` duplicated between `benchmark.cpp` and `verify.cpp` (DRY violation)

**Location:** `bench/demos/03-simd-blackscholes/benchmark.cpp` lines 41–54 and `verify.cpp` lines 41–53.

**Observation:** Both TUs contain an identical `gen_inputs()` function: same RNG (`mt19937`, seed `0xCAFEBABE`), same five distributions, same size (`MAX_N` / `N = 1<<20`). `verify.cpp` comments explicitly that it uses "the same RNG seed" as `benchmark.cpp` — acknowledging the coupling.

**Problem:** If the input range, seed, or sample count changes in `benchmark.cpp`, `verify.cpp` must be updated manually. A stale `verify.cpp` would silently test a different input distribution from the one benchmarked, meaning the correctness check no longer validates the actual benchmark inputs.

**Suggested fix:** Declare `gen_inputs(float*, float*, float*, float*, float*, int64_t)` in a shared `inputs.h` in the demo directory and include it from both TUs.

**Severity:** Material


### M8 — Demo 04: wall-clock timing block triplicated (DRY violation)

**Location:** `bench/demos/04-spsc-queue/benchmark.cpp`:
- `run_lockfree_handrolled` lines 245–264
- `run_lockfree_boost` lines 325–344
- `run_mutex_condvar` lines 430–457

**Observation:** The 7-line `struct timespec t0/t1 + clock_gettime(CLOCK_MONOTONIC_RAW) + result.wall_ns_total +=` block is byte-for-byte identical in all three variant runners (inside the per-run loop).

**Problem:** Changing the wall-clock source (e.g., `CLOCK_MONOTONIC` → `CLOCK_BOOTTIME`), adding a field to `RunResult`, or fixing an off-by-one in the nanosecond arithmetic requires touching all three copies. With the current code volume this is manageable; with a fourth variant it becomes a maintenance liability.

**Suggested fix:** Extract into a free function `void accumulate_wall_time(RunResult& r, const timespec& t0, const timespec& t1)` called from all three loops.

**Severity:** Material


### M9 — Demo 04: producer/consumer handshake and pacing logic triplicated (DRY violation)

**Location:** `bench/demos/04-spsc-queue/benchmark.cpp` — `run_lockfree_handrolled`, `run_lockfree_boost`, `run_mutex_condvar`.

**Observation:** The `consumer_ready/start_signal` atomic handshake (~5 lines), the warmup drain wait (`warmup_consumed.load() >= ITEMS_WARMUP`), and the TSC pacing block (`while (__rdtsc() < next_release_cycles) { _mm_pause(); } next_release_cycles += period_cycles;`) are byte-for-byte identical in all three variant runners. The only variation between the producer measurement loops is the queue API call.

**Problem:** Any refinement to pacing (e.g., using `__rdtscp` instead of `__rdtsc` in the pacing spin), the warmup drain protocol, or the handshake must be applied to three separate code blocks. This was already identified as a pattern concern in earlier remediation work; it has not been extracted.

**Suggested fix:** Parameterise the variant logic as a template or lambda, and extract the shared outer scaffolding into a `run_spsc_variant<QueuePolicy>` template function. The queue API differences (`try_push`/`try_pop` vs `push`/`pop` vs condvar) can be expressed as policy methods.

**Severity:** Material


### M10 — Groups-building loop duplicated in `assemble_results.py` and `assemble_results_03.py` (DRY violation)

**Location:** `bench/scripts/assemble_results.py` lines 52–58 and `bench/scripts/assemble_results_03.py` lines 75–83.

**Observation:** Both scripts build a `groups` dict with identical logic: skip non-`"iteration"` rows, split `name` on `/`, extract `variant` and `n`, `setdefault(key, []).append(b)`. The only difference is the name-parsing function (`parse_bench_name()` vs inline split).

**Problem:** A new run_type, a change in how benchmark names are structured, or an additional grouping key must be applied in two places. As `assemble_results_0N.py` scripts proliferate with demo 5+, this multiplies.

**Suggested fix:** Extract `build_groups(benchmarks, parse_name_fn)` into `stats_utils.py` and import it from both scripts.

**Severity:** Material


### M11 — `run_one.sh`: no `/sys/devices/system/cpu/isolated` check; no SMT check; governor set but not pre-verified

*(This consolidates Focus Area 6 — auditing each precondition.)*

| Precondition | Check present? | Behaviour on failure |
|---|---|---|
| `CRUCIBLE_TURBO` derived | Yes (lines 45–58) | `exit 1` with message naming the fix ✓ |
| `/sys/.../isolated` matches expected | No (demos 01, 03, 04); yes (`perf_capture.sh`, demo 02) | Silent proceed for 3 of 4 demos |
| SMT disabled | No (demos 01, 03, 04); yes (binary check, demo 02) | Silent proceed for 3 of 4 demos |
| Governor is performance | Set + verified (`lib.sh`) | `exit 1` ✓ — but governor is SET rather than checked; a pre-existing performance governor would be overwritten silently |

**Problem:** The three missing checks (isolated, SMT) can allow contaminated data to be collected for demos 01, 03, 04 without any script-level rejection. See M3 and M4 for detailed impact per demo.

**Suggested fix:** Add `assert_smt_off` and `warn_if_not_isolated` to `lib.sh`, called unconditionally from `run_one.sh` before demo-specific branching.

**Severity:** Material (duplicate of M3+M4 aggregated for the script audit section)


---

## Minor

### N1 — Demo 04 mutex-condvar: `deq_ts == 0` items included in histogram unguarded

**Location:** `bench/demos/04-spsc-queue/benchmark.cpp`, lines 460–465.

**Observation:** After each mutex-condvar run, any `deq_ts[i] == 0` (item not consumed) is logged with `fprintf(stderr, "WARN: ...")` but `bin_run` is still called unconditionally. Since `deq_ts` is zero-initialised and `enq_ts[i] > 0`, the subtraction `0 - enq_ts[i]` underflows uint64_t to a large value that lands in the top bucket, inflating `top_bucket_count`.

**Problem:** In practice this should not occur in a correct run, but if the consumer exits early (e.g., due to the `producer_done_flag + queue empty` break path), the histogram is silently contaminated. The WARN provides observability but the data is still passed to `bin_run`.

**Suggested fix:** After logging the WARN, either `std::abort()` (strict) or skip the item in `bin_run` by checking for zero timestamps before computing latency.

**Severity:** Minor


### N2 — Demo 02: `check_smt_off()` silently swallows the check on kernels without SMT sysfs

**Location:** `bench/demos/02-false-sharing/false_sharing_pnl.cpp`, lines 79–82.

**Observation:** When `/sys/devices/system/cpu/smt/active` can't be opened (`!f.is_open()`), `check_smt_off()` returns silently. A user on a kernel compiled without CONFIG_SCHED_SMT would get no indication that the check was skipped.

**Suggested fix:** Print `"WARNING: /sys/devices/system/cpu/smt/active not found — SMT check skipped"` to stderr before returning. Not an abort since the kernel genuinely lacks SMT.

**Severity:** Minor


### N3 — `--machine-info` argv scanning is inconsistent across demos

**Location:** demo 01 `benchmark.cpp` lines 154–158; demo 02 line 232; demo 03 lines 144–148; demo 04 lines 567–570.

**Observation:** Demos 01 and 03 scan all argv positions for `--machine-info`. Demos 02 and 04 check only `argv[1]`. Demo 02 uses `std::string(argv[1])` (unnecessary heap allocation); demo 04 uses `std::string_view` (modern idiom). The scan-all approach in demos 01 and 03 would trigger `--machine-info` mode and exit if the flag appears as a later argument (e.g., after `--benchmark_filter`), which is unintuitive.

**Suggested fix:** Standardise on the demo 04 pattern: check only `argv[1]` using `std::string_view`.

**Severity:** Minor


### N4 — Demo 01: `BM_Sort_32M` absence of PerfCounters is uncommented

**Location:** `bench/demos/01-branch-prediction/benchmark.cpp`, lines 124–135.

**Observation:** `BM_Sort_32M` is the only benchmark in demo 01 that does not instantiate `PerfCounters`. The omission is intentional (sort cost is wall-time only, not branch-behavior), but there is no comment stating this.

**Suggested fix:** Add a one-line comment: `// PerfCounters omitted — this benchmark measures sort wall time, not branch behavior.`

**Severity:** Minor


### N5 — `machine_info.h`: `shell()` and `shell_multiline()` share duplicated popen boilerplate

**Location:** `bench/common/machine_info.h`, lines 15–57.

**Observation:** Both functions repeat the identical `FILE* fp = ::popen(cmd, "r"); while fgets; ::pclose(fp); trim trailing newlines` block. The only difference is the character escaping applied to the output.

**Suggested fix:** Extract a private `shell_capture(cmd)` that returns the raw trimmed string, then apply different escaping in `shell()` and `shell_multiline()`.

**Severity:** Minor


### N6 — `bench/tests/CMakeLists.txt` hardcodes a macOS SDK path

**Location:** `bench/tests/CMakeLists.txt`, lines 6–10.

**Observation:** The CMake workaround sets `CMAKE_OSX_SYSROOT` to `/Applications/Xcode.app/.../MacOSX14.2.sdk`. On any machine with a different Xcode version, SDK location, or on Linux, this path is wrong or irrelevant. The SDK is only needed on macOS and should be discovered dynamically.

**Suggested fix:** Replace the hardcoded path with `execute_process(COMMAND xcrun --show-sdk-path ...)` or remove the workaround if the underlying Xcode issue has been resolved.

**Severity:** Minor


---

## Per-focus-area summary

| Focus area | Verdict |
|---|---|
| 1. DRY across demos | Findings: M1 (demo 01 BM_Branchless), M7 (demo 03 gen_inputs), M8–M9 (demo 04 triplication), M10 (assembler groups loop), N5 (machine_info.h) |
| 2. Harness asymmetries within demos | Demo 01: BM_Sorted/BM_Unsorted symmetric; BM_Branchless structurally diverged (M1). Demo 02: padded/unpadded symmetric ✓. Demo 03: all four variants use identical run_bm framing ✓. Demo 04: timestamp placement and queue bounding now symmetric ✓ |
| 3. Defensive static_asserts | Demo 02: `sizeof/alignof PaddedStrategy`, `sizeof Strategy` all present ✓. Demo 04: `sizeof/alignof PaddedAtomic`, power-of-2 N all present ✓. Demos 01, 03: no layout assumptions requiring asserts. No missing critical asserts found. |
| 4. Volatile/atomic in demo 02 | `volatile double` used consistently on both `Strategy::pnl` and `PaddedStrategy::pnl` ✓. No hybrid usage found. CI assertion (`check_volatile_codegen.sh`) wired into CMake POST_BUILD ✓. Two redundant copies of the check script exist (M2). |
| 5. TSC and timing in demo 04 | `rdtscp_ordered` pattern (rdtscp + lfence) correct ✓. TSC stability flags (`constant_tsc`, `nonstop_tsc`) verified before calibration ✓. `percentile_convention: log2_bucket_midpoint` matches histogram.h implementation ✓. Top-bucket spillover warned and reported ✓. Sweep mode drift not monitored — hard-coded 0.0 (C2). |
| 6. Script robustness (run_one.sh) | CRUCIBLE_TURBO: checked, fail-loud ✓. Isolated CPUs: missing for demos 01/03/04 (M4). SMT: missing for demos 01/03/04 (M3). Governor: set-and-verified ✓. Script exits non-zero on all current checks ✓. |
| 7. parse_perf.py double-counting | Previous bug (real_time / iterations again) confirmed fixed. Current implementation divides real_time directly by `ops_per_iter = nthreads × N_ITERS × N_FILLS` ✓. Test suite (`test_parse_perf.py`) includes round-trip identity tests ✓. Demo 01 `branch_misses_per_op`: already per-element in C++, taken as-is — no double-counting ✓. Demo 03 IPC: ratio, no division issue ✓. `runs[]` `ns_per_op` per-call inconsistency noted separately (C1). l1d event not captured (M5). |
| 8. Idiom and style consistency | `--machine-info` parsing: inconsistent (N3). Wall-clock timing: identical across demo 04 variants (M8). Error-exit style: consistent use of `exit 1` with named fix ✓. `std::string_view` adopted in demo 04 but not back-ported (N3). |

---

## Items flagged for Opus triage

- **Requires recapture to confirm:** M6 (stale sweep notes — needs a fresh run to verify the JSON notes field against actual data). Recapture not required to confirm the code defect; the discrepancy is visible in the source alone.
- **Unverifiable from code alone:** C2 (sweep drift — TSC stability over a full sweep can only be confirmed on the reference machine). The code defect (hard-coded 0.0) is confirmed; the magnitude of actual drift is unknown.
- **Not covered by focus areas above, surfaced by general review:**
  - N6 (macOS SDK hardcoding in tests/CMakeLists.txt)
  - N5 (machine_info.h popen boilerplate DRY)
