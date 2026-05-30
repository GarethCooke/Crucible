# Crucible — Demo 04 (SPSC) spike paragraph: final wording

Prose brief for Claude Code. Supersedes Edit 3 of `crucible-demo-04-throughput-attribution-brief.md` (already implemented). That edit got the *mechanism* right — a consumer-side stall, not the producer filling the queue — but labelled the spike a "one-off" "measurement contaminant." The diagnostic instrumentation and the per-point p99.9 pull have now disproved the "one-off" part: the stall is intermittent and recurring, and its appearance at one sweep point is a sampling artifact. This brief corrects that framing. Prose only, one paragraph, no rerun, no code, no JSON change.

## Context

Two pieces of evidence settled the open question the prior brief flagged:

1. **The diagnostic loop** (consumer/producer max-gap instrumentation, 10 invocations × 5 internal runs at the 16 MHz offered rate) showed: every high-impact run has `max_deq_gap` of tens of µs with a near-baseline `max_enq_gap` — the producer kept stamping items while the consumer went dark. That confirms the consumer-stall mechanism *directly* (it was inference before). It also showed the stall is **intermittent**: ~8 of 50 one-million-item runs carried a tens-of-µs stall, and 5 of the 10 five-run invocations would have spiked — close to a coin flip per five-run sample. The stally runs clustered consecutively in wall-clock time, the fingerprint of transient background interference rather than anything workload-intrinsic.
2. **The per-point p99.9 pull** from `04-spsc-queue.json` (hand-rolled, sweep): every point sits at 172–592 ns except 16 MHz at ~42,000 ns. 28 MHz and 50 MHz — equally near/past saturation — are clean (592 ns, 560 ns).

Reconciling the two: the stall is real and recurring, but rate-*independent* in incidence, and its latency impact only shows near saturation (below ~9 MHz the producer feeds slowly enough that even a stalled consumer drains the small backlog before it matters). With only five runs per published sweep point, whether a given high-load point catches a stall is roughly a coin flip — so 16 MHz spiking while 28/50 MHz stayed clean is the unlucky draw, not a property of 16 MHz. The diagnostic confirms this directly: re-running 16 MHz comes back clean about half the time.

Net: the spike is **not** one-off (it recurs), **not** a feature of 16 MHz (any near-saturation point is equally exposed), and **is** an external consumer-core stall whose chart position is sampling-driven.

## Decision for Gareth (resolve before CC ships)

Two honest ways to handle a dramatic 200× spike that is, on the evidence, a sampling artifact:

- **(A) Reframe in prose, keep the data — this brief's default.** No rerun. The paragraph explains the spike correctly: an intermittent consumer-side stall, near-saturation amplification, five-runs-per-point sampling noise. Ships now. The honest framing is a credibility asset for a rigour-focused project, but the chart still visibly shows a spike the prose then explains as noise.
- **(B) Re-measure for a defensible chart — Gareth's rig task, out of scope here.** If you'd rather the chart reflect reality rather than explain an artifact, the principled fix is to raise runs-per-point (e.g. 20+, not re-rolling 5) and re-sweep. That either smooths the spike or reveals a consistent near-saturation tail across all high-load points — either is more defensible than one outlier. Cost: a rig run that regenerates the whole `04-spsc-queue.json`, so other demo-04 numbers may shift and need reconciling. Do **not** just re-run five and hope — that only moves the spike to a different point.

This brief implements (A). If Gareth chooses (B), this brief is deferred until the new data lands and the paragraph is re-derived from it; the prose below assumes the current five-run JSON stays.

## MDX change — `site/src/posts/04-spsc-queue.mdx`

