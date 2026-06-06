# Demo 05 rescope brief — pool ordering below measurement resolution (decision A)

Branch: `feature/boost-off-recapture`. Scope: `content/posts/05-allocators.mdx`, plus committing the pre-recapture JSONs as supplementary data for derivability. No rig recapture, no bench-code change, no chart-component change.

## Context

The 2026-06-05 recapture (same kernel, same code, clean rebuild + reboot apart from the 2026-05-21 capture) **inverts the post's same-CCX ordering**: arena and malloc swapped p50 (old: malloc/freelist 172, arena 204; new: arena 172, freelist 188, malloc 204) and the pools converged in the tail (old: freelist 312 < arena 344 at p99.9; new: both 328). The shipped narrative — "the bump-pointer that doesn't win," three mechanisms explaining arena's loss, "freelist wins at every percentile" — explains an ordering that does not reproduce. Cross-CCX likewise: arena now beats freelist at p50 (408 vs 488) and p99.9 (720 vs 784).

Four results DO reproduce across both captures and both topologies, and the rescope is built on them:

1. **Malloc is the tail outlier everywhere** (worst p99/p99.9 in all four datasets).
2. **Arena's pressure-sweep p99.9 is exactly 344 ns at all nine points in both captures** — the dead-flat claim is the post's most robust result. (New capture: freelist is now also flat at 344.)
3. **Cross-CCX amplifies malloc's tail ~2.3–2.5× vs the pools** (2.44× old; 2.33×/2.53× new).
4. **Malloc's pressure response is non-monotonic** (moderate pressure worse than peak) in both captures, though the new swing is much smaller (344→376→360 vs 328→424→344).

The replacement content for the dead horse race is the instability finding itself: orderings within ~1–2 histogram buckets (~±15–30 ns here) did not survive a rebuild, and a single capture cannot resolve them. The old capture is committed alongside the new so the both-captures comparison is derivable.

## Pre-flight sentinel (abort on mismatch)

`05-allocators.json` (site data): `captured_at == "2026-06-05T06:07:50Z"`, `turbo:false`, `turbo_source:"cpb"`, `freq_max_available_mhz:3900`. Paced stats must read: arena p50 **172**/p99 **220**/p99.9 **328**; freelist **188/220/328**; malloc **204/312/376**. `05-allocators-cross-ccx.json`: same captured_at; malloc p99.9 **1824**, freelist **784**, arena **720**.

## Task 0 — commit the pre-recapture JSONs as supplementary data

Add `site/src/data/perf/archive/05-allocators_2026-05-21.json` and `05-allocators-cross-ccx_2026-05-21.json` (the OLD files, byte-identical, renamed by capture date). The rewritten prose cites the old capture's orderings; every cited number must trace to committed data. These are not loaded by charts — archive only.

## Task 1 — Summary/headline (line 11)

Find: `modest (1.1–1.3× p99.9) when producer and consumer share a CCX, substantial (2.4×) when they don't.`
Replace: `modest (~1.15–1.3× p99.9) when producer and consumer share a CCX, substantial (~2.3–2.5×) when they don't.`

(Derivation: same-CCX 376/328 = 1.15 new, 392/312 = 1.26 old; cross-CCX 1824/784 = 2.33 and 1824/720 = 2.53 new, 2.44 old.)

## Task 2 — CCDF prose (line 80)

Find (verbatim, the full paragraph beginning `The CCDF reads right-to-left:` and ending `…1.26× at p99.9.`).

Replace with:

```
The CCDF reads right-to-left: a lower curve at any latency means fewer samples are
that slow or slower. At the median the three variants sit within two histogram
buckets of each other — 172, 188, and 204 ns in this capture — and that ordering
should not be trusted: a re-capture of the same code after a clean rebuild
reordered them (the May capture put malloc at 172 and arena at 204; this one puts
arena at 172 and malloc at 204). Differences of one or two log-spaced buckets at
the median are below what this harness resolves across rebuilds. The tail is where
the signal is, and it sorts the same way in every capture: the two pool variants
travel together (p99 = 220, p99.9 = 328 here, within one bucket of each other in
every dataset), while malloc's tail stretches under background pressure to
p99 = 312 and p99.9 = 376 — about 1.4× the pools at p99 and 1.15× at p99.9 in this
capture.
```

## Task 3 — same-CCX max paragraph (line 82)

Find (the paragraph beginning `The numbers are modest in absolute terms` and ending `…the design-discussion framing materialises.`).

Replace with:

```
The numbers are modest in absolute terms because both producer and consumer share
a CCX; the cross-CCX section near the end of the post shows what happens to
malloc's tail when the queue traversal stops being free. One cautionary footnote
on single-sample statistics: the May capture's headline featured a dramatic malloc
max of 46,710 ns against the pools' 10–15 µs. In this capture all three maxes land
between 14 and 16 µs and malloc's is unremarkable. A max is one sample out of five
million; it carried no structural information then and carries none now.
```

## Task 4 — replace the "bump-pointer that doesn't win" section

