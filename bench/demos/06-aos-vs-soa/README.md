# Demo 06 — AoS vs SoA across the cache hierarchy

## Overview

Benchmarks three layout/codegen variants of a sum-reduction kernel across a
(N, K) grid, where N is the working-set element count and K is the number of
struct fields touched per element.

**Variants:**
- `aos-scalar` — Array-of-Structs, scalar (strided access defeats auto-vectorisation).
- `soa-scalar` — Struct-of-Arrays, vectorisation explicitly disabled via `__attribute__((optimize("no-tree-vectorize")))`. Isolates bandwidth advantage from SIMD advantage.
- `soa-autovec` — Struct-of-Arrays, auto-vectorised with `-O3 -march=native`. Stacks SIMD on top of bandwidth.

**Working-set sweep (N):**
```
{4 096, 8 192, 16 384, 32 768, 65 536, 131 072, 262 144, 524 288, 1 048 576}
```
At 128 B per AoS element: 512 KB → 128 MB.

**Hot-column sweep (K):**
```
{1, 2, 4, 8, 16}
```
Bandwidth-waste model: `64 / (K × 8)` at small K.  
K = 8 is the one-cache-line parity point.  
K = 12 was tested in the pilot but excluded from production — it sits on a smooth ramp between K = 8 and K = 16 with no inflection; see `bench/calibration-notes/06-aos-vs-soa-pilot/README.md §8.2`.

**Total cells:** 3 variants × 9 N values × 5 K values = 135 cells.

---

## Record layout

```cpp
// AoS: 128 bytes, alignas(64), 16 × double
struct alignas(64) RecordAoS { double f0..f15; };
static_assert(sizeof(RecordAoS) == 128);
static_assert(alignof(RecordAoS) == 64);

// SoA: 16 separate aligned_buffer<double> columns
// Each column buffer is 64-byte aligned (std::aligned_alloc(64, ...)).
// Assertion fires at construction if alignment is not satisfied.
```

**`aligned_buffer<T>` choice:** Preferred over `std::vector<double>` with a
custom deleter because it gives an unambiguous invariant (64-byte alignment
guaranteed at the type level) and `assert(reinterpret_cast<uintptr_t>(data) % 64 == 0)`
fires immediately at construction if the allocator disagrees.

---

## Codegen verification

Run after building:

```bash
# Via main binary --verify-codegen flag (uses /proc/self/exe)
./bench/build/demos/06-aos-vs-soa/bench_06_aos_vs_soa aos-scalar --verify-codegen

# Via standalone verifier
./bench/build/demos/06-aos-vs-soa/verify_06_aos_vs_soa \
    ./bench/build/demos/06-aos-vs-soa/bench_06_aos_vs_soa
```

**Expected output** (paste here after first reference-machine run):

```
  [PASS] scan_aos (aos-scalar)
         strided 128 B access must NOT emit ymm packed-double ops
  [PASS] scan_soa_scalar (soa-scalar)
         no-tree-vectorize must suppress ymm packed-double ops
  [PASS] scan_soa_autovec (soa-autovec)
         auto-vectorised column loop MUST emit ymm packed-double ops

Codegen verification PASSED
```

*(To be updated after headline capture on the 3800X.)*

**What the check looks for:**
- `scan_aos`: no `vaddpd ymm` / `vmovapd ymm` (strided 128 B stride is not SIMD-vectorisable).
- `scan_soa_scalar`: no `ymm` packed-double instructions (no-tree-vectorize pragma in effect).
- `scan_soa_autovec`: presence of `vaddpd ymm` / `vmovapd ymm` (compiler emitted AVX2 for the column loop).

`vmovsd` / `vaddsd` (xmm scalar double) are allowed in all variants.

---

## Warmup

500 ms wall-clock or 100 iterations of the kernel, whichever is shorter, per
(variant, N, K) cell. The cset shield establishes a clean cache state before
each cell; warmup ensures the steady-state resident set is loaded before timing
begins (avoiding cold-cache distortion on the first measurement iteration).

---

## Sweep ordering in `run_one.sh`

Outer loop: variant. Middle loop: N descending. Inner loop: K.

Rationale: descending N means each warmup walks into a smaller working set than
the previous cell's measurement. This avoids the "previous cell's tail still
resident" scenario where a large-N DRAM-bound cell leaves data in L3 that
shortcuts the subsequent smaller-N cell's warmup. K ordering is arbitrary.

---

## Affinity and isolation

- Benchmark thread pinned to core 4 (CCX1) via `taskset -c 4` in `run_one.sh`.
- The binary verifies this with `sched_getcpu()` at startup; mismatch aborts.
- `cset shield --cpu=4-7` is active for the duration of the run.
- `sudo cset shield --reset` is called at the start of `run_one.sh` to clear
  any stale shield from a previous session (demo 5 surfaced a PID-1 affinity
  bug when the shield was not reset between sessions).

---

## JSON schema (per-run object)

```json
{
  "variant":              "aos-scalar",
  "n":                    1048576,
  "k":                    1,
  "struct_size_bytes":    128,
  "struct_field_count":   16,
  "field_type_bytes":     8,
  "access_pattern":       "sequential",
  "kernel":               "sum_reduction",
  "iterations":           5,
  "items_measured":       1048576,
  "items_warmup":         0,
  "warmup_ms":            500,
  "ns_per_op":            { "median": 5.24, "min": 5.18, "p99": 5.31, "iqr": 0.09 },
  "ops_per_sec":          190839700,
  "llc_misses_per_op":    0.123456,
  "l1d_misses_per_op":    null,
  "instructions_per_cycle": 1.82,
  "calibration_drift_pct": 0.0012,
  "transparent_hugepage": "madvise",
  "captured_at":          "2026-05-23T12:00:00Z"
}
```

`ns_per_op` is **per Record element scanned** (not per field-touch, not per
byte). This matches the units convention in demos 1–5 after the pre-demo-5
`ns_per_op` units fix. The round-trip identity `ops_per_sec × ns_per_op.median
/ 1e9 ∈ [0.999, 1.001]` must hold.

`l1d_misses_per_op` is always `null` in the current implementation because
`l1d.replacement` is not in `perf_wrapper.h`. Add it to the `CacheCounters`
struct in `benchmark.cpp` once the fallback event name (`L1-dcache-load-misses`)
is confirmed available on the reference machine.

---

## Building

```bash
cmake -B bench/build -S bench -DCMAKE_BUILD_TYPE=Release
cmake --build bench/build --target bench_06_aos_vs_soa verify_06_aos_vs_soa
```

Or clean build:

```bash
cmake --build bench/build --clean-first
```

---

## Running a single cell (manual)

```bash
taskset -c 4 ./bench/build/demos/06-aos-vs-soa/bench_06_aos_vs_soa \
    aos-scalar --n 1048576 --k 1 --iterations 5
```

## Running the full sweep

```bash
CRUCIBLE_TURBO=off ./bench/scripts/run_one.sh 06-aos-vs-soa
```

Output: `site/src/data/perf/06-aos-vs-soa.json`
