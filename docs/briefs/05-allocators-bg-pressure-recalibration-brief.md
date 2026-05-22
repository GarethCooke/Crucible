# Crucible — Demo 05: background-pressure re-calibration brief

Companion to `BRIEF.md`, `crucible-handover.md`, `05-allocators-brief.md`, and the first capture pass of `bench/demos/05-allocators/`. Lands on the `demo-5-allocators` feature branch; the post is still WIP on `main` via the teaser stub.

## Why this brief

The first capture (`05-allocators.json`, 30 runs, 5 May iter set) is clean — every acceptance check passes (`max ≥ p99.9` everywhere, calibration drift 0, sustained 1.00 MHz, no top-bucket overflow). But the data refutes the headline thesis. At 1 MHz offered load + 1 M/s background pressure on the same-CCX configuration:

| variant | p50 | p99 | p99.9 |
|---|---|---|---|
| cross-thread-malloc | 180 | 228 | 312 |
| freelist-return-queue | 220 | 244 | 360 |
| arena-batch-handoff | 172 | 228 | 296 |

Arena wins at every percentile through p99.9. Freelist is the slowest variant at every percentile. Malloc trails arena by ~5% on p99.9 and beats freelist there. The cross-CCX side run preserves the same ordering. The brief's required ≥2× p99.9 ratio between malloc and the pool variants is missing by a wide margin.

The pressure sweep tells us why. Malloc's p99.9 is essentially **constant** across two orders of magnitude of background pressure, including the no-T_bg baseline:

```
cross-thread-malloc:  bg=no bg  p99.9=296    bg=100k   p99.9=296
                      bg=1M     p99.9=312    bg=10M    p99.9=312
```

That insensitivity is diagnostic. The current T_bg loop on core 6 is not interfering with the producer's allocator state on core 4. glibc's default `MALLOC_ARENA_MAX` ≈ `8 × ncpu` gives each thread its own arena with its own lock and its own freelists. T_bg churns on its own arena; the producer's `new Order` never contends. The demo's premise — "background heap pressure stretches the malloc tail" — never gets to fire.

## The fix

Configure the environment such that T_bg and the producer share allocator state. The single highest-leverage change is `MALLOC_ARENA_MAX=1`, which forces glibc to use one arena for all threads. This is also a realistic production configuration: trading shops and other RSS-sensitive workloads commonly set it to control fragmentation and resident-memory footprint. Choosing it as the demo's baseline isn't cheating — it's the configuration where the cross-thread allocator question actually matters.

If `MALLOC_ARENA_MAX=1` alone doesn't produce ≥2× malloc-vs-pool p99.9 separation, escalate through additional levers (more live allocations, multi-threaded T_bg, larger size classes) until the picture surfaces, or stop and report.

## Approach: diagnostic ladder

Run each step as a single 1M-item paced capture (cross-thread-malloc + arena-batch-handoff only — skip freelist for the diagnostic to halve runtime). Compare p99.9 ratios. Don't move to the next rung until the current one is measured.

**Rung 1.** Existing binary, `MALLOC_ARENA_MAX=1` in env. No code change. Expected: malloc p99.9 grows substantially under T_bg pressure; arena stays roughly flat (the arena variant bypasses glibc entirely on the hot path).

**Rung 2.** If rung 1 shows separation but it's <2×, increase T_bg's live-allocation working set from 512 to 8192 and the live-vector cap to 16384. Increases fragmentation pressure on the shared arena.

**Rung 3.** If still <2×, add larger size classes. Replace the existing classes with `{64, 128, 512, 2048, 8192, 32768, 131072}` — the last class crosses glibc's default `M_MMAP_THRESHOLD` (128 KiB) and exercises the kernel mmap/munmap path on T_bg, which is a documented tail-latency contributor.

**Rung 4.** If still <2×, spawn 2 T_bg threads on cores 6 and 7 (both same-CCX). Each at half the target rate. Multiplies concurrent arena lock acquisition.