Replace the section header (line 84) and everything through line 102 (`…the freelist wins.`) — keeping the `allocate()` code block intact — with:

```
## The ordering the harness can't resolve

The May capture of this benchmark put the arena last at the median, 32 ns behind
malloc and the freelist, and this section originally explained why a
two-instruction bump pointer was losing. The arena's steady-state `allocate()`,
in 99.97% of calls, is:

```cpp
Order* o = &arenas_[current_].slots[orders_in_current_++];
o->arena_idx = static_cast<uint8_t>(current_);
return o;
```

Two instructions on the hot path; the `[[unlikely]]` rotation branch fires roughly
every 4096 orders. The freelist's hot path is a vector pop plus an amortised
return-queue drain. On instruction count the arena should be at least as fast — and
in the May capture it wasn't, by a consistent 24–32 ns at every percentile.

Then the recapture inverted it. Same code, same kernel, same machine state, a
clean rebuild and a reboot apart: arena 172 ns at p50, malloc 204 — the May
ordering exactly swapped, with the freelist's tail converging onto the arena's
(both 328 ns at p99.9). Three mechanisms were drafted to explain the arena's
loss; all three were plausible; none of them was the cause, because there was no
stable effect to cause. Orderings at the ±30 ns scale on a ~200 ns pipeline are
hostage to binary layout, page placement, and alignment luck that a rebuild
reshuffles.

That is the honest result of the pool-vs-pool comparison: **within this harness's
resolution, the freelist and the arena are the same speed.** Any benchmark that
hands you a winner at this scale from a single build is handing you a coin toss —
the mechanism-shaped explanations write themselves either way, which is exactly
why they should be distrusted without a stable effect to explain.

What does separate the designs is variance, not magnitude: the arena's p99.9 is
flat at 344 ns across the entire pressure sweep — all nine points, zero-pressure
baseline included, in *both* captures. That reproducibility is the strongest
result in this post. If a tail-latency SLA is written in jitter terms, the
arena's flat line is a real, capture-stable property.
```

## Task 5 — Throughput paragraph (line 116)

Find: `All three variants sustain close to 1 M/s; the freelist variant shows slightly tighter variance than malloc or arena because its amortised return-queue drain smooths over per-allocation cost spikes. Throughput differences are secondary to latency at this load level.`

Replace: `All three variants sustain close to 1 M/s (1,000,241–1,000,243 ops/s in this capture). Throughput differences are secondary to latency at this load level.`

(The variance claim was not derivable from the published stats; removed.)

## Task 6 — pressure-sweep section (lines 132–138)

Replace the four paragraphs from `**Arena is flat.**` through `…and only in a specific pressure regime.` with:

```
**Both pools are flat.** The arena lands at p99.9 = 344 ns at every sweep point,
zero-pressure baseline included — and it did exactly that in the May capture too,
making it the most reproducible number in this demo. The freelist sits on the same
344 ns line at every point in this capture (in May it ranged 296–328). Whatever
background heap churn does to the system, the pool designs don't transmit it to
the pipeline's tail.

**Malloc is the only variant that responds, and not where intuition puts it.** Its
p99.9 rises from 344 with no background pressure to 376 across the
100 k/s–1.4 M/s band, then settles back to 360 from 2.7 M/s up. The May capture
showed the same shape with a larger swing (328 → 424 at 372 k/s → 344). The
mechanism is cache locality: at high churn rates malloc's recently-freed blocks
get re-touched fast enough to stay warm in L1/L2, while moderate rates expose the
fragmentation tail. Two captures agree on the shape — moderate pressure is
malloc's worst case, not peak pressure — and disagree on the amplitude, so treat
the shape as the result and the amplitude as capture-specific.

The faint horizontal reference lines show each variant's p99.9 with no background
pressure. Both pools' references sit on their sweep lines. Only malloc's sweep
diverges from its no-pressure reference, and only in the moderate-pressure band.
```

## Task 7 — cross-CCX section (lines 153–157)

Replace the three paragraphs (`Cross-CCX configuration: …` through `…rather than a structural property of the variant.`) with:

```
Cross-CCX configuration: producer on core 4 (CCX1), consumer on core 1 (CCX0),
T_bg on core 6 (CCX1). The p50 floor roughly doubles for all three variants — 408
and 488 ns in this capture, one histogram bucket apart, with the same
bucket-level reordering caveat as the same-CCX medians (the May capture put all
three on 408). The Infinity Fabric round-trip is the new baseline.

The tail is where the variants part, and it parts the same way in both captures.
The pools top out within one bucket of each other — p99.9 = 720 and 784 ns here,
both 720 in May — about 2.2–2.5× their same-CCX baselines. Malloc reaches
p99 = 1184 ns and p99.9 = 1824 ns: roughly 1.7× the pools at p99 and 2.3–2.5× at
p99.9, and a ~4.9× expansion of its own same-CCX p99.9 (376 → 1824) against the
pools' ~2.2–2.4×. The cross-CCX environment amplifies malloc's allocator-overhead
tail disproportionately — the lock-contention and arena-coordination paths malloc
runs internally pay an extra Infinity-Fabric round-trip every time they cross
between threads on different L3 domains.

Single-sample max values don't track the percentile ordering and reshuffle
between captures (this capture: malloc 8,370, arena 8,930, freelist 8,990; May:
freelist 7,200, malloc 10,460, arena 12,200). One sample out of five million
reflects where an interrupt landed, not a property of the variant.
```

