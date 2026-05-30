# Crucible — Demo 04 (SPSC) throughput-attribution fix

Companion to `crucible-demo-04-honest-prose-brief.md`. That pass separated the two saturation mechanisms in the load-sweep section. This one finishes the job: it fixes a contradiction it left behind in the **Throughput** section (hand-rolled and Boost ceilings attributed to the same cause when they're opposite), and clears up two reader-tripping spots that flow from the same root — the offered-load-vs-achieved-rate ambiguity at "28 MHz", and the under-explained p99.9 spike paragraph.

Scope: three prose edits to `04-spsc-queue.mdx` — the Throughput paragraph, a one-clause clarification at the "28 MHz" mention, and a rewrite of the p99.9-spike paragraph to add colour on what the paced producer is physically doing. No rerun. No C++ changes. No chart changes. The data file is unchanged.

## Why this revision

The Throughput section currently says hand-rolled and Boost are both "limited by the producer's per-iteration cost (timestamp, `try_push`, spin) rather than anything queue-implementation-specific." That is true for hand-rolled and false for Boost, and the sentence immediately after it proves the contradiction: "Boost runs with its queue near capacity at saturation." A near-full queue is the signature of a *consumer*-bound system. A system cannot be producer-limited and carry a backed-up queue at the same time — if the producer were the bottleneck the queue would drain empty (which is exactly what the post says hand-rolled does).

The contradiction also points the other way, at the load-sweep section the previous pass wrote. That section states "the Boost consumer is roughly 3× slower than the hand-rolled one." If Boost's consumer is 3× slower *and* its saturated queue sits near capacity, then Boost's throughput ceiling **is** queue-implementation-specific — it's set by Boost's consumer drain rate. So the Throughput paragraph contradicts the sweep section as well as itself.

The numbers are all fine and no rerun is needed. The 14.7 M/s (hand-rolled) and 14.9 M/s (Boost) near-match is a **coincidence**: hand-rolled's number is its *producer* loop rate, Boost's is its *consumer* drain rate, and they happen to land within 1.4% of each other. The current prose reads that coincidence as evidence of a shared cause, which is the error. The fix is to attribute each ceiling to the correct side and name the match as coincidental.

A reader who has just read the sweep section ("two different saturation mechanisms... worth separating") and then reaches the Throughput section ("both limited by the same producer cost") sees the two sections disagree. The earlier honest-prose pass set up the distinction; this pass carries it through to the one place that still flattens it.

There's also a smaller clarity issue feeding the same confusion: the load-sweep section says Boost "saturates around 28 MHz" while the Throughput section caps it at 14.9 M/s, and nothing tells the reader these are different axes (offered load requested vs throughput achieved). One clause fixes it.

Finally, the p99.9-spike paragraph has a related muddle. It explains the 16 MHz spike with "at lower loads the queue never fills, at higher loads the producer is consistently pacer-limited by its own cost and the queue stays small" — which invites the obvious question: if the queue is fine below *and* above, why is the middle worse? The phrase "pacer-limited by its own cost" is itself garbled (a producer is limited by the pacer *or* by its own cost, not "pacer-limited by its cost"). The missing concept is **burstiness**: the producer's output is smooth below the knee (gapped) and smooth above it (gapless flat-out), and bursty only *at* the knee, where the requested rate and the producer's per-push cost are neck-and-neck and jitter flips it between waiting and firing catch-up bursts. Queue-depth tails are driven by short-term arrival variance, not mean rate, so the burstiest regime — the knee, not the top of the sweep — is where the tail spikes. The paragraph states the conclusion ("transient across the sweep") without the load-bearing mechanism, and the fix is to add colour on what the producer is actually doing across the three regimes.

## MDX changes — `site/src/posts/04-spsc-queue.mdx`

### Edit 1 — Throughput paragraph (the contradiction)

Current (the paragraph beginning "Saturated throughput: the producer runs flat-out…"):

> Saturated throughput: the producer runs flat-out with no pacing. Hand-rolled and Boost cap at near-identical rates — 14.7 M/s and 14.9 M/s respectively, within 1.4%. Both are limited by the producer's per-iteration cost (timestamp, `try_push`, spin) rather than anything queue-implementation-specific. The latency distribution is what separates them under load (see the histograms above): Boost runs with its queue near capacity at saturation, hand-rolled with its queue near empty, so an item resident in Boost's queue waits ~200× longer end-to-end. Same throughput, very different residency.

Replace with:

> Saturated throughput: the producer runs flat-out with no pacing. Hand-rolled and Boost cap at near-identical rates — 14.7 M/s and 14.9 M/s respectively, within 1.4% — but for opposite reasons, and the near-match is a coincidence. Hand-rolled is **producer-bound**: its consumer drains faster than the producer can push, the queue stays near empty, and the ceiling is the producer's own per-iteration cost (timestamp, `try_push`, spin). Boost is **consumer-bound**: its consumer is the ~3× slower one (see the load-sweep section above), so the queue fills, `try_push` starts failing and spinning, and the producer is throttled down to Boost's consumer drain rate. The 14.7-vs-14.9 agreement is two unrelated numbers — one producer rate, one consumer rate — happening to land close together, not evidence of a shared bottleneck. That difference is exactly what the queue-depth gap shows: Boost runs with its queue near capacity at saturation, hand-rolled with it near empty, so an item resident in Boost's queue waits ~200× longer end-to-end. Same throughput, very different residency — and very different reason for the ceiling.

### Edit 2 — Offered-load vs achieved-rate clarification

In the load-sweep section, the sentence introducing Boost's saturation point currently reads:

> **Boost saturates around 28 MHz by the same mechanism**, just further to the right because its consumer is faster.

Append one clause so the 28 MHz (offered load, an input) doesn't read as in tension with the 14.9 M/s (achieved throughput, an output) in the Throughput section:

> **Boost saturates around 28 MHz by the same mechanism**, just further to the right because its consumer is faster. (That 28 MHz is *offered* load — the rate the pacer requests; it's higher than the ~14.9 M/s Boost actually delivers at saturation, because past the saturation point the producer spends its time blocked on a full queue rather than pushing items through.)

### Edit 3 — Spike paragraph: producer colour and burst mechanism

In the load-sweep section, the paragraph beginning "One artefact worth naming: the hand-rolled p99.9 line has a single spike at the 16 MHz sweep point…" currently reads:

> One artefact worth naming: the hand-rolled p99.9 line has a single spike at the 16 MHz sweep point — about 42 µs, against a baseline of ~200 ns either side. This is the transition load where the producer occasionally hits queue-full and spins on `try_push` long enough to be counted in the tail; at lower loads the queue never fills, at higher loads the producer is consistently pacer-limited by its own cost and the queue stays small. The spike is reproducible at this offered rate but transient across the sweep — present at one point, gone at the next.

Replace with:

> One artefact worth naming: the hand-rolled p99.9 line has a single spike at the 16 MHz sweep point — about 42 µs, against a baseline of ~200 ns either side. To see why it lands here and nowhere else, it helps to watch what the paced producer is actually doing as offered load rises, because it isn't emitting a uniform stream — it works to a schedule, and the way it meets that schedule changes across the sweep. Well below saturation, each push takes its small fixed cost and the producer then waits out the rest of the requested interval before the next one: a steady, gapped metronome, and the consumer clears every item long before its successor arrives. Well above saturation, the schedule asks for items faster than the producer can physically emit them, so the pacing wait never fires and the producer free-runs flat out — a steady, gapless stream at its ~14.7 M/s ceiling, which the still-faster consumer keeps drained to a few items deep.
>
> The 16 MHz point is neither. It sits right on that ~14.7 M/s ceiling — the one rate where the requested period and the producer's per-push cost are neck-and-neck — so small timing jitter keeps flipping the producer between "momentarily ahead, wait a few nanoseconds" and "momentarily behind, fire the next pushes back-to-back to catch up." Its output stops being smooth and clusters into short bursts, and a burst leaves no pacing gaps for the consumer to recover in, so any consumer hiccup lets residency build — and on a rare alignment it builds far enough that `try_push` finds the queue full and spins. Because the enqueue timestamp is taken before `try_push`, that spin is counted in the item's end-to-end latency: the 42 µs spike. So the queue isn't filling "more at low load than high load" — it fills only at the boundary, where the producer's output is burstiest: smooth on both sides, bunched in the middle. Reproducible at this offered rate but metastable — a resonance right at the saturation knee that the coarse twelve-point sweep happens to catch at one point and miss on either side.

The rewrite (a) adds the producer colour Gareth asked for — the three regimes of producer behaviour, with the burst-at-the-knee picture made explicit; (b) replaces the garbled "consistently pacer-limited by its own cost" with the cost-ceilinged free-running description of the high-load regime; (c) keeps every number unchanged (42 µs, ~200 ns, 16 MHz, 14.7 M/s); (d) keeps the metastability hedge.

## Acceptance criteria

- The Throughput paragraph no longer claims hand-rolled and Boost are limited by the same cause. `grep -ni 'both are limited by the producer' site/src/posts/04-spsc-queue.mdx` returns zero hits.
- The Throughput paragraph names hand-rolled as producer-bound and Boost as consumer-bound. `grep -ni 'producer-bound' site/src/posts/04-spsc-queue.mdx` and `grep -ni 'consumer-bound' site/src/posts/04-spsc-queue.mdx` each return at least one hit.
- The 14.7-vs-14.9 match is described as coincidental, not as a shared bottleneck.
- The load-sweep section distinguishes offered load (28 MHz) from achieved throughput (~14.9 M/s) at the Boost saturation mention. `grep -ni 'offered.*load' site/src/posts/04-spsc-queue.mdx` returns the new clause among its hits.
- The spike paragraph no longer contains the garbled "pacer-limited by its own cost." `grep -ni 'pacer-limited by its own cost' site/src/posts/04-spsc-queue.mdx` returns zero hits.
- The spike paragraph describes the producer's behaviour as bursty *at the knee* and smooth on either side. `grep -ni 'burst' site/src/posts/04-spsc-queue.mdx` returns at least one hit, and the prose names all three regimes (gapped below, gapless flat-out above, bursty at the knee).
- No internal contradictions: the load-sweep section's "two different saturation mechanisms" framing, its "Boost consumer is roughly 3× slower" statement, and the Throughput section all attribute Boost's ceiling to consumer drain rate and hand-rolled's to producer cost. They tell one consistent story.
- The numbers (14.7 M/s, 14.9 M/s, ~3×, ~200×, 28 MHz, 42 µs, ~200 ns spike baseline, 16 MHz) are unchanged — this is an attribution and clarity fix, not a re-measurement.
- Lighthouse perf on the post page still ≥ 90.

## Out of scope

- Re-running anything. The data is correct and complete; this is a prose-attribution fix only.
- The transient-peak nuance (19.8 M/s settling to 14.9 M/s) added by the prior honest-prose pass. That paragraph is correct and stays as-is — it's about steady-state vs transient *for Boost specifically*, a different point from the producer-vs-consumer attribution this brief fixes. Do not merge or rewrite it.
- Changing chart components or the data source the Throughput chart reads (`mode="saturated"`).
- The mutex variant's throughput prose (~5.7 M/s, 2.6×). It's already correct and consumer-bound by condvar wake-up cost; leave it.
- Investigating *why* Boost's consumer drains slower than the hand-rolled one beyond the existing one-line explanation (portable/defensive vs hand-tuned). That stays a one-liner; a deeper dive is a separate post, as the prior brief already noted.

## Open items for CC to flag

- If a prior pass has already reworded the Throughput paragraph since this brief was written and the "both are limited by the producer" sentence is gone, verify the producer-bound/consumer-bound distinction is present and correct; if it is, skip Edit 1 and note it. Do not re-apply on top of a correct version.
- If the load-sweep section's "Boost consumer is roughly 3× slower" sentence has been removed or changed, the cross-reference in Edit 1 ("see the load-sweep section above") needs to point somewhere real — flag it rather than leaving a dangling reference.
- **Verify the pacer mechanism before publishing Edit 3's burst story.** The catch-up-burst description assumes the producer paces against an *absolute schedule* (deadlines for items pile up in the past when it falls behind, so it fires back-to-back to catch up). Read the pacing code in `run_variant` (or wherever the paced producer loop lives in `bench/demos/04-spsc-queue/benchmark.cpp`). If it instead does a fixed sleep/spin *between* pushes (relative pacing), it would not generate catch-up bursts the same way and the spike's mechanism is different — **stop and flag** rather than shipping a mechanism that doesn't match the code.
- **Confirm "hits queue-full" against the per-step `q_depth` data.** Edit 3 keeps the post's existing claim that `try_push` finds the queue *full* at the 16 MHz point. Check the `q_depth` (or equivalent) value for hand-rolled at the 16 MHz sweep step in `04-spsc-queue.json`. If it approaches the 1024 capacity, "queue full" is correct. If it only reaches, say, a few hundred, the queue *deepens* but doesn't fill, and both the original prose and Edit 3 overstate it — soften to "the queue deepens enough that residency dominates the tail" and flag the discrepancy. Do not silently keep "queue-full" if the data contradicts it.

## Notes for CC

- All three edits are pure prose. No code, no JSON, no chart-component changes.
- The substantive edit is Edit 1 — it removes a genuine self-contradiction. Edit 2 is a smaller clarity addition. Edit 3 adds the producer colour Gareth asked for and fixes the garbled "pacer-limited by its own cost" wording.
- The 132 ns / 264 ns / ~200× / ~3× figures referenced in the replacement prose all come from the existing `04-spsc-queue.json` and the already-shipped sweep prose. Read them against the data file before committing so the prose tracks the actual numbers if anything has been rounded since.
- Edit 3 deliberately does **not** introduce a per-push-cost figure in nanoseconds. The producer's per-push cost is the inverse of its ~14.7 M/s flat-out rate (≈68 ns), but that's a *different* quantity from the ~132 ns end-to-end p50 latency floor cited elsewhere (latency includes the handoff and the consumer). If CC wants to add the per-push number for concreteness, fine — but state it as "the inverse of the 14.7 M/s ceiling" so a reader doesn't read 68 ns and 132 ns as contradictory. Default: leave it numberless as written.
