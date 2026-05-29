# Crucible — bench DRY cleanup brief

**Pre-demo-5 brief 3 of 9. All bench-side DRY violations the review flagged, grouped because they share the same shape: code that didn't matter when there were two demos but multiplies maintenance cost as the series grows.**

---

## 1. Context

Seven findings, no behaviour change to shipped data. Pure refactoring to make the bench codebase easier to extend for demo 5 and beyond.

| # | Where | What | Severity |
|---|---|---|---|
| M1 | `01-branch-prediction/benchmark.cpp` | `BM_Branchless` duplicates `BM_impl` body | Material |
| M2 | three locations | redundant volatile-codegen check scripts | Material |
| M7 | `03-simd-blackscholes/{benchmark,verify}.cpp` | `gen_inputs()` duplicated between TUs | Material |
| M8 | `04-spsc-queue/benchmark.cpp` | wall-clock timing block triplicated | Material |
| M9 | `04-spsc-queue/benchmark.cpp` | handshake + warmup + pacing triplicated | Material |
| M10 | `assemble_results.py` + `assemble_results_03.py` | groups-building loop duplicated | Material |
| N5 | `machine_info.h` | `shell()` + `shell_multiline()` popen boilerplate | Minor |

Each section is its own self-contained refactor; they can be landed independently or in one PR.

---

## 2. M1 — Demo 01 `BM_Branchless` dedup

**File:** `bench/demos/01-branch-prediction/benchmark.cpp`, lines 75–94 (`BM_impl`) vs 101–120 (`BM_Branchless`).

`BM_Branchless` reimplements the entire perf-counter loop, the ops calculation, both `state.counters[...]` assignments, and `SetItemsProcessed`. Only differences:

- calls `sum_threshold_branchless` instead of `sum_threshold`
- uses `make_shuffled` unconditionally (vs the parameterised data shape in `BM_impl`)

### 2.1 Fix

Add a function-pointer or `bool branchless` parameter to `BM_impl`. Function-pointer is more idiomatic for benchmark dispatching:

```cpp
using ThresholdFn = int64_t(*)(const int*, size_t, int);

static void BM_impl(benchmark::State& state, ThresholdFn fn, bool shuffled) {
    // … existing BM_impl body, calling fn(...) instead of sum_threshold(...)
    // … shuffled flag controls make_sorted vs make_shuffled
}

// Then BM_Branchless becomes:
BENCHMARK_CAPTURE(BM_impl, Branchless, sum_threshold_branchless, /*shuffled=*/true)
    ->Arg(N);
```

The `BENCHMARK_CAPTURE` macro is Google Benchmark's first-class mechanism for parameterised benchmarks. CC should verify against the project's existing benchmark registrations whether `BENCHMARK_CAPTURE` or a manual `BENCHMARK_REGISTER_F`-style binding is the established style.

### 2.2 Recapture

Not required — the generated machine code for the parameterised version should be identical to the original (the function pointer becomes a constant after inlining). Spot-check with `objdump -d` on the new binary if paranoid.

---

## 3. M2 — Redundant volatile-codegen checks

Three locations check `>=2 movsd` in `worker_fn`:

1. `bench/scripts/check_volatile_codegen.sh` — CMake POST_BUILD-invoked. Canonical.
2. `bench/demos/02-false-sharing/check_codegen.sh` — never invoked by anything. Abandoned earlier version.
3. `bench/scripts/run_one.sh` lines 188–195 — inline re-implementation for demo 02 capture path.

### 3.1 Fix

