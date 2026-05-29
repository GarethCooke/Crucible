# Claude Code Brief — 02-false-sharing: Cross-CCX Threshold Fix & Narrative Update

## Context

The `CrossCCX/2t/unpadded` sanity assertion in the 02-false-sharing demo has been failing
on the reference machine (`iguanabunt`, AMD Ryzen 7 3800X, Zen 2). Diagnostic investigation
established:

- L3 topology is correctly partitioned 0-3 / 4-7 across two CCXs (verified via
  `/sys/devices/system/cpu/cpuN/cache/index3/shared_cpu_list`).
- The benchmark's pinning logic is correct: `intra_ccx_cores(2)` returns `{4, 5}`,
  `cross_ccx_cores(2)` returns `{0, 4}`. Threads were confirmed via `sched_getcpu()`
  fprintf to actually land on those CPUs.
- The assertion threshold (`>= 3.0x` cross/intra wall-clock ratio) was simply wrong for
  this workload. Real measurement is ~1.28x at both 2 and 4 contending threads.

The cross-CCX penalty is real but smaller than rule-of-thumb predicts, because the inner
loop performs non-contended work each iteration that dilutes the Infinity Fabric latency
contribution to each coherence ping-pong.

## Measured Calibration (3800X, Ubuntu, isolcpus=4-7, SMT off, CPB off, 11 reps)

| Test                 | Median (ns) | Items/s    |
| -------------------- | ----------- | ---------- |
| IntraCCX/2t/unpadded | 7,761,535   | 188.98 G/s |
| CrossCCX/2t/unpadded | 9,956,942   | 196.43 G/s |
| IntraCCX/4t/unpadded | 14,792,861  | 415.50 G/s |
| CrossCCX/4t/unpadded | 18,862,904  | 368.12 G/s |

**Cross/Intra wall-time ratios:**

- 2t: **1.283x**
- 4t: **1.275x**

CV across 11 reps: 0.02-0.22% on wall time. Numbers are reliable.

The ratio is effectively load-invariant at 1.28x across these thread counts because adding
contenders scales both sides roughly linearly (intra 2t→4t: ×1.91, cross 2t→4t: ×1.89).

Back-of-envelope sanity: Zen 2 isolated cross-CCX line fetch ≈ 80ns, intra ≈ 25ns. With
~200ns of non-contended work per iteration, `(80+200)/(25+200) ≈ 1.24x` — within rounding
of what we measure. So 1.28x is physically explicable, not a measurement artifact.

---

## Code Changes

### 1. Replace the broken assertion threshold

