# Crucible — Demo 2 (false sharing) micro-edits before ship

Two prose additions to pre-empt sharp questions a careful reader will ask. Both are pure text changes in `site/src/posts/02-false-sharing.mdx` — no JSON, no code, no methodology page.

## Background

Two observations from review of the rendered post:

1. The `cache_miss_ratio` chart shows ~96% at both 2t and 4t (essentially identical), but IPC keeps falling from 0.21 to 0.11. A reader will ask "if miss rate plateaued, why did IPC keep dropping?" The answer matters and isn't currently in the post: the miss _rate_ saturates at ~100% (it can't go higher), but the _cost_ of each miss grows as more cores contend for the same line.

2. The wall-clock `ns/op` chart shows padded values halving as thread count doubles (2.85 → 1.42 → 0.71). A reader will ask "did individual operations get faster?" No — the chart shows aggregate-across-threads ns/op (system throughput), not per-thread latency. Per-thread latency is roughly constant. The framing matters because aggregate ns/op is the right metric for the "system loses 5× capacity" story, but the units need labelling.

## Tasks

### 1. Replace the commentary after the IPC and cache_miss_ratio CounterOverlay charts

Find the existing paragraph in the "Mechanism" section that comments on the IPC and miss-ratio charts. It currently reads something like:

```
Commentary on the numbers: at 1 thread the two layouts are indistinguishable
(no contention, ~26% miss ratio, IPC ~0.56). At 4 threads the unpadded layout
collapses to IPC 0.11 and a 96% miss ratio; the padded layout holds at IPC
0.55 and ~19% miss ratio.
```

(Exact wording may have drifted slightly during the 02b rewrite — find whatever paragraph currently sits between or after the two CounterOverlay tags.)

Replace with:

```
Two counters surface the contention. At 1 thread the layouts are
indistinguishable: IPC sits near 0.56, miss ratio near 28-30% (the steady-state
miss rate of the inner loop, dominated by the volatile reload of `pnl`). At 2
threads the unpadded miss ratio jumps to 96% — once two cores write to the
same line, nearly every access misses — and IPC collapses to 0.21. At 4
threads the miss ratio barely moves (still ~96%, already saturated), but IPC
drops further to 0.11. The signal there is subtle: the *rate* of misses can't
go much higher than ~100%, but the *cost* of each miss grows as more cores
compete for the same line. Padded holds at IPC ~0.55 and miss ratio under 30%
throughout — no shared line, no coherency traffic, no penalty.
```

### 2. Add a units-clarification sentence to the "Wall-clock cost" section

Find the opening paragraph of the "The wall-clock cost" section, which currently reads:

```
The counter collapse translates directly into wall-clock time. At 4 threads on
a single CCX, unpadded is 3.61 ns/op against padded's 0.71 ns/op — **a 5×
wall-clock penalty inside one core complex**, lockstep with the 5× IPC
collapse. The shared L3 doesn't rescue you — every false-sharing round-trip
still costs you instructions you could have been executing.
```

After this paragraph, before the `<ThroughputBars ... />` tag, add a new paragraph:

```
A note on the chart units: ns/op below is reported as wall-clock time per
operation aggregated across all participating threads — system throughput, not
per-thread latency. For padded this falls roughly linearly with thread count
because the work parallelises cleanly; for unpadded it stays approximately
constant (or worsens) because the threads cancel each other out via cacheline
ping-pong. Per-thread latency for padded sits near 2.85 ns/op across all
thread counts (the inner loop's architectural floor); the system-level number
falls because more threads share the wall-clock budget.
```

## Acceptance criteria

- The IPC/miss-ratio commentary distinguishes between _miss rate saturation_ and _miss cost growth_. The phrases "rate of misses can't go much higher" and "cost of each miss grows" both appear.
- The wall-clock section explicitly states ns/op is aggregate across threads, not per-thread.
- Build still succeeds: `cd site && npm run build`.
- No other changes — no chart components touched, no JSON edits, no methodology page edits.

## Out of scope

- Chart component changes (no switching to per-thread ns/op rendering).
- Any other section of the post.
- Other demos.
