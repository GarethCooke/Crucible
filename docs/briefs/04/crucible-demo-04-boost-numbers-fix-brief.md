# Crucible — Demo 04: Boost-comparison numbers fix

Patch brief for `site/src/posts/04-spsc-queue.mdx`. One prose edit. No rerun, no
C++ change, no JSON change. Companion to `crucible-demo-04-honest-prose-brief.md`
and the pre-demo-5 hostile cross-read findings (finding M-10).

## Context

The "Boost comparison" section (lines 230–240) quotes Boost's 1 MHz paced
percentiles as 122 ns p50 / 148 ns p99.9 and frames the result as Boost being
marginally faster than the hand-rolled queue ("within 8%", "the p99.9 gap is
wider"). Those Boost figures do not appear anywhere in `04-spsc-queue.json`.

Ground truth from `latency_ns.stats` on the paced (1 MHz) runs — the merged
5×1M-sample histogram the chart reads:

| percentile | hand-rolled | Boost  |
| ---------- | ----------- | ------ |
| p50        | 132 ns      | 140 ns |
| p99        | 164 ns      | 172 ns |
| p99.9      | 172 ns      | 172 ns |

The hand-rolled p50/p99.9 figures the post quotes (132, 172) are correct. Only
the Boost column is wrong, and it is wrong in the direction that invents a Boost
lead. With the real numbers the direction reverses: hand-rolled is faster at p50
and p99 and ties at p99.9 — it wins or ties at every percentile. The 122/148
values look stale or mis-transcribed; M-10 changed the "similarly close" framing
but carried the wrong Boost numbers through unchecked.

Both edges (132 vs 140, 164 vs 172) are roughly one histogram bucket
(`log2_subbuckets_16`, ~5 ns wide in this range), so they are small and
consistent rather than decisive — and below what the load-sweep chart can resolve
on a log axis running to 100,000 ns. The corrected prose must say so rather than
overclaiming a hand-rolled win in the other direction.

## Task

In `site/src/posts/04-spsc-queue.mdx`, Boost-comparison section (~line 234).

**Find:**

> Under 1 MHz paced load, the hand-rolled
> implementation comes in at 132 ns p50 vs Boost's 122 ns — within 8%. The p99.9
> gap is wider — 172 ns vs 148 ns, about 16% — but both are still orders of
> magnitude inside the mutex variant's tail. That's the credibility check:
> the hand-rolled version isn't leaving anything obvious on the table relative to a
> battle-tested production library, and conversely Boost isn't doing anything clever
> in its hot path that the 50-line version misses.

**Replace with:**

> Under 1 MHz paced load — the queue stays effectively empty, so latency is
> dominated by per-op cost rather than drain rate — the hand-rolled implementation
> comes in at 132 ns p50 against Boost's 140 ns, and 164 ns vs 172 ns at p99. At
> p99.9 the two are identical at 172 ns. These percentiles are quantised to the
> histogram's log-spaced buckets (~5 ns wide in this range), so the p50 and p99
> gaps are about one bucket each — a small, consistent edge to the hand-rolled
> version, not a decisive one, and below what the load-sweep chart can resolve on a
> log axis. That's the credibility check: at this load the 50-line hand-rolled
> queue matches a battle-tested production library across the distribution, edging
> it at the median and tying it in the tail. Neither leaves anything obvious on the
> table, and neither is doing anything clever in its hot path that the other misses.

Leave the preceding sentence (lines 232–234, "`boost::lockfree::spsc_queue` is a
production-quality implementation … cache-line-aware layout.") unchanged.

## Acceptance

- `grep -n "Boost's 122" site/src/posts/04-spsc-queue.mdx` → zero matches.
- `grep -n "148 ns" site/src/posts/04-spsc-queue.mdx` → zero matches.
- `grep -n "within 8%" site/src/posts/04-spsc-queue.mdx` → zero matches.
- `grep -n "Boost's 140 ns" site/src/posts/04-spsc-queue.mdx` → exactly one match.
- The four percentiles in the replacement (hand-rolled 132/164/172, Boost
  140/172/172) match `latency_ns.stats` for the `paced` runs of
  `lockfree-handrolled` and `lockfree-boost` in
  `site/src/data/perf/04-spsc-queue.json` exactly.
- `cd site && npm run build` produces a clean static export and the post renders.

## Out of scope

- The intro claim (line 7) that "all three look similar at the median." It is a
  separate, independent claim — mutex p50 is 1300–3000 ns across the sub-saturation
  sweep vs 132–140 ns for the lock-free pair, a 10–23× median gap at every load —
  and needs its own decision. Do **not** edit line 7 in this brief.
- The saturation / throughput / bottleneck-attribution prose (lines 147–205),
  including the "Boost consumer is ~3× slower" claim. That describes the
  saturated-drain regime, a different measurement from the near-empty 1 MHz
  headline, and is not contradicted by this edit. Do not touch it.
- Any recapture or JSON change (none required; the JSON is already correct).
- Any other demo's prose, code, or JSON.

## Open items for CC to flag

- If the section has already been edited and the verbatim "Find" block no longer
  matches, **stop and report** the current text rather than guessing at a partial
  replacement.
- If `grep` finds 122 / 148 / "within 8%" anywhere outside the Boost-comparison
  section after the edit, flag it — those numbers should not survive anywhere in
  this post.