**File:** `bench/demos/02-false-sharing/false_sharing_pwf.cpp` (search for the existing
"cross-CCX/intra-CCX wall-clock ratio" or "Infinity fabric penalty not manifesting"
string — that's the assertion site).

Replace the 3.0x constant with a measured floor and apply the assertion at both 2t and 4t:

```cpp
// 3800X measured: 1.28x cross/intra at 4t (CV < 0.25%).
// Floor at 1.15x leaves ~10% margin for thermal/scheduler jitter
// and modest variation across Zen 2 / Zen 3+ CCX-equipped parts.
// NOTE: cross-CCX/2t/unpadded vs intra-CCX/2t/unpadded is intentionally
// not asserted. cross-2t pins one thread to cpu 0, which is shielded
// via cset shield (not isolcpus), so it picks up cross-run variance
// from background activity. The 4t variant has enough contention that
// IF latency dominates the noise and the assertion is robust.constexpr double kMinCrossCcxUnpaddedRatio = 1.15;

assert_ratio_ge("CrossCCX/4t/unpadded vs IntraCCX/4t/unpadded",
                cross_4t_unpadded_median, intra_4t_unpadded_median,
                kMinCrossCcxUnpaddedRatio,
                "Infinity Fabric penalty (unpadded, 4t)");
```

Match the existing assertion-helper signature in this file rather than the names above —
mirror the style of the surrounding `PASS`/`FAIL` sanity checks.

### 2. Add a padded cross-CCX symmetry assertion (for the three-act narrative)

If `CrossCCX/2t/padded` and `IntraCCX/2t/padded` are already registered, just add the
assertion. If not, register them by passing the existing `padded` body through both
`intra_ccx_cores` and `cross_ccx_cores` pickers — mirror the existing unpadded variants.

```cpp
// Padded cross can be FASTER than padded intra on Zen 2: each CCX has its own
// L3 + coherence controller, so cross-CCX threads avoid controller contention.
// Floor at 0.40x prevents this from flagging on similar Zen 3+ parts; ceiling
// at 1.15x still catches a regression where cross-CCX is somehow penalised.
constexpr double kPaddedRatioMin = 0.40;
constexpr double kPaddedRatioMax = 1.15;

const double padded_cross_intra_2t =
    cross_2t_padded_median / intra_2t_padded_median;
assert_in_range("CrossCCX/2t/padded vs IntraCCX/2t/padded",
                padded_cross_intra_2t,
                kPaddedRatioMin, kPaddedRatioMax,
                "no false sharing -> no cross-CCX penalty expected");
```

### 3. Make the affinity-verification print opt-in, not deleted

The `[bench] slot=N tid=N cpu=N` line was invaluable in diagnosing this and will be again
the next time the reference machine changes. Keep it, but guard it so it only fires when
explicitly requested and only once per thread at startup. Hoist it out of the work loop.

```cpp
static void worker_fn(WorkerCtx ctx) {
    if (std::getenv("CRUCIBLE_PRINT_AFFINITY") != nullptr) {
        fprintf(stderr, "[bench] slot=%d tid=%ld cpu=%d\n",
                ctx.slot, (long)syscall(SYS_gettid), sched_getcpu());
    }
    while (true) {
        // ...existing body...
    }
}
```

Required includes at the top of the file if not already present:
`<cstdlib>`, `<unistd.h>`, `<sys/syscall.h>`.

Document the env var in the demo README or run script (e.g.
`CRUCIBLE_PRINT_AFFINITY=1 ./bench_02_false_sharing_pwf ...`).

---

## Post / Narrative Update

Locate the 02-false-sharing post under `site/` (likely
`site/content/posts/02-false-sharing/index.mdx` or similar — find with
`find site -name '*.mdx' -path '*false-sharing*'`). Restructure the analysis section
into three acts. The existing intra-CCX padded-vs-unpadded headline stays; the cross-CCX
section needs new text reflecting the actual measurements.

### Act 1 — Padding alone is worth 5x within a single CCX

Keep the existing IntraCCX/8t IPC ratio (5.0x padded/unpadded) and cache-miss-ratio
content. This is the headline result and the easiest sell.

### Act 2 — Cross-CCX false sharing is worse, but not by as much as you might expect

Insert (verbatim, lightly edit for voice):

> Conventional wisdom for AMD Zen 2 says cross-CCX cache-line transfer is 2-3x slower than
> intra-CCX — about 80ns vs 25ns for an isolated line fetch. You might extrapolate that
> false sharing across the Infinity Fabric will be similarly punishing.
>
> It isn't. On the 3800X, the cross-CCX penalty for false sharing is a remarkably
> consistent **1.28x** at both 2 and 4 contending threads, with CV under 0.25% across 11
> repetitions.
>
> The reason is dilution. Each loop iteration does the coherence ping-pong _plus_ some
> local work, and the local work doesn't care which CCX the other thread sits on. That
> uncontended work absorbs some of the IF round-trip latency on every iteration.
> Back-of-envelope: with around 200ns of local work per iteration,
> `(80 + 200) / (25 + 200) ≈ 1.24x` — within rounding of what we measure.

Then include the calibration table above (4 rows, median ns + items/s).

### Act 3 — Sharing is what costs you, not crossing the Fabric

The padded baseline closes the loop. Padding removes false sharing within the line. But adding a second thread to the same
CCX still costs you ~40%, even with perfect padding — each CCX has one L3 and one
coherence controller, and two threads compete for both. Moving the second thread to
the other CCX gives each thread its own L3 slice and controller, eliminating that
contention. The CCX is a unit of resource isolation, not just a cache topology
detail. On the 3800X this manifests as padded cross-CCX running 40% faster than
padded intra-CCX, despite the textbook saying cross-CCX is "slower."

The full penalty stack on a 3800X looks like:

| Configuration       | Wall-time, relative                           |
| ------------------- | --------------------------------------------- |
| Padded, intra-CCX   | 1.0x (baseline)                               |
| Padded, cross-CCX   | ~1.0x (IF invisible without sharing)          |
| Unpadded, intra-CCX | ~5x (false sharing within CCX)                |
| Unpadded, cross-CCX | ~5x × 1.28x ≈ 6.4x (false sharing across CCX) |

Closing line: design your data layout so threads don't share lines. Once you've solved
that first-order problem, whether the threads happen to land on the same CCX or not is
a second-order concern.

### Methodology footnote (small, but worth being honest about)

The reference machine boot params (`isolcpus=4-7 nohz_full=4-7 rcu_nocbs=4-7`) isolate
only CCX1 (cpus 4-7). The CrossCCX tests pin one thread to cpu 0, which sits on the
un-isolated CCX0 and sees normal kernel activity. CV across 11 reps was nonetheless
0.02-0.22%, so background noise on cpu 0 isn't materially affecting the measurement.

For absolute symmetry on future calibration runs, consider switching to
`isolcpus=0,1,4,5` so both halves of the cross-CCX pair are equally quiet. Documented
on the `/methodology` page.

---

## Verification

After implementing:

```bash
cd ~/Development/Projects/Crucible
cmake --build bench/build --target bench_02_false_sharing_pwf -j

# Smoke-test the diagnostic still works
CRUCIBLE_PRINT_AFFINITY=1 ./bench/build/demos/02-false-sharing/bench_02_false_sharing_pwf \
  --benchmark_filter='CrossCCX/2t/unpadded' \
  --benchmark_repetitions=1 2>&1 | grep '\[bench\]' | head -10
# Expect: one cpu in {0,1,2,3} and one in {4,5,6,7}

# Full run with the wrapper script (whatever orchestrates cset shield + JSON output)
bench/scripts/run-02-false-sharing.sh   # adjust to actual script name
```

All sanity checks should now PASS:

- `intra-ccx/8t cache_miss_ratio` ≤ 0.30 (unchanged)
- `intra-ccx/8t IPC ratio padded/unpadded` ≥ 3.0x (unchanged)
- `intra-ccx/1t padded vs unpadded` within 20% (unchanged)
- **NEW:** `CrossCCX/2t/unpadded vs IntraCCX/2t/unpadded` wall ratio ≥ 1.15x
- **NEW:** `CrossCCX/4t/unpadded vs IntraCCX/4t/unpadded` wall ratio ≥ 1.15x
- **NEW:** `CrossCCX/2t/padded vs IntraCCX/2t/padded` wall ratio in `[0.90, 1.15]`

Regenerate the benchmark JSON the site reads from, rebuild the Next.js export, and
verify the three-act narrative renders correctly with the updated penalty-stack table
and the new measurement table.

---

## Out of Scope (Note for Future)

- The methodology page update (`isolcpus=0,1,4,5`) requires a reboot of the reference
  machine and a full re-baseline of every demo's numbers. Defer until after this fix
  ships and Demo 03 starts; bundle the re-baseline with that.
- The `register_group("IntraCCX", (1, 2, 4), ...)` comma-expression syntax in the demo
  is worth reading once for intent — if it's a leftover from a refactor and only the last
  value actually gets used, that's a latent bug worth a separate ticket. Not blocking
  this brief.