**Stop condition.** If rung 4 + `MALLOC_ARENA_MAX=1` + 1 M/s aggregate T_bg pressure still produces malloc p99.9 within 2× of the arena variant, stop and report. Do not proceed to a full capture. The demo's premise is dead on this hardware/libc combination and we pivot to option (b): rewrite the prose around the honest negative result.

## Scope

In scope:

- New CLI knob `--malloc-tuning {default,arena1}` on `bench_05_allocators` that sets `MALLOC_ARENA_MAX` via `mallopt(M_ARENA_MAX, 1)` (cleaner than env var; survives if user forgets the env). Default `arena1` for the headline capture; expose `default` for the diagnostic / future cross-reference.
- T_bg parameter knobs surfaced as CLI: `--bg-live-allocs N` (default 8192 after rung 2; ride 512 only if rung 1 succeeds without it), `--bg-size-classes {default,large,huge}` where `large` adds the 8K/32K/131K classes (used iff rung 3 needed), `--bg-threads N` (default 1; 2 iff rung 4 needed).
- Recording the chosen configuration in each run's JSON record under a new top-level field `pressure_config` with sub-fields `malloc_tuning`, `bg_live_allocs`, `bg_size_classes`, `bg_threads`. Captured per-run.
- `run_one.sh 05-allocators` updated to use the headline configuration that produced the ≥2× separation. Document the configuration choice in the demo README.
- Full re-capture of paced + sweep + cross-CCX at the chosen headline configuration. Discard the existing JSON; this is a replacement, not an addition.

Out of scope:

- Any change to the three allocator implementations themselves. The C++ for the variants is correct; only the surrounding configuration changes.
- Switching libc (musl, jemalloc-as-default) — that's a separate post.
- Switching the producer's arena via `mallopt(M_ARENA_TEST, ...)` or `arena_thread_freeres()` calls. The clean lever is `M_ARENA_MAX`.
- Changing the threading topology (T_p / T_c / T_bg core assignment is unchanged).
- Touching the C++ for the SPSC queue, the Order struct, the risk check, or the histogram. All unchanged.
- The MDX prose. Holds at the current state until the new capture is in hand.

## Specification

### CLI changes

```
bench_05_allocators <variant> --mode paced
    [--offered-rate-hz N]
    [--bg-pressure-hz N]
    [--malloc-tuning default|arena1]            # NEW, default arena1
    [--bg-live-allocs N]                        # NEW, default 8192
    [--bg-size-classes default|large|huge]      # NEW, default "default"; selection per rung
    [--bg-threads N]                            # NEW, default 1

bench_05_allocators <variant> --mode pressure_sweep
    [same flags as above]
```

Defaults shipped after this brief: `malloc-tuning=arena1`, `bg-live-allocs=8192`, `bg-size-classes=default`, `bg-threads=1`. These are the **provisional** headline configuration assuming rung 2 succeeds. Update defaults to whatever rung the diagnostic ladder actually stops at.

### Implementation notes

**`--malloc-tuning arena1`.** At process startup, before any allocation, call:

```cpp
#include <malloc.h>
if (cfg.malloc_tuning == MallocTuning::Arena1) {
    if (mallopt(M_ARENA_MAX, 1) != 1) {
        std::fprintf(stderr, "warning: mallopt(M_ARENA_MAX, 1) returned non-1; "
                             "tuning may not have taken effect\n");
    }
}
```

Verify it took effect by reading `/proc/self/maps` after producer + consumer + T_bg threads have started and confirming only one `[heap]` region exists (or the arena count via `malloc_stats()` to stderr in `--verbose` runs). Document the verification result in the README.

**T_bg restructure.** The existing T_bg loop (in `bench/demos/05-allocators/background_pressure.h`) needs three changes:

1. Live-allocation working set sized via the new CLI knob (currently hardcoded 512 / cap 2048).
2. Size-class table selected via the new CLI knob:
   - `default`: `{32, 64, 128, 256, 512, 1024}` (current behaviour).
   - `large`: `{64, 128, 512, 2048, 8192, 32768, 131072}`.
   - `huge`: future placeholder; specify when/if needed.