(Derivations: 1184/688 = 1.72; 1824/784 = 2.33, 1824/720 = 2.53; 1824/376 = 4.85; 784/328 = 2.39, 720/328 = 2.20.)

## Task 8 — Takeaway (lines 171–175)

Replace the three takeaway paragraphs with:

```
For cross-thread Order lifetimes on this CPU, the reproducible result is not a
pool-vs-pool winner — it's that there isn't one. Across two captures of identical
code, the freelist and arena traded places at the median and converged at the
tail; their differences sit below what this harness resolves across rebuilds.
Both reliably beat `new`/`delete` where it matters: the tail under pressure, and
everything cross-CCX.

What the arena offers that nothing else here does is reproducible flatness: its
p99.9 sat at exactly 344 ns across all nine pressure-sweep points in both
captures, no-pressure baseline included. If the latency SLA is written in jitter
or worst-case-under-load terms, that capture-stable flat line — not a ±30 ns
median ordering — is the property to buy.

`new`/`delete` is the only variant whose tail responds to background heap
pressure, and the response isn't where intuition puts it: moderate pressure hurts
malloc more than peak pressure, because at peak churn recently-freed blocks stay
warm in cache. Both captures agree on that shape. The same-CCX gap is real but
modest (~1.15–1.3× p99.9 across captures). Cross the CCX boundary and the gap
opens to ~2.3–2.5× at p99.9 — roughly a 5× expansion of malloc's own same-CCX
tail against the pools' ~2.2–2.4× — with malloc compounding the Infinity-Fabric
round-trip with its own coordination overhead. If your producer and consumer
don't share an L3, the case for replacing `new`/`delete` is much sharper than the
same-CCX numbers suggest.
```

## Task 9 — section header consistency check

The chart above Task 2's paragraph references markers and the section around line 96 is renamed by Task 4. CC: confirm no table-of-contents component or internal anchor links reference the old header slug `the-bump-pointer-that-doesnt-win`; if rehype-slug anchors are linked anywhere (index, other posts), report before renaming.

## Task 10 — footer isolation

Find: `cores 0–7 isolated (core 0 carries unavoidable kernel housekeeping; benchmarks pinned to 4–7)`
Replace: `cores 1–7 isolated (cpu0 cannot be kernel-isolated and carries housekeeping; benchmarks pinned to 4–7)`

## Task 11 — frontmatter date

Update `date:` to `"2026-06-05"`.

## Acceptance

1. Archive files exist under `site/src/data/perf/archive/` and are byte-identical to the originals.
2. `grep -c 'contradicts the design discussion\|freelist wins at every percentile\|32 ns slower\|46,710 ns versus\|424 at 372\|2.44× at p99.9\|4.5× as an expansion'` → 0.
3. `grep -c 'rebuild'` → ≥3; `grep -c 'coin toss'` → 1; `grep -c '344 ns'` → ≥3.
4. `grep -c '1824\|1,824'` → ≥1; `grep -c '1760\|1,760\|1120 ns\|1,120'` → 0.
5. `grep -c 'cores 0–7'` → 0; `date:` reads 2026-06-05.
6. Every number in the rewritten prose matches either the new JSONs or the committed archive JSONs (CC: spot-check the table in Task 7's derivations against the data, not against this brief).
7. `npm run build` clean; both CCDF charts and the sweep chart render unchanged (they read the new JSONs directly; no component edits).

## Out of scope

- Bench-code changes, recaptures, and any repeatability study (decision B was declined; if later wanted — N rebuild+capture cycles to quantify ordering churn — it's its own spec).
- Chart components and the `<Benchmark>` blocks — data-driven, untouched.
- The "What this doesn't show" bullets — re-read, all still accurate, no edits.
- Other demos, methodology page, correction note.

## Open items

1. The instability finding generalizes: demos 01–04's re-derivations assumed orderings are stable and only magnitudes drift. Demo 05 shows bucket-scale orderings can flip on a rebuild. The hostile cross-read skill should gain a check: "is any claim an exact tie or a ≤2-bucket ordering? If so, it needs multi-capture support." Propose adding to the skill after this branch merges.
2. Correction-note input: demo 05's divergence is rebuild/layout sensitivity — a third distinct environment-sensitivity class alongside demo 04's kernel/governor finding and the boost-verification gap. The note's framing (per demo-04 open item 3) accumulates another exhibit.
3. Clock forensics: old capture at base clock (deltas bucket-scale, not 12%-scale) — consistent with all prior demos.
