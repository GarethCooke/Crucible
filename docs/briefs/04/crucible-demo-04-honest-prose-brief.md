# Crucible — Demo 04 (SPSC) honest-prose pass

Companion to `crucible-demo-04-final-pass-brief.md`. The rerun with the extended sweep range is clean — schema, data integrity, sweep step count, and previous prose corrections all landed. The remaining work is prose-only.

Scope: three MDX edits to the load-sweep and throughput sections. No rerun. No C++ changes. The data file is unchanged.

## Why this revision

The 50 MHz × 12-step rerun surfaced a genuine physical property of the hand-rolled variant that the post's current framing flattens. The chart will show it, the prose currently doesn't account for it, and a careful reader comparing the two will notice the mismatch.

The three variants saturate via two different mechanisms:

- **Mutex** saturates at ~9 MHz because the consumer can't drain fast enough. Queue fills to capacity (q_depth = 1023), latency climbs to depth × consumer_period (~190 µs). Classical queueing behaviour.
- **Boost** saturates at ~28 MHz the same way: q_depth climbs to 198, latency to ~10 µs at p50.
- **Hand-rolled** never reaches that regime. At 50 MHz target, throughput caps at 14.7 M/s but q_depth stays at ~4 and p50 stays at 264 ns. The producer is bottlenecked by its own per-push cost (rdtscp + push + spin), not by consumer drain rate. The consumer empties the queue faster than the producer can fill it.

The post currently describes saturation as one unified mechanism ("latency scales as `queue_depth × consumer_period`... producing the steep climb visible on the right of the mutex curves") and then claims "the hand-rolled implementation saturates around 16 MHz" without distinguishing the two regimes. The chart will plainly show the handrolled p50 curve sitting flat near 132 ns across the entire range, with only a small step at 16 MHz. A reviewer sees "saturates around 16 MHz" next to a curve that visibly doesn't.

Two other items: a transient p99.9 spike at the 16 MHz transition point that the chart will show without explanation, and a discrepancy between saturated-mode throughput and peak sweep throughput for boost that the Throughput chart conceals.

## MDX changes — `site/src/posts/04-spsc-queue.mdx`

### Edit 1 — Load-sweep prose (lines 143–153)

Current:

> Each line shows p50, p99, and p99.9 across twelve log-spaced offered-load points from 100 kHz to 50 MHz. The mutex variant saturates first, around 9 MHz offered load — its consumer can't drain fast enough beyond that and the queue fills toward capacity. Once saturated, latency scales as `queue_depth × consumer_period` rather than per-op cost plus wake-up overhead, producing the steep climb visible on the right of the mutex curves.
>
> The lock-free variants stay flat much further. The hand-rolled implementation saturates around 16 MHz; Boost around 28 MHz. Their consumers spin on the producer's `tail_` store via cache coherence and proceed without kernel involvement, so they keep up until the producer's per-push cost itself becomes the bottleneck.

Replace with:

> Each line shows p50, p99, and p99.9 across twelve log-spaced offered-load points from 100 kHz to 50 MHz. There are two different saturation mechanisms visible on this chart, and they're worth separating.
>
> **Mutex saturates around 9 MHz the way classical queueing theory predicts.** The consumer can't drain fast enough, the queue fills toward its 1024-entry capacity, and latency climbs to `queue_depth × consumer_period` — about 190 µs once depth pins at the ceiling. The mutex p50 line above 9 MHz is a near-horizontal plateau because depth is also a near-horizontal plateau at capacity.
>
> **Boost saturates around 28 MHz by the same mechanism**, just further to the right because its consumer is faster. Queue depth climbs to ~200 items at the top of the swept range; p50 climbs to ~10 µs.
>
> **The hand-rolled variant doesn't saturate this way at all.** Throughput caps at ~14.7 M/s starting around 16 MHz offered load, but p50 stays near its 132 ns floor across the entire sweep — at 50 MHz target, p50 is still 264 ns and queue depth is still ~4. Its consumer drains items so quickly that the queue never deepens. The bottleneck is the producer side: each `try_push` plus the surrounding spin and timestamp costs more than the inter-arrival period the pacer is requesting, so the achieved rate caps at the producer's own throughput. Same outcome as the others — the variant can't keep up with the offered load — but expressed as a throughput ceiling rather than a latency wall.
>
> The practical implication is the same in all three cases: offering more than the system can sustain produces dropped or delayed items. The mutex and Boost variants signal it through latency that climbs by orders of magnitude. The hand-rolled variant signals it through a hard throughput cap with latency that barely moves. Either way, sizing the consumer below the actual offered load matters more than implementation choice.