- Delete `bench/demos/02-false-sharing/check_codegen.sh`. Confirm with `grep -r check_codegen.sh bench/ tools/ CMakeLists.txt` that nothing references it before deletion.
- In `run_one.sh:188–195`, replace the inline reimplementation with a call to `bench/scripts/check_volatile_codegen.sh <path-to-binary>`. The canonical script already takes the binary path as an arg (or should — CC to verify the script's CLI signature).

Net result: one canonical check, called from CMake at build time and from `run_one.sh` at capture time, sharing the same logic.

---

## 4. M7 — Demo 03 `gen_inputs()` dedup

**Files:** `bench/demos/03-simd-blackscholes/benchmark.cpp:41–54` and `verify.cpp:41–53`.

Identical RNG (`mt19937`, seed `0xCAFEBABE`), identical distributions, identical sample count. `verify.cpp` comments acknowledge the coupling ("the same RNG seed").

### 4.1 Fix

Create `bench/demos/03-simd-blackscholes/inputs.h`:

```cpp
#pragma once
#include <cstdint>

void gen_inputs(float* spot, float* strike, float* time,
                float* rate, float* vol, int64_t n);
```

Move the function definition to `bench/demos/03-simd-blackscholes/inputs.cpp` (linked into both targets) or keep it as a `static inline` in the header if the size warrants. The header approach is simpler for a single-call function; the `.cpp` approach prevents accidental duplicate definitions if linking gets complex.

Remove the local definition from both `benchmark.cpp` and `verify.cpp`. Include `inputs.h` in both.

Confirm `verify` still passes against the new shared implementation.

---

## 5. M8 + M9 — Demo 04 triplication

These two are tightly related: the same three functions (`run_lockfree_handrolled`, `run_lockfree_boost`, `run_mutex_condvar` in `04-spsc-queue/benchmark.cpp`) contain three independent triplicated blocks. Solve together.

### 5.1 M8 — wall-clock block

The 7-line block:

```cpp
struct timespec t0, t1;
clock_gettime(CLOCK_MONOTONIC_RAW, &t0);
// … producer/consumer work …
clock_gettime(CLOCK_MONOTONIC_RAW, &t1);
result.wall_ns_total += (t1.tv_sec - t0.tv_sec) * 1'000'000'000ULL + (t1.tv_nsec - t0.tv_nsec);
```

is byte-identical at lines 245–264, 325–344, 430–457.

Extract a free function:

```cpp
static inline void accumulate_wall_time(RunResult& r, const timespec& t0, const timespec& t1) {
    r.wall_ns_total += (t1.tv_sec - t0.tv_sec) * 1'000'000'000ULL +
                       (t1.tv_nsec - t0.tv_nsec);
}
```

Call site shrinks to three lines per variant.

### 5.2 M9 — handshake, warmup, pacing

The harder one. The producer/consumer handshake (~5 lines), warmup drain wait (~3 lines), and TSC pacing block (~5 lines) are identical across all three runners. Only the queue API call differs (`try_push`/`try_pop` vs `push`/`pop` vs condvar wait+notify).

Extract a `run_spsc_variant<QueuePolicy>` template. The policy provides three methods: `produce(item)`, `consume() -> item`, and any required setup/teardown:

```cpp
template <typename Policy>
RunResult run_spsc_variant(const RunConfig& cfg, Policy& policy) {
    RunResult result;
    std::atomic<bool> start_signal{false};
    std::atomic<bool> consumer_ready{false};
    std::atomic<size_t> warmup_consumed{0};

    std::thread consumer([&] {
        consumer_ready.store(true);
        while (!start_signal.load()) { _mm_pause(); }
        // … shared consumer logic, calls policy.consume()
    });

    while (!consumer_ready.load()) { _mm_pause(); }
    start_signal.store(true);

    // … shared producer logic with TSC pacing, calls policy.produce(item)

    consumer.join();
    return result;
}
```

Each variant becomes:

```cpp
RunResult run_lockfree_handrolled(const RunConfig& cfg) {
    HandrolledQueuePolicy policy(cfg);
    return run_spsc_variant(cfg, policy);
}
```

Three policy structs in the same TU, one shared template. CC should check that this preserves the exact behaviour of the current code — in particular:

- TSC pacing spin (`__rdtsc()` vs `__rdtscp()`) stays identical
- Memory ordering on the atomic handshake stays identical
- Any compiler hints (`__builtin_expect`, `[[likely]]`) preserved

The mutex-condvar variant is the trickiest because it doesn't naturally fit the "single produce/consume call" shape — the condvar coordination interleaves with the queue ops. CC may need to expose a `produce_batch`-style policy method to keep the mutex variant's batched behaviour. If the template shape becomes contorted, the alternative is a lambda-based design (variant logic as a `std::function<void()>` passed in). Document the choice in the PR.

### 5.3 Recapture

Behaviour change risk is non-zero with this refactor — the template's instantiation might generate slightly different code than the hand-written versions (extra moves, missed inlining, register allocation differences). Recapture demo 04 after the change and diff the JSON against pre-refactor: the latency distributions and throughput numbers should match within run-to-run noise (~1–2%). If they don't, the refactor changed behaviour; investigate.

---

## 6. M10 — Groups-building loop dedup

**Files:** `bench/scripts/assemble_results.py:52–58` and `bench/scripts/assemble_results_03.py:75–83`.

Both build a `groups` dict from a list of benchmark records: skip non-`"iteration"` rows, split `name` on `/`, extract `variant` and `n`, `setdefault(key, []).append(b)`. Only difference is the name-parsing function.

### 6.1 Fix

Add to `bench/scripts/stats_utils.py` (or create if it doesn't exist):

```python
def build_groups(benchmarks, parse_name_fn):
    """Group iteration records by (variant, n) via the supplied name parser."""
    groups = {}
    for b in benchmarks:
        if b.get("run_type") != "iteration":
            continue
        parsed = parse_name_fn(b["name"])
        if parsed is None:
            continue
        key = (parsed["variant"], parsed["n"])
        groups.setdefault(key, []).append(b)
    return groups
```

Both `assemble_results.py` and `assemble_results_03.py` import and call `build_groups`. The differences in name parsing are encapsulated in the `parse_name_fn` argument — each script keeps its own parser, just stops duplicating the grouping scaffolding.

When `assemble_results_04.py` joins the pattern (currently uses different grouping), or when demo 5's assembler is written, both get this for free.

---

## 7. N5 — `machine_info.h` popen dedup

**File:** `bench/common/machine_info.h:15–57`.

`shell()` and `shell_multiline()` repeat the identical popen/fgets/pclose/trim scaffolding. Only the output escaping differs.

### 7.1 Fix

Add a private helper at the top of the file:

```cpp
namespace detail {
inline std::string shell_capture(const char* cmd) {
    std::string result;
    FILE* fp = ::popen(cmd, "r");
    if (!fp) return result;
    char buf[4096];
    while (fgets(buf, sizeof(buf), fp)) result.append(buf);
    ::pclose(fp);
    while (!result.empty() && (result.back() == '\n' || result.back() == '\r')) {
        result.pop_back();
    }
    return result;
}
}  // namespace detail

inline std::string shell(const char* cmd) {
    return escape_for_json(detail::shell_capture(cmd));
}

inline std::string shell_multiline(const char* cmd) {
    return escape_multiline_for_json(detail::shell_capture(cmd));
}
```

Names of the escape functions are placeholders — match whatever the current code uses.

---

## 8. Out of scope

- **Adding new behaviour to the dedup'd code.** Pure refactoring. Any improvements to the wall-clock timing source, the RNG seed for demo 03, etc., are separate concerns.
- **Demo 02 dedup of padded-vs-unpadded harness.** Review explicitly notes these are symmetric and correct as-is. No change.
- **`assemble_results_04.py` joining the `build_groups` pattern.** Out of scope until 04's grouping logic is reviewed against the helper's signature; could be a follow-up.
- **N6 (macOS SDK hardcoding) and N3 (`--machine-info` argv inconsistency).** Folded into brief 9 (minor cleanup pass).

---

## 9. Acceptance checklist

### M1

- [ ] `BM_Branchless` defined via `BENCHMARK_CAPTURE` or equivalent dispatching pattern; no duplicated counter-loop body.
- [ ] Demo 01 binary builds; `BM_Branchless/N` benchmark still registered.
- [ ] Spot-check: new binary's `BM_Branchless` produces the same numbers (within noise) as the old one. Recapture not required.

### M2

- [ ] `bench/demos/02-false-sharing/check_codegen.sh` deleted; no references in the codebase.
- [ ] `run_one.sh:188–195` calls `bench/scripts/check_volatile_codegen.sh` instead of inlining the check.
- [ ] CMake POST_BUILD still runs the canonical check on every build.

### M7

- [ ] `bench/demos/03-simd-blackscholes/inputs.h` (and `.cpp` if used) created.
- [ ] `gen_inputs` removed from `benchmark.cpp` and `verify.cpp`; both include `inputs.h`.
- [ ] Demo 03 binary builds; `verify` runs and passes.

### M8 + M9

- [ ] `accumulate_wall_time` free function added; called from all three variant runners.
- [ ] `run_spsc_variant<Policy>` template added; three policy structs encapsulate per-variant queue logic.
- [ ] `run_lockfree_handrolled`, `run_lockfree_boost`, `run_mutex_condvar` each become single-call dispatch functions.
- [ ] Demo 04 re-captured after refactor; JSON values match pre-refactor within run-to-run noise (latency p50/p99 within 5%, throughput within 2%).
- [ ] Any divergence beyond noise documented and investigated before merge.

### M10

- [ ] `bench/scripts/stats_utils.py` exports `build_groups(benchmarks, parse_name_fn)`.
- [ ] `assemble_results.py` and `assemble_results_03.py` import and call `build_groups`; inline grouping loops removed.
- [ ] Both scripts produce byte-identical (or trivially-identical-modulo-ordering) JSON output compared to pre-refactor.

### N5

- [ ] `detail::shell_capture` private helper in `machine_info.h`.
- [ ] `shell()` and `shell_multiline()` thin wrappers calling `shell_capture`.
- [ ] `--machine-info` output on any demo binary unchanged from pre-refactor (diff machine_info JSON before/after).

### Cross-cutting

- [ ] Full `bench/` build passes after all changes.
- [ ] All existing tests pass.
- [ ] No shipped JSON file is invalidated; only demo 04 recapture is required (and only because of M8+M9's code-path change).
