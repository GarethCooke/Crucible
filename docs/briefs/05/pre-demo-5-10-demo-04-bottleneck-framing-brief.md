# Crucible — Demo 04 prose: asymmetric-bottleneck framing

Companion to the pre-demo-5 review. One narrow MDX edit in the demo 04 post ("What happens as offered load rises" section) to make the asymmetric-bottleneck point upfront and to explain the Boost-vs-handrolled consumer-period gap honestly, rather than letting a skim-reader infer "handrolled is just faster" from the chart.

## Why

The current section opens with the latency-vs-load chart, then walks variant-by-variant through the saturation behaviour. The mechanism (`queue_depth × consumer_period`) is named correctly. Two things a skeptical reader will want made explicit are currently either buried or absent:

1. **The hand-rolled variant doesn't win at high load by being uniformly faster.** Its producer caps at 14.7 M/s — *below* Boost's 28 MHz saturation point. It wins on tail because its bottleneck moved sides: throughput ceiling on the producer rather than latency wall on the consumer. The current prose does say this ("the bottleneck is the producer side… expressed as a throughput ceiling rather than a latency wall") but it lives in the third paragraph, too far down for a chart-first reader. A reader who skims the chart and the first paragraph walks away with "handrolled is faster everywhere."

2. **Why the Boost consumer is materially slower than the hand-rolled consumer.** The current prose says only that Boost's consumer is faster than the mutex's; it says nothing about Boost vs handrolled. A reader who sees the 100× p99.9 gap at high load could reasonably ask "is this a Boost defect?" The honest answer (portable header-only vs hand-tuned for this machine — cache-line padding, ordering, template instantiation, mask vs modulo) belongs in the post.

## What to change

File: `site/src/posts/04-spsc-queue.mdx`
Section: "What happens as offered load rises"

### Change 1 — add framing paragraph immediately after the existing intro

Currently, the section opens (after the chart) with:

> Each line shows p50, p99, and p99.9 across twelve log-spaced offered-load points from 100 kHz to 50 MHz. There are two different saturation mechanisms visible on this chart, and they're worth separating.

Insert a new paragraph after this one and before the "Mutex saturates around 9 MHz…" paragraph:

> Two failure modes. Mutex and Boost fail by *latency wall*: queue fills toward capacity, residency time becomes `queue_depth × consumer_period`, p50 jumps by orders of magnitude. The hand-rolled variant fails by *throughput ceiling*: its producer caps at 14.7 M/s — below Boost's 28 MHz saturation point — and the queue never gets a chance to fill. Hand-rolled staying low at the right of the chart isn't because it's uniformly faster on every operation; its bottleneck moved sides. Same root cause in all three cases (consumer can't drain at the offered rate), three different surfaces it shows up on.

### Change 2 — extend the Boost paragraph with the consumer-period explanation

Current paragraph:

> **Boost saturates around 28 MHz by the same mechanism**, just further to the right because its consumer is faster. Queue depth climbs to ~200 items at the top of the swept range; p50 climbs to ~10 µs.

Replace with:

> **Boost saturates around 28 MHz by the same mechanism**, just further to the right because its consumer is faster. Queue depth climbs to ~200 items at the top of the swept range; p50 climbs to ~10 µs. The Boost consumer is roughly 3× slower than the hand-rolled one — the standard gap between a portable header-only library and ~50 lines tuned for one machine. `boost::lockfree::spsc_queue` templates on arbitrary `T` and is defensive about ordering. The hand-rolled variant pads `head_` and `tail_` to separate 64-byte cache lines (so the consumer's tail-load doesn't trigger coherence traffic from the producer's tail-write), picks `acquire`/`release` semantics with exactly one writer per atomic, uses a mask instead of modulo for power-of-two capacity, and assumes POD items. A 2-3× consumer-period gap between a portable lock-free ring and a hand-tuned one is the standard result in SPSC microbenchmarks, not a Boost defect.

### Change 3 — optional tidy of the hand-rolled paragraph

The third paragraph currently ends:

> …so the achieved rate caps at the producer's own throughput. Same outcome as the others — the variant can't keep up with the offered load — but expressed as a throughput ceiling rather than a latency wall.

With Change 1 in place, the "Same outcome as the others — expressed as throughput ceiling rather than latency wall" recap is redundant with the new framing paragraph. CC's call whether to trim. Two options:

- **Keep**: reads as a deliberate "see, this is what I said up top" landing. Fine.
- **Trim**: drop everything after "throughput." The framing paragraph already carries that point.

If trimming, the paragraph ends:

> …so the achieved rate caps at the producer's own throughput.

Either is acceptable. Default to keep if undecided.

## Acceptance criteria

- `site/src/posts/04-spsc-queue.mdx` builds cleanly (`cd site && npm run build` succeeds).
- The "What happens as offered load rises" section now leads with the failure-mode framing paragraph before the variant-by-variant walk.
- The Boost paragraph contains the consumer-period explanation (cache-line padding, ordering, template instantiation, mask vs modulo) and the "not a defect" framing.
- No other section of the post is modified.
- The chart and its caption are unchanged.
- The MDX renders correctly in dev (`npm run dev`) — backticks render as inline code, italics render correctly, no broken markdown.

## Out of scope

- Any change to the underlying benchmark data, JSON files, or chart component.
- Re-running benchmarks.
- Other sections of the post (sweep methodology, throughput, takeaway, methodology link).
- Anything in the methodology page or other demo posts.
- Adding new charts or supporting visuals.
