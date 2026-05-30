# Crucible — Demo 04 (SPSC) throughput-attribution fix

Companion to `crucible-demo-04-honest-prose-brief.md`. That pass separated the two saturation mechanisms in the load-sweep section. This one finishes the job: it fixes a contradiction it left behind in the **Throughput** section (hand-rolled and Boost ceilings attributed to the same cause when they're opposite), clears up the offered-load-vs-achieved-rate ambiguity at "28 MHz", and corrects the p99.9-spike paragraph, whose stated mechanism (the producer filling the queue) is physically impossible given a producer-bound variant.

Scope: three prose edits to `04-spsc-queue.mdx` — the Throughput paragraph, a one-clause clarification at the "28 MHz" mention, and a correction to the p99.9-spike paragraph (its stated mechanism is wrong). No rerun. No C++ changes. No chart changes. The data file is unchanged.

## Why this revision

The Throughput section currently says hand-rolled and Boost are both "limited by the producer's per-iteration cost (timestamp, `try_push`, spin) rather than anything queue-implementation-specific." That is true for hand-rolled and false for Boost, and the sentence immediately after it proves the contradiction: "Boost runs with its queue near capacity at saturation." A near-full queue is the signature of a *consumer*-bound system. A system cannot be producer-limited and carry a backed-up queue at the same time — if the producer were the bottleneck the queue would drain empty (which is exactly what the post says hand-rolled does).

The contradiction also points the other way, at the load-sweep section the previous pass wrote. That section states "the Boost consumer is roughly 3× slower than the hand-rolled one." If Boost's consumer is 3× slower *and* its saturated queue sits near capacity, then Boost's throughput ceiling **is** queue-implementation-specific — it's set by Boost's consumer drain rate. So the Throughput paragraph contradicts the sweep section as well as itself.

The numbers are all fine and no rerun is needed. The 14.7 M/s (hand-rolled) and 14.9 M/s (Boost) near-match is a **coincidence**: hand-rolled's number is its *producer* loop rate, Boost's is its *consumer* drain rate, and they happen to land within 1.4% of each other. The current prose reads that coincidence as evidence of a shared cause, which is the error. The fix is to attribute each ceiling to the correct side and name the match as coincidental.

A reader who has just read the sweep section ("two different saturation mechanisms... worth separating") and then reaches the Throughput section ("both limited by the same producer cost") sees the two sections disagree. The earlier honest-prose pass set up the distinction; this pass carries it through to the one place that still flattens it.

There's also a smaller clarity issue feeding the same confusion: the load-sweep section says Boost "saturates around 28 MHz" while the Throughput section caps it at 14.9 M/s, and nothing tells the reader these are different axes (offered load requested vs throughput achieved). One clause fixes it.

Finally, the p99.9-spike paragraph is wrong on mechanism, not just muddled in wording. It currently explains the 16 MHz spike as the producer hitting queue-full and spinning on `try_push`, with the queue staying small at lower and higher loads. Two problems. First, the wording "pacer-limited by its own cost" is garbled (a producer is limited by the pacer *or* by its own cost). Second, and more seriously, the implied causal story — that the producer fills the queue at the knee — cannot be right. The producer can never emit faster than its flat-out ~14.7 M/s rate (that rate *is* its per-push floor), and the hand-rolled consumer drains faster than that flat-out rate (which is why the variant is producer-bound with a near-empty queue). So `dQ/dt = fill − drain < 0` whenever the queue is non-empty, at every offered load. Producer behaviour — bursty or smooth — cannot deepen the queue while the consumer out-drains the producer's maximum. Any earlier draft of this brief that explained the spike via producer "burstiness at the knee" was wrong; do not ship it.

Work the number backwards instead: 42 µs of residency is roughly `42000 ns ÷ ~60 ns consumer-period ≈ 700 items deep`. For the queue to reach several hundred when the consumer normally wins the rate race, the **consumer** must have briefly stopped draining — a transient stall of tens of µs on the consumer core while the producer kept filling. On a spinning, pinned, isolated consumer that rules out C-states and the pacer; the realistic causes are an SMI (firmware, OS-invisible, classically tens of µs) or a cross-core IPI such as a TLB shootdown — neither of which is load-dependent. That also makes "hits queue-full and spins on `try_push`" an overstatement: ~700 deep is not the 1024 capacity (full would need a ~70 µs stall), so the latency is residency behind a deep queue, not `try_push` spin time. And it explains the post's own hedge ("present at one point, gone at the next"): a one-off external stall that happened to land on one sweep point is exactly what a non-reproducing single-point spike looks like — a contaminant, not a feature of 16 MHz. The honest fix is to describe it as a transient consumer-side stall at a single sweep point and stop, not to manufacture a load-dependent mechanism.

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

### Edit 3 — Spike paragraph: honest mechanism (consumer-side stall, not producer burst)

In the load-sweep section, the paragraph beginning "One artefact worth naming: the hand-rolled p99.9 line has a single spike at the 16 MHz sweep point…" currently reads:

> One artefact worth naming: the hand-rolled p99.9 line has a single spike at the 16 MHz sweep point — about 42 µs, against a baseline of ~200 ns either side. This is the transition load where the producer occasionally hits queue-full and spins on `try_push` long enough to be counted in the tail; at lower loads the queue never fills, at higher loads the producer is consistently pacer-limited by its own cost and the queue stays small. The spike is reproducible at this offered rate but transient across the sweep — present at one point, gone at the next.

Replace with (subject to the data check in Open items — confirm depth and non-reproduction before publishing):

> One artefact worth naming: the hand-rolled p99.9 line has a single spike at the 16 MHz sweep point — about 42 µs, against a baseline of ~200 ns either side, with no counterpart at the points on either side. It's tempting to pin this on the offered load, but the arithmetic points elsewhere: 42 µs of residency is roughly 700 items deep at the consumer's drain rate, and the hand-rolled consumer normally drains faster than the producer can fill (that's why this variant is producer-bound, with a near-empty queue). The producer can't deepen a queue the consumer is out-draining — so for the queue to reach several hundred, the *consumer* must have briefly stopped draining. On a pinned, spinning, isolated core that isn't a scheduling or power-state effect; it's the kind of tens-of-microseconds stall an SMI or a cross-core TLB-shootdown IPI produces, and neither depends on offered load. The single affected sweep point, with clean neighbours, is the signature of exactly that: a one-off stall that happened to land here, not a property of 16 MHz. We flag it rather than smoothing it over, but it's a measurement contaminant, not a feature of the curve.

If the data check shows the queue genuinely reaching ~1024 at this point, keep a clause noting `try_push` then spins on the full queue (and, because the enqueue timestamp precedes `try_push`, that spin is counted in latency); if it only reaches the low hundreds, drop the "queue-full / `try_push` spin" framing entirely as above.

The rewrite (a) removes the unsound producer-burst causal story; (b) replaces the garbled "pacer-limited by its own cost"; (c) attributes the spike to a transient consumer-side stall, explicitly framed as a non-load-dependent contaminant; (d) keeps every number unchanged (42 µs, ~200 ns, 16 MHz); (e) preserves the post's existing honesty hedge but gives it a mechanism instead of leaving it dangling.

**Alternative Gareth may prefer:** if the spike is a non-reproducing contaminant, the cleanest treatment may be to shrink it to one sentence ("a single-point p99.9 spike at 16 MHz, absent at adjacent points and consistent with a one-off consumer-core stall — treated as a measurement contaminant") rather than a full paragraph, or to re-run that sweep point on the rig to confirm non-reproduction. Both are out of scope for CC here; surface the choice in the PR.

## Acceptance criteria

- The Throughput paragraph no longer claims hand-rolled and Boost are limited by the same cause. `grep -ni 'both are limited by the producer' site/src/posts/04-spsc-queue.mdx` returns zero hits.
- The Throughput paragraph names hand-rolled as producer-bound and Boost as consumer-bound. `grep -ni 'producer-bound' site/src/posts/04-spsc-queue.mdx` and `grep -ni 'consumer-bound' site/src/posts/04-spsc-queue.mdx` each return at least one hit.
- The 14.7-vs-14.9 match is described as coincidental, not as a shared bottleneck.
- The load-sweep section distinguishes offered load (28 MHz) from achieved throughput (~14.9 M/s) at the Boost saturation mention. `grep -ni 'offered.*load' site/src/posts/04-spsc-queue.mdx` returns the new clause among its hits.
- The spike paragraph no longer contains the garbled "pacer-limited by its own cost." `grep -ni 'pacer-limited by its own cost' site/src/posts/04-spsc-queue.mdx` returns zero hits.
- The spike paragraph no longer attributes the spike to the producer filling the queue. It attributes it to a transient consumer-side stall and frames it as a non-load-dependent contaminant. `grep -ni 'consumer.*stall\|SMI\|contaminant\|shootdown' site/src/posts/04-spsc-queue.mdx` returns at least one hit in that paragraph.
- The "queue-full / `try_push` spin" framing is present only if the `q_depth` data check confirms the queue reaches capacity at the 16 MHz point; otherwise it is removed.
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
- **Confirm the spike's depth against the per-step `q_depth` data before publishing Edit 3.** Read the `q_depth` (or equivalent) value for hand-rolled at the 16 MHz sweep step in `04-spsc-queue.json`. If it reaches the low hundreds, the residency-behind-a-deep-queue framing is right and the "queue-full / `try_push` spin" clause stays out. If it genuinely reaches ~1024, add the `try_push`-spin clause back per Edit 3's conditional. Either way, the cause is a consumer stall, not the producer.
- **If the sweep points are single short runs**, one stall dominating one point's p99.9 is expected and reinforces the contaminant reading — note it. If they're multi-run merged and the spike survived merging, that's more surprising; flag it for Gareth, because a *reproducible* 42 µs stall at one specific offered load would need a real explanation rather than the contaminant framing.
- **The producer-burst / "resonance at the knee" explanation is retracted** — it cannot be right (the producer can't out-pace its flat-out rate, which the consumer already beats). If any draft of the post still contains burst/resonance language for this spike, remove it.

## Notes for CC

- All three edits are pure prose. No code, no JSON, no chart-component changes.
- Edit 1 removes a genuine self-contradiction (the substantive one). Edit 2 is a small clarity addition. Edit 3 corrects a wrong mechanism in the spike paragraph — the post currently blames the producer for a deep queue the producer cannot create; the real cause is a transient consumer-side stall.
- The 132 ns / 264 ns / ~200× / ~3× figures referenced in the replacement prose all come from the existing `04-spsc-queue.json` and the already-shipped sweep prose. Read them against the data file before committing so the prose tracks the actual numbers if anything has been rounded since.
- Edit 3's "~700 items deep" is an order-of-magnitude estimate (42 µs ÷ ~60 ns consumer-period). Don't print "700" as a precise figure in the post — the prose says "roughly 700" / "several hundred," which is the right level of precision for a back-of-envelope. The actual depth comes from the `q_depth` data check.
