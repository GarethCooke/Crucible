# Crucible — Demo 2 (false sharing) remediation brief

Read `BRIEF.md` and `crucible-handover.md` for project context. Demo 2 is shipped but blocked by integrity issues from the skeptical review pass. This brief addresses them; prose rewrite is out of scope and handled separately.

## Root causes

Most of the issues from review trace to two bugs and one methodology drift:

1. **`tools/parse_perf.py` produces physically impossible `ops_per_sec` and `ns_per_op` values.** The JSON shows 67 G ops/sec on a single thread (~17 ops per cycle at 3.9 GHz — exceeds Zen 2's dispatch ceiling by ~3×). Ratios between variants are roughly preserved, so the IPC-collapse story still reads, but every absolute number is ~190× off. The headline "341× gap" and the in-post data table both ride on these bogus numbers.

2. **The 1-thread baseline is artifactually slow.** Padded burst time is 2.92 ms at 1 thread, 1.67 ms at 4 threads, and 1.56 ms at 8 threads cross-CCX — for the same per-thread workload. With padding there is no shared resource being decontested; burst time should be approximately constant across thread counts. The implication is that any "vs 1 thread" claim in the post inherits the artefact, including the "near-perfect linear 8× scaling" framing (the data actually shows ~16× super-linear, which can't be real).

3. **Isolation method silently changed from the locked brief.** `BRIEF.md` commits to `isolcpus=4-7`; the current implementation uses `cset shield`. The post itself acknowledges cset is "best-effort" and that 2t cross-CCX results are contaminated — exactly the failure mode isolation was meant to prevent. Cross-CCX runs also use cores 0–3 which the brief never isolated.

Fix these three things, recapture all 12 variants, then the prose rewrite becomes tractable.

## Tasks

### 1. Fix `tools/parse_perf.py`

**Symptom.** `ns_per_op` for 1t intra-CCX unpadded reads 0.0149; the inner loop's physical floor is ~1.3 ns and the observed `real_time_ns` of 2.92 ms / 1,024,000 ops gives ~2.85 ns. The reported value is ~190× too low. `ops_per_sec` is the corresponding inverse and equally wrong.

**Likely cause.** The parser is dividing `real_time_ns` by `iterations × nthreads × N_ITERS × N_FILLS`. Google Benchmark's `real_time` field in the per-repetition JSON output is already normalised per state iteration, so the iterations factor is being applied twice. The factor of ~190 is consistent with a typical auto-chosen iteration count for a 3 ms benchmark at the default min-time of 0.5 s.

**Fix.** Aggregate ns/op should be:

```
ns_per_op = real_time_ns / (nthreads * N_ITERS * N_FILLS)
ops_per_sec = 1e9 / ns_per_op
```

where `real_time_ns` is the per-iteration value Google Benchmark already reports. Don't multiply by `iterations` anywhere — Google Benchmark has done that for you.

**Sanity check.** After the fix, 1t intra-CCX padded should land at ~2.85 ns/op aggregate, ~350 M ops/sec. 8t cross-CCX padded should land at ~0.19 ns/op aggregate, ~5 G ops/sec total. Anything quoting "G ops/sec" higher than a few G is still wrong.

**Add a unit test.** For each row in a parsed JSON, assert:

```
abs(ns_per_op * nthreads * N_ITERS * N_FILLS - real_time_ns) / real_time_ns < 0.001
```

This catches the entire class of bug. Run on the existing placeholder JSON: it will fail. Run on a corrected JSON: it should pass.

### 2. Fix the 1-thread (and 2-thread intra-CCX padded) baseline

**Symptom.** Padded burst time is non-monotonic in thread count:

| Config              | Burst (ms) |
| ------------------- | ---------- |
| 1t intra-CCX padded | 2.92       |
| 2t intra-CCX padded | 3.00       |
| 4t intra-CCX padded | 1.67       |
| 8t cross-CCX padded | 1.56       |
| 2t cross-CCX padded | 1.77       |

Per-thread workload is identical (1,024,000 ops). With padding, there is no shared resource being contended. Burst time should therefore be roughly constant. It isn't.

**Likely cause.** Insufficient warmup, combined with Google Benchmark's auto-chosen iteration count. For slow benchmarks the framework picks a low iteration count; if first-iteration cold-cache and page-fault costs are not amortised, the median is contaminated. At higher thread counts the same one-off costs are absorbed differently (more iterations, more parallel touches).

**Fix in `bench/demos/02-false-sharing/false_sharing_pnl.cpp`.**

- **Add an explicit warmup burst** before entering the measurement loop. One full barrier dance with workers, result discarded. This pre-touches every `fills[]` page on every participating core, warms the branch predictor, and resolves first-touch NUMA allocations.

- **Pin iteration count** with `->Iterations(N)` (suggest N=50, giving ~150 ms per repetition for the slowest unpadded 8t case). Removes Google Benchmark's dynamic choice as a variable. Re-test with N=20 and N=100 to confirm results converge.

- **Re-test.** Padded burst time should now be approximately constant across thread counts within ~5%. Specifically: 2t cross-CCX padded should not be 1.7× faster than 2t intra-CCX padded (currently 1.77 ms vs 3.00 ms — this is the single most physically implausible row in the data).

**If the anomaly persists after warmup and fixed iterations**, instrument and flag back before papering over. Plausible culprits in order of likelihood: NUMA first-touch on `g_padded` (it's a static array, so first thread to write it owns the page), CPU frequency variation across runs (verify with `/sys/devices/system/cpu/cpufreq/scaling_cur_freq` during a run), or barrier overhead at low party counts. Don't ship if it persists — the entire scaling narrative depends on the padded curve being flat.

### 3. Resolve core isolation

`BRIEF.md` locks `isolcpus=4-7` as non-negotiable methodology. The original implementation used `cset shield`, which is best-effort and contaminated the 2t cross-CCX results. **This is now resolved at the host level:** the reference machine has a second GRUB entry, "Ubuntu (benchmark — cores 0-7 isolated)", which boots with kernel params `isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7`. Cross-CCX runs span both CCXs, so all 8 cores are shielded. The dev-box-unusable cost is mitigated by booting the standard entry for development work and the benchmark entry only for capture runs.

**CC tasks:**

- **Remove all `cset shield` invocations** from `tools/perf_capture.sh` and any other capture/runner scripts. Replace with a precondition check that asserts `cat /sys/devices/system/cpu/isolated` returns `0-7`, fail with a clear error if it doesn't ("Boot into the benchmark GRUB entry — cores 0-7 must be isolated. See /methodology.").

- **Update `/methodology` page** to document the actual approach: dual GRUB entry, `isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7` for benchmark runs, full 8-core shielding. Drop any prior wording referring to `cset` or `isolcpus=4-7` specifically. The boot params are user-managed on the reference machine; the project repo doesn't need to ship a GRUB config.

- **Remove the apologetic caveats** in `02-false-sharing.mdx` about cset being best-effort and 2t cross-CCX being unreliable for that reason. (Note: the caveats may still be partly accurate after recapture — that's a prose call once real data is in. CC's job here is just to delete the cset-specific wording; the post's framing of 2t vs 4t cross-CCX reliability is part of the prose rewrite, out of scope for this brief.)

- **Document the precondition** in the demo's README and in `tools/perf_capture.sh --help`: capture must be run from the benchmark GRUB entry.

### 4. CI-assert the volatile codegen

The `false_sharing_pnl.cpp` header comment tells the reader to verify with `objdump | grep movsd`, but nothing in the build enforces it. If GCC ever changes its handling of `volatile double` (compiler-version drift, optimisation pass reordering, anything), the false-sharing effect collapses silently and every number in the post becomes meaningless.

Add a CMake post-build step that runs the objdump grep against `bench_02_false_sharing_pnl`, asserts ≥2 `movsd` instructions appear in the `worker_fn` inner block, and fails the build if absent. The exact grep is in the cpp file's header comment.

### 5. Recapture

After 1–4 land:

```bash
# (after rebooting into isolcpus= entry if Option A, or with cset if Option C)
cd bench && cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build --parallel
# objdump CI step runs automatically and must pass

for placement in intra-ccx cross-ccx; do
  for threads in 1 2 4 8; do
    for padded in 0 1; do
      ./tools/perf_capture.sh \
        build/demos/02-false-sharing/bench_02_false_sharing_pnl \
        $placement $threads $padded
    done
  done
done
# (skip combinations the cpp doesn't register: intra-ccx 8t, cross-ccx 1t)

python3 tools/parse_perf.py \
  --inputs <captured files> \
  --out site/src/data/perf/false-sharing-pnl.json
# Set captured_at to real ISO timestamp on the reference machine
```

User runs the capture step on the reference machine; CC's job is to produce the corrected scripts and verify the schema round-trips through the fixed parser.

## Acceptance criteria

- Parser unit test passes against the regenerated JSON.
- `ops_per_sec` for 1t case is in the 100s of M/s, not 10s of G/s.
- Padded burst time across thread counts varies by ≤5%.
- `objdump` CI step passes and is required for the build.
- `perf_capture.sh` aborts cleanly when not run from the benchmark GRUB entry (i.e. when `/sys/devices/system/cpu/isolated` is not `0-7`).
- All `cset shield` references removed from scripts and post.
- `/methodology` reflects the dual-GRUB-entry / `isolcpus=0-7` approach.
- New `false-sharing-pnl.json` exists with real `captured_at`, all 12 variants, captured from the benchmark GRUB entry.

## Out of scope

- Rewriting prose in `02-false-sharing.mdx`. Every quantitative claim in the post depends on what the real data shows — title, intra-CCX wall-clock ratio, "stays near 2.8% throughout," "200 ns of local work per iteration," "near-perfect linear 8× scaling." All of these get revisited in chat after the new JSON lands.
- Other demos.
- Schema changes. The JSON contract stays as in `BRIEF.md`.