### Edit 2 — Handrolled p99.9 transition spike

After Edit 1's prose, add as a new paragraph:

> One artefact worth naming: the hand-rolled p99.9 line has a single spike at the 16 MHz sweep point — about 42 µs, against a baseline of ~200 ns either side. This is the transition load where the producer occasionally hits queue-full and spins on `try_push` long enough to be counted in the tail; at lower loads the queue never fills, at higher loads the producer is consistently pacer-limited by its own cost and the queue stays small. The spike is reproducible at this offered rate but transient across the sweep — present at one point, gone at the next.

### Edit 3 — Throughput section reconciliation (after line 176)

The current Throughput chart uses `mode="saturated"`. For boost specifically, that's 14.9 M/s — but the same variant briefly reached 19.8 M/s at the top of the sweep, with the queue at intermediate depth rather than at capacity. The post doesn't acknowledge this.

After the current paragraph ending "The cost shows up as determinism, not rate." (line 176), insert:

> A nuance on the throughput numbers above: they reflect _steady-state_ behaviour with the producer flat-out and the queue at capacity. For Boost specifically, this slightly understates peak rate — the load sweep shows it transiently reaching ~19.8 M/s when the queue is at intermediate depth, before settling into the lower steady-state rate as the queue fills. The hand-rolled variant doesn't show this gap because its queue never reaches capacity (see the saturation discussion above). Mutex doesn't show it because its steady-state and transient rates are both bound by condvar wake-up cost, which doesn't vary with queue depth.

### Edit 4 — One small consistency fix

Line 233 (in the Takeaway) says:

> the scheduler cannot keep pace before the lock-free consumer can.

That sentence has a syntactic issue: "before the lock-free consumer can" — can what? The original parallel was presumably "the scheduler cannot keep pace [with the producer] before the lock-free consumer can [become saturated]" but it reads as a fragment.

Replace with:

> the scheduler can't keep pace with the producer long before the lock-free consumer reaches its own ceiling.

## Acceptance criteria

- The phrase "saturates around 16 MHz" no longer appears anywhere in the MDX as a claim about hand-rolled — replaced by the more precise "throughput caps at ~14.7 M/s starting around 16 MHz" framing.
- The two saturation mechanisms (depth-driven vs producer-cost-driven) are named separately in the load-sweep section.
- The p99.9 transient spike at the 16 MHz handrolled point is acknowledged in the prose, not left as an unexplained chart feature.
- The saturated-vs-sweep boost throughput gap is acknowledged in the Throughput section.
- No internal contradictions: the load-sweep prose, the load-sweep chart, the Throughput chart, and the Takeaway all tell the same story about each variant's failure mode.
- Lighthouse perf on the post page still ≥ 90.

## Out of scope

- Re-running anything. The data is correct and complete.
- Changing chart components. Throughput stays on `mode="saturated"`; the gap with sweep peak is acknowledged in prose rather than by switching data sources.
- Investigating _why_ boost's drain rate is queue-depth-sensitive. That's a separate (and possibly interesting) post about Boost's internals.
- Adding new charts. The load-sweep chart already shows everything Edits 1 and 2 describe; the prose just needs to match it.

## Notes for CC

- All four edits are pure prose. No code, no JSON, no chart component changes. Grep checks: after these edits, `grep -n 'saturates around 16' site/src/posts/04-spsc-queue.mdx` should return zero hits, and `grep -ni 'producer.*bottleneck\|producer-bound\|producer side' site/src/posts/04-spsc-queue.mdx` should return at least one.
- The numbers cited in the replacement prose (14.7 M/s, 264 ns, 200 µs, 19.8 M/s, 42 µs, etc.) all come from the existing `04-spsc-queue.json` — no rerun is needed, just reading the data file. Verify them against the JSON before committing so the prose tracks the actual numbers if anything has been rounded since this brief was written.
- Edit 1 is the substantive one. Edits 2, 3, 4 are smaller defensive additions.
