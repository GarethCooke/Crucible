# Crucible — Demo 04 (SPSC) throughput-attribution fix

Companion to `crucible-demo-04-honest-prose-brief.md`. That pass separated the two saturation mechanisms in the load-sweep section. This one fixes a contradiction it left behind in the **Throughput** section: the prose attributes hand-rolled's and Boost's saturated ceilings to the *same* cause, when they're caused by opposite things.

Scope: two prose edits to `04-spsc-queue.mdx` — the Throughput paragraph and a one-clause clarification at the "28 MHz" mention in the load-sweep section. No rerun. No C++ changes. No chart changes. The data file is unchanged.

## Why this revision

The Throughput section currently says hand-rolled and Boost are both "limited by the producer's per-iteration cost (timestamp, `try_push`, spin) rather than anything queue-implementation-specific." That is true for hand-rolled and false for Boost, and the sentence immediately after it proves the contradiction: "Boost runs with its queue near capacity at saturation." A near-full queue is the signature of a *consumer*-bound system. A system cannot be producer-limited and carry a backed-up queue at the same time — if the producer were the bottleneck the queue would drain empty (which is exactly what the post says hand-rolled does).

The contradiction also points the other way, at the load-sweep section the previous pass wrote. That section states "the Boost consumer is roughly 3× slower than the hand-rolled one." If Boost's consumer is 3× slower *and* its saturated queue sits near capacity, then Boost's throughput ceiling **is** queue-implementation-specific — it's set by Boost's consumer drain rate. So the Throughput paragraph contradicts the sweep section as well as itself.

The numbers are all fine and no rerun is needed. The 14.7 M/s (hand-rolled) and 14.9 M/s (Boost) near-match is a **coincidence**: hand-rolled's number is its *producer* loop rate, Boost's is its *consumer* drain rate, and they happen to land within 1.4% of each other. The current prose reads that coincidence as evidence of a shared cause, which is the error. The fix is to attribute each ceiling to the correct side and name the match as coincidental.

A reader who has just read the sweep section ("two different saturation mechanisms... worth separating") and then reaches the Throughput section ("both limited by the same producer cost") sees the two sections disagree. The earlier honest-prose pass set up the distinction; this pass carries it through to the one place that still flattens it.

There's also a smaller clarity issue feeding the same confusion: the load-sweep section says Boost "saturates around 28 MHz" while the Throughput section caps it at 14.9 M/s, and nothing tells the reader these are different axes (offered load requested vs throughput achieved). One clause fixes it.

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

## Acceptance criteria

- The Throughput paragraph no longer claims hand-rolled and Boost are limited by the same cause. `grep -ni 'both are limited by the producer' site/src/posts/04-spsc-queue.mdx` returns zero hits.
- The Throughput paragraph names hand-rolled as producer-bound and Boost as consumer-bound. `grep -ni 'producer-bound' site/src/posts/04-spsc-queue.mdx` and `grep -ni 'consumer-bound' site/src/posts/04-spsc-queue.mdx` each return at least one hit.
- The 14.7-vs-14.9 match is described as coincidental, not as a shared bottleneck.
- The load-sweep section distinguishes offered load (28 MHz) from achieved throughput (~14.9 M/s) at the Boost saturation mention. `grep -ni 'offered.*load' site/src/posts/04-spsc-queue.mdx` returns the new clause among its hits.
- No internal contradictions: the load-sweep section's "two different saturation mechanisms" framing, its "Boost consumer is roughly 3× slower" statement, and the Throughput section all attribute Boost's ceiling to consumer drain rate and hand-rolled's to producer cost. They tell one consistent story.
- The numbers (14.7 M/s, 14.9 M/s, ~3×, ~200×, 28 MHz) are unchanged — this is an attribution fix, not a re-measurement.
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

## Notes for CC

- Both edits are pure prose. No code, no JSON, no chart-component changes.
- The substantive edit is Edit 1 — it removes a genuine self-contradiction. Edit 2 is a smaller clarity addition that heads off the offered-vs-achieved confusion at its source.
- The 132 ns / 264 ns / ~200× / ~3× figures referenced in the replacement prose all come from the existing `04-spsc-queue.json` and the already-shipped sweep prose. Read them against the data file before committing so the prose tracks the actual numbers if anything has been rounded since.
