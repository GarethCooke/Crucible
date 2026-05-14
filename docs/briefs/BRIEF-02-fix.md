# Crucible — Demo 02 Fix Brief

Follow-up to `BRIEF.md`. Demo 02 (false sharing) is already implemented but the wall-clock sanity check fails on Zen 2 intra-CCX. This brief specifies the fixes plus a small scope expansion (cross-CCX variant). Component contracts and data schema are otherwise unchanged.

## Context

Current state:

- Padded vs unpadded per-thread counters; configurations 1t, 2t unpadded, 4t unpadded, 4t padded — all intra-CCX (cores 4–7)
- Sanity check asserts wall-clock ratio unpadded/padded ≥ 5× for 4t
- Observed ratio: 1.2× — sanity check fails

Diagnosis (validated in review):

- Counters confirm false sharing IS occurring (cache miss ratio 2.5% → 80%, IPC 0.56 → 0.11 for 4t unpadded)
- Wall-clock magnification is muted on Zen 2 intra-CCX because the shared 16 MB L3 absorbs coherency traffic; cache-to-cache transfer stays in silicon at tens-of-ns rather than going to DRAM
- Two secondary issues distort the wall-clock numbers further:
  - `std::barrier` sync overhead is significant at the current ~8 µs iteration timescale
  - 4t unpadded shows lower wall-clock than 2t unpadded — physically backwards, consistent with barrier overhead dominating

The fix is twofold:

1. Make the benchmark robust at this timescale (move barriers out of measurement, increase iterations)
2. Reframe the demo around what the counters actually show, with a cross-CCX variant providing the wall-clock contrast

## Required changes

### Benchmark (C++)

1. **Move barriers outside the measurement window.** Replace per-iteration `std::barrier` sync with a single startup barrier, a long measurement burst, and a single teardown barrier. The measurement must not include barrier cost.

2. **Increase N_ITERS** from 100 to at least 1000, and size the per-iteration workload so total measurement runtime per variant is ≥10 ms. This amortizes any residual sync cost and gives Google Benchmark's auto-calibration enough signal.

3. **Add a cross-CCX 2-thread variant.** Verify topology with `lscpu --extended` or `lstopo` — on the 3800X with SMT off, the expected layout is CCX0 = cores 0–3, CCX1 = cores 4–7, but confirm before pinning. The cross-CCX configuration pins the two incrementer threads to one core in each CCX (e.g. core 0 and core 4). This is the configuration that should reproduce the canonical wall-clock blowup.

4. **Reconcile compiler flags.** `BRIEF.md` specifies `-O3 -march=native`; current build is reportedly `-O2 -march=native`. Move to `-O3` to match the documented standard. If `-O2` was deliberate (e.g. `-O3` obscures the effect via auto-vectorization), document that on the post page and in the JSON `compiler_flags` field.

5. **Capture L1D miss counter specifically.** False sharing's most direct signal is L1D miss rate (line invalidated and refetched), not generic "cache misses." Find the right Zen 2 event name with `perf list | grep -i l1` on the reference machine — likely `l1d.replacement` or similar. Add to the JSON schema as `runs[].l1d_misses_per_op`. Keep the existing aggregate cache miss field too.

### Sanity check

6. **Replace the wall-clock threshold** with counter-based assertions. Wall-clock ratio is topology-dependent; the counter signal is universal evidence that the mechanism is firing. Required assertions:
   - 4t intra-CCX unpadded: `l1d_miss_ratio ≥ 0.3` (currently ~0.80; threshold gives margin)
   - 4t intra-CCX padded vs unpadded: IPC ratio (padded / unpadded) ≥ 3.0 (currently ~5.0)
   - 2t cross-CCX vs intra-CCX unpadded: wall-clock ratio ≥ 3.0 (this is where wall-clock magnification _does_ hold)

   Keep all wall-clock numbers in the JSON; just don't gate the intra-CCX sanity check on them.

### MDX post

7. **Flip the headline chart.** Lead with IPC or L1D miss rate bars (`<ThroughputBars>` pointed at those fields, or a small grouped-bar chart showing IPC + miss-rate side by side if straightforward). Wall-clock throughput becomes a supporting view further down the page.

8. **Add the intra-CCX vs cross-CCX comparison** as the post's punch. Two views: one showing the counter collapse is the same in both topologies (universal false-sharing signature), one showing the wall-clock blowup only reasserts itself cross-CCX. This contrast is the story.

9. **Avoid "MOESI Owner state" framing** in the post copy. The Owner state primarily helps read-after-write patterns; false sharing is write-after-write, where each core still needs exclusive ownership and the line still bounces. The actual mechanism is shared 16 MB L3 within the CCX plus low intra-CCX cache-to-cache transfer latency. Frame it that way — same insight, doesn't invite the pedantic objection from a reader who knows the protocol.

10. **Takeaway should explicitly call out the regime question.** False sharing's counter signature is universal; its wall-clock impact depends on where the coherency traffic has to travel. Modern shared-LLC architectures (Zen 2+ within a CCX, Intel within a socket) absorb much of the cost; cross-coherency-domain transfers (cross-CCX, cross-socket, NUMA) restore the canonical penalty.

### CounterOverlay component

The handover identifies this demo as the one that justifies building `<CounterOverlay>`. If the headline can be served by `<ThroughputBars>` pointed at the IPC / miss-rate fields, defer building CounterOverlay until a later demo needs it. Only build it if the IPC-or-miss-rate-vs-thread-count overlay genuinely adds clarity beyond what bars can show.

## Open items for CC to flag

- **Core isolation for cross-CCX runs.** Current `isolcpus=4-7` only isolates one CCX. The cross-CCX variant needs one core in each. Options: (a) widen isolation in GRUB to e.g. `isolcpus=1,2,3,5,6,7`; (b) run the cross-CCX variant with non-isolated cores and document the caveat in the post + JSON `notes` field; (c) leave to the operator to reconfigure GRUB. Recommend (b) for now — boot-param changes shouldn't be silent.
- **Exact perf event name for L1D misses on Zen 2.** Confirm against `perf list` output and document the chosen event in the post.
- **GB auto-iteration stability** at the new N_ITERS and workload size. Verify variance across runs is acceptable (IQR small relative to median) before committing the numbers.

## Acceptance criteria

- Benchmark builds and runs on the reference machine with `-O3 -march=native` (or documented exception)
- Five configurations emit valid JSON conforming to the schema: 1t baseline, 2t intra-CCX unpadded, 4t intra-CCX unpadded, 4t intra-CCX padded, 2t cross-CCX unpadded
- JSON includes `l1d_misses_per_op` per run
- Sanity check passes via counter-based assertions; wall-clock ratios are reported but the intra-CCX one is not a gate
- Post leads with IPC or miss-rate bars; wall-clock is supporting
- Intra-CCX vs cross-CCX comparison is present and clearly framed; cross-CCX shows ≥3× wall-clock blowup
- Post copy describes the mechanism as shared L3 + intra-CCX cache-to-cache latency, not MOESI Owner state
- All v1 acceptance criteria still hold (Lighthouse ≥90, static export works, etc.)