3. Multiple T_bg threads via the new CLI knob. When `bg_threads > 1`, divide `target_rate_hz` evenly; each thread uses its own PRNG seeded as `42 + thread_index`. Pin to cores `6, 7, ...` (still on CCX1 of the 3800X). If `bg_threads > 2`, the demo escapes the CCX — error out.

**Per-run JSON field.** Add a top-level `pressure_config` to each `runs[]` element:

```json
{
  "variant": "cross-thread-malloc",
  "mode": "paced",
  ...
  "pressure_config": {
    "malloc_tuning": "arena1",
    "bg_live_allocs": 8192,
    "bg_size_classes": "default",
    "bg_threads": 1
  },
  ...
}
```

Field is non-null on every demo-05 record. Demos 01–04 JSON unchanged.

### Diagnostic protocol

Before the full re-capture, CC runs a short diagnostic and reports back:

1. Build with the new CLI flags.
2. Run rung 1: `bench_05_allocators cross-thread-malloc --mode paced --bg-pressure-hz 1000000 --malloc-tuning arena1` and the same for `arena-batch-handoff`. 1 iteration × 1M items each. ~4 seconds wall-clock per variant. Report p99.9, p99, p50 for both.
3. If malloc p99.9 / arena p99.9 ≥ 2.0, **stop the ladder** — rung 1 is enough. Bake `malloc-tuning=arena1` + `bg-live-allocs=512` (existing default preserved) into defaults. Proceed to full re-capture.
4. Else, run rung 2 (add `--bg-live-allocs 8192`). Same measure. Same stop condition.
5. Else, run rung 3 (add `--bg-size-classes large`). Same measure. Same stop condition.
6. Else, run rung 4 (add `--bg-threads 2`). Same measure. Same stop condition.
7. Report all four rung results in the PR description regardless of which one fired. The diagnostic is part of the deliverable.

If rung 4 fails the stop condition, **do not run the full sweep**. Report and wait for the next brief (option b: prose-rewrite around the negative result).

### Verification before full re-capture

Once the headline configuration is locked in:

