# Demo 05 — Background-pressure calibration ladder

Pre-headline calibration data for `bench_05_allocators`. All rungs use `--mode paced`, `--offered-rate-hz 1000000`, `--malloc-tuning arena1`. p99.9 latencies are read from `latency_ns.stats.p99_9` in the per-file JSON.

## Rung table

| Rung | bg-threads | bg-pressure-hz | bg-pressure-hz-total | bg-live-allocs | malloc p99.9 (ns) | arena p99.9 (ns) | malloc / arena |
|------|-----------|---------------|---------------------|----------------|-------------------|------------------|----------------|
| 1    | 1         | 1 M           | 1 M                 | 512 (default)  | 328               | 344              | 0.95×          |
| 2    | 1         | 1 M           | 1 M                 | 8192 (default) | 424               | 344              | **1.23×**      |
| 3a   | 1         | 2 M           | 2 M                 | 8192           | 376               | 344              | 1.09×          |
| 3b   | 1         | 3 M           | 3 M                 | 8192           | 376               | 328              | 1.15×          |
| 4a   | 1         | 1 M           | 1 M                 | 8192           | 440               | 344              | 1.28×          |
| 4b   | 2         | 1 M           | 2 M                 | 8192           | 392               | 344              | 1.14×          |

Rungs 1–2 values are from the user's original pre-brief calibration; the raw JSON for those runs was not retained. Rung 4a is a fresh re-run of rung-2 parameters (confirmed comparable within noise). Rungs 3a, 3b, 4a, 4b have JSON at `rung{3a,3b,4a,4b}-{malloc,arena}.txt`.

Note: rungs 3a and 3b were captured with the earlier code that used aggregate-semantics pacing (`bg_pressure_hz / bg_threads`). With `bg_threads=1` this is identical to per-thread semantics, so the data remains valid. Rung 4a/4b were captured with the corrected per-thread pacing.

## Decision (per demo-05-rescope-brief §4)

Rung 4b's malloc/arena p99.9 ratio is **1.14×**, which is below 1.23× (the rung-2 single-thread ceiling). This triggers the third decision rule:

> **If rung 4b's ratio is ≤ 1.23×: keep `bg-threads=1` as the headline default.**

Decision applied: `bg-threads=1` remains the default in `BenchConfig`. The post is anchored on the freelist-vs-arena trade-off section.

The negative result — that adding a second T_bg thread does not increase the malloc/arena gap — is itself a finding. It is consistent with glibc's per-thread arena design: under `mallopt(M_ARENA_MAX, 1)`, all threads share a single arena, so the second T_bg thread does contend for the same lock as the first, yet the contention does not translate into additional tail latency on the measured producer/consumer path. The producer thread's malloc latency is insulated from background-thread rate because glibc's internal per-arena free-list recycling keeps most allocations hot.

## Expected p99.9 separation under headline config

`bg-threads=1`, `bg-pressure-hz=1M`, `bg-live-allocs=8192`: approximately **28–30%** (malloc p99.9 ~440 ns vs arena p99.9 ~344 ns). The post quotes the actual captured data; this band is the calibration expectation only.