Replace the spike paragraph. The current live text (from the prior brief's Edit 3 — confirm against the file, it may have been lightly adjusted on implementation) reads approximately:

> One artefact worth naming: the hand-rolled p99.9 line has a single spike at the 16 MHz sweep point — about 42 µs, against a baseline of ~200 ns either side, with no counterpart at the points on either side. It's tempting to pin this on the offered load, but the arithmetic points elsewhere: 42 µs of residency is roughly 700 items deep at the consumer's drain rate, and the hand-rolled consumer normally drains faster than the producer can fill (that's why this variant is producer-bound, with a near-empty queue). The producer can't deepen a queue the consumer is out-draining — so for the queue to reach several hundred, the *consumer* must have briefly stopped draining. On a pinned, spinning, isolated core that isn't a scheduling or power-state effect; it's the kind of tens-of-microseconds stall an SMI or a cross-core TLB-shootdown IPI produces, and neither depends on offered load. The single affected sweep point, with clean neighbours, is the signature of exactly that: a one-off stall that happened to land here, not a property of 16 MHz. We flag it rather than smoothing it over, but it's a measurement contaminant, not a feature of the curve.

Replace with:

> One artefact worth naming, because it's instructive rather than incidental: the hand-rolled p99.9 line has a single spike at the 16 MHz sweep point — about 42 µs, roughly 200× its neighbours, which sit between 170 and 590 ns across the rest of the sweep. A 200× jump at one offered load looks like a property of that load. It isn't. The arithmetic rules out the producer: 42 µs of residency is several hundred items deep, and the hand-rolled consumer drains faster than the producer can fill — that's why this variant is producer-bound, with a near-empty queue — so the producer cannot build that backlog. Only the consumer pausing can. Instrumenting the dequeue stream confirms it directly: at the spike the consumer shows a tens-of-microseconds gap with no matching gap on the producer side, so the producer kept stamping items while the consumer briefly went dark. On a pinned, spinning, isolated core that's an external stall — a cross-core IPI or an SMI — and neither cares about offered load.
>
> What pins it to one point is sampling, not 16 MHz. Re-running that point shows the stall is intermittent — it surfaces in roughly half of five-run samples — and each sweep point here is only five runs, so whether a point catches a stall is close to a coin flip. It shows up near saturation specifically because of amplification: below ~9 MHz the producer feeds slowly enough that a stalled consumer clears the small backlog before it matters, but once the producer is flat-out, the same stall backs up hundreds of items and the residency lands in the tail. The honest reading is that the lock-free path's tail is stall-sensitive near saturation on real hardware, and this sweep happened to catch one instance of it at 16 MHz — 28 and 50 MHz are equally exposed and simply drew clean here. We leave the spike in and label it rather than re-rolling for a tidier curve.

## Acceptance criteria

- `grep -ni 'one-off\|contaminant' site/src/posts/04-spsc-queue.mdx` returns zero hits in the spike paragraph.
- `grep -ni 'intermittent\|sampling\|coin flip\|half of' site/src/posts/04-spsc-queue.mdx` returns at least one hit — the recurring/sampling framing is present.
- The paragraph still attributes the spike to a consumer-side stall and still rules out the producer (mechanism unchanged from the live version).
- The paragraph states the stall is *not* a property of 16 MHz and names 28/50 MHz as equally exposed.
- Numbers match the JSON CC pulled: neighbour range "170–590 ns" (points read 172/204/592/560 ns), spike "about 42 µs" (`p99.9` ≈ 41,984 ns at the 16 MHz hand-rolled sweep entry). No invented figures.
- No change to `04-spsc-queue.json` or any chart component. `git diff` touches only the one MDX paragraph.
- Lighthouse performance on the post page still ≥ 90.

## Out of scope

- **Re-measuring the sweep** (Decision B above). Gareth's rig task if chosen; this brief assumes the current JSON.
- The diagnostic instrumentation added by `crucible-demo-04-spike-diagnostic-brief.md`. It stays — it's now proven to catch real contamination. Do not remove or gate it.
- Any other paragraph in the post, any other demo, any chart component.
- Chasing the interrupt/SMI source (`/proc/interrupts`, `nohz_full`, C-states). A real but separate methodology thread; not a prose change and not required to ship this.

## Open items for CC to flag

- If the live spike paragraph differs materially from the quoted text (e.g. a prior pass already softened "one-off"/"contaminant"), do **not** blindly swap — confirm the mechanism wording is intact, apply only the frequency-framing correction, and note what was already there.
- If Gareth has chosen Decision B (re-measure), stop: this brief's prose is tied to the current five-run data and must be re-derived from the new sweep. Flag and wait.
- If the per-point p99.9 values in the JSON have changed since CC's pull (172/204/592/560 ns and ~41,984 ns at 16 MHz), update the "170–590 ns" range and the "~200×" multiplier to match — the prose must track the actual data.

## Notes for CC

- This is a frequency-framing correction, not a mechanism rewrite. The consumer-stall explanation in the live paragraph is correct and confirmed by the dequeue-gap instrumentation; only "one-off" / "measurement contaminant" / "a property of 16 MHz" needs to go.
- "Roughly half of five-run samples" comes directly from the diagnostic (5 of 10 invocations spiked). Keep that level of precision — don't sharpen it to a false exact figure.
- "Several hundred items deep" replaces the prior "roughly 700": the diagnostic showed per-stall backlogs ranging ~400–820 items, so "several hundred" is the honest span rather than a single number.