- Confirm `malloc_stats()` or `/proc/self/maps` shows the single-arena state with `arena1` tuning.
- Confirm T_bg achieves its requested rate within ±5% under the chosen configuration (pacing loop doesn't fall behind). Print the achieved rate to stderr in debug builds.
- Confirm producer + consumer affinity is still verified at thread start (existing assertion path unchanged).
- One smoke run of 1M items per variant before the full 5-iter capture. Compare its p99.9 against the diagnostic rung — they should match to within ~10%. Mismatch means a configuration drift somewhere; investigate before burning the full capture.

## Acceptance criteria

### Capture

- Diagnostic ladder run and reported. PR description includes the four rung results regardless of stop point.
- Chosen headline configuration produces malloc p99.9 / arena p99.9 ≥ 2.0 at 1 MHz offered + 1 M/s aggregate background pressure.
- Full re-capture written to `site/src/data/perf/05-allocators.json` (replaces existing) and `site/src/data/perf/05-allocators-cross-ccx.json` (replaces existing). Existing files are discarded — no merge.
- Every paced run is 5 iterations × 1M items per variant. Pressure sweep is 9 points × 1 iter × 1M items per variant per point. Cross-CCX is 5 iter × 1M items per variant.
- Acceptance checks unchanged from original brief: `max >= p99.9` everywhere, `calibration_drift_pct` within ±0.5, `ops_per_sec` within ±0.5% of 1 MHz, `top_bucket_count == 0` everywhere.
- Each run's JSON record includes the `pressure_config` block.

### Schema

- `pressure_config` block on every demo-05 record. Demos 01–04 unchanged.
- Cross-CCX JSON includes the same `pressure_config` block. Configuration identical to same-CCX headline except for thread placement.

### Documentation

- `bench/demos/05-allocators/README.md` updated with: the new CLI flags, the diagnostic ladder result, the chosen headline configuration, the rationale paragraph for `MALLOC_ARENA_MAX=1` (production realism, not cheating).
- `run_one.sh 05-allocators` updated to invoke the chosen configuration.

### Site

- No site or prose changes in this brief. The MDX rewrite waits for the new capture.
- The stub on `main` is untouched.

## Out of scope

- The MDX prose rewrite. Sequenced after this capture lands.
- Anything in `site/src/components/` (chart components, `<Benchmark>` wrapper). No changes.
- Anything in `bench/common/` (SPSC queue, histogram, stats, machine_info). No changes.
- Re-running demos 01–04. No changes.
- A "comparison of glibc tuning modes" sub-experiment in the post itself. The post chooses one configuration as its baseline; tuning-mode comparison is a future-work mention.

## Open items for CC to flag

1. **`mallopt(M_ARENA_MAX, 1)` return value.** glibc's `mallopt` may return 0 or 1 depending on libc version and prior allocation state. If it returns 0, the call took effect on some libc versions; on others it's a no-op silently. Verify via `/proc/self/maps` arena count after threads have started, regardless of the return value. Report the libc version (`ldd --version`) in the README.

2. **Order of `mallopt` vs first allocation.** `mallopt(M_ARENA_MAX, 1)` must run before any thread other than the main thread has called malloc. If C++ runtime allocates anything during static init (it does, e.g. for `std::cerr`), the call may be too late. If verification shows multiple arenas despite the `arena1` flag, move the `mallopt` call to a global constructor in a `.cpp` file that links before the rest of the demo, or set `MALLOC_ARENA_MAX=1` as a fallback env var in `run_one.sh`.

3. **T_bg's own latency.** With `MALLOC_ARENA_MAX=1`, T_bg's per-op latency under producer contention may grow enough that its pacing loop falls behind. If the achieved bg rate is <90% of target at the headline configuration, surface this and discuss whether to lower the target rate or accept the discrepancy and document it.

4. **Producer-side allocator inversion.** If `MALLOC_ARENA_MAX=1` causes the producer's `new Order` (variant 1) to occasionally serialise behind T_bg, the producer's own pacing may also fall behind. Watch `ops_per_sec` on variant 1; if it drops below 99% of the offered rate, the demo is now measuring pacing slippage rather than latency. Flag immediately.

5. **Arena variant under arena-1 tuning.** The arena variant bypasses glibc on the hot path but still uses `new` for its initial slab allocation. That happens once at startup, before measurement. Confirm it's not in the measured path. (It shouldn't be — startup is pre-warmup — but confirm.)

6. **Freelist variant under arena-1 tuning.** Same situation: the initial slab is glibc-allocated, but allocation during measurement is from the freelist. Confirm and document.

7. **Headline configuration's relationship to the demo's framing.** Once the configuration is chosen, the post's "Setup → Background heap pressure" section needs a paragraph that explains the `MALLOC_ARENA_MAX=1` choice. Don't bury it. Out of scope for this brief — for the prose-rewrite brief — but flag in the PR so it isn't forgotten.

## Notes for CC

- Budget ~1 day of CC time, weighted heavily toward the diagnostic ladder. The four rung runs are ~half an hour of wall-clock total. The full re-capture is ~2 hours wall-clock (same as the original capture). Most of the day is verification + README + run-script changes.

- The honest stop condition (rung 4 fails) is not a failure mode — it's data. If the demo's premise really is dead on this hardware/libc combination, that itself is publishable as a more rigorous negative result. Don't twist knobs past rung 4 to manufacture separation. If anything past rung 4 gets considered, surface it as a question, don't ship it.

- The diagnostic-first protocol exists because the original capture burned ~2 hours of wall-clock at the wrong configuration. Doing four cheap probes before the full re-run is cheap insurance. Resist the urge to skip straight to the full capture.

- Do not pre-write any prose. The chart components and MDX wait until the capture is in hand. The prose-rewrite brief (separate) will reference whatever the data actually shows post-recapture.
